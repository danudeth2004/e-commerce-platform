import { Controller } from "@hotwired/stimulus"

export default class QuantityController extends Controller {
  static targets = ["count", "input", "submit"]

  connect() {
    // เริ่มทุกครั้งที่เปิดหน้าให้เป็น 0 เสมอ (ไม่ใช้ค่าจาก DOM ที่อาจ cache ไว้)
    this.value = 0
    this.render()
  }

  increase() {
    this.value++
    this.render()
  }

  decrease() {
    if (this.value > 0) {
      this.value--
      this.render()
    }
  }

  render() {
    if (this.countTarget) {
      this.countTarget.textContent = this.value
    }
    if (this.inputTarget) {
      this.inputTarget.value = this.value
    }
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = this.value === 0
      this.submitTarget.classList.toggle("opacity-50", this.value === 0)
      this.submitTarget.classList.toggle("cursor-not-allowed", this.value === 0)
    }
  }
}