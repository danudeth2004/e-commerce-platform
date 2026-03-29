import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["token", "form", "button", "shippingText", "totalText"]

  connect() {
    this.storeCount = parseInt(this.element.dataset.storeCount || 0)
    this.baseAmount = parseInt(this.element.dataset.amount || 0)

    this.waitForOmise()
    this.updateUI()
  }

  waitForOmise() {
    if (!window.Omise || !window.OmiseCard) {
      console.log("Omise not ready yet...");
      setTimeout(() => this.waitForOmise(), 300)
      return
    }

    console.log("Omise READY ✅")

    Omise.setPublicKey(this.publicKey)

    OmiseCard.configure({
      publicKey: this.publicKey,
      currency: "THB",
      frameLabel: "My Shop",
      submitLabel: "PAY NOW",
      buttonLabel: "Pay with Omise"
    })
  }

  get selectedShipping() {
    return document.querySelector('input[name="shipping_method"]:checked')?.value
  }

  get shippingCost() {
    if (this.selectedShipping === "express") {
      return this.storeCount * 10 * 100
    }
    return 0
  }

  get totalAmount() {
    return this.baseAmount + this.shippingCost
  }

  updateUI() {
    const shippingBaht = this.shippingCost / 100
    const totalBaht = this.totalAmount / 100

    if (this.hasShippingTextTarget) {
      this.shippingTextTarget.innerText = `฿ ${shippingBaht.toLocaleString()}`
    }

    if (this.hasTotalTextTarget) {
      this.totalTextTarget.innerText = `฿ ${totalBaht.toLocaleString()}`
    }
  }

  changeShipping() {
    this.updateUI()
  }

  pay() {


    const total = this.totalAmount

    OmiseCard.open({
      amount: total,

      onCreateTokenSuccess: (token) => {
        console.log("TOKEN:", token)

        this.tokenTarget.value = token

        const input = document.createElement("input")
        input.type = "hidden"
        input.name = "shipping_method"
        input.value = this.selectedShipping
        this.formTarget.appendChild(input)

        this.formTarget.submit()
      },

      onFormClosed: () => {
        console.log("Closed")
      }
    })
  }

  get publicKey() {
    return this.element.dataset.publicKey
  }
}