class Seller::Store < ApplicationRecord
  belongs_to :owner, class_name: "Seller::User", foreign_key: :seller_user_id

  has_many :products, foreign_key: :seller_store_id, dependent: :destroy
end
