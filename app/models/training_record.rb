class TrainingRecord < ApplicationRecord
  belongs_to :user

  validates :training_day, presence: true
  validates :training_name, presence: true
  validates :weight_kg, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :reps, numericality: { only_integer: true, greater_than: 0 }
  validates :set_count, numericality: { only_integer: true, greater_than: 0 }

end
