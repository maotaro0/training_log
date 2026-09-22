class Exercise < ApplicationRecord
  has_many :training_records
  
  validates :name, presence: true, uniqueness: true
  
end
