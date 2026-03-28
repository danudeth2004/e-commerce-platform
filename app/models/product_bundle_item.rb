class ProductBundleItem < ApplicationRecord
  belongs_to :bundle_product, class_name: "Product", inverse_of: :bundle_items
  belongs_to :component_product, class_name: "Product", inverse_of: :product_bundle_items_as_component

  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :usage_instructions, presence: true

  validate :component_must_be_standard
  validate :same_store

  private

  def component_must_be_standard
    return unless component_product

    return if component_product.standard?

    errors.add(:component_product, "ต้องเป็นสินค้าชิ้นเดียว ไม่ใช่เซต")
  end

  def same_store
    return unless bundle_product && component_product

    return if bundle_product.seller_store_id == component_product.seller_store_id

    errors.add(:base, "สินค้าต้องอยู่ร้านเดียวกัน")
  end
end
