# frozen_string_literal: true

class Campaign < ApplicationRecord
  has_many :campaign_products, dependent: :destroy
  has_many :products, through: :campaign_products

  validates :name, :slug, :starts_at, :ends_at, presence: true
  validates :slug, uniqueness: true
  validates :discount_percent, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :ends_after_starts

  before_validation :assign_slug_from_name

  scope :active_at, ->(time = Time.current) {
    where("starts_at <= ? AND ends_at >= ?", time, time)
  }

  def apply_discount_to_cents(cents)
    return cents if discount_percent.to_i <= 0

    (cents * (100 - discount_percent) / 100.0).round
  end

  private

  def assign_slug_from_name
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "ต้องอยู่หลังเวลาเริ่ม") if ends_at < starts_at
  end
end
