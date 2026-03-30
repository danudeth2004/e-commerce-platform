class CheckoutsController < BaseController
  before_action :authenticate_user!
  before_action :set_order, only: [ :payment, :pay ]
  before_action :order_paid?, only: [ :payment, :pay ]
  before_action :hide_app_header, only: :payment

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

    @order_items = @order.order_items.includes(product: [ :store, { images_attachments: :blob } ])
    @items_by_store = @order_items.group_by { |oi| oi.product.store }
    @item_qty_total = @order_items.sum(&:quantity)
    @subtotal_cents = @order.total_amount_cents

    product_ids = @order_items.map(&:product_id).uniq
    @promo_flag_by_product_id = promo_flags_for_checkout(product_ids)

    @list_price_subtotal_cents = @order_items.sum do |oi|
      p = oi.product
      fp = @promo_flag_by_product_id[oi.product_id]
      candidates = [ p.amount_cents ]
      candidates << fp.original_amount_cents if fp&.original_amount_cents
      unit_list = candidates.compact.max
      unit_list * oi.quantity
    end

    @product_discount_cents = [ @list_price_subtotal_cents - @subtotal_cents, 0 ].max
    @saved_percent =
      if @list_price_subtotal_cents.positive? && @product_discount_cents.positive?
        ((@product_discount_cents.to_f / @list_price_subtotal_cents) * 100).round
      end
    @coupons = [
    { id: 1, discount: "20%", min_order: "ไม่มีขั้นต่ำ", expires_at: "30 เมษายน", selected: true },
    { id: 2, discount: "20%", min_order: "ไม่มีขั้นต่ำ", expires_at: "30 เมษายน", selected: false } ]
  end

  def pay
    shipping_cents = calculate_shipping(@order)
    total_cents = @order.total_amount_cents + shipping_cents

    @order.update!(total_amount_cents: total_cents, shipping_cents: shipping_cents, platform_fee_cents: (total_cents * 0.1).to_i)
    OmiseService::CreateCharge.new(order: @order, token: params[:omise_token], amount: total_cents).call
    @order.reload

    order_store_payouts = @order.order_store_payouts

    if @order.paid?
      @order.order_store_payouts.each do |payout|
        payout.update!(amount_cents: payout.amount_cents + (10 * 100))
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

    def hide_app_header
      @hide_app_header = true
    end

    def set_order
      @order = current_user.orders.find(params[:order_id])
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
end
