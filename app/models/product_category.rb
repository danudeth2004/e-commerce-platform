class ProductCategory
  DATA = [
    { key: "serum", label: "เซรั่ม" },
    { key: "moisturizer", label: "ครีมบำรุงผิว" },
    { key: "sunscreen", label: "กันแดด" },
    { key: "skin_care", label: "ผลิตภัณฑ์สำหรับผิว" }
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
