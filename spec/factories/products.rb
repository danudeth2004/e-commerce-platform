FactoryBot.define do
  factory :product do
    title { "MyString" }
    description { "MyText" }
    sku { "MyString" }
    amount_cents { 1 }
    amount_currency { "MyString" }
    seller_store { nil }
  end
end
