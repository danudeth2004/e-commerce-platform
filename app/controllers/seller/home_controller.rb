module Seller
  class HomeController < BaseController
    before_action :authenticate_seller_user!

    def index
      @store = current_seller_user.store ||
               current_seller_user.build_store(
                 name: "Glad2Glow Official Store",
                 location: "Bangkok, Thailand"
               )
    end

    # def create
    # store = current_user.build_seller_store(store_params)
    # store.save!

    # OmiseService::CreateRecipient.new(store: store).call
    # end
  end
end
