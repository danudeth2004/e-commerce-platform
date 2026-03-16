class HomeController < ApplicationController
  def index
    @banners            = banners
    @skin_concerns      = skin_concerns
    @flash_products     = flash_products
    @bestsellers        = bestsellers
    @bestseller_tabs    = bestseller_tabs
    @essential_products = essential_products
  end

  def show
    @product = Product.find(params[:id])

    @product_image       = @product
    @brand_section       = @product
    @product_description = @product
    @product_bottom_bar  = @product
  end

  private
  # data สำหรับหน้า Home:
  # - banners/skin_concerns เป็น static config ใน controller
  # - flash/bestseller/essential ดึงจาก FlagProduct + Product ใน database อย่างเดียว

  def banners
    [
      { brand: "Glad2Glow", sub: "POMEGRANATE NIACINAMIDE", emoji: "🍎", bg: "linear-gradient(135deg, #FFD6E8 0%, #FFF0F5 60%, #FFBDD8 100%)" },
      { brand: "CeraVe",    sub: "HYDRATING COLLECTION",    emoji: "💙", bg: "linear-gradient(135deg, #D6EAFF 0%, #ECF5FF 60%, #C2D4FF 100%)" },
      { brand: "Vaseline",  sub: "GLUTA-HYA SERIES",        emoji: "🧴", bg: "linear-gradient(135deg, #FFF3D6 0%, #FFFAEC 60%, #FFE8C2 100%)" }
    ]
  end

  def skin_concerns
    SkinConcern.all
  end

  def flash_products
    flagged_products(:flash, limit: 10)
      .map { |fp| product_card_payload(fp.product, fp) }
  end

  def bestseller_tabs
    [ "ทั้งหมด", "เซรั่ม", "ครีมบำรุงผิว", "กันแดด", "มอยส์เจอไรเซอร์" ]
  end

  def bestsellers
    flagged_products(:bestseller, limit: 10)
      .map { |fp| bestseller_payload(fp.product, fp) }
  end

  def essential_products
    Product
      .includes(images_attachments: :blob)
      .limit(4)
      .map { |product| product_card_payload(product) }
  end

  def flagged_products(flag_type, limit:)
    FlagProduct.for_home_section(flag_type, limit: limit)
  end

  def product_card_payload(product, flag_product = nil)
    original_price = money_to_baht(flag_product&.original_amount_cents)
    price = money_to_baht(product.amount_cents)

    {
      id: product.id,
      name: product.title,
      desc: product.description,
      price:,
      original_price:,
      discount_percent: discount_percent(price:, original_price:),
      image_url: product_image_url(product)
    }
  end

  def bestseller_payload(product, flag_product = nil)
    {
      brand: product.title,
      desc: product.description,
      price: money_to_baht(product.amount_cents),
      original_price: money_to_baht(flag_product&.original_amount_cents),
      image_url: product_image_url(product)
    }
  end

  def discount_percent(price:, original_price:)
    return nil if price.blank? || original_price.blank?
    return nil unless original_price.to_i.positive? && original_price.to_i > price.to_i

    (((original_price.to_f - price.to_f) / original_price.to_f) * 100).round
  end

  def money_to_baht(amount_cents)
    return nil if amount_cents.nil?

    (amount_cents.to_i / 100.0).round
  end

  def product_image_url(product)
    return nil unless product.images.attached?

    helpers.rails_blob_path(product.images.first, only_path: true)
  end
end
