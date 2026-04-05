# frozen_string_literal: true

module ProductDisplayHelper
  def product_to_card_hash(product, flag_product: nil, time: Time.current)
    return bundle_product_to_card_hash(product, flag_product: flag_product, time: time) if product.bundle?

    final_cents = product.final_price_cents(time)
    list_cents = product.amount_cents
    final_baht = (final_cents / 100.0).round
    list_baht = (list_cents / 100.0).round
    orig_flag_baht = flag_product&.original_amount_cents ? (flag_product.original_amount_cents / 100.0).round : nil

    strike_baht =
      if final_cents < list_cents
        list_baht
      elsif orig_flag_baht && orig_flag_baht > final_baht
        orig_flag_baht
      end

    discount_pct =
      if strike_baht && strike_baht > final_baht
        (((strike_baht - final_baht).to_f / strike_baht) * 100).round
      end

    {
      id: product.id,
      name: product.title,
      desc: product.description,
      price: final_baht,
      original_price: strike_baht,
      discount_percent: discount_pct,
      image_url: product.images.attached? ? rails_blob_path(product.images.first, only_path: true) : nil
    }
  end

  # เซตสินค้า: ราคาขีดฆ่า = รวมราคาขายจริงของทุกชิ้นในชุด (เมื่อราคาเซตถูกกว่า)
  def bundle_product_to_card_hash(product, flag_product: nil, time: Time.current)
    items = product.bundle_items.includes(component_product: { images_attachments: :blob })
    count = items.size
    thumb_urls = items.map { |i| component_product_first_image_url(i.component_product) }.first(3)
    overflow = count > 3 ? count - 3 : 0

    sum_cents = items.sum { |i| i.component_product.final_price_cents(time) }
    final_cents = product.final_price_cents(time)
    list_cents = product.amount_cents
    final_baht = (final_cents / 100.0).round
    sum_baht = (sum_cents / 100.0).round
    list_baht = (list_cents / 100.0).round
    orig_flag_baht = flag_product&.original_amount_cents ? (flag_product.original_amount_cents / 100.0).round : nil

    strike_baht =
      if final_baht < sum_baht
        sum_baht
      elsif final_cents < list_cents
        list_baht
      elsif orig_flag_baht && orig_flag_baht > final_baht
        orig_flag_baht
      end

    discount_pct =
      if strike_baht && strike_baht > final_baht
        (((strike_baht - final_baht).to_f / strike_baht) * 100).round
      end

    cover_url =
      if product.images.attached?
        rails_blob_path(product.images.first, only_path: true)
      else
        thumb_urls.compact.first
      end

    {
      id: product.id,
      name: product.title,
      desc: product.description,
      price: final_baht,
      original_price: strike_baht,
      discount_percent: discount_pct,
      image_url: cover_url,
      bundle: true,
      bundle_thumb_urls: thumb_urls,
      bundle_overflow_count: overflow,
      bundle_item_count: count,
      skin_concern_labels: product.skin_concern_labels[0..1],
      skin_concern_labels_count: product.skin_concern_labels.size - 2
    }
  end

  def product_detail_price_parts(product, time: Time.current)
    final_cents = product.final_price_cents(time)
    list_cents = product.amount_cents
    final_baht = (final_cents / 100.0).round
    list_baht = (list_cents / 100.0).round
    flash_flag = product.flag_products.flash.first
    orig_fp = flash_flag&.original_amount_cents ? (flash_flag.original_amount_cents / 100.0).round : nil

    strike =
      if final_cents < list_cents
        list_baht
      elsif orig_fp && orig_fp > final_baht
        orig_fp
      end

    discount_pct =
      if strike && strike > final_baht
        (((strike - final_baht).to_f / strike) * 100).round
      end

    { price: final_baht, original: strike, discount_percent: discount_pct }
  end

  def component_product_first_image_url(component_product)
    return nil unless component_product&.images&.attached?

    rails_blob_path(component_product.images.first, only_path: true)
  end

  # รูปในหน้า PDP — เซต: รวมรูปที่แนบกับเซต + รูปแรกของแต่ละชิ้นในชุด (ไม่ซ้ำ blob)
  def product_detail_gallery_image_urls(product)
    urls = []
    seen_blob_ids = []

    if product.images.attached?
      product.images.each do |img|
        append_unique_gallery_attachment!(urls, seen_blob_ids, img)
      end
    end

    if product.bundle?
      product.bundle_items.each do |item|
        cp = item.component_product
        next unless cp&.images&.attached?

        append_unique_gallery_attachment!(urls, seen_blob_ids, cp.images.first)
      end
    end

    return [ product_detail_placeholder_image_url(product) ] if urls.empty?

    urls
  end

  private

  def product_detail_placeholder_image_url(product)
    "https://via.placeholder.com/300x300.png?text=#{ERB::Util.url_encode(product.title)}"
  end

  def append_unique_gallery_attachment!(urls, seen_blob_ids, attachment)
    return if attachment.blank?

    bid = attachment.blob_id
    return if seen_blob_ids.include?(bid)

    seen_blob_ids << bid
    urls << rails_blob_path(attachment, only_path: true)
  end
end
