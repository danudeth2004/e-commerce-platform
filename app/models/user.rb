class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_one :cart, dependent: :destroy

  validates :first_name, :last_name, presence: true
  validates :phone_number, format: { with: /\A0\d{9}\z/ }
end
