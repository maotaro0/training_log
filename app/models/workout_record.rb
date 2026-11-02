class WorkoutRecord < ApplicationRecord
  belongs_to :workout
  belongs_to :exercise

  has_many :workout_sets, dependent: :destroy,inverse_of: :workout_record

  accepts_nested_attributes_for :workout_sets, allow_destroy: true, limit: 100
  validates :memo, length: { maximum: 1000 }
  validate :has_active_sets
  validate :exercise_is_available

  private

  def has_active_sets
    sets = workout_sets.reject(&:marked_for_destruction?)
    errors.add(:base, "セットは最低1つ必要です。") if sets.empty?
    if sets.map(&:set_number).uniq.length != sets.length
      errors.add(:base, "セット番号が重複しています。")
    end
  end

  def exercise_is_available
    if exercise && exercise.user_id && exercise.user_id != workout&.user_id
      errors.add(:exercise, "は利用できません。")
    end
  end

end
