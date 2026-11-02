ENV["RAILS_ENV"] ||= "test"
ENV["BASIC_AUTH_ENABLED"] = "false"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  fixtures :all

  def workout_attributes(exercise: exercises(:one), weight: 60, reps: 10)
    { date: Date.current, memo: "今日の記録", workout_records_attributes: [
      { exercise_id: exercise.id, workout_sets_attributes: [
        { set_number: 1, weight_kg: weight, reps: reps },
        { set_number: 2, weight_kg: weight, reps: reps }
      ] }
    ] }
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
