import { Controller } from "@hotwired/stimulus"

export default class BackNavController extends Controller {
  static values = { fallback: String }

  go(event) {
    event.preventDefault()
    if (this.fallbackValue) {
      globalThis.location.assign(this.fallbackValue)
    }
  }
}
