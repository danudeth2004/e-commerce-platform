class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Explicit type required by Rails 8.1 enum until the DB column exists (run db:migrate).
  attribute :account_status, :string, default: "active"

  enum :account_status, {
    active: "active",
    suspended: "suspended"
  }, default: :active

  has_one_attached :avatar
  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :coupons, dependent: :destroy
  has_many :shipping_addresses, dependent: :destroy

  accepts_nested_attributes_for :shipping_addresses,
                                allow_destroy: true,
                                reject_if: :reject_blank_shipping_address

  validates :first_name, :last_name, presence: true
  validates :phone_number, format: { with: /\A0\d{9}\z/ }

  def default_shipping_address
    shipping_addresses.find_by(is_default: true) || shipping_addresses.first
  end

  def active_for_authentication?
    super && !suspended?
  end

  def inactive_message
    suspended? ? :suspended : super
  end

  private

    def reject_blank_shipping_address(attributes)
      attrs = attributes.stringify_keys
      %w[address_detail province_id district_id sub_district_id postal_code].all? { |k| attrs[k].blank? }
    end
end
