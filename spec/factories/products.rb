FactoryBot.define do
  factory :product do
    title { "MyString" }
    description { "MyText" }
    sku { "MyString" }
    amount_cents { 1 }
    amount_currency { "THB" }
    category_key { "skin_care" }
    seller_store { nil }
  end
end
