# frozen_string_literal: true

module AdminHelper
  def admin_nav_item_classes(active)
    base = "flex items-center gap-3 px-4 py-3 rounded-lg transition"
    if active
      "#{base} bg-blue-600 text-white"
    else
      "#{base} text-slate-300 hover:bg-slate-800"
    end
  end
end
