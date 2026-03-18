class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(:product)
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

  def set_cart
    @cart = current_user.cart || current_user.create_cart!
  end
end
