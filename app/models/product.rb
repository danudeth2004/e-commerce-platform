class Product < ApplicationRecord
  belongs_to :store, class_name: "Seller::Store", foreign_key: :seller_store_id

  monetize :amount_cents

  has_many_attached :images
end
