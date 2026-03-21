import { Controller } from "@hotwired/stimulus"

export default class CharacterCountController extends Controller {
  static targets = ["field", "count", "message"]
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    const field = this.fieldTarget
    const max = this.maxValue
    const len = field.value.length
    const over = len > max

    this.countTarget.textContent = `${len}/${max}`

    const msg = over ? `เกินจำนวนตัวอักษรสูงสุด ${max} ตัว` : ""
    field.setCustomValidity(msg)

    this.countTarget.classList.toggle("text-text-accents-red", over)
    this.countTarget.classList.toggle("text-text-neutral-300", !over)

    field.setAttribute("aria-invalid", over ? "true" : "false")

    if (this.hasMessageTarget) {
      this.messageTarget.textContent = msg
      this.messageTarget.classList.toggle("hidden", !over)
    }
  }
}
