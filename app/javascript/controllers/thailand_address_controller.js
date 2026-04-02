import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

const PLACEHOLDER = "— เลือก —"

export default class ThailandAddressController extends Controller {
  static values = {
    provinceId: Number,
    districtId: Number,
    subDistrictId: Number
  }

  static targets = ["province", "district", "subdistrict", "postal"]

  connect() {
    this.districtsAll = null
    this.subDistrictsAll = null
    this.init().catch((e) => console.error(e))
  }

  disconnect() {
    this.destroySelect(this.provinceTarget)
    this.destroySelect(this.districtTarget)
    this.destroySelect(this.subdistrictTarget)
    this.provinces = null
    this.districtsAll = null
    this.subDistrictsAll = null
  }

  destroySelect(el) {
    if (!el) return
    if (el.tomselect) el.tomselect.destroy()
  }

  tomSelectOptions(select, placeholder) {
    return {
      create: false,
      plugins: ["dropdown_input"],
      maxOptions: null,
      sortField: { field: "text", direction: "asc" },
      placeholder: placeholder || PLACEHOLDER,
      allowEmptyOption: true,
      render: {
        no_results: () =>
          '<div class="py-2 px-3 text-sm text-gray-500">ไม่พบรายการ</div>'
      },
      onChange: () => {
        this.handleSelectChange(select)
      }
    }
  }

  handleSelectChange(select) {
    if (select === this.provinceTarget) {
      this.provinceChanged()
    } else if (select === this.districtTarget) {
      this.districtChanged()
    } else if (select === this.subdistrictTarget) {
      this.subdistrictChanged()
    }
  }

  async init() {
    await this.ensureProvinces()
    if (this.hasProvinceIdValue && this.provinceIdValue > 0) {
      this.setSelectValueSilent(this.provinceTarget, String(this.provinceIdValue))
      await this.provinceChanged()
      if (this.hasDistrictIdValue && this.districtIdValue > 0) {
        this.setSelectValueSilent(this.districtTarget, String(this.districtIdValue))
        await this.districtChanged()
        if (this.hasSubDistrictIdValue && this.subDistrictIdValue > 0) {
          this.setSelectValueSilent(this.subdistrictTarget, String(this.subDistrictIdValue))
          this.subdistrictChanged()
        }
      }
    }
  }

  setSelectValueSilent(select, value) {
    if (select.tomselect) {
      select.tomselect.setValue(value || "", true)
    } else {
      select.value = value
    }
  }

  async ensureProvinces() {
    if (this.provinces) return
    const res = await fetch("/data/thailand/province.json")
    const rows = await res.json()
    this.provinces = rows.filter((r) => !r.deleted_at)
    this.fillSelect(
      this.provinceTarget,
      this.provinces.map((r) => [r.name_th, r.id])
    )
    new TomSelect(this.provinceTarget, this.tomSelectOptions(this.provinceTarget, "จังหวัด — พิมพ์ค้นหาได้"))
  }

  async ensureDistricts() {
    if (this.districtsAll) return
    const res = await fetch("/data/thailand/district.json")
    const rows = await res.json()
    this.districtsAll = rows.filter((r) => !r.deleted_at)
  }

  async ensureSubDistricts() {
    if (this.subDistrictsAll) return
    const res = await fetch("/data/thailand/sub_district.json")
    const rows = await res.json()
    this.subDistrictsAll = rows.filter((r) => !r.deleted_at)
  }

  async provinceChanged() {
    await this.ensureProvinces()
    await this.ensureDistricts()
    const pid = Number.parseInt(this.provinceTarget.value, 10)
    const filtered = Number.isFinite(pid)
      ? this.districtsAll.filter((d) => d.province_id === pid)
      : []
    this.fillSelect(
      this.districtTarget,
      filtered.map((r) => [r.name_th, r.id])
    )
    new TomSelect(this.districtTarget, this.tomSelectOptions(this.districtTarget, "อำเภอ / เขต — พิมพ์ค้นหาได้"))
    this.resetSubdistrict()
    if (this.hasPostalTarget) this.postalTarget.value = ""
  }

  async districtChanged() {
    await this.ensureSubDistricts()
    const did = Number.parseInt(this.districtTarget.value, 10)
    const filtered = Number.isFinite(did)
      ? this.subDistrictsAll.filter((s) => s.district_id === did)
      : []
    this.fillSelect(
      this.subdistrictTarget,
      filtered.map((r) => [r.name_th, r.id])
    )
    new TomSelect(this.subdistrictTarget, this.tomSelectOptions(this.subdistrictTarget, "ตำบล / แขวง — พิมพ์ค้นหาได้"))
    if (this.hasPostalTarget) this.postalTarget.value = ""
  }

  subdistrictChanged() {
    const sid = Number.parseInt(this.subdistrictTarget.value, 10)
    const row = Number.isFinite(sid)
      ? this.subDistrictsAll.find((s) => s.id === sid)
      : null
    if (this.hasPostalTarget) {
      this.postalTarget.value = row ? String(row.zip_code) : ""
    }
  }

  fillSelect(select, pairs) {
    this.destroySelect(select)
    select.innerHTML = ""
    const ph = document.createElement("option")
    ph.value = ""
    ph.textContent = PLACEHOLDER
    ph.dataset.placeholder = "true"
    select.appendChild(ph)
    pairs.forEach(([label, id]) => {
      const opt = document.createElement("option")
      opt.value = String(id)
      opt.textContent = label
      select.appendChild(opt)
    })
  }

  resetSubdistrict() {
    this.fillSelect(this.subdistrictTarget, [])
    new TomSelect(this.subdistrictTarget, this.tomSelectOptions(this.subdistrictTarget, "ตำบล / แขวง — พิมพ์ค้นหาได้"))
  }
}
