seller = Seller::User.find_by!(email: "demo-seller@example.com")
store  = Seller::Store.find_by!(seller_user_id: seller.id)

products_data = [
  { title: "Vaseline",   sku: "VAS-001", amount_baht: 119, description: "วาสลีน เฮลธี้ ไบรท์ กลูต้า-ไฮยา เซรั่ม เบิร์ส โลชั่น ดิวอี้..." },
  { title: "Glad2Glow",  sku: "GLD-001", amount_baht: 119, description: "สเปรย์เติมความชุ่มชื้นเนียนละมุน ช่วยเสริมพลังสกิน..." },
  { title: "CeraVe",     sku: "CRV-001", amount_baht: 389, description: "Moisturizing Cream สำหรับผิวแห้ง เนียนนุ่ม..." },
  { title: "LANEIGE",    sku: "LNG-001", amount_baht: 290, description: "Lip Sleeping Mask Berry สูตรใหม่ ริมฝีปากชุ่มชื้น..." },
  { title: "clear nose", sku: "CLN-001", amount_baht: 1090, description: "เซรั่มเคลียร์โนส Clear Nose ดาร์คสปอต โบดี้ เซรั่มตัวดัง..." },
  { title: "AGLAM",      sku: "AGL-001", amount_baht: 450,  description: "Skin Daily Toner Pad 221g (60 Pads) โทนเนอร์แพดสูตรเข้มข้น..." },
  { title: "Shiseido",   sku: "SHS-001", amount_baht: 4380, description: "Ultimune Power Infusing Serum 75ml โทนนิกเซรั่ม สูตรใหม่..." },
  { title: "SK-II",      sku: "SK2-001", amount_baht: 1330, description: "Skinpower Advanced Cream 15g ครีมบำรุงผิวสูตรปรับปรุงใหม่..." }
]

products_data.each do |data|
  product = Product.find_or_create_by!(sku: data[:sku]) do |p|
    p.store = store
    p.title = data[:title]
    p.description = data[:description]
    p.amount_cents = data[:amount_baht] * 100
    p.amount_currency = "THB"
  end

  image_path = Rails.root.join("app/assets/images/seed_products/#{data[:sku]}.png")
  if File.exist?(image_path) && !product.images.attached?
    product.images.attach(
      io: File.open(image_path),
      filename: "#{data[:sku]}.png",
      content_type: "image/png"
    )
  end
end

