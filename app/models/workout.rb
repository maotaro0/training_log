class Workout < ApplicationRecord
  belongs_to :user

  has_many :workout_records, dependent: :destroy, inverse_of: :workout

  accepts_nested_attributes_for :workout_records, allow_destroy: true, limit: 30

  validates :date, presence: true
  validates :memo, length: { maximum: 5000 }
  validate :has_active_records

  private

  def has_active_records
    errors.add(:base, "種目は最低1つ必要です。") if workout_records.reject(&:marked_for_destruction?).empty?
  end
end
