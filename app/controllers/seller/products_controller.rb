module Seller
  class ProductsController < BaseController
    layout "devise"
    before_action :set_store, only: [ :choose, :new, :create, :edit, :update, :destroy ]
    before_action :set_product, only: [ :edit, :update, :destroy ]

    def choose
    end

    def new
      @product = @store.products.new
    end

    def create
      @product = @store.products.new(product_params)

      if @product.save
        redirect_to seller_root_path, notice: "เพิ่มสินค้าเรียบร้อยแล้ว"
      else
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      if @product.bundle?
        redirect_to edit_seller_product_bundle_path(@product)
        nil
      end
    end

    def update
      if @product.bundle?
        redirect_to edit_seller_product_bundle_path(@product), alert: "แก้ไขเซตสินค้าได้จากฟอร์มจัดเซต"
        return
      end

      attrs = product_params.except(:images)
      if @product.update(attrs)
        attach_new_images_if_any(@product)
        redirect_to product_path(@product, seller_preview: 1), notice: "อัปเดตสินค้าแล้ว"
      else
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @product.order_items.exists?
        redirect_to product_path(@product, seller_preview: 1), alert: "ไม่สามารถลบสินค้าที่เคยถูกสั่งซื้อได้"
        return
      end

      if @product.standard? && @product.product_bundle_items_as_component.exists?
        redirect_to product_path(@product, seller_preview: 1), alert: "ไม่สามารถลบได้ — สินค้านี้ถูกใช้ในเซต กรุณาลบหรือแก้เซตก่อน"
        return
      end

      @product.destroy
      redirect_to seller_root_path, notice: "ลบสินค้าแล้ว"
    end

    private

    def set_store
      @store = Seller::Store.find(current_seller_user.store.id)
    end

    def set_product
      @product = @store.products.find(params[:id])
    end

    def attach_new_images_if_any(product)
      files = params.dig(:product, :images)
      return if files.blank?

      files = Array(files).compact.reject(&:blank?)
      product.images.attach(files) if files.any?
    end

    def product_params
      permitted = params.require(:product).permit(
        :title,
        :sku,
        :amount,
        :promotion,
        :promotion_starts_at,
        :promotion_ends_at,
        :description,
        :skin_concern_key,
        :category_key,
        :effect,
        :volume,
        :volume_unit,
        :usage,
        images: []
      )

      permitted[:promotion_starts_at] = permitted[:promotion_starts_at].presence
      permitted[:promotion_ends_at] = permitted[:promotion_ends_at].presence

      if permitted[:amount].present?
        permitted[:amount_cents] = (permitted.delete(:amount).to_f * 100).to_i
        permitted[:amount_currency] = "THB"
      end

      promo = permitted.delete(:promotion)
      if promo.present?
        permitted[:promotion_cents] = (promo.to_f * 100).to_i
        permitted[:promotion_currency] = "THB"
      else
        permitted[:promotion_cents] = 0
        permitted[:promotion_currency] = "THB"
      end

      permitted
    end
  end
end
