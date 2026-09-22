class TrainingRecord < ApplicationRecord
  belongs_to :user

  validates :training_day, presence: true
  validates :training_name, presence: true
  validates :weight_kg, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :reps, numericality: { only_integer: true, greater_than: 0 }
  validates :set_count, numericality: { only_integer: true, greater_than: 0 }



  def previous_record
  user.training_records
      .where(training_name: training_name)
      .where("training_day < ?", training_day)
      .order(training_day: :desc)
      .first
  end
end
