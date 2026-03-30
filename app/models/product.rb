class Product < ApplicationRecord
  BUNDLE_SET_TYPE_KEYS = %w[facial_routine hair_care serum_cream body_care other].freeze

  BUNDLE_SET_TYPE_OPTIONS = [
    [ "เซตล้างหน้า–บำรุงผิว", "facial_routine" ],
    [ "เซตเส้นผม", "hair_care" ],
    [ "เซตเซรั่ม+ครีม", "serum_cream" ],
    [ "เซตบำรุงผิวกาย", "body_care" ],
    [ "อื่น ๆ", "other" ]
  ].freeze

  belongs_to :store, class_name: "Seller::Store", foreign_key: :seller_store_id

  monetize :amount_cents
  monetize :promotion_cents
  before_validation :assign_defaults

  attribute :kind, :string, default: "standard"
  enum :kind, { standard: "standard", bundle: "bundle" }, default: :standard, validate: true

  has_many_attached :images
  has_many :flag_products, dependent: :destroy
  has_many :campaign_products, dependent: :destroy
  has_many :campaigns, through: :campaign_products
  has_many :cart_items, dependent: :destroy
  has_many :order_items
  has_many :bundle_items, -> { order(:position) },
           class_name: "ProductBundleItem",
           foreign_key: :bundle_product_id,
           dependent: :destroy,
           inverse_of: :bundle_product
  has_many :bundle_component_products, through: :bundle_items, source: :component_product
  has_many :product_bundle_items_as_component,
           class_name: "ProductBundleItem",
           foreign_key: :component_product_id,
           dependent: :restrict_with_error,
           inverse_of: :component_product
  has_many :coupon_products, dependent: :destroy
  has_many :coupons, through: :coupon_products

  validates :title, presence: true
  validates :volume, :volume_unit, presence: true, if: :standard?
  validates :sku, presence: true, uniqueness: true
  validates :amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :amount_currency, presence: true
  validates :promotion_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :promotion_currency, presence: true
  validates :category_key, presence: true, inclusion: { in: ProductCategory.keys }
  validates :bundle_set_type_key,
            presence: true,
            inclusion: { in: BUNDLE_SET_TYPE_KEYS },
            if: :bundle?
  validate :bundle_skin_concerns_presence, if: :bundle?
  validate :promotion_schedule_order

  default_scope -> { order(created_at: :desc) }

  # ราคาหลังโปรร้าน (ช่วงเวลา + promotion_cents) ยังไม่รวมแคมเปญแพลตฟอร์ม
  def price_after_product_promotion_cents(time = Time.current)
    promotion_price_applicable?(time) ? promotion_cents : amount_cents
  end

  # ราคาขายจริงต่อหน่วย (รวมโปรร้าน + แคมเปญที่สมัครและ active)
  # เซตสินค้าไม่ร่วมแคมเปญแพลตฟอร์ม — ใช้แค่โปรที่ตั้งที่สินค้า
  def final_price_cents(time = Time.current)
    base = price_after_product_promotion_cents(time)
    return base if bundle?

    campaign_scope = campaigns.active_at(time)
    return base unless campaign_scope.exists?

    best = campaign_scope.map { |c| c.apply_discount_to_cents(base) }.min
    [ best, 0 ].max
  end

  # เซต: ลดจากราคาเต็ม หรือถูกกว่าซื้อชิ้นในชุดแยก (ราคาขายจริงเทียบรวมราคาชิ้น)
  def bundle_discount_active?(time = Time.current)
    return false unless bundle?

    f = final_price_cents(time)
    return true if f < amount_cents

    f < bundle_components_final_sum_cents(time)
  end

  def title_with_store
    "#{store.name} — #{title} (#{id})"
  end

  def skin_concern_keys_array
    skin_concern_keys.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  # ป้ายภาษาไทยสำหรับแสดง (เซตหลายค่า หรือสินค้าชิ้นเดียวค่าเดียว)
  def skin_concern_labels
    keys =
      if bundle? && skin_concern_keys.present?
        skin_concern_keys_array
      elsif skin_concern_key.present?
        [ skin_concern_key ]
      else
        []
      end
    keys.filter_map do |k|
      SkinConcern::DATA.find { |d| d[:key] == k }&.dig(:label)
    end
  end

  private

  def bundle_components_final_sum_cents(time)
    bundle_items.sum { |i| i.component_product.final_price_cents(time) }
  end

  def bundle_skin_concerns_presence
    keys = skin_concern_keys_array
    valid = SkinConcern::DATA.map { |d| d[:key] }
    keys.each do |k|
      unless valid.include?(k)
        errors.add(:skin_concern_keys, "มีค่าที่ไม่ถูกต้อง")
        return
      end
    end
    errors.add(:skin_concern_keys, "กรุณาเลือกอย่างน้อย 1 ข้อ") if keys.empty?
  end

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
    self.promotion_currency = "THB" if promotion_currency.blank?
    self.sku = generate_sku if sku.blank?
  end

  def generate_sku
    loop do
      candidate = "SKU-#{SecureRandom.alphanumeric(8).upcase}"
      break candidate unless self.class.exists?(sku: candidate)
    end
  end
end
