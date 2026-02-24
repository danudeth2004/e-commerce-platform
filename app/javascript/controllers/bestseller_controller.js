import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  setTab(event) {

    this.element.querySelectorAll(".tab-btn").forEach(btn => {
      btn.style.background  = "white"
      btn.style.color       = "#9CA3AF"
      btn.style.boxShadow   = "none"
    })

    const btn = event.currentTarget
    btn.style.background  = "#FF1493"
    btn.style.color       = "white"
    btn.style.boxShadow   = "0 4px 12px rgba(255,107,157,0.35)"

    this.dispatch("tabChanged", { detail: { tab: btn.dataset.tab } })
  }
}