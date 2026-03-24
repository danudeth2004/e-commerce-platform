class ProductsController < ApplicationController
  def index
    @skin_concern_key = params[:skin_concern].presence
    @category_key = params[:category].presence
    @category_key = nil unless ProductCategory.keys.include?(@category_key)

    @products = Product.joins(:store).merge(Seller::Store.active)
    @products = @products.where(skin_concern_key: @skin_concern_key) if @skin_concern_key.present?
    @products = @products.where(category_key: @category_key) if @category_key.present?

    q = params[:q].to_s.strip
    if q.present?
      like = "%#{Product.sanitize_sql_like(q)}%"
      @products = @products.where("products.title ILIKE ?", like)
    end
  end
end
