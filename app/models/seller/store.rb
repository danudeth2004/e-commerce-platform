class Seller::Store < ApplicationRecord
  before_validation :normalize_bank_number

  belongs_to :owner, class_name: "Seller::User", foreign_key: :seller_user_id

  has_one_attached :cover
  has_one_attached :logo
  has_many :products, foreign_key: :seller_store_id, dependent: :destroy
  has_many :order_store_payouts, foreign_key: :seller_store_id, dependent: :destroy
  has_many :orders, through: :order_store_payouts

  validates :name, uniqueness: true
  validates :name, :location, :seller_user_id, presence: true
  validates :seller_user_id, uniqueness: true
  validates :bank_code, :bank_number, :bank_name, presence: true

  VALID_BANK_CODES = %w[bbl kbank scb ktb ttb].freeze
  validates :bank_code, inclusion: { in: VALID_BANK_CODES }

  validates :bank_number, format: {
    with: /\A\d{9,12}\z/,
    message: "เลขบัญชีต้องเป็นตัวเลข 9-12 หลัก"
  }

  enum :status, {
    active: "active",
    inactive: "inactive",
    suspended: "suspended"
  }

  default_scope -> { order(id: :asc) }

  private
    def normalize_bank_number
      self.bank_number = bank_number.to_s.gsub(/\D/, "")
    end
end
