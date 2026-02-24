import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["addBtn"]

  addToCart(event) {
    event.stopPropagation()

    const btn       = this.addBtnTarget
    const productId = this.element.dataset.productId

    btn.textContent       = "✓"
    btn.style.background  = "#22C55E"
    btn.disabled          = true

    fetch("/cart/items", {
      method:  "POST",
      headers: {
        "Content-Type":  "application/json",
        "X-CSRF-Token":  document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ product_id: productId, quantity: 1 })
    })
    .then(res => {
      if (!res.ok) throw new Error("Failed")
      this.dispatch("added", { detail: { productId } })
    })
    .catch(() => {
      btn.textContent      = "+"
      btn.style.background = "#FF6B9D"
    })
    .finally(() => {
      setTimeout(() => {
        btn.textContent      = "+"
        btn.style.background = "#FF6B9D"
        btn.disabled         = false
      }, 1200)
    })
  }
}