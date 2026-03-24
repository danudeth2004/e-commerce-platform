module Seller
  class ProductsController < BaseController
    layout "devise"
    before_action :set_store, only: [:new, :create]

    def new
      @product = @store.products.new
    end

    def create
      p "ก"
      p product_params
      @product = @store.products.new(product_params)

      if @product.save
        redirect_to seller_root_path, notice: "เพิ่มสินค้าเรียบร้อยแล้ว"
      else
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_store
      @store = Seller::Store.find(current_seller_user.store.id)
    end

    def product_params
      permitted = params.require(:product).permit(
        :title,
        :sku,
        :amount,
        :promotion,
        :description,
        :skin_concern_key,
        :category_key,
        :effect,
        :volume,
        :volume_unit,
        :usage,
        images: []
      )

      if permitted[:amount].present?
        permitted[:amount_cents] = (permitted.delete(:amount).to_f * 100).to_i
        permitted[:amount_currency] = "THB"
      end

      if permitted[:promotion].present?
        permitted[:promotion_cents] = (permitted.delete(:promotion).to_f * 100).to_i
        permitted[:promotion_currency] = "THB"
      end

      permitted
    end
  end
end

