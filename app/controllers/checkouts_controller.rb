class CheckoutsController < BaseController
  before_action :authenticate_user!
  before_action :set_order, only: [ :payment, :pay ]
  before_action :order_paid?, only: [ :payment, :pay ]
  before_action :hide_buyer_bottom_nav, only: :payment

  def create_order
    if params[:order_id]
      old_order = current_user.orders.find(params[:order_id])

      new_order = Orders::CreateFromCart.new(old_order.order_items, user: current_user).call

      redirect_to payment_checkout_path(order_id: new_order.id)
    else
      cart = current_user.cart
      return redirect_to cart_path, alert: "ไม่มีสินค้าในตะกร้า" if cart.blank? || cart.cart_items.empty?

      order = Orders::CreateFromCart.new(cart, user: current_user).call

      redirect_to payment_checkout_path(order_id: order.id)
    end
  end

  def payment
    @public_key = ENV["OMISE_PUBLIC_KEY"]

    ensure_order_shipping_address

    @order_items = @order.order_items.includes(product: [ :store, { images_attachments: :blob } ])
    @items_by_store = @order_items.group_by { |oi| oi.product.store }
    @item_qty_total = @order_items.sum(&:quantity)
    @subtotal_cents = @order.total_amount_cents

    @shipping_address = @order.shipping_address
    @checkout_return = payment_checkout_path(order_id: @order.id)

    @coupons = current_user.coupons.active.map do |c|
      eligible_items = @order_items.select do |oi|
        c.products.exists?(oi.product_id)
      end

      eligible_amount = eligible_items.sum do |oi|
        oi.amount_cents * oi.quantity
      end

      next if eligible_amount <= 0

      {
        id: c.id,
        discount: c.discount,
        eligible_amount_cents: eligible_amount,
        min_order: c.min_order,
        product_ids: eligible_items.map(&:product_id),
        product_title: c.products.first.title,
        expires_at: c.expires_at.strftime("%d/%m/%Y")
      }
    end.compact
  end

  def pay
    ensure_order_shipping_address

    unless @order.shipping_address.present?
      return redirect_to payment_checkout_path(order_id: @order.id), alert: "กรุณาเลือกหรือเพิ่มที่อยู่จัดส่ง"
    end

    @order.update!(shipping_address_snapshot: @order.shipping_address.full_snapshot_text)

    shipping_cents = calculate_shipping(@order)

    coupon = nil
    discount_cents = 0

    if params[:coupon_id].present?
      coupon = current_user.coupons.find_by(id: params[:coupon_id])

      product_ids = params[:coupon_product_ids].to_s.split(",").map(&:to_i)
      return 0 unless product_ids.all? { |id| coupon.coupon_products.exists?(product_id: id) }

      discount_cents = calculate_coupon_discount(@order, coupon, product_ids)

      @order.order_items.each do |oi|
        if product_ids.include?(oi.product_id)
          oi_amount_before_discount = oi.amount_cents * oi.quantity
          discounted_amount = (oi_amount_before_discount * (1 - coupon.discount.to_f / 100)).to_i
          oi.update!(amount_cents: (discounted_amount / oi.quantity.to_f).round)
        end
      end
    end

    total_cents = @order.total_amount_cents + shipping_cents - discount_cents

    @order.update!(total_amount_cents: total_cents, shipping_cents: shipping_cents, discount_cents: discount_cents, platform_fee_cents: (total_cents * 0.1).to_i)
    if total_cents > 0
      OmiseService::CreateCharge.new(order: @order, token: params[:omise_token], amount: total_cents).call
    elsif total_cents == 0
      @order.update!(status: :paid, paid_at: Time.current)
    else
      redirect_to root_path, alert: "ชำระเงินไม่สำเร็จ กรุณาลองใหม่"
    end
    @order.reload

    order_store_payouts = @order.order_store_payouts

    if @order.paid?

      if coupon.present?
        coupon.update!(used: true)
      end

      @order.order_items.each do |oi|
        total_after_discount = oi.amount_cents * oi.quantity
        original_total = oi.product.amount_cents * oi.quantity

        next if total_after_discount < original_total

        new_coupon = @order.user.coupons.create!(
          discount: 20,
          min_order: 0,
          started_at: @order.paid_at,
          expires_at: @order.paid_at + 30.days
        )
        new_coupon.coupon_products.create!(product_id: oi.product_id)
      end

      @order.order_store_payouts.each do |payout|
        payout.update!(amount_cents: payout.amount_cents + shipping_cents)
        TransferToStoreJob.perform_later(payout.id)
      end
      redirect_to root_path, flash: { payment_success: true }
    else
      redirect_to root_path, alert: "ชำระเงินไม่สำเร็จ กรุณาลองใหม่"
    end
  end

  def cancel
    order = current_user.orders.find(params[:order_id])

    unless order.pending?
      return redirect_to root_path, alert: "ไม่สามารถยกเลิกได้"
    end

    order.update!(status: :cancelled)

    redirect_to users_orders_path(status: "pending"), notice: "ยกเลิกคำสั่งซื้อเรียบร้อยแล้ว"
  end

  private

    def hide_buyer_bottom_nav
      @hide_buyer_bottom_nav = true
    end

    def ensure_order_shipping_address
      return if @order.shipping_address_id.present?

      addr = current_user.default_shipping_address
      @order.update!(shipping_address_id: addr.id) if addr
    end

    def set_order
      @order = current_user.orders.includes(:shipping_address).find(params[:order_id])
    end

    def order_paid?
      redirect_to root_path if @order.paid?
    end

    def promo_flags_for_checkout(product_ids)
      return {} if product_ids.empty?

      FlagProduct.active
        .where(product_id: product_ids)
        .where.not(original_amount_cents: nil)
        .includes(:product)
        .each_with_object({}) do |fp, memo|
          product = fp.product
          next unless product
          next unless fp.original_amount_cents.to_i > product.final_price_cents

          memo[fp.product_id] ||= fp
        end
    end

    def calculate_shipping(order)
      return 0 unless params[:shipping_method] == "express"

      store_count = order.order_items
                        .joins(:product)
                        .distinct
                        .count("products.seller_store_id")

      store_count * 10 * 100
    end

    def calculate_coupon_discount(order, coupon, product_ids)
      return 0 unless coupon

      items = order.order_items.where(product_id: product_ids)

      eligible_total = items.sum do |item|
        item.amount_cents * item.quantity
      end

      return 0 if eligible_total < coupon.min_order * 100

      (eligible_total * coupon.discount / 100.0).to_i
    end
end
