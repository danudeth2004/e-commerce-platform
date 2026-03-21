class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [ :index ]

  def index
    @skin_concern_key = params[:skin_concern].presence
    @category_key = params[:category].presence
    @category_key = nil unless ProductCategory.keys.include?(@category_key)

    @products = Product.all
    @products = @products.where(skin_concern_key: @skin_concern_key) if @skin_concern_key.present?
    @products = @products.where(category_key: @category_key) if @category_key.present?
  end
end
