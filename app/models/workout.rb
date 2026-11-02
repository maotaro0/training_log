class Workout < ApplicationRecord
  belongs_to :user

  has_many :workout_records, dependent: :destroy, inverse_of: :workout

  accepts_nested_attributes_for :workout_records, allow_destroy: true, limit: 60

  validates :date, presence: true
  validates :memo, length: { maximum: 5000 }
  validate :has_active_records

  private

  def has_active_records
    records = workout_records.reject(&:marked_for_destruction?)
    errors.add(:base, "種目は最低1つ必要です。") if records.empty?
    errors.add(:base, "種目は30個まで登録できます。") if records.length > 30
  end
end
