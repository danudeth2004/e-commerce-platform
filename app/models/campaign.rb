# frozen_string_literal: true

class Campaign < ApplicationRecord
  has_many :campaign_products, dependent: :destroy
  has_many :products, through: :campaign_products

  has_many_attached :banners

  # จากฟอร์มแอดมินเท่านั้น — ใช้ตรวจว่าต้องแนบแบนเนอร์ตอนสร้าง (ไม่บังคับใน Campaign.create! จาก seed/test)
  attr_accessor :from_admin_form, :banner_files_for_validation

  validates :name, presence: { message: "กรุณากรอกชื่อแคมเปญ" }
  validates :slug, presence: { message: "กรุณากรอก Slug" },
                     uniqueness: { message: "Slug นี้ถูกใช้งานแล้ว" }
  validates :starts_at, presence: { message: "กรุณากรอกวันเริ่ม" }
  validates :ends_at, presence: { message: "กรุณากรอกวันสิ้นสุด" }
  validates :discount_percent, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    allow_nil: true
  }
  validate :discount_percent_must_be_provided
  validate :ends_after_starts
  validate :must_have_at_least_one_product
  validate :product_ids_must_not_include_bundles
  validate :banners_required_on_create, on: :create

  scope :active_at, ->(time = Time.current) {
    where("starts_at <= ? AND ends_at >= ?", time, time)
  }

  def apply_discount_to_cents(cents)
    return cents if discount_percent.nil? || discount_percent.to_i <= 0

    (cents * (100 - discount_percent) / 100.0).round
  end

  private

  def discount_percent_must_be_provided
    return unless discount_percent.nil?

    errors.add(:discount_percent, "กรุณากรอกส่วนลด")
  end

  def banners_required_on_create
    return unless from_admin_form

    files = Array(banner_files_for_validation).flatten.compact.reject(&:blank?)
    errors.add(:banner_files, "กรุณาเลือกรูปแบนเนอร์") if files.empty?
  end

  def must_have_at_least_one_product
    ids = product_ids.reject(&:blank?).map(&:to_i)
    return if ids.any?

    errors.add(:product_ids, "กรุณาเลือกสินค้าในแคมเปญ")
  end

  def product_ids_must_not_include_bundles
    ids = product_ids
    return if ids.blank?

    return unless Product.where(id: ids, kind: :bundle).exists?

    errors.add(:product_ids, "เซตสินค้าเข้าร่วมแคมเปญไม่ได้")
  end

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "วันเริ่มต้นต้องน้อยกว่าวันสิ้นสุด") if ends_at < starts_at
  end
end
