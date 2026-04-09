class ProductCategory
  DATA = [
    { key: "serum", label: "เซรั่ม" },
    { key: "moisturizer", label: "ครีมบำรุงผิว" },
    { key: "sunscreen", label: "กันแดด" },
    { key: "skin_care", label: "ผลิตภัณฑ์สำหรับผิว" },
    { key: "bundle", label: "ชุดสินค้า" },
    { key: "toner", label: "โทนเนอร์" },
    { key: "essence", label: "เอสเซนส์" },
    { key: "eye_cream", label: "ครีมบำรุงรอบดวงตา" },
    { key: "face_mask", label: "มาส์กหน้า" },
    { key: "face_wash", label: "คลีนเซอร์/โฟมล้างหน้า" },
    { key: "makeup_remover", label: "เมคอัพรีมูฟเวอร์" },
    { key: "exfoliator", label: "สครับ/เอ็กซ์โฟเลียเตอร์" },
    { key: "face_oil", label: "เฟซออยล์" },
    { key: "lip_care", label: "ผลิตภัณฑ์บำรุงริมฝีปาก" },
    { key: "body_lotion", label: "โลชั่นบำรุงผิวกาย" },
    { key: "body_wash", label: "ครีมอาบน้ำ" },
    { key: "hand_cream", label: "ครีมบำรุงมือ" },
    { key: "spot_treatment", label: "ผลิตภัณฑ์แต้มสิว" },
    { key: "sheet_mask", label: "ชีทมาส์ก" },
    { key: "mist_spray", label: "มิสต์/สเปรย์บำรุงผิว" },
    { key: "supplement", label: "อาหารเสริมเพื่อผิว" },
    { key: "tool_device", label: "อุปกรณ์และเครื่องมือดูแลผิว" }
  ].freeze

  def self.all
    DATA
  end

  def self.keys
    DATA.map { |row| row[:key] }
  end

  def self.label_for(key)
    return nil if key.blank?

    DATA.find { |row| row[:key] == key }&.dig(:label)
  end
end
