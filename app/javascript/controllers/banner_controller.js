import { Controller } from "@hotwired/stimulus"

export default class BannerController extends Controller {
  static values = { index: Number }

  connect() {
    this.banners = globalThis.BANNERS || []
    if (this.banners.length > 1) {
      this.timer = setInterval(() => this.next(), 3500)
    }
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  go(event) {
    this.indexValue = Number.parseInt(event.currentTarget.dataset.index, 10)
    this.render()
  }

  next() {
    if (this.banners.length <= 1) return
    this.indexValue = (this.indexValue + 1) % this.banners.length
    this.render()
  }

  render() {
    const b = this.banners[this.indexValue]
    if (!b) return

    const img = document.getElementById("bannerImage")
    if (b.image_url && img) {
      img.src = b.image_url
    }

    document.querySelectorAll(".dot").forEach((dot, i) => {
      if (i === this.indexValue) {
        dot.style.width = "16px"
        dot.style.background = "#FF6B9D"
      } else {
        dot.style.width = "6px"
        dot.style.background = "#FBCFE8"
      }
    })
  }
}
