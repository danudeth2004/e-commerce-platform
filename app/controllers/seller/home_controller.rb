module Seller
  class HomeController < BaseController
    before_action :authenticate_seller_user!

    def index
    end

    # def create
    # store = current_user.build_seller_store(store_params)
    # store.save!

    # OmiseService::CreateRecipient.new(store: store).call
    # end
  end
end
