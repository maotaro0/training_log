require "test_helper"

class ProgressTest < ActiveSupport::TestCase
  test "streak counts distinct days and keeps yesterday's streak until today ends" do
    travel_to Time.zone.local(2026, 11, 3, 10) do
      user = users(:one)
      [1, 1, 2, 4].each { |days| user.workouts.create!(workout_attributes.merge(date: Date.current - days)) }
      assert_equal 2, user.training_streak
      user.workouts.create!(workout_attributes)
      assert_equal 3, user.training_streak
      travel 2.days
      assert_equal 0, user.training_streak
    end
  end

  test "progress groups days and excludes other users" do
    exercise = users(:one).exercises.create!(name: "分析用")
    users(:one).workouts.create!(workout_attributes(exercise: exercise, weight: 50, reps: 10))
    users(:one).workouts.create!(workout_attributes(exercise: exercise, weight: 60, reps: 5))
    progress = ExerciseProgress.new(user: users(:one), exercise: exercise)
    assert_equal 1, progress.daily.size
    assert_equal [60.0], progress.values(:weight)
    assert_equal [1600.0], progress.values(:volume)
    assert_equal [30], progress.values(:reps)
    assert_equal 4, progress.daily.first[:sets]
    assert_empty ExerciseProgress.new(user: users(:two), exercise: exercise).daily
  end

  test "personal best and previous set comparison follow training dates" do
    exercise = users(:one).exercises.create!(name: "比較用")
    old = users(:one).workouts.create!(workout_attributes(exercise: exercise, weight: 50).merge(date: Date.yesterday))
    latest = users(:one).workouts.create!(workout_attributes(exercise: exercise, weight: 55))
    record = latest.workout_records.first
    assert_equal old.workout_records.first, record.previous_record
    assert record.personal_best?
    record.workout_sets.each { |set| set.update!(weight_kg: 40) }
    assert_not record.reload.personal_best?
  end
end
