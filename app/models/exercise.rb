class Exercise < ApplicationRecord
  belongs_to :user, optional: true
  has_many :training_records, dependent: :restrict_with_error
  has_many :workout_records, dependent: :restrict_with_error
  
  scope :available_to, ->(user) { where(user_id: [nil, user.id]) }
  normalizes :name, with: ->(name) { name.strip }
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { scope: :user_id }
  
end
