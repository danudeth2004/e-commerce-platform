# frozen_string_literal: true

# หน้าร้านค้าสำหรับผู้ซื้อ (ดูสินค้าแบรนด์จาก PDP)
class StoresController < BaseController
  def show
    @store = Seller::Store.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @store.active?

    @category_key = params[:category].presence
    @category_key = nil unless ProductCategory.keys.include?(@category_key)

    scope = @store.products
      .includes(bundle_items: { component_product: { images_attachments: :blob } })
      .order(created_at: :desc)
    scope = scope.where(category_key: @category_key) if @category_key.present?

    @bundle_products = scope.where(kind: :bundle)
    @standard_products = scope.where(kind: :standard)
  end
end
