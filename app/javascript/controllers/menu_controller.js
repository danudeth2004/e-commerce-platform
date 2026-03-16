import { Controller } from "@hotwired/stimulus"

export default class MenuController extends Controller {
  static targets = ["panel"]

  toggle() {
    this.panelTarget.classList.toggle("hidden")
  }
}

