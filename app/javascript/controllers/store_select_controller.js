import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["storeGroup", "productCheckbox", "selectAll"]

  connect() {
    this.refreshAllGroups()
  }

  toggleAll(event) {
    const group = event.target.closest("[data-store-select-target='storeGroup']")
    const checked = event.target.checked

    group.querySelectorAll("[data-store-select-target='productCheckbox']")
      .forEach(cb => cb.checked = checked)
  }

  updateSelectAll(event) {
    const group = event.target.closest("[data-store-select-target='storeGroup']")
    this.updateGroupState(group)
  }

  refreshAllGroups() {
    this.storeGroupTargets.forEach(group => {
      this.updateGroupState(group)
    })
  }

  updateGroupState(group) {
    const checkboxes = group.querySelectorAll("[data-store-select-target='productCheckbox']")
    const selectAll = group.querySelector("[data-store-select-target='selectAll']")

    if (!selectAll || checkboxes.length === 0) return

    const allChecked = Array.from(checkboxes).every(cb => cb.checked)
    const someChecked = Array.from(checkboxes).some(cb => cb.checked)

    selectAll.checked = allChecked
    selectAll.indeterminate = !allChecked && someChecked
  }
}