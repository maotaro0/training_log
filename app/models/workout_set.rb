class WorkoutSet < ApplicationRecord
  belongs_to :workout_record

  validates :set_number,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :reps,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :weight_kg,
            numericality: {
              greater_than_or_equal_to: 0
            },
            allow_nil: true


end
