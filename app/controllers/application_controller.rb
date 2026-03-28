class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configured_devise_permitted_parameters, if: :devise_controller?

  helper_method :seller_owns_product?

  # ผู้ขายล็อกอิน seller และสินค้านี้อยู่ร้านของตัวเอง (ใช้หน้ารายละเอียดสินค้า)
  def seller_owns_product?(product)
    return false unless seller_user_signed_in?

    store = current_seller_user.store
    return false if store.blank?

    product.seller_store_id == store.id
  end

  protected
    def configured_devise_permitted_parameters
      keys = %i[first_name last_name phone_number location avatar]

      devise_parameter_sanitizer.permit(:sign_up, keys: keys)
      devise_parameter_sanitizer.permit(:account_update, keys: keys)
    end
end
