module Seller
  class ProductsController < BaseController
    before_action :authenticate_seller_user!

    def new
      @store = ensure_store!
      @product = @store.products.new
    end

    def create
      @store = ensure_store!
      @product = @store.products.new(product_params)

      if @product.save
        redirect_to seller_root_path, notice: "เพิ่มสินค้าเรียบร้อยแล้ว"
      else
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    private

    def ensure_store!
      current_seller_user.store ||
        current_seller_user.create_store!(
          name: "Glad2Glow Official Store",
          location: current_seller_user.location.presence || "Bangkok, Thailand"
        )
    end

    def product_params
      permitted = params.require(:product).permit(
        :title,
        :sku,
        :amount,
        :description,
        :skin_concern_key,
        :category_key,
        :effect,
        :volume,
        :volume_unit,
        :promotion_price,
        :usage,
        images: []
      )

      if permitted[:amount].present?
        permitted[:amount_cents] = (permitted.delete(:amount).to_f * 100).to_i
        permitted[:amount_currency] = "THB"
      end

      permitted
    end
  end
end

