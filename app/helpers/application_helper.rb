module ApplicationHelper
  include ProductDisplayHelper
  def current_cart_item_count
    return 0 unless user_signed_in?

    cart = current_user.cart
    return 0 unless cart

    cart.cart_items.sum(:quantity)
  end

  # 0812345678 → (+66)08******78
  def masked_thai_mobile(phone)
    return "—" if phone.blank?

    digits = phone.gsub(/\D/, "")
    return phone if digits.length < 10

    "(+66)#{digits[0..1]}******#{digits[-2, 2]}"
  end
end
