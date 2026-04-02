module ApplicationHelper
  include ProductDisplayHelper

  def app_back_fallback
    if instance_variable_defined?(:@app_back_fallback) && @app_back_fallback.present?
      return @app_back_fallback
    end

    ref = request.referer
    return root_path if ref.blank?

    begin
      uri = URI.parse(ref)
      return root_path unless uri.host == request.host
      return root_path if uri.path == request.path

      if uri.path.to_s.start_with?("/checkout/") && (request.path == cart_path || request.path == users_profile_path)
        return root_path
      end

      ref
    rescue URI::InvalidURIError
      root_path
    end
  end

  def current_cart_item_count
    return 0 unless user_signed_in?

    cart = current_user.cart
    return 0 unless cart

    cart.cart_items.sum(:quantity)
  end

  # แถบค้นหา + รถเข็นด้านบน — เฉพาะหน้าแรกกับรายการสินค้า (ยกเว้นถ้า @hide_app_header เช่น flow พิเศษ)
  def show_app_header?
    return false if @hide_app_header

    c = controller.controller_name
    a = controller.action_name
    (c == "home" && a == "index") || (c == "products" && a == "index")
  end

  # แถบนำทางล่างฝั่งผู้ซื้อ — ปิดได้ด้วย @hide_buyer_bottom_nav (เช่น flow พิเศษ)
  def show_buyer_bottom_nav?
    return false if @hide_buyer_bottom_nav

    true
  end

  def buyer_nav_active?(key)
    c = controller.controller_name
    a = controller.action_name
    case key
    when :home
      c == "home" && a == "index"
    when :products
      (c == "products" && a == "index") ||
        (c == "home" && a == "show") ||
        (c == "stores" && a == "show")
    when :profile
      cp = controller.controller_path
      (cp == "users/profiles" && a == "show") ||
        (cp == "users/sessions" && a == "new") ||
        (cp == "users/registrations" && %w[edit update].include?(a))
    else
      false
    end
  end

  # 0812345678 → (+66)08******78
  # หน้าสมัครแบบหลายขั้น: ถ้า error อยู่ที่ที่อยู่ ให้เปิดขั้นที่ 2
  def signup_wizard_initial_step(resource)
    return 1 unless resource.respond_to?(:errors) && resource.errors.any?

    names = resource.errors.attribute_names.map(&:to_s)
    personal = %w[email first_name last_name phone_number password password_confirmation]
    return 1 if names.any? { |a| personal.include?(a) }

    return 2 if names.any? { |a| a.include?("shipping_address") }

    1
  end

  def masked_thai_mobile(phone)
    return "—" if phone.blank?

    digits = phone.gsub(/\D/, "")
    return phone if digits.length < 10

    "(+66)#{digits[0..1]}******#{digits[-2, 2]}"
  end
end
