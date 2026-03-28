import { Controller } from "@hotwired/stimulus"

export default class BundleWizardController extends Controller {
  static targets = ["step", "nextButton", "submitButton", "subtitle"]
  static values = {
    backUrl: String,
    requireNewImages: { type: Boolean, default: true }
  }

  connect() {
    this.stepIndex = 0
    this.showStep(0)
  }

  showStep(index) {
    this.stepIndex = index
    this.stepTargets.forEach((el, i) => {
      el.classList.toggle("hidden", i !== index)
    })

    const isLast = index === this.stepTargets.length - 1
    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.classList.toggle("hidden", isLast)
    }
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.classList.toggle("hidden", !isLast)
    }

    if (this.hasSubtitleTarget) {
      const hint = this.stepTargets[index]?.dataset?.stepHint
      if (hint) this.subtitleTarget.textContent = hint
    }

    if (index === 2) {
      const pick = this.bundlePickController
      pick?.sync?.()
    }
  }

  get bundlePickController() {
    const fn = this.application.getControllerForElementAndIdentifier
    if (typeof fn !== "function") return null
    try {
      return fn.call(this.application, this.element, "bundle-product-pick")
    } catch {
      return null
    }
  }

  next(event) {
    event.preventDefault()

    const form = this.element.querySelector("form")
    if (!form) return

    if (this.stepIndex === 0) {
      if (!this.validateStepOne(form)) return
    }

    if (this.stepIndex === 1) {
      const ids = form.querySelectorAll("input[name='product_bundle[bundle_ordered_ids][]']")
      if (ids.length < 2) {
        globalThis.alert("กรุณาเลือกสินค้าอย่างน้อย 2 รายการ และเรียงลำดับการใช้")
        return
      }
    }

    if (this.stepIndex < this.stepTargets.length - 1) {
      this.showStep(this.stepIndex + 1)
    }
  }

  validateStepOne(form) {
    const title = form.querySelector("[name='product_bundle[title]']")?.value?.trim()
    if (!title) {
      globalThis.alert("กรุณากรอกชื่อเซตสินค้า")
      return false
    }

    if (this.requireNewImagesValue) {
      const files = form.querySelector("#bundle_product_images_input")?.files?.length
      if (!files) {
        globalThis.alert("กรุณาอัปโหลดรูปเซตสินค้าอย่างน้อย 1 รูป")
        return false
      }
    }

    const setType = form.querySelector("[name='product_bundle[bundle_set_type_key]']")?.value
    if (!setType) {
      globalThis.alert("กรุณาเลือกประเภทเซต")
      return false
    }

    const skinChecked = form.querySelectorAll(
      "input[name='product_bundle[skin_concern_keys][]']:checked"
    )
    if (skinChecked.length < 1) {
      globalThis.alert("กรุณาเลือกปัญหาผิวที่เหมาะกับเซตอย่างน้อย 1 ข้อ (เลือกได้หลายข้อ)")
      return false
    }

    return true
  }

  back(event) {
    event.preventDefault()

    if (this.stepIndex > 0) {
      this.showStep(this.stepIndex - 1)
      return
    }

    if (this.hasBackUrlValue && this.backUrlValue) {
      globalThis.location.href = this.backUrlValue
    }
  }

  validateSubmit(event) {
    if (this.stepIndex !== this.stepTargets.length - 1) {
      event.preventDefault()
      return
    }

    const form =
      event.currentTarget instanceof HTMLFormElement
        ? event.currentTarget
        : event.target?.closest?.("form")
    if (!form) return
    const ordered = Array.from(
      form.querySelectorAll("input[name='product_bundle[bundle_ordered_ids][]']")
    ).map((el) => el.value)

    if (ordered.length < 2) {
      event.preventDefault()
      globalThis.alert("กรุณาเลือกสินค้าอย่างน้อย 2 รายการ")
      return
    }

    for (const id of ordered) {
      const ta = form.querySelector(`textarea[name='product_bundle[bundle_usages][${id}]']`)
      if (!ta?.value?.trim()) {
        event.preventDefault()
        globalThis.alert("กรุณากรอกวิธีการใช้งานให้ครบทุกชิ้นในเซต")
        return
      }
    }

    const mode = form.querySelector("input[name='product_bundle[pricing_mode]']:checked")?.value
    if (mode === "custom") {
      const amt = form.querySelector("[name='product_bundle[bundle_amount]']")?.value
      if (!amt || Number.parseFloat(amt) <= 0) {
        event.preventDefault()
        globalThis.alert("กรุณาระบุราคาเซตเมื่อเลือกตั้งราคาพิเศษ")
      }
    }
  }
}
