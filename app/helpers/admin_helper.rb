# frozen_string_literal: true

module AdminHelper
  # แสดง error ใต้ช่อง input แบบฟอร์มทั่วไป
  def admin_field_error?(record, attr)
    record.errors[attr].present?
  end

  def admin_field_error(record, attr)
    msgs = record.errors[attr]
    return if msgs.blank?

    content_tag(:p, msgs.join(" "), class: "mt-1 text-sm text-red-600", role: "alert")
  end

  def admin_field_input_classes(record, attr, extra_classes = "")
    base = "w-full rounded-lg px-3 py-2 text-sm #{extra_classes}".strip
    if admin_field_error?(record, attr)
      "#{base} border border-red-500 bg-red-50/40 text-gray-900 focus:border-red-600 focus:outline-none focus:ring-1 focus:ring-red-500"
    else
      "#{base} border border-gray-300 focus:border-gray-400 focus:outline-none focus:ring-1 focus:ring-gray-300"
    end
  end

  def admin_file_field_classes(record, attr)
    base = "block w-full text-sm text-gray-600 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
    if admin_field_error?(record, attr)
      "#{base} rounded-lg border border-red-500 bg-red-50/30 p-2"
    else
      "#{base} rounded-lg border border-gray-300 px-3 py-2"
    end
  end

  def admin_collection_select_classes(record, attr)
    base = "w-full rounded-lg px-3 py-2 text-sm font-sans"
    if admin_field_error?(record, attr)
      "#{base} border border-red-500 bg-red-50/40 focus:border-red-600 focus:outline-none focus:ring-1 focus:ring-red-500"
    else
      "#{base} border border-gray-300 focus:border-gray-400 focus:outline-none focus:ring-1 focus:ring-gray-300"
    end
  end

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
