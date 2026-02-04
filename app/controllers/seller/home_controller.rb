module Seller
  class HomeController < BaseController
    before_action :authenticate_seller_user!

    def index
    end
  end
end
