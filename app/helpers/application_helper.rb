module ApplicationHelper
  def current_cart_item_count
    return 0 unless user_signed_in?

    cart = current_user.cart
    return 0 unless cart

    cart.cart_items.sum(:quantity)
  end
end
