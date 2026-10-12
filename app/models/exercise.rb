class Exercise < ApplicationRecord
  has_many :training_records
  has_many :workout_records
  
  validates :name, presence: true, uniqueness: true
  
end
