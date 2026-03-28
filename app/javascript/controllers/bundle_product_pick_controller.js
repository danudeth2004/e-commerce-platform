import { Controller } from "@hotwired/stimulus"

export default class BundleProductPickController extends Controller {
  static targets = ["hiddenContainer", "sumDisplay", "row", "usage", "customBlock"]
  static values = {
    prices: Object,
    initialOrder: { type: Array, default: [] }
  }

  connect() {
    if (Array.isArray(this.initialOrderValue) && this.initialOrderValue.length > 0) {
      this.order = this.initialOrderValue
        .map((x) => Number.parseInt(String(x), 10))
        .filter((n) => !Number.isNaN(n))
    } else {
      this.order = []
    }
    this.sync()
  }

  toggle(event) {
    event.preventDefault()
    const id = Number.parseInt(event.currentTarget.dataset.productId, 10)
    const ix = this.order.indexOf(id)
    if (ix >= 0) {
      this.order.splice(ix, 1)
    } else {
      this.order.push(id)
    }
    this.sync()
  }

  sync() {
    if (this.hasHiddenContainerTarget) {
      this.hiddenContainerTarget.innerHTML = ""
      this.order.forEach((pid) => {
        const inp = document.createElement("input")
        inp.type = "hidden"
        inp.name = "product_bundle[bundle_ordered_ids][]"
        inp.value = String(pid)
        this.hiddenContainerTarget.appendChild(inp)
      })
    }

    let cents = 0
    this.order.forEach((pid) => {
      const key = String(pid)
      const p = this.pricesValue[key] ?? this.pricesValue[pid]
      cents += Number(p) || 0
    })

    if (this.hasSumDisplayTarget) {
      const baht = Math.round(cents / 100)
      this.sumDisplayTarget.textContent = `฿ ${baht.toLocaleString("th-TH")}`
    }

    this.rowTargets.forEach((row) => {
      const pid = Number.parseInt(row.dataset.productId, 10)
      const pos = this.order.indexOf(pid)
      const badge = row.querySelector("[data-bundle-role='badge']")
      const empty = row.querySelector("[data-bundle-role='empty']")

      if (pos >= 0) {
        row.classList.add("ring-2", "ring-[#FF1493]", "border-[#FF1493]/40")
        if (badge) {
          badge.textContent = String(pos + 1)
          badge.classList.remove("hidden")
        }
        if (empty) empty.classList.add("hidden")
      } else {
        row.classList.remove("ring-2", "ring-[#FF1493]", "border-[#FF1493]/40")
        if (badge) badge.classList.add("hidden")
        if (empty) empty.classList.remove("hidden")
      }
    })

    this.usageTargets.forEach((el) => {
      const pid = Number.parseInt(el.dataset.productId, 10)
      const pos = this.order.indexOf(pid)
      const on = pos >= 0
      el.classList.toggle("hidden", !on)
      const idxEl = el.querySelector("[data-bundle-role='usage-index']")
      if (idxEl) {
        idxEl.textContent = on ? String(pos + 1) : ""
      }
    })

    this.updateCustomVisibility()
  }

  pricingModeChanged() {
    this.updateCustomVisibility()
  }

  updateCustomVisibility() {
    // คอนโทรลเลอร์อยู่ที่ div ห่อ form — ใช้ querySelector ไม่ใช่ closest("form")
    const form = this.element.querySelector("form")
    if (!form || !this.hasCustomBlockTarget) return

    const mode = form.querySelector("input[name='product_bundle[pricing_mode]']:checked")?.value
    const showCustom = mode === "custom"
    this.customBlockTarget.classList.toggle("hidden", !showCustom)
  }
}
