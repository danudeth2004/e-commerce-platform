class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :order_store_payouts, dependent: :destroy

  monetize :total_amount_cents
  monetize :shipping_cents
  monetize :platform_fee_cents

  enum :status, {
    cancelled: "cancelled",
    pending: "pending",
    paid: "paid",
    failed: "failed"
  }
end
