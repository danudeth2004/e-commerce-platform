import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hours", "minutes", "seconds"]
  static values  = { end: Number }

  connect() {
    this.completeDispatched = false
    this.tick()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const now = new Date()

    const midnight = new Date()
    midnight.setHours(24, 0, 0, 0)

    const remaining = Math.max(Math.floor((midnight - now) / 1000), 0)

    const h = Math.floor(remaining / 3600)
    const m = Math.floor((remaining % 3600) / 60)
    const s = remaining % 60

    this.hoursTarget.textContent   = String(h).padStart(2, "0")
    this.minutesTarget.textContent = String(m).padStart(2, "0")
    this.secondsTarget.textContent = String(s).padStart(2, "0")

    if (remaining === 0) {
      clearInterval(this.timer)
      if (!this.completeDispatched) {
        this.completeDispatched = true
        this.dispatch("complete", { bubbles: true })
      }
    }
  }
}