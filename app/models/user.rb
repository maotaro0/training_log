class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :rememberable,
         :validatable

  has_many :training_records, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :workouts, dependent: :destroy
  has_many :exercises, dependent: :destroy
  validates :guest_expires_at, presence: true, if: :guest?

  def training_streak
    dates = workouts.where("date <= ?", Date.current).distinct.order(date: :desc).pluck(:date)
    return 0 unless dates.first && dates.first >= Date.yesterday

    count = 0
    dates.each do |date|
      break unless date == dates.first - count
      count += 1
    end
    count
  end

  def monthly_training_count
     workouts
      .where(date: Date.current.all_month)
      .distinct
      .count(:date)
   end

end
