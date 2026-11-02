class GuestAccount
  def self.create!
    User.transaction do
      user = User.create!(email: "guest-#{SecureRandom.hex(12)}@example.invalid",
                          password: SecureRandom.base64(32), guest: true,
                          guest_expires_at: 24.hours.from_now)
      user.create_profile!(name: "ゲスト", monthly_goal: 12)
      exercise = Exercise.where(user_id: nil).find_by(name: "ベンチプレス") || Exercise.where(user_id: nil).first
      if exercise
        [2, 1, 0].each do |days_ago|
          user.workouts.create!(date: Date.current - days_ago, memo: "体験用のサンプル記録",
            workout_records_attributes: [
              { exercise: exercise, workout_sets_attributes: [
                { set_number: 1, weight_kg: 50 + (2 - days_ago) * 2.5, reps: 10 },
                { set_number: 2, weight_kg: 50, reps: 8 + (2 - days_ago) }
              ] }
            ])
        end
      end
      user
    end
  end

  def self.cleanup!
    User.where(guest: true).where("guest_expires_at < ?", Time.current).limit(100).each(&:destroy!)
  end
end
