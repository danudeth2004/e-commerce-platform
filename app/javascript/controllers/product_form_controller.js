import { Controller } from "@hotwired/stimulus"

export default class ProductFormController extends Controller {
  static targets = ["form", "stepOne", "stepTwo", "confirmModal"]
  static values = { backUrl: String }

  showStepTwo() {
    this.stepOneTarget.classList.add("hidden")
    this.stepTwoTarget.classList.remove("hidden")
  }

  showStepOne() {
    this.stepTwoTarget.classList.add("hidden")
    this.stepOneTarget.classList.remove("hidden")
  }

  back(event) {
    event.preventDefault()

    if (this.stepTwoTarget && !this.stepTwoTarget.classList.contains("hidden")) {
      this.showStepOne()
      return
    }

    if (this.hasBackUrlValue && this.backUrlValue) {
      globalThis.location.href = this.backUrlValue
      return
    }

    globalThis.history.back()
  }

  openConfirm() {
    this.confirmModalTarget.classList.remove("hidden")
  }

  closeConfirm() {
    this.confirmModalTarget.classList.add("hidden")
  }

  submit(event) {
    event.preventDefault()
    this.formTarget.requestSubmit()
  }
}

