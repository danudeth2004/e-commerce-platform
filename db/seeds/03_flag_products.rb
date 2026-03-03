# Flash sale (ใช้ราคาเดิมเพื่อโชว์ % ลด)
flash_map = {
  "DEMO-001" => 269,
  "DEMO-002" => 350,
  "DEMO-003" => 320,
  "DEMO-004" => 480
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
bestseller_skus = %w[DEMO-005 DEMO-006 DEMO-003 DEMO-007 DEMO-008]

bestseller_skus.each_with_index do |sku, idx|
  product = Product.find_by!(sku: sku)
  FlagProduct.find_or_create_by!(product: product, flag_type: :bestseller) do |fp|
    fp.position = idx
    fp.active = true
  end
end

# Essentials grid
essential_skus = %w[DEMO-001 DEMO-002 DEMO-003 DEMO-004]

essential_skus.each_with_index do |sku, idx|
  product = Product.find_by!(sku: sku)
  FlagProduct.find_or_create_by!(product: product, flag_type: :essential) do |fp|
    fp.position = idx
    fp.active = true
  end
end
