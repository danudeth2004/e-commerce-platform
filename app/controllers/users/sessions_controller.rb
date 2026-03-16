# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  layout "devise"

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    email = params.dig(:user, :email)
    password = params.dig(:user, :password)

    if (user = User.find_by(email: email))&.valid_password?(password)
      sign_in(:user, user)
      redirect_to root_path
      return
    end

    if (seller = Seller::User.find_by(email: email))&.valid_password?(password)
      sign_in(:seller_user, seller)
      redirect_to seller_root_path
      return
    end

    self.resource = resource_class.new(sign_in_params)
    flash.now[:alert] = "Invalid email or password"

    clean_up_passwords(resource)
    render :new, status: :unprocessable_entity
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
