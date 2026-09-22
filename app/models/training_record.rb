class TrainingRecord < ApplicationRecord
  belongs_to :user
  belongs_to :exercise

  validates :training_day, presence: true
  validates :weight_kg, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :reps, numericality: { only_integer: true, greater_than: 0 }
  validates :set_count, numericality: { only_integer: true, greater_than: 0 }



  def previous_record
  user.training_records
      .where(exercise_id: exercise_id)
      .where("training_day < ?", training_day)
      .order(training_day: :desc)
      .first
  end

  def weight_difference
    previous = previous_record

    return nil if previous.nil?
    return nil if weight_kg.nil? || previous.weight_kg.nil?

    weight_kg - previous.weight_kg
  end

  def first_record
    user.training_records
      .where(exercise_id: exercise_id)
      .where("training_day <= ?", training_day)
      .order(training_day: :asc)
      .first
  end

  def growth_from_first
    first = first_record

    return nil if first.nil?
    return nil if weight_kg.nil? || first.weight_kg.nil?

    weight_kg - first.weight_kg
  end

end
