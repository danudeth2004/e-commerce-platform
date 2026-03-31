module Seller
  class HomeController < BaseController
    def index
      @store = current_seller_user.store
      @search_query = params[:q].to_s.strip.presence

      if @store.persisted?
        scope = @store.products
          .includes(bundle_items: { component_product: { images_attachments: :blob } })
          .order(created_at: :desc)
        scope = apply_store_search(scope) if @search_query.present?

        @products = scope
        @bundle_products = scope.where(kind: :bundle)
        @standard_products = scope.where(kind: :standard)
      else
        @products = []
        @bundle_products = Product.none
        @standard_products = Product.none
      end
    end

    private

    def apply_store_search(scope)
      q = @search_query
      like = "%#{Product.sanitize_sql_like(q)}%"
      scope.where(
        <<~SQL.squish,
          products.title ILIKE :like
          OR COALESCE(products.description, '') ILIKE :like
          OR products.sku ILIKE :like
          OR COALESCE(products.effect, '') ILIKE :like
        SQL
        like: like
      )
    end
  end
end
