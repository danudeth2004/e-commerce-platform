import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["token", "form", "button", "shippingText", "totalText", "couponDiscountText"]

  connect() {
    this.total = parseInt(this.element.dataset.amount || 0)

    this.storeCount = parseInt(this.element.dataset.storeCount || 0)

    this.couponPercent = 0
    this.eligibleAmount = 0
    this.selectedCoupon = null
    this.couponProductIds = ""

    this.waitForOmise()
    this.updateUI()
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

  changeShipping() {
    this.updateUI()
  }

  toggleCoupon(event) {
    const clicked = event.currentTarget

    if (this.selectedCoupon === clicked) {
      clicked.checked = false
      this.selectedCoupon = null

      this.resetCoupon()
    } else {
      this.selectedCoupon = clicked
      this.applyCoupon(event)
    }

    this.updateUI()
  }

  resetCoupon() {
    this.couponPercent = 0
    this.eligibleAmount = 0
    this.couponProductIds = ""

    this.updateUI() 
  }

  applyCoupon(event) {
    const el = event.currentTarget
    this.couponPercent = parseInt(el.dataset.discount || 0)
    this.eligibleAmount = parseInt(el.dataset.eligible || 0)
    this.couponProductIds = el.dataset.products || ""
    this.updateUI()
  }

  get couponDiscountAmount() {
    return Math.floor(this.eligibleAmount * this.couponPercent / 100)
  }

  get finalTotal() {
    return this.total - this.couponDiscountAmount + this.shippingCost
  }

  updateUI() {
    const shipping = this.shippingCost / 100
    const discount = this.couponDiscountAmount / 100
    const total = this.finalTotal / 100

    if (this.hasShippingTextTarget) {
      this.shippingTextTarget.innerText = `${shipping.toLocaleString()} ฿`
    }

    if (this.hasCouponDiscountTextTarget) {
      const discountBht = discount;
      this.couponDiscountTextTarget.innerText = `- ${discountBht.toLocaleString('th-TH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} ฿`;
    }

    if (this.hasTotalTextTarget) {
      this.totalTextTarget.innerText = `${total.toLocaleString()} ฿`
    }
  }

  pay() {
    const total = this.finalTotal

    OmiseCard.open({
      amount: total,

      onCreateTokenSuccess: (token) => {
        this.tokenTarget.value = token

        const shippingInput = document.createElement("input")
        shippingInput.type = "hidden"
        shippingInput.name = "shipping_method"
        shippingInput.value = this.selectedShipping
        this.formTarget.appendChild(shippingInput)

        const selectedCoupon = document.querySelector('input[name="coupon_id"]:checked')
        if (selectedCoupon) {
          const couponInput = document.createElement("input")
          couponInput.type = "hidden"
          couponInput.name = "coupon_id"
          couponInput.value = selectedCoupon.value
          this.formTarget.appendChild(couponInput)

          const productInput = document.createElement("input")
          productInput.type = "hidden"
          productInput.name = "coupon_product_ids"
          productInput.value = this.couponProductIds
          this.formTarget.appendChild(productInput)
        }

        this.formTarget.submit()
      }
    })
  }

  waitForOmise() {
    if (!window.Omise || !window.OmiseCard) {
      setTimeout(() => this.waitForOmise(), 300)
      return
    }

    Omise.setPublicKey(this.publicKey)

    OmiseCard.configure({
      publicKey: this.publicKey,
      currency: "THB"
    })
  }

  get publicKey() {
    return this.element.dataset.publicKey
  }
}
