class Product < ApplicationRecord
  belongs_to :store, class_name: "Seller::Store", foreign_key: :seller_store_id

  monetize :amount_cents

  has_many_attached :images
  has_many :flag_products, dependent: :destroy
  has_many :cart_items, dependent: :destroy

  validates :title, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :amount_currency, presence: true
end
