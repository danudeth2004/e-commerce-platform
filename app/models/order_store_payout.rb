class OrderStorePayout < ApplicationRecord
  belongs_to :order
  belongs_to :store, class_name: "Seller::Store", foreign_key: :seller_store_id

  monetize :amount_cents

  enum :status, {
    pending: "pending",
    transferred: "transferred",
    failed: "failed"
  }
end
