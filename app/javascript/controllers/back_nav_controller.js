import { Controller } from "@hotwired/stimulus"

export default class BackNavController extends Controller {
  static values = { fallback: String }

  go(event) {
    event.preventDefault()
    if (globalThis.history.length > 1) {
      globalThis.history.back()
    } else {
      globalThis.location.assign(this.fallbackValue)
    }
  }
}
