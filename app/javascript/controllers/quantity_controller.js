import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count"]

  connect() {
    this.value = 0
  }

  increase() {
    this.value++
    this.countTarget.textContent = this.value
  }

  decrease() {
    if (this.value > 0) {
      this.value--
      this.countTarget.textContent = this.value
    }
  }
}