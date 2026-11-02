class WorkoutRecord < ApplicationRecord
  belongs_to :workout
  belongs_to :exercise

  has_many :workout_sets, dependent: :destroy,inverse_of: :workout_record

  accepts_nested_attributes_for :workout_sets, allow_destroy: true, limit: 200
  validates :memo, length: { maximum: 1000 }
  validate :has_active_sets
  validate :exercise_is_available

  def earlier_records
    WorkoutRecord.joins(:workout)
      .where(exercise_id: exercise_id, workouts: { user_id: workout.user_id })
      .where("workouts.date < :date OR (workouts.date = :date AND workouts.id < :id)", date: workout.date, id: workout.id)
  end

  def previous_record
    earlier_records.includes(:workout_sets, :workout).order("workouts.date DESC, workouts.id DESC, workout_records.id DESC").first
  end

  def personal_best?
    maximum = workout_sets.filter_map(&:weight_kg).max
    return false unless maximum
    previous_best = earlier_records.joins(:workout_sets).maximum("workout_sets.weight_kg")
    previous_best.nil? || maximum > previous_best
  end

  private

  def has_active_sets
    sets = workout_sets.reject(&:marked_for_destruction?)
    errors.add(:base, "セットは最低1つ必要です。") if sets.empty?
    errors.add(:base, "セットは100個まで登録できます。") if sets.length > 100
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
