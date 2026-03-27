class Product < ApplicationRecord
  belongs_to :store, class_name: "Seller::Store", foreign_key: :seller_store_id

  monetize :amount_cents
  monetize :promotion_cents
  before_validation :assign_defaults

  has_many_attached :images
  has_many :flag_products, dependent: :destroy
  has_many :campaign_products, dependent: :destroy
  has_many :campaigns, through: :campaign_products
  has_many :cart_items, dependent: :destroy
  has_many :order_items

  validates :title, :volume, :volume_unit, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :amount_currency, presence: true
  validates :promotion_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :promotion_currency, presence: true
  validates :category_key, presence: true, inclusion: { in: ProductCategory.keys }
  validate :promotion_schedule_order

  default_scope -> { order(created_at: :desc) }

  # ราคาหลังโปรร้าน (ช่วงเวลา + promotion_cents) ยังไม่รวมแคมเปญแพลตฟอร์ม
  def price_after_product_promotion_cents(time = Time.current)
    promotion_price_applicable?(time) ? promotion_cents : amount_cents
  end

  # ราคาขายจริงต่อหน่วย (รวมโปรร้าน + แคมเปญที่สมัครและ active)
  def final_price_cents(time = Time.current)
    base = price_after_product_promotion_cents(time)
    campaign_scope = campaigns.active_at(time)
    return base unless campaign_scope.exists?

    best = campaign_scope.map { |c| c.apply_discount_to_cents(base) }.min
    [ best, 0 ].max
  end

  def title_with_store
    "#{store.name} — #{title} (#{id})"
  end

  private

  def promotion_price_applicable?(time)
    return false if promotion_cents.to_i <= 0
    return false if promotion_cents >= amount_cents

    if promotion_starts_at.blank? && promotion_ends_at.blank?
      return true
    end

    after_start = promotion_starts_at.nil? || time >= promotion_starts_at
    before_end = promotion_ends_at.nil? || time <= promotion_ends_at
    after_start && before_end
  end

  def promotion_schedule_order
    return if promotion_starts_at.blank? || promotion_ends_at.blank?

    errors.add(:promotion_ends_at, "ต้องอยู่หลังเวลาเริ่ม") if promotion_ends_at < promotion_starts_at
  end

  def assign_defaults
    self.amount_currency = "THB" if amount_currency.blank?
    self.promotion_currency = "THB" if amount_currency.blank?
    self.sku = generate_sku if sku.blank?
  end

  def generate_sku
    loop do
      candidate = "SKU-#{SecureRandom.alphanumeric(8).upcase}"
      break candidate unless self.class.exists?(sku: candidate)
    end
  end
end
