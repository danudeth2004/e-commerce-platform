import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["password", "confirmation"]

  connect() {
    // เรียก validate ทุกครั้งที่ user พิมพ์
    this.passwordTarget.addEventListener("input", () => this.validate())
    this.confirmationTarget.addEventListener("input", () => this.validate())
  }

  validate() {
    const password = this.passwordTarget.value
    const confirmation = this.confirmationTarget.value

    if (confirmation && password !== confirmation) {
      this.confirmationTarget.setCustomValidity("Please make sure the passwords match")
    } else {
      this.confirmationTarget.setCustomValidity("")
    }
  }
}