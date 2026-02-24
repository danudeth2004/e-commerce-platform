class HomeController < ApplicationController
  def index
    @banners            = banners
    @skin_concerns      = skin_concerns
    @flash_products     = flash_products
    @bestsellers        = bestsellers
    @bestseller_tabs    = bestseller_tabs
    @essential_products = essential_products
  end

  private
  # mock data เพื่อใช้แสดงผลในหน้า Home (จริงๆ ควรเชื่อมกับ database models)

  def banners
    [
      { brand: "Glad2Glow", sub: "POMEGRANATE NIACINAMIDE", emoji: "🍎", bg: "linear-gradient(135deg, #FFD6E8 0%, #FFF0F5 60%, #FFBDD8 100%)" },
      { brand: "CeraVe",    sub: "HYDRATING COLLECTION",    emoji: "💙", bg: "linear-gradient(135deg, #D6EAFF 0%, #ECF5FF 60%, #C2D4FF 100%)" },
      { brand: "Vaseline",  sub: "GLUTA-HYA SERIES",        emoji: "🧴", bg: "linear-gradient(135deg, #FFF3D6 0%, #FFFAEC 60%, #FFE8C2 100%)" }
    ]
  end

  def skin_concerns
    [
      { id: 1, label: "ผิวเป็นสิว",  image_url: nil },
      { id: 2, label: "ผิวมัน",       image_url: nil },
      { id: 3, label: "ผิวแห้ง",      image_url: nil },
      { id: 4, label: "ผิวผสม",       image_url: nil },
      { id: 5, label: "ผิวแพ้ง่าย",  image_url: nil },
      { id: 6, label: "ผิวหมองคล้ำ", image_url: nil },
      { id: 7, label: "รอยดำ",        image_url: nil },
      { id: 8, label: "รอยแดง",       image_url: nil }
    ]
  end

  def flash_products
    [
      { id: 1, name: "Vaseline",  desc: "วาสลีน เจลลี่ โบดี้ กลูต้า-ไฮยา เซรั่ม เพลท ไลน์...",     price: 119, original_price: 269, image_url: nil, discount_percent: 56 },
      { id: 2, name: "Glad2Glow", desc: "สเปรย์เติมความชุ่มชื้นเนียนละมุน ช่วยเสริมพลังสกิน...",     price: 119, original_price: 250, image_url: nil, discount_percent: 52 },
      { id: 3, name: "CeraVe",    desc: "Moisturizing Cream สำหรับผิวแห้ง เนียนนุ่ม...",              price: 389, original_price: 590, image_url: nil, discount_percent: 34 },
      { id: 4, name: "LANEIGE",   desc: "Lip Sleeping Mask Berry สูตรใหม่ ริมฝีปากชุ่มชื้น...",       price: 290, original_price: 480, image_url: nil, discount_percent: 40 }
    ]
  end

  def bestseller_tabs
    [ "ทั้งหมด", "เซรั่ม", "ครีมบำรุงผิว", "กันแดด", "มอยส์เจอไรเซอร์" ]
  end

  def bestsellers
    [
      { brand: "clear nose", desc: "เซรั่มเคลียร์โนส Clear Nose ดาร์คสปอต โบดี้ เซรั่มตัวดัง...",   price: 1090, original_price: nil, image_url: nil },
      { brand: "AGLAM",      desc: "Skin Daily Toner Pad 221g (60 Pads) โทนเนอร์แพดสูตรเข้มข้น...", price: 450,  original_price: nil, image_url: nil },
      { brand: "CeraVe",     desc: "CeraVe Hydrating Cream to Foam Cleanser 236ml คลีนเซอร์...",     price: 579,  original_price: 610, image_url: nil },
      { brand: "Shiseido",   desc: "Ultimune Power Infusing Serum 75ml โทนนิกเซรั่ม สูตรใหม่...",   price: 4380, original_price: nil, image_url: nil },
      { brand: "SK-II",      desc: "Skinpower Advanced Cream 15g ครีมบำรุงผิวสูตรปรับปรุงใหม่...",  price: 1330, original_price: nil, image_url: nil }
    ]
  end

  def essential_products
    [
      { id: 5, name: "Vaseline", desc: "วาสลีน เฮลธี้ ไบรท์ กลูต้า-ไฮยา เซรั่ม เบิร์ส โลชั่น ดิวอี้...", price: 119, original_price: 259, image_url: nil },
      { id: 6, name: "Vaseline", desc: "วาสลีน เฮลธี้ ไบรท์ กลูต้า-ไฮยา เซรั่ม เบิร์ส โลชั่น ดิวอี้...", price: 119, original_price: 269, image_url: nil },
      { id: 7, name: "Vaseline", desc: "วาสลีน เฮลธี้ ไบรท์ กลูต้า-ไฮยา เซรั่ม เบิร์ส โลชั่น ดิวอี้...", price: 119, original_price: 259, image_url: nil },
      { id: 8, name: "Vaseline", desc: "วาสลีน เฮลธี้ ไบรท์ กลูต้า-ไฮยา เซรั่ม เบิร์ส โลชั่น ดิวอี้...", price: 119, original_price: 269, image_url: nil }
    ]
  end
end
