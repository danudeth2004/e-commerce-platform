class BaseController < ApplicationController
  before_action :destroy_seller_user_session!

  private

  def destroy_seller_user_session!
    sign_out(:seller_user)
  end
end
