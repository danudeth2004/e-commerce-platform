# frozen_string_literal: true

class CampaignProduct < ApplicationRecord
  belongs_to :campaign
  belongs_to :product

  validate :product_must_not_be_bundle

  private

  def product_must_not_be_bundle
    return unless product&.bundle?

    errors.add(:base, "เซตสินค้าเข้าร่วมแคมเปญไม่ได้")
  end
end
