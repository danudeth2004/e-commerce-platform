class Coupon < ApplicationRecord
  belongs_to :user
  has_many :coupon_products, dependent: :destroy
  has_many :products, through: :coupon_products

  validates :discount, presence: true, numericality: { greater_than: 0 }
  validates :min_order, numericality: { greater_than_or_equal_to: 0 }
  validates :started_at, :expires_at, presence: true
  validate :expires_after_started

  scope :active, -> {
    where("started_at <= ? AND expires_at >= ?", Time.current, Time.current).where(used: false)
  }

  def active?
    !used && started_at <= Time.current && expires_at >= Time.current
  end

  def valid_for_order?(order)
    order.order_items.any? do |item|
      products.exists?(id: item.product_id)
    end
  end

  private

  def expires_after_started
    return if expires_at > started_at

    errors.add(:expires_at, "must be after started_at")
  end
end
