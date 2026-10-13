class WorkoutRecord < ApplicationRecord
  belongs_to :workout
  belongs_to :exercise

  has_many :workout_sets, dependent: :destroy,inverse_of: :workout_record

accepts_nested_attributes_for :workout_sets,allow_destroy: true

end