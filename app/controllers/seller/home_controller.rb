module Seller
  class HomeController < BaseController
    def index
      @store = current_seller_user.store
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
  end
end
