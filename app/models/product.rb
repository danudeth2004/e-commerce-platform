class Product < ApplicationRecord
  belongs_to :store, class_name: "Seller::Store", foreign_key: :seller_store_id

  monetize :amount_cents
  before_validation :assign_defaults

  has_many_attached :images
  has_many :flag_products, dependent: :destroy
  has_many :cart_items, dependent: :destroy

  attr_accessor :effect,
                :skin_type,
                :volume,
                :volume_unit,
                :promotion_price,
                :usage

  validates :title, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :amount_currency, presence: true
  validates :category_key, presence: true, inclusion: { in: ProductCategory.keys }

  default_scope -> { order(created_at: :desc) }

  private

  def assign_defaults
    self.amount_currency = "THB" if amount_currency.blank?
    self.sku = generate_sku if sku.blank?
  end

  def generate_sku
    loop do
      candidate = "SKU-#{SecureRandom.alphanumeric(8).upcase}"
      break candidate unless self.class.exists?(sku: candidate)
    end
  end
end
