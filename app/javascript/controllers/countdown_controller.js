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
    let endSec = Number(this.endValue)
    if (Number.isNaN(endSec)) endSec = 0
    // วินาทีปกติ ~1.7e9 (10 หลัก); มิลลิวินาที ~1.7e12 (13 หลัก) — ถ้าเข้าใจผิดหน่วยจะได้ชั่วโมงเป็นหลายล้าน
    if (endSec > 1_000_000_000_000) endSec = Math.floor(endSec / 1000)

    const now = Math.floor(Date.now() / 1000)
    const remaining = Math.max(endSec - now, 0)

    const h = Math.floor(remaining / 3600)
    const m = Math.floor((remaining % 3600) / 60)
    const s = remaining % 60

    this.hoursTarget.textContent   = h < 100 ? String(h).padStart(2, "0") : String(h)
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