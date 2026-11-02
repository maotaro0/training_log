import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["records", "recordTemplate"]

  connect() {
    this.recordsTarget.querySelectorAll("[data-workout-form-record][hidden]").forEach(record => this.markRemoved(record, "record"))
    this.recordsTarget.querySelectorAll("[data-workout-form-set][hidden]").forEach(set => {
      if (!set.closest("[data-workout-form-record]").hidden) this.markRemoved(set, "set")
    })
    this.activeRecords().forEach(record => this.renumberSets(record))
  }

  nextId() {
    // Rails strong parameters recognize numeric keys as nested form entries.
    this.lastId = Math.max(Date.now(), (this.lastId || 0) + 1)
    return String(this.lastId)
  }

  activeRecords() {
    return [...this.recordsTarget.querySelectorAll("[data-workout-form-record]")].filter(record => !record.hidden)
  }

  activeSets(record) {
    return [...record.querySelectorAll("[data-workout-form-set]")].filter(set => !set.hidden)
  }

  addRecord() {
    if (this.activeRecords().length >= 30) return alert("種目は30個まで追加できます。")
    this.recordsTarget.insertAdjacentHTML("beforeend", this.recordTemplateTarget.innerHTML.replaceAll("NEW_RECORD", this.nextId()))
    const record = this.activeRecords().at(-1)
    this.insertSet(record)
    record.querySelector("select").focus()
  }

  addSet(event) {
    this.insertSet(event.currentTarget.closest("[data-workout-form-record]"))
  }

  insertSet(record) {
    if (this.activeSets(record).length >= 100) return alert("セットは100個まで追加できます。")
    const template = record.querySelector("[data-workout-form-set-template]")
    record.querySelector("[data-workout-form-sets]").insertAdjacentHTML("beforeend", template.innerHTML.replaceAll("NEW_SET", this.nextId()))
    this.renumberSets(record)
  }

  removeSet(event) {
    const record = event.currentTarget.closest("[data-workout-form-record]")
    if (this.activeSets(record).length <= 1) return alert("セットは最低1つ必要です。")
    this.remove(event.currentTarget.closest("[data-workout-form-set]"), "set")
    this.renumberSets(record)
  }

  removeRecord(event) {
    if (this.activeRecords().length <= 1) return alert("種目は最低1つ必要です。")
    this.remove(event.currentTarget.closest("[data-workout-form-record]"), "record")
  }

  remove(element, kind) {
    if (element.querySelector("[data-" + kind + "-id]")?.value) this.markRemoved(element, kind)
    else element.remove()
  }

  markRemoved(element, kind) {
    const id = element.querySelector("[data-" + kind + "-id]")
    const destroy = element.querySelector("[data-" + kind + "-destroy]")
    element.hidden = true
    element.querySelectorAll("input, select, textarea, button").forEach(input => { input.disabled = true })
    id.disabled = false
    destroy.disabled = false
    destroy.value = "1"
  }

  renumberSets(record) {
    this.activeSets(record).forEach((set, index) => {
      set.querySelector("[data-set-label]").textContent = (index + 1) + "セット目"
      set.querySelector("[data-set-number]").value = index + 1
    })
  }
}
