# frozen_string_literal: true

module ProductDisplayHelper
  def product_to_card_hash(product, flag_product: nil, time: Time.current)
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
end
