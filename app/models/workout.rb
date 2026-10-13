class Workout < ApplicationRecord
  belongs_to :user

  has_many :workout_records, dependent: :destroy,inverse_of: :workout

  accepts_nested_attributes_for :workout_records,allow_destroy: true

  validates :date, presence: true
end