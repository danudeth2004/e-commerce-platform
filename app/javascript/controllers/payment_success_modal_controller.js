import { Controller } from "@hotwired/stimulus"

export default class PaymentSuccessModalController extends Controller {
  connect() {
    document.body.classList.add("overflow-hidden")
  }

  disconnect() {
    document.body.classList.remove("overflow-hidden")
  }

  close() {
    this.element.remove()
  }
}
