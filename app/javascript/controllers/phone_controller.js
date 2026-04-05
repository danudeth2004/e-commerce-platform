import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error"]

  format() {
    this.inputTarget.value = this.inputTarget.value.replace(/[^0-9]/g, "")
    this.validate()
  }

  validate() {
    const value = this.inputTarget.value
    const isValid = /^0\d{9}$/.test(value)

    if (!isValid) {
      this.showError("เบอร์ต้องขึ้นต้นด้วย 0 และมี 10 หลัก")
      return false
    } else {
      this.clearError()
      return true
    }
  }

  submit(event) {
    const isValid = this.validate()

    if (!isValid) {
      event.preventDefault() // 🚫 กัน submit
      this.inputTarget.focus()
    }
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
    this.inputTarget.classList.add("border-red-500")
  }

  clearError() {
    this.errorTarget.textContent = ""
    this.errorTarget.classList.add("hidden")
    this.inputTarget.classList.remove("border-red-500")
  }
}
