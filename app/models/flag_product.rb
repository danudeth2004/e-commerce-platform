class FlagProduct < ApplicationRecord
  belongs_to :product

  enum :flag_type, {
    flash: 0,
    bestseller: 1,
    essential: 2
  }

  scope :active, ->(time = Time.current) do
    where(active: true)
      .where("starts_at IS NULL OR starts_at <= ?", time)
      .where("ends_at IS NULL OR ends_at >= ?", time)
  end

  scope :ordered, -> { order(:position, created_at: :desc) }

  scope :for_home_section, ->(section_flag_type, limit: 10, time: Time.current) do
    active(time)
      .public_send(section_flag_type)
      .ordered
      .includes(product: { images_attachments: :blob })
      .limit(limit)
  end

  validates :flag_type, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :flag_type }
end
