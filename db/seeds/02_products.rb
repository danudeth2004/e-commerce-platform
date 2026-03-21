seller = Seller::User.find_by!(email: "demo-seller@example.com")
store  = Seller::Store.find_by!(seller_user_id: seller.id)

products_data = [
  {
    title: "Demo Glow Serum",
    sku: "DEMO-001",
    amount_baht: 119,
    description: "เซรั่มบำรุงผิวเนื้อบางเบา ช่วยให้ผิวดูกระจ่างใสและชุ่มชื้น เหมาะสำหรับทุกสภาพผิว"
  },
  {
    title: "Hydra Balance Moisturizer",
    sku: "DEMO-002",
    amount_baht: 289,
    description: "มอยส์เจอไรเซอร์เนื้อครีมเจล เติมน้ำให้ผิวไม่เหนอะหนะ ใช้ได้ทั้งเช้าและก่อนนอน"
  },
  {
    title: "Soft Foam Cleanser",
    sku: "DEMO-003",
    amount_baht: 189,
    description: "โฟมล้างหน้าสูตรอ่อนโยน ช่วยทำความสะอาดคราบมันและสิ่งสกปรก โดยไม่ทำให้ผิวแห้งตึง"
  },
  {
    title: "Sun Care Daily SPF50",
    sku: "DEMO-004",
    amount_baht: 290,
    description: "ครีมกันแดดสำหรับใช้ทุกวัน ป้องกันรังสี UVA/UVB เนื้อบางเบาไม่วอก"
  },
  {
    title: "Clarifying Spot Serum",
    sku: "DEMO-005",
    amount_baht: 450,
    description: "เซรั่มแต้มจุดด่างดำ ช่วยให้รอยสิวดูจางลงอย่างเป็นธรรมชาติเมื่อใช้ต่อเนื่อง"
  },
  {
    title: "Calming Repair Cream",
    sku: "DEMO-006",
    amount_baht: 720,
    description: "ครีมบำรุงผิวสำหรับผิวแพ้ง่าย ช่วยปลอบประโลมผิวและเสริมเกราะปกป้องผิว"
  },
  {
    title: "Overnight Recovery Mask",
    sku: "DEMO-007",
    amount_baht: 890,
    description: "มาสก์บำรุงผิวข้ามคืน ช่วยให้ผิวรู้สึกนุ่ม ชุ่มชื้น และดูอิ่มฟูในตอนเช้า"
  },
  {
    title: "Radiance Boost Essence",
    sku: "DEMO-008",
    amount_baht: 650,
    description: "เอสเซนส์เตรียมผิว ช่วยให้ขั้นตอนการบำรุงถัดไปซึมซาบได้ดีขึ้น เหมาะสำหรับผิวหมองคล้ำ"
  }
]

# Map SKU -> category_key (ใช้ key จาก ProductCategory::DATA)
category_by_sku = {
  "DEMO-001" => "serum",
  "DEMO-002" => "moisturizer",
  "DEMO-003" => "skin_care",
  "DEMO-004" => "sunscreen",
  "DEMO-005" => "serum",
  "DEMO-006" => "moisturizer",
  "DEMO-007" => "skin_care",
  "DEMO-008" => "skin_care"
}

# Map SKU -> skin_concern_key (ใช้ key จาก SkinConcern::DATA)
skin_concern_by_sku = {
  "DEMO-001" => "dry_skin",
  "DEMO-002" => "combination_skin",
  "DEMO-003" => "oily_skin",
  "DEMO-004" => "sensitive_skin",
  "DEMO-005" => "acne_skin",
  "DEMO-006" => "dull_skin",
  "DEMO-007" => "dry_skin",
  "DEMO-008" => "dull_skin"
}

products_data.each do |data|
  product = Product.find_or_create_by!(sku: data[:sku]) do |p|
    p.store = store
    p.title = data[:title]
    p.description = data[:description]
    p.amount_cents = data[:amount_baht] * 100
    p.amount_currency = "THB"
    p.category_key = category_by_sku[data[:sku]] || "skin_care"
    p.skin_concern_key = skin_concern_by_sku[data[:sku]] if skin_concern_by_sku[data[:sku]]
  end

  attrs = {}
  if (skin_key = skin_concern_by_sku[data[:sku]])
    attrs[:skin_concern_key] = skin_key
  end
  if (cat_key = category_by_sku[data[:sku]])
    attrs[:category_key] = cat_key
  end
  product.update!(attrs) if attrs.any?
end
