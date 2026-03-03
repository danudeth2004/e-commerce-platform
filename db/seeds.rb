# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

seller = Seller::User.find_or_create_by!(email: "demo-seller@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
  u.first_name = "Demo"
  u.last_name = "Seller"
  u.phone_number = "0123456789"
end

store = Seller::Store.find_or_initialize_by(seller_user_id: seller.id)
store.name ||= "Demo Store #{seller.id}"
store.location ||= "Bangkok"
store.description ||= "Seed data store"
store.save!

products_data = [
  { title: "Vaseline",  sku: "VAS-001", amount_baht: 119, description: "วาสลีน เฮลธี้ ไบรท์ กลูต้า-ไฮยา เซรั่ม เบิร์ส โลชั่น ดิวอี้..." },
  { title: "Glad2Glow", sku: "GLD-001", amount_baht: 119, description: "สเปรย์เติมความชุ่มชื้นเนียนละมุน ช่วยเสริมพลังสกิน..." },
  { title: "CeraVe",    sku: "CRV-001", amount_baht: 389, description: "Moisturizing Cream สำหรับผิวแห้ง เนียนนุ่ม..." },
  { title: "LANEIGE",   sku: "LNG-001", amount_baht: 290, description: "Lip Sleeping Mask Berry สูตรใหม่ ริมฝีปากชุ่มชื้น..." },
  { title: "clear nose", sku: "CLN-001", amount_baht: 1090, description: "เซรั่มเคลียร์โนส Clear Nose ดาร์คสปอต โบดี้ เซรั่มตัวดัง..." },
  { title: "AGLAM",      sku: "AGL-001", amount_baht: 450,  description: "Skin Daily Toner Pad 221g (60 Pads) โทนเนอร์แพดสูตรเข้มข้น..." },
  { title: "Shiseido",   sku: "SHS-001", amount_baht: 4380, description: "Ultimune Power Infusing Serum 75ml โทนนิกเซรั่ม สูตรใหม่..." },
  { title: "SK-II",      sku: "SK2-001", amount_baht: 1330, description: "Skinpower Advanced Cream 15g ครีมบำรุงผิวสูตรปรับปรุงใหม่..." }
]

products = products_data.map do |data|
  Product.find_or_create_by!(sku: data[:sku]) do |p|
    p.store = store
    p.title = data[:title]
    p.description = data[:description]
    p.amount_cents = data[:amount_baht] * 100
    p.amount_currency = "THB"
  end
end

# Flash sale (ใช้ราคาเดิมเพื่อโชว์ % ลด)
flash_map = {
  "VAS-001" => 269,
  "GLD-001" => 250,
  "CRV-001" => 590,
  "LNG-001" => 480
}
flash_map.each_with_index do |(sku, original_baht), idx|
  product = Product.find_by!(sku: sku)
  FlagProduct.find_or_create_by!(product: product, flag_type: :flash) do |fp|
    fp.position = idx
    fp.original_amount_cents = original_baht * 100
    fp.active = true
  end
end

# Bestseller list (เรียงตาม position)
bestseller_skus = %w[CLN-001 AGL-001 CRV-001 SHS-001 SK2-001]
bestseller_skus.each_with_index do |sku, idx|
  product = Product.find_by!(sku: sku)
  FlagProduct.find_or_create_by!(product: product, flag_type: :bestseller) do |fp|
    fp.position = idx
    fp.active = true
  end
end

# Essentials grid
essential_skus = %w[VAS-001 GLD-001 CRV-001 LNG-001]
essential_skus.each_with_index do |sku, idx|
  product = Product.find_by!(sku: sku)
  FlagProduct.find_or_create_by!(product: product, flag_type: :essential) do |fp|
    fp.position = idx
    fp.active = true
  end
end

