class Profile < ApplicationRecord
  belongs_to :user
  validates :name, length: { maximum: 50 }
end
