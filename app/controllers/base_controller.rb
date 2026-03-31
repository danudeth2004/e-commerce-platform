class BaseController < ApplicationController
  before_action :destroy_seller_user_session!

  private

  def destroy_seller_user_session!
    return if prefetch_request?

    sign_out(:seller_user)
  end

  def prefetch_request?
    purpose = request.headers["Sec-Purpose"].to_s
    purpose.include?("prefetch") || request.headers["Purpose"].to_s == "prefetch"
  end
end
