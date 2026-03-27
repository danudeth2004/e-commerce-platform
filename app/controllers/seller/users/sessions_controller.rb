# frozen_string_literal: true

class Seller::Users::SessionsController < Devise::SessionsController
  layout "devise"

  protected

  def after_sign_in_path_for(resource)
    seller_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_seller_user_session_path
  end
end
