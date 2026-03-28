import { Controller } from "@hotwired/stimulus"

const ALLOWED_TYPES = new Set(["image/jpeg", "image/png"])

export default class ProductImagesController extends Controller {
  static targets = ["dropZone", "fileInput", "previewRow", "error"]
  static values = {
    max: { type: Number, default: 5 },
    maxBytes: { type: Number, default: 1048576 },
    // [{ url, signed_id }] — รูปที่มีอยู่แล้ว (เช่น ตอนแก้ไข) แสดงในแถวพรีวิว ไม่ใส่ใน file input
    initialUrls: { type: Array, default: [] },
  }

  connect() {
    this.items = []
    for (const raw of this.initialUrlsValue) {
      const obj = typeof raw === "object" && raw !== null ? raw : {}
      const url = typeof raw === "string" ? raw : obj.url
      if (!url) continue
      const signedId = obj.signed_id
      const id = signedId ? `existing-${signedId}` : `existing-${globalThis.crypto?.randomUUID?.() ?? Date.now()}`
      this.items.push({
        id,
        file: null,
        url,
        phase: "ready",
        existing: true,
        signedId: signedId ?? null,
      })
    }
    this.render()
  }

  disconnect() {
    this.revokeAllUrls()
  }

  revokeAllUrls() {
    for (const item of this.items) {
      if (item.url?.startsWith("blob:")) URL.revokeObjectURL(item.url)
    }
  }

  openPicker() {
    if (this.items.length >= this.maxValue) return
    this.fileInputTarget.click()
  }

  delegateClick(event) {
    if (event.target.closest("[data-product-images-add]")) {
      event.preventDefault()
      this.openPicker()
      return
    }
    const removeBtn = event.target.closest("[data-product-images-remove]")
    if (removeBtn?.dataset?.id) {
      event.preventDefault()
      this.removeById(removeBtn.dataset.id)
    }
  }

  dragEnter(event) {
    event.preventDefault()
    event.stopPropagation()
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "copy"
    this.dropZoneTarget.classList.add("ring-2", "ring-sky-400", "ring-offset-2")
  }

  dragLeave(event) {
    event.preventDefault()
    if (!this.dropZoneTarget.contains(event.relatedTarget)) {
      this.dropZoneTarget.classList.remove("ring-2", "ring-sky-400", "ring-offset-2")
    }
  }

