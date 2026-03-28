import { Controller } from "@hotwired/stimulus"

export default class ProductGalleryController extends Controller {
  static targets = [ "track", "dot" ]

  connect() {
    this.onScroll = () => this.sync()
    this.trackTarget.addEventListener("scroll", this.onScroll, { passive: true })
    requestAnimationFrame(() => this.sync())
  }

  disconnect() {
    this.trackTarget.removeEventListener("scroll", this.onScroll)
  }

  sync() {
    const scroll = this.trackTarget
    const slide = scroll.children[0]
    if (!slide || !this.hasDotTarget) return

    const step = slide.offsetWidth || scroll.clientWidth
    const idx = Math.min(
      this.dotTargets.length - 1,
      Math.max(0, Math.round(scroll.scrollLeft / (step || 1)))
    )

    this.dotTargets.forEach((dot, i) => {
      const active = i === idx
      dot.setAttribute("aria-current", active ? "true" : "false")
      dot.classList.toggle("w-8", active)
      dot.classList.toggle("bg-Primary-color", active)
      dot.classList.toggle("w-1.5", !active)
      dot.classList.toggle("bg-gray-300", !active)
    })
  }

  goTo(event) {
    const i = Number.parseInt(event.currentTarget.dataset.index, 10)
    const scroll = this.trackTarget
    const slide = scroll.children[i]
    if (!slide) return

    scroll.scrollTo({ left: slide.offsetLeft, behavior: "smooth" })
  }
}
