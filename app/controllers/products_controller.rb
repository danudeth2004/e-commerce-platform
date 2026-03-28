class ProductsController < ApplicationController
  def index
    @skin_concern_key = params[:skin_concern].presence
    allowed_skin = SkinConcern::DATA.map { |d| d[:key] }
    @skin_concern_key = nil if @skin_concern_key.present? && !allowed_skin.include?(@skin_concern_key)
    @category_key = params[:category].presence
    @category_key = nil unless ProductCategory.keys.include?(@category_key)

    @products = Product.joins(:store).merge(Seller::Store.active)
    if @skin_concern_key.present?
      @products = @products.where(
        "products.skin_concern_key = ? OR (products.skin_concern_keys IS NOT NULL AND (',' || products.skin_concern_keys || ',') LIKE ?)",
        @skin_concern_key,
        "%,#{@skin_concern_key},%"
      )
    end
    @products = @products.where(category_key: @category_key) if @category_key.present?

    q = params[:q].to_s.strip
    if q.present?
      like = "%#{Product.sanitize_sql_like(q)}%"
      @products = @products.where("products.title ILIKE ?", like)
    end

    @products = @products.includes(bundle_items: { component_product: { images_attachments: :blob } })
    @bundle_products = @products.where(kind: :bundle)
    @standard_products = @products.where(kind: :standard)
  end
end
