import { Controller } from "@hotwired/stimulus"

export default class RegistrationWizardController extends Controller {
  static targets = ["step1", "step2", "step1Header", "step2Header", "progress"]
  static values = { initialStep: { type: Number, default: 1 } }

  connect() {
    if (this.initialStepValue === 2) {
      this.showStep2(false)
    } else {
      this.showStep1(false)
    }
  }

  handleSubmit(event) {
    if (!this.step1Target.classList.contains("hidden")) {
      event.preventDefault()
      event.stopImmediatePropagation()
      if (!this.validateStep1()) return
      this.showStep2(true)
    }
  }

  next(event) {
    event.preventDefault()
    if (!this.validateStep1()) return
    this.showStep2(true)
  }

  back(event) {
    event.preventDefault()
    this.showStep1(true)
  }

  validateStep1() {
    const fields = this.step1Target.querySelectorAll("input, select, textarea")
    for (const el of fields) {
      if (el.closest("[hidden]")) continue
      if (typeof el.reportValidity === "function" && !el.checkValidity()) {
        el.reportValidity()
        return false
      }
    }
    return true
  }

  showStep1(focusFirst) {
    this.step1Target.classList.remove("hidden")
    this.step2Target.classList.add("hidden")
    if (this.hasStep1HeaderTarget) this.step1HeaderTarget.classList.remove("hidden")
    if (this.hasStep2HeaderTarget) this.step2HeaderTarget.classList.add("hidden")
    if (this.hasProgressTarget) this.progressTarget.textContent = "ขั้นตอนที่ 1 จาก 2"
    if (focusFirst) {
      const first = this.step1Target.querySelector("input:not([type=hidden])")
      first?.focus()
    }
  }

  showStep2(focusFirst) {
    this.step1Target.classList.add("hidden")
    this.step2Target.classList.remove("hidden")
    if (this.hasStep1HeaderTarget) this.step1HeaderTarget.classList.add("hidden")
    if (this.hasStep2HeaderTarget) this.step2HeaderTarget.classList.remove("hidden")
    if (this.hasProgressTarget) this.progressTarget.textContent = "ขั้นตอนที่ 2 จาก 2"
    if (focusFirst) {
      const first = this.step2Target.querySelector("input:not([type=hidden]), select, textarea")
      first?.focus()
    }
  }
}