  drop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropZoneTarget.classList.remove("ring-2", "ring-sky-400", "ring-offset-2")
    if (event.dataTransfer?.files?.length) {
      this.addFiles(event.dataTransfer.files)
    }
  }

  picked(event) {
    const { files } = event.target
    if (files?.length) this.addFiles(files)
  }

  clearError() {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = ""
      this.errorTarget.classList.add("hidden")
    }
  }

  showError(message) {
    if (!this.hasErrorTarget) return
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }

  validateFile(file) {
    const type = file.type.toLowerCase()
    if (!ALLOWED_TYPES.has(type)) {
      return "รองรับเฉพาะ JPG, JPEG, PNG"
    }
    if (file.size > this.maxBytesValue) {
      return "แต่ละไฟล์ต้องไม่เกิน 1MB"
    }
    return null
  }

  addFiles(fileList) {
    this.clearError()
    const incoming = Array.from(fileList)
    const room = this.maxValue - this.items.length
    if (room <= 0) {
      this.showError(`อัปโหลดได้สูงสุด ${this.maxValue} รูป`)
      return
    }

    let added = 0
    for (const file of incoming) {
      if (added >= room) {
        this.showError(`เพิ่มได้อีกไม่เกิน ${room} รูป (สูงสุด ${this.maxValue} รูป)`)
        break
      }
      const err = this.validateFile(file)
      if (err) {
        this.showError(err)
        continue
      }
      const id = globalThis.crypto?.randomUUID?.() ?? `img-${Date.now()}-${added}`
      const url = URL.createObjectURL(file)
      this.items.push({ id, file, url, phase: "uploading", progress: 0 })
      added += 1
      this.runFakeUpload(id)
    }

    this.syncInput()
    this.render()
  }

  runFakeUpload(id) {
    const item = this.items.find((i) => i.id === id)
    if (!item) return

    const duration = 700
    const start = performance.now()

    const tick = (now) => {
      const t = Math.min(1, (now - start) / duration)
      item.progress = Math.round(t * 100)
      this.render()

      if (t < 1) {
        requestAnimationFrame(tick)
      } else {
        item.phase = "ready"
        item.progress = 100
        this.render()
      }
    }
    requestAnimationFrame(tick)
  }

  removeById(id) {
    const idx = this.items.findIndex((i) => i.id === id)
    if (idx === -1) return
    const [removed] = this.items.splice(idx, 1)
    if (removed.url?.startsWith("blob:")) URL.revokeObjectURL(removed.url)
    this.clearError()
    this.syncInput()
    this.render()
  }

  syncInput() {
    const dt = new DataTransfer()
    for (const item of this.items) {
      if (item.file) dt.items.add(item.file)
    }
    this.fileInputTarget.files = dt.files
  }

  render() {
    if (!this.hasPreviewRowTarget) return
    this.previewRowTarget.replaceChildren()

    for (const item of this.items) {
      const wrap = document.createElement("div")
      wrap.className = "relative w-[4.5rem] h-[4.5rem] shrink-0 rounded-xl overflow-hidden border border-[#E0E0E0] bg-gray-100"

      if (item.phase === "uploading") {
        wrap.innerHTML = `
          <img src="${item.url}" alt="" class="w-full h-full object-cover opacity-50" />
          <div class="absolute inset-0 flex flex-col items-center justify-center bg-black/45">
            <span class="text-[10px] font-medium text-white">Uploading</span>
          </div>
          <div class="absolute bottom-0 left-0 right-0 h-1 bg-white/90 px-0.5 py-px">
            <div class="h-full rounded-sm bg-emerald-500 transition-[width] duration-75" style="width: ${item.progress}%"></div>
          </div>
        `
      } else if (item.existing) {
        wrap.innerHTML = `
          <img src="${item.url}" alt="" class="w-full h-full object-cover" />
          <span class="pointer-events-none absolute bottom-0 left-0 right-0 bg-black/55 py-0.5 text-center text-[9px] font-medium text-white">รูปเดิม</span>
        `
      } else {
        wrap.innerHTML = `
          <img src="${item.url}" alt="" class="w-full h-full object-cover" />
          <button type="button" class="absolute top-0.5 right-0.5 flex h-5 w-5 items-center justify-center rounded-full bg-black/55 text-white text-xs leading-none hover:bg-black/70" data-product-images-remove data-id="${item.id}" aria-label="ลบรูป">×</button>
        `
      }
      this.previewRowTarget.appendChild(wrap)
    }

    if (this.items.length < this.maxValue) {
      const add = document.createElement("button")
      add.type = "button"
      add.className =
        "flex h-[4.5rem] w-[4.5rem] shrink-0 items-center justify-center rounded-xl border-2 border-dashed border-[#E0E0E0] bg-gray-50 hover:bg-gray-100 transition-colors"
      add.dataset.productImagesAdd = ""
      add.setAttribute("aria-label", "เพิ่มรูป")
      add.innerHTML = `
        <span class="flex h-9 w-9 items-center justify-center rounded-full bg-gray-300 text-white text-lg font-light leading-none">+</span>
      `
      this.previewRowTarget.appendChild(add)
    }

    const full = this.items.length >= this.maxValue
    this.dropZoneTarget.classList.toggle("opacity-50", full)
    this.dropZoneTarget.classList.toggle("pointer-events-none", full)
    this.dropZoneTarget.classList.toggle("cursor-not-allowed", full)
    this.dropZoneTarget.classList.toggle("cursor-pointer", !full)
  }
}
