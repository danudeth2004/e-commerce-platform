import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this)
  }

  toggle(event) {
    event.stopPropagation()
    this.panelTarget.classList.toggle("hidden")

    if (!this.panelTarget.classList.contains("hidden")) {
      document.addEventListener("click", this.handleClickOutside)
    } else {
      document.removeEventListener("click", this.handleClickOutside)
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.panelTarget.classList.add("hidden")
      document.removeEventListener("click", this.handleClickOutside)
    }
  }
}