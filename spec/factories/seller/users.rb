FactoryBot.define do
  factory :seller_user, class: "Seller::User" do
    sequence(:email) { |n| "seller#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    first_name { "Seller" }
    last_name { "User" }
    phone_number { "0812345678" }
  end
end
