// app/javascript/controllers/flash_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: Number }

  connect() {
    const t = this.timeoutValue || 5000
    requestAnimationFrame(() => {
      this.element.classList.add("transition-all", "duration-300", "ease-out")
      requestAnimationFrame(() => {
        this.element.classList.remove("opacity-0", "-translate-y-full")
      })
    })
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, t)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    const el = this.element
    el.classList.add("-translate-y-full", "opacity-0")
    setTimeout(() => {
      el.remove()
    }, 320)
  }
}
