# frozen_string_literal: true

module AdminHelper
  def admin_format_thb(cents)
    c = cents.to_i
    return "฿0.00" if c.zero?

    number_to_currency(c / 100.0, unit: "฿", precision: 2, separator: ".", delimiter: ",")
  end

  def admin_store_status_options
    [
      [ "ใช้งาน", "active" ],
      [ "ไม่แสดงในหน้าลูกค้า", "inactive" ],
      [ "ระงับร้าน", "suspended" ]
    ]
  end

  def admin_store_status_label(store)
    case store.status
    when "active" then "ใช้งาน"
    when "inactive" then "ไม่แสดงหน้าลูกค้า"
    when "suspended" then "ระงับ"
    else store.status.to_s
    end
  end

  def admin_nav_item_classes(active)
    base = "flex items-center gap-3 px-4 py-3 rounded-lg transition"
    if active
      "#{base} bg-blue-600 text-white"
    else
      "#{base} text-slate-300 hover:bg-slate-800"
    end
  end
end
