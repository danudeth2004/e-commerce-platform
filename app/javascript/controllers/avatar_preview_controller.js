import { Controller } from "@hotwired/stimulus"

export default class AvatarPreviewController extends Controller {
  static targets = ["input", "image", "fallback"]

  disconnect() {
    this.revokeObjectUrl()
  }

  preview() {
    const file = this.inputTarget.files?.[0]
    if (!file?.type?.startsWith("image/")) return

    this.revokeObjectUrl()
    this.objectUrl = URL.createObjectURL(file)
    this.imageTarget.src = this.objectUrl
    this.imageTarget.classList.remove("hidden")
    this.fallbackTarget.classList.add("hidden")
  }

  revokeObjectUrl() {
    if (this.objectUrl) {
      URL.revokeObjectURL(this.objectUrl)
      this.objectUrl = null
    }
  }
}
