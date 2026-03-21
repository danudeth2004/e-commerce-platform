class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :hide_app_header, only: :show

  def show
    @cart_items = @cart.cart_items.includes(:product)
    @cart_qty_total = @cart_items.sum(&:quantity)
    @promo_flag_by_product_id = promo_flags_for_cart_products(@cart_items)
  end

  def add_item
    product = Product.find(params[:product_id])
    item = @cart.cart_items.find_or_initialize_by(product:)
    quantity_to_add = (params[:quantity].presence || 0).to_i
    if quantity_to_add <= 0
      return redirect_back fallback_location: cart_path, alert: "กรุณาเลือกจำนวนอย่างน้อย 1 ชิ้น"
    end

    item.quantity ||= 0
    item.quantity += quantity_to_add if item.quantity > 1
    item.save!

    redirect_back fallback_location: cart_path, notice: "เพิ่มสินค้าในตะกร้าแล้ว"
  end

  def remove_item
    item = @cart.cart_items.find(params[:id])
    item.destroy

    redirect_to cart_path, notice: "ลบสินค้าออกจากตะกร้าแล้ว"
  end

  def increase_item
    item = @cart.cart_items.find(params[:id])
    item.increment!(:quantity)
    redirect_to cart_path
  end

  def decrease_item
    item = @cart.cart_items.find(params[:id])
    if item.quantity > 1
      item.decrement!(:quantity)
    else
      item.destroy
    end
    redirect_to cart_path
  end

  private

  def hide_app_header
    @hide_app_header = true
  end

  def set_cart
    @cart = current_user.cart || current_user.create_cart!
  end

  def promo_flags_for_cart_products(cart_items)
    product_ids = cart_items.map(&:product_id).uniq
    return {} if product_ids.empty?

    FlagProduct.active
      .where(product_id: product_ids)
      .where.not(original_amount_cents: nil)
      .includes(:product)
      .each_with_object({}) do |fp, memo|
        product = fp.product
        next unless product
        next unless fp.original_amount_cents.to_i > product.amount_cents

        memo[fp.product_id] ||= fp
      end
  end
end
