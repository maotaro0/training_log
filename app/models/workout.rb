class Workout < ApplicationRecord
  belongs_to :user

  has_many :workout_records, dependent: :destroy

  validates :date, presence: true
end