FactoryBot.define do
  factory :seller_store, class: 'Seller::Store' do
    seller_user { nil }
    name { "MyString" }
    description { "MyText" }
    location { "MyString" }
  end
end
