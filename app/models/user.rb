class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :rememberable,
         :validatable

  has_many :training_records, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :workouts, dependent: :destroy
  has_many :exercises, dependent: :destroy

  def monthly_training_count
     workouts
      .where(date: Date.current.all_month)
      .distinct
      .count(:date)
   end

end
