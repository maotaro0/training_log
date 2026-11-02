require "test_helper"

class WorkoutTest < ActiveSupport::TestCase
  test "saves a workout with multiple sets atomically" do
    workout = users(:one).workouts.new(workout_attributes)
    assert_difference ["Workout.count", "WorkoutRecord.count"], 1 do
      assert_difference "WorkoutSet.count", 2 do
        assert workout.save, workout.errors.full_messages.join(", ")
      end
    end
  end

  test "rejects empty records and records without sets" do
    workout = users(:one).workouts.new(date: Date.current)
    assert_not workout.valid?
    workout.workout_records.build(exercise: exercises(:one))
    assert_not workout.valid?
  end

  test "rejects invalid numbers without saving any part" do
    [-1, 0, 1.5].each do |reps|
      assert_no_difference ["Workout.count", "WorkoutRecord.count", "WorkoutSet.count"] do
        assert_not users(:one).workouts.create(workout_attributes(reps: reps)).persisted?
      end
    end
    assert_not users(:one).workouts.new(workout_attributes(weight: -1)).valid?
    assert_not users(:one).workouts.new(workout_attributes(weight: 10000)).valid?
    assert users(:one).workouts.new(workout_attributes(weight: nil)).valid?
  end

  test "rejects another user's private exercise" do
    assert_not users(:one).workouts.new(workout_attributes(exercise: exercises(:private))).valid?
  end

  test "cannot remove all sets from a saved record" do
    workout = users(:one).workouts.create!(workout_attributes)
    sets = workout.workout_records.first.workout_sets
    assert_not workout.update(workout_records_attributes: [
      { id: workout.workout_records.first.id, workout_sets_attributes: sets.map { |s| { id: s.id, _destroy: "1" } } }
    ])
    assert_equal 2, workout.reload.workout_records.first.workout_sets.count
  end
end
