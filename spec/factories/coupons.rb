FactoryBot.define do
  factory :coupon do
    discount { 1 }
    min_order { 1 }
    started_at { "2026-03-30 18:54:50" }
    expires_at { "2026-03-30 18:54:50" }
  end
end
