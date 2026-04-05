class HomeController < BaseController
  skip_before_action :destroy_seller_user_session!, only: %i[show]
  def index
    @banners            = marketplace_banner_payload
    @home_has_banners   = @banners.any?
    @skin_concerns      = skin_concerns
    assign_flash_sale!
    @bestsellers        = bestsellers
    @bestseller_tabs    = bestseller_tabs
    @essential_products = essential_products
    @marketplace_has_products = base_products.exists?

    unless @marketplace_has_products
      @hide_app_header = true
      @hide_buyer_bottom_nav = true
    end

    @show_payment_success_modal = flash[:payment_success] == true
    flash.delete(:payment_success)
  end

  def show
    if params[:seller_preview].present?
      @product = current_seller_user.store.products.find(params[:id])
    else
      @product = Product
                   .joins(:store)
                   .merge(Seller::Store.active)
                   .with_attached_images
                   .includes(:store, bundle_items: { component_product: { images_attachments: :blob } })
                   .find(params[:id])
    end

    @product_image       = @product
    @product_description = @product
    @product_bottom_bar  = @product

    if request.referer.blank?
      @app_back_fallback = products_path
    end

    @hide_app_header = true unless show_seller_product_page?

    if show_seller_product_page?
      render :show_seller, layout: "seller"
      nil
    end
  end

  def flash_sale
    assign_flash_sale!
    render layout: false
  end

  private

  # หน้ารายละเอียดสินค้าแบบผู้ขาย (layout seller, ไม่มีตะกร้า) — เฉพาะเมื่อล็อกอิน seller
  def show_seller_product_page?
    return false unless seller_user_signed_in?

    params[:seller_preview].to_s == "1" || !user_signed_in?
  end

  def assign_flash_sale!
    @flash_sale_entries = build_flash_sale_entries
    @flash_products = @flash_sale_entries.map { |product, fp| product_card_payload(product, fp) }
    @flash_countdown_end_unix = flash_sale_countdown_end_unix(@flash_sale_entries.map(&:first))
  end

  # รูปแบนเนอร์จากแคมเปญที่ยังไม่จบ (รวมแคมเปญที่ยังไม่ถึงวันเริ่ม — รูปที่อัปโหลดจะขึ้นตำแหน่งแบนเนอร์ได้)
  # เรียงแคมเปญที่เริ่มล่าสุดก่อน แล้วต่อด้วยรูปในแต่ละแคมเปญ
  def marketplace_banner_payload
    time = Time.current
    Campaign
      .where("ends_at >= ?", time)
      .with_attached_banners
      .order(starts_at: :desc)
      .flat_map do |campaign|
        next [] unless campaign.banners.attached?

        campaign.banners.map { |attachment| { image_url: helpers.url_for(attachment) } }
      end
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
      .to_a
  end

  # [[product, flag_product|nil], ...] — 1) FlagProduct flash 2) เซตที่ลดราคา 3) สินค้าชิ้นเดียวที่ลด (โปรร้าน+แคมเปญ)
  def build_flash_sale_entries
    time = Time.current
    out = []
    seen = []

    flagged_products(:flash, limit: 10).each do |fp|
      out << [ fp.product, fp ]
      seen << fp.product_id
    end

    if out.size < 10
      base_products
        .where(kind: :bundle)
        .includes(bundle_items: { component_product: { images_attachments: :blob, campaign_products: :campaign } })
        .reorder(:id)
        .find_each do |product|
          next if seen.include?(product.id)
          next unless product.bundle_discount_active?(time)

          out << [ product, nil ]
          seen << product.id
          break if out.size >= 10
        end
    end

    if out.size < 10
      base_products
        .where(kind: :standard)
        .includes(:campaigns)
        .reorder(:id)
        .find_each do |product|
          next if seen.include?(product.id)
          next unless product.final_price_cents(time) < product.amount_cents

          out << [ product, nil ]
          seen << product.id
          break if out.size >= 10
        end
    end

    out
  end

  # เวลาสิ้นสุดที่ใกล้ที่สุดจากโปรสินค้า (promotion_ends_at) + แคมเปญที่เกี่ยวข้อง — ใช้นับถอยหลังจริง
  def flash_sale_countdown_end_unix(products)
    time = Time.zone.now
    return time.end_of_day.to_i if products.blank?

    candidates = []
    products.each do |p|
      next unless p.bundle? ? p.bundle_discount_active?(time) : p.final_price_cents(time) < p.amount_cents

      candidates << p.promotion_ends_at if p.promotion_ends_at.present? && p.promotion_ends_at > time

      next if p.bundle?

      p.campaigns.active_at(time).each do |c|
        candidates << c.ends_at if c.ends_at > time
      end
    end

    earliest = candidates.compact.min
    raw = earliest ? earliest.to_i : time.end_of_day.to_i
    helpers.countdown_end_unix_seconds(raw)
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
      .includes(bundle_items: { component_product: { images_attachments: :blob } })
      .map { |product| bestseller_payload(product) }
  end

  def base_products
    Product
      .joins(:store)
      .merge(Seller::Store.active)
      .with_attached_images
      .includes(bundle_items: { component_product: { images_attachments: :blob } })
  end

  def flagged_products(flag_type, limit:)
    FlagProduct
      .for_home_section(flag_type, limit: limit)
      .joins(product: :store)
      .merge(Seller::Store.active)
      .includes(product: { images_attachments: :blob, bundle_items: { component_product: { images_attachments: :blob } } })
  end

  def product_card_payload(product, flag_product = nil)
    helpers.product_to_card_hash(product, flag_product: flag_product)
  end

  def bestseller_payload(product, flag_product = nil)
    h = helpers.product_to_card_hash(product, flag_product: flag_product)
    {
      id: h[:id],
      brand: h[:name],
      desc: h[:desc],
      price: h[:price],
      original_price: h[:original_price],
      image_url: h[:image_url]
    }
  end
end
