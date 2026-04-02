class ApplicationController < ActionController::Base
  include TracksAppVisit

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configured_devise_permitted_parameters, if: :devise_controller?
  before_action :enforce_buyer_not_suspended, if: :user_signed_in?

  helper_method :seller_owns_product?
  helper_method :safe_return_path

  def seller_owns_product?(product)
    return false unless seller_user_signed_in?

    store = current_seller_user.store
    return false if store.blank?

    product.seller_store_id == store.id
  end

  private

    def enforce_buyer_not_suspended
      return unless current_user.suspended?

      sign_out(:user)
      redirect_to root_path, alert: I18n.t("devise.failure.suspended")
    end

  protected
    def configured_devise_permitted_parameters
      shared = %i[first_name last_name phone_number avatar]

      devise_parameter_sanitizer.permit(:sign_up, keys: shared + [
        {
          shipping_addresses_attributes: %i[
            id label recipient_name phone_number address_detail province_id district_id sub_district_id postal_code is_default _destroy
          ]
        }
      ])
      devise_parameter_sanitizer.permit(:account_update, keys: shared)
    end

    def safe_return_path(url)
      return nil if url.blank?

      path = url.to_s.strip
      return path if path.start_with?("/") && !path.start_with?("//")

      nil
    end
end
