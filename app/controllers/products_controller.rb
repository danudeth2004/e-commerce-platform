class ProductsController < ApplicationController
  def index
    @skin_concern_key = params[:skin_concern]

    @products =
      if @skin_concern_key.present?
        Product.where(skin_concern_key: @skin_concern_key)
      else
        Product.all
      end
  end
end

