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

