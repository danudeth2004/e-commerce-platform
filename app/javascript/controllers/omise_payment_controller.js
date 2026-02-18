import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["token", "form", "button"]

  connect() {
    this.waitForOmise()
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

  pay() {
    console.log("Opening OmiseCard...")

    OmiseCard.open({
      amount: this.amount,

      onCreateTokenSuccess: (token) => {
        console.log("TOKEN:", token)

        this.tokenTarget.value = token
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

  get amount() {
    return parseInt(this.element.dataset.amount)
  }
}