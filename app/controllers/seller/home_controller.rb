module Seller
  class HomeController < BaseController
    def index
      @store = current_seller_user.store
      if @store.persisted?
          scope = @store.products
            .includes(bundle_items: { component_product: { images_attachments: :blob } })
            .order(created_at: :desc)
          @products = scope
          @bundle_products = scope.where(kind: :bundle)
          @standard_products = scope.where(kind: :standard)
      else
          @products = []
          @bundle_products = Product.none
          @standard_products = Product.none
      end
    end
  end
end
