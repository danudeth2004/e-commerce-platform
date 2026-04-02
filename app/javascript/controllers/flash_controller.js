// app/javascript/controllers/flash_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: Number }

  connect() {
    const t = this.timeoutValue || 5000

    this.timeout = setTimeout(() => {
      this.dismiss()
    }, t)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.add("transition-opacity", "duration-500", "opacity-0")
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}
