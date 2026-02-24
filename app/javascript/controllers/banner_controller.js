import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { index: Number }

  connect() {
    this.banners = window.BANNERS || []
    this.timer = setInterval(() => this.next(), 3500)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  go(event) {
    this.indexValue = parseInt(event.currentTarget.dataset.index)
    this.render()
  }

  next() {
    this.indexValue = (this.indexValue + 1) % this.banners.length
    this.render()
  }

  render() {
    const b = this.banners[this.indexValue]
    if (!b) return

    document.getElementById("bannerCard").style.background = b.bg
    document.getElementById("bannerBrand").textContent = b.brand
    document.getElementById("bannerSub").textContent = b.sub
    document.getElementById("bannerEmoji").textContent = b.emoji

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