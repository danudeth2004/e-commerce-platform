class ProductsController < BaseController
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
    @search_query = q.presence
    if q.present?
      like = "%#{Product.sanitize_sql_like(q)}%"
      @products = @products.where(
        <<~SQL.squish,
          products.title ILIKE :like
          OR COALESCE(products.description, '') ILIKE :like
          OR products.sku ILIKE :like
          OR COALESCE(products.effect, '') ILIKE :like
          OR seller_stores.name ILIKE :like
        SQL
        like: like
      )
    end

    @products = @products.includes(bundle_items: { component_product: { images_attachments: :blob } })
    @bundle_products = @products.where(kind: :bundle)
    @standard_products = @products.where(kind: :standard)
  end

  def campaign
    @campaign = Campaign.find(params[:id])

    @products = @campaign.products
      .joins(:store)
      .includes(:store, images_attachments: :blob)

    q = params[:q].to_s.strip
    @search_query = q.presence

    if q.present?
      like = "%#{Product.sanitize_sql_like(q)}%"
      @products = @products.where(
        <<~SQL.squish,
          products.title ILIKE :like
          OR COALESCE(products.description, '') ILIKE :like
          OR products.sku ILIKE :like
          OR COALESCE(products.effect, '') ILIKE :like
          OR seller_stores.name ILIKE :like
        SQL
        like: like
      )
    end
  end
end
