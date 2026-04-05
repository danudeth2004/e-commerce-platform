import { Controller } from "@hotwired/stimulus"

const ALLOWED_TYPES = new Set(["image/jpeg", "image/png"])

export default class StoreImageUploadController extends Controller {
  static targets = ["input", "preview", "empty", "nameLabel", "error"]
  static values = {
    maxBytes: { type: Number, default: 10485760 },
    existingUrl: { type: String, default: "" },
  }

  connect() {
    this.previewObjectUrl = null
    if (this.existingUrlValue) {
      this.previewTarget.src = this.existingUrlValue
      this.previewTarget.classList.remove("hidden")
      this.emptyTarget.classList.add("hidden")
    }
  }

  disconnect() {
    if (this.previewObjectUrl) {
      URL.revokeObjectURL(this.previewObjectUrl)
    }
  }

  open(event) {
    event.preventDefault()
    this.inputTarget.click()
  }

  picked(event) {
    const file = event.target.files?.[0]
    if (!file) return

    const err = this.validateFile(file)
    if (err) {
      this.showError(err)
      event.target.value = ""
      return
    }

    this.clearError()
    if (this.previewObjectUrl) {
      URL.revokeObjectURL(this.previewObjectUrl)
      this.previewObjectUrl = null
    }

    this.previewObjectUrl = URL.createObjectURL(file)
    this.previewTarget.src = this.previewObjectUrl
    this.previewTarget.classList.remove("hidden")
    this.emptyTarget.classList.add("hidden")

    if (this.hasNameLabelTarget) {
      this.nameLabelTarget.textContent = file.name
    }
  }

  validateFile(file) {
    const type = file.type.toLowerCase()
    if (!ALLOWED_TYPES.has(type)) {
      return "รองรับเฉพาะ JPG, JPEG, PNG"
    }
    if (file.size > this.maxBytesValue) {
      return "ขนาดไฟล์ต้องไม่เกิน 10MB"
    }
    return null
  }

  clearError() {
    if (!this.hasErrorTarget) return
    this.errorTarget.textContent = ""
    this.errorTarget.classList.add("hidden")
  }

  showError(message) {
    if (!this.hasErrorTarget) return
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }
}
