class HomeController < ApplicationController
  def index
    @banners            = banners
    @skin_concerns      = skin_concerns
    assign_flash_sale!
    @bestsellers        = bestsellers
    @bestseller_tabs    = bestseller_tabs
    @essential_products = essential_products
    @marketplace_has_products = base_products.exists?
    @hide_app_header = !@marketplace_has_products

    @show_payment_success_modal = flash[:payment_success] == true
    flash.delete(:payment_success)
  end

  def show
    @product = Product
                 .joins(:store)
                 .merge(Seller::Store.active)
                 .with_attached_images
                 .find(params[:id])

    @product_image       = @product
    @brand_section       = @product
    @product_description = @product
    @product_bottom_bar  = @product
  end

  def flash_sale
    assign_flash_sale!
    render layout: false
  end

  private

  def assign_flash_sale!
    @flash_sale_entries = build_flash_sale_entries
    @flash_products = @flash_sale_entries.map { |product, fp| product_card_payload(product, fp) }
    @flash_countdown_end_unix = flash_sale_countdown_end_unix(@flash_sale_entries.map(&:first))
  end

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

  def bestseller_tabs
    [ "ทั้งหมด", "เซรั่ม", "ครีมบำรุงผิว", "กันแดด", "มอยส์เจอไรเซอร์" ]
  end

  def essential_products
    base_products
      .limit(20)
      .map { |product| product_card_payload(product) }
  end

  # [[product, flag_product|nil], ...] — 1) FlagProduct flash 2) สินค้าลดราคาจริง
  def build_flash_sale_entries
    flagged = flagged_products(:flash, limit: 10)
    if flagged.any?
      return flagged.map { |fp| [ fp.product, fp ] }
    end

    time = Time.current
    out = []
    base_products.includes(:campaigns).find_each do |product|
      next unless product.final_price_cents(time) < product.amount_cents

      out << [ product, nil ]
      break if out.size >= 10
    end
    out
  end

  # เวลาสิ้นสุดที่ใกล้ที่สุดจากโปรสินค้า (promotion_ends_at) + แคมเปญที่เกี่ยวข้อง — ใช้นับถอยหลังจริง
  def flash_sale_countdown_end_unix(products)
    time = Time.zone.now
    return time.end_of_day.to_i if products.blank?

    candidates = []
    products.each do |p|
      next unless p.final_price_cents(time) < p.amount_cents

      candidates << p.promotion_ends_at if p.promotion_ends_at.present? && p.promotion_ends_at > time

      p.campaigns.active_at(time).each do |c|
        candidates << c.ends_at if c.ends_at > time
      end
    end

    earliest = candidates.compact.min
    earliest ? earliest.to_i : time.end_of_day.to_i
  end

  def bestsellers
    # flagged_products(:bestseller, limit: 10)
    #   .map { |fp| bestseller_payload(fp.product, fp) }
    Product
      .joins(order_items: :order)
      .joins(:store)
      .merge(Seller::Store.active)
      .where(orders: { status: "paid" })
      .group("products.id")
      .reorder(nil)
      .order(Arel.sql("SUM(order_items.quantity) DESC"))
      .limit(5)
      .with_attached_images
      .map { |product| bestseller_payload(product) }
  end

  def base_products
    Product
      .joins(:store)
      .merge(Seller::Store.active)
      .with_attached_images
  end

  def flagged_products(flag_type, limit:)
    FlagProduct
      .for_home_section(flag_type, limit: limit)
      .joins(product: :store)
      .merge(Seller::Store.active)
      .includes(product: { images_attachments: :blob })
  end

  def product_card_payload(product, flag_product = nil)
    helpers.product_to_card_hash(product, flag_product: flag_product)
  end

  def bestseller_payload(product, flag_product = nil)
    h = helpers.product_to_card_hash(product, flag_product: flag_product)
    {
      brand: h[:name],
      desc: h[:desc],
      price: h[:price],
      original_price: h[:original_price],
      image_url: h[:image_url]
    }
  end

end