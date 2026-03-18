class Seller::Store < ApplicationRecord
  belongs_to :owner, class_name: "Seller::User", foreign_key: :seller_user_id

  has_one_attached :cover
  has_one_attached :logo
  has_many :products, foreign_key: :seller_store_id, dependent: :destroy
  has_many :order_store_payouts, dependent: :destroy
  has_many :order_store_payouts, foreign_key: :seller_store_id, dependent: :destroy

  validates :name, uniqueness: true
  validates :name, :location, :seller_user_id, presence: true
  validates :seller_user_id, uniqueness: true

  enum :status, {
    active: "active",
    inactive: "inactive",
    suspended: "suspended"
  }
end
