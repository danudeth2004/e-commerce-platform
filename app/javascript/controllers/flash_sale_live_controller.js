import { Controller } from "@hotwired/stimulus"

// เมื่อ countdown ในโซน flash sale ถึง 0 โหลด /home/flash_sale แทน frame — อัปเดตรายการ/ซ่อนโซนแบบ realtime
export default class extends Controller {
  static values = { refreshUrl: String }

  refresh() {
    if (!this.refreshUrlValue) return
    this.element.src = `${this.refreshUrlValue}?t=${Date.now()}`
  }
}
