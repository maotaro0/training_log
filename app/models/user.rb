class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  has_many :training_records

  def monthly_training_count
     training_records
      .where(training_day: Date.current.beginning_of_month..Date.current.end_of_month)
      .distinct
      .count(:training_day)
   end
end
