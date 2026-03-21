module Seller
  class HomeController < BaseController
    before_action :authenticate_seller_user!

    def index
      @store = current_seller_user.store || current_seller_user.build_store(name: "Glad2Glow Official Store", location: "Bangkok, Thailand")
      @category_key = params[:category].presence
      @category_key = nil unless ProductCategory.keys.include?(@category_key)
      @products =
        if @store.persisted?
          scope = @store.products.order(created_at: :desc)
          scope = scope.where(category_key: @category_key) if @category_key.present?
          scope
        else
          []
        end
    end

    # def create
    # store = current_user.build_seller_store(store_params)
    # store.save!

    # OmiseService::CreateRecipient.new(store: store).call
    # end
  end
end
