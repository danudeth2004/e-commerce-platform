# frozen_string_literal: true

class ShippingAddress < ApplicationRecord
  belongs_to :user
  has_many :orders, dependent: :nullify

  before_save :ensure_single_default_for_user
  after_create :ensure_default_if_only_address

  validates :address_detail, :province_id, :district_id, :sub_district_id, :postal_code, presence: true
  validates :phone_number, format: { with: /\A0\d{9}\z/ }, allow_blank: true

  scope :default_first, -> { order(is_default: :desc, updated_at: :desc) }

  def display_phone
    phone_number.presence || user&.phone_number
  end

  def display_recipient
    recipient_name.presence || [ user&.first_name, user&.last_name ].compact_blank.join(" ")
  end

  def province_name_th
    ThailandGeography.province_name(province_id)
  end

  def district_name_th
    ThailandGeography.district_name(district_id)
  end

  def sub_district_name_th
    ThailandGeography.sub_district_name(sub_district_id)
  end

  def full_address_lines
    geo_line = [
      "ตำบล#{sub_district_name_th}",
      "อำเภอ#{district_name_th}",
      "จังหวัด#{province_name_th}",
      postal_code
    ].compact_blank.join(" ")

    [ address_detail.to_s.strip, geo_line ].compact_blank
  end

  def full_snapshot_text
    lines = []
    lines << display_recipient
    lines.concat(full_address_lines)
    lines << "โทร #{display_phone}" if display_phone.present?
    lines.join("\n")
  end

  private

    def ensure_single_default_for_user
      return unless is_default? && user_id.present?

      user.shipping_addresses.where.not(id: id).update_all(is_default: false)
    end

    def ensure_default_if_only_address
      return unless user.shipping_addresses.one?

      update_column(:is_default, true) unless is_default?
    end
end
