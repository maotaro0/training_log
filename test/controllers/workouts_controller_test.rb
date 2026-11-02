require "test_helper"

class WorkoutsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:one) }

  test "login is required" do
    sign_out users(:one)
    get workouts_path
    assert_redirected_to new_user_session_path
  end

  test "all main pages render" do
    [root_path, workouts_path, workout_path(workouts(:one)), new_workout_path, edit_workout_path(workouts(:one)), exercises_path, profile_path].each do |path|
      get path
      assert_response :success, path
    end
  end

  test "index does not show another user's workout" do
    get workouts_path
    assert_select "a[href=?]", workout_path(workouts(:one))
    assert_select "a[href=?]", workout_path(workouts(:two)), count: 0
  end

  test "cannot view edit delete or copy another user's workout" do
    [workout_path(workouts(:two)), edit_workout_path(workouts(:two)), new_workout_path(copy_from: workouts(:two).id)].each do |path|
      sign_in users(:one)
      get path
      assert_response :not_found
    end
    assert_no_difference "Workout.count" do
      sign_in users(:one)
      delete workout_path(workouts(:two))
      assert_response :not_found
    end
    sign_in users(:one)
    patch workout_path(workouts(:two)), params: { workout: { memo: "unauthorized" } }
    assert_response :not_found
  end

  test "create edit and delete a workout" do
    post workouts_path, params: { workout: workout_attributes.merge(user_id: users(:two).id) }
    workout = users(:one).workouts.order(:id).last
    assert_redirected_to workout_path(workout)
    assert_equal 2, workout.workout_records.first.workout_sets.count
    patch workout_path(workout), params: { workout: { memo: "変更後" } }
    assert_redirected_to workout_path(workout)
    assert_equal "変更後", workout.reload.memo
    assert_difference "WorkoutSet.count", -2 do
      delete workout_path(workout)
    end
    assert_redirected_to workouts_path
  end

  test "invalid create keeps values and shows errors" do
    assert_no_difference "Workout.count" do
      post workouts_path, params: { workout: workout_attributes(reps: 0) }
    end
    assert_response :unprocessable_entity
    assert_select "[role=alert]"
    assert_select "textarea", text: "今日の記録"
  end

  test "copy starts today without persisting changes" do
    assert_no_difference "Workout.count" do
      get new_workout_path(copy_from: workouts(:one).id)
    end
    assert_response :success
    assert_select "input[name='workout[date]'][value=?]", Date.current.iso8601
    assert_select "input[name*='[reps]'][value='1']"
    assert_select "input[data-record-id]", count: 0
  end

  test "nested ids cannot modify another workout" do
    patch workout_path(workouts(:one)), params: { workout: { workout_records_attributes: [
      { id: workout_records(:two).id, memo: "tampered" }
    ] } }
    assert_response :not_found
    assert_not_equal "tampered", workout_records(:two).reload.memo
  end

  test "exercise ownership is enforced" do
    patch exercise_path(exercises(:one)), params: { exercise: { name: "tampered" } }
    assert_response :not_found
    sign_in users(:one)
    get edit_exercise_path(exercises(:private))
    assert_response :not_found
    sign_in users(:one)
    post exercises_path, params: { exercise: { name: "自作種目", user_id: users(:two).id } }
    assert_equal users(:one).id, Exercise.find_by!(name: "自作種目").user_id
  end

  test "account deletion removes all associated records" do
    user_id = users(:one).id
    workout_id = workouts(:one).id
    users(:one).exercises.create!(name: "自作")
    delete user_registration_path
    assert_not User.exists?(user_id)
    assert_not Workout.exists?(workout_id)
    assert_not TrainingRecord.where(user_id: user_id).exists?
  end
end
