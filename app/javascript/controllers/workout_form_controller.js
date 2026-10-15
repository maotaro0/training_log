import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["records", "recordTemplate"]

  connect() {
    this.counter = 0
  }

  nextId() {
    this.counter += 1
    return `new_${this.counter}`
  }

  addRecord() {
    const html = this.recordTemplateTarget.innerHTML.replaceAll(
      "NEW_RECORD",
      this.nextId()
    )

    this.recordsTarget.insertAdjacentHTML("beforeend", html)

    const records = this.recordsTarget.querySelectorAll(
      "[data-workout-form-record]"
    )

    const newRecord = records[records.length - 1]

    this.insertSet(newRecord)
  }

  addSet(event) {
    const record = event.currentTarget.closest(
      "[data-workout-form-record]"
    )

    this.insertSet(record)
  }

  insertSet(record) {
    const template = record.querySelector(
      "[data-workout-form-set-template]"
    )

    const container = record.querySelector(
      "[data-workout-form-sets]"
    )

    const html = template.innerHTML.replaceAll(
      "NEW_SET",
      this.nextId()
    )

    container.insertAdjacentHTML("beforeend", html)

    this.renumberSets(record)
  }

  removeSet(event) {
    const record = event.currentTarget.closest(
      "[data-workout-form-record]"
    )

    const sets = record.querySelectorAll(
      "[data-workout-form-set]"
    )

    if (sets.length <= 1) {
      alert("セットは最低1つ必要です。")
      return
    }

    event.currentTarget.closest(
      "[data-workout-form-set]"
    ).remove()

    this.renumberSets(record)
  }

  removeRecord(event) {
    const records = this.recordsTarget.querySelectorAll(
      "[data-workout-form-record]"
    )

    if (records.length <= 1) {
      alert("種目は最低1つ必要です。")
      return
    }

    event.currentTarget.closest(
      "[data-workout-form-record]"
    ).remove()
  }

  renumberSets(record) {
    const sets = record.querySelectorAll(
      "[data-workout-form-set]"
    )

    sets.forEach((set, index) => {
      const number = index + 1

      set.querySelector("[data-set-label]").textContent =
        `${number}セット目`

      set.querySelector("[data-set-number]").value = number
    })
  }
}