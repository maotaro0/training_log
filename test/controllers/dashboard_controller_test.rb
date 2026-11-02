require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "dashboard uses only the current user's records" do
    sign_in users(:one)
    get root_path
    assert_response :success
    assert_select "h1", text: "ジムログ"
    assert_select "a[href=?]", workout_path(workouts(:two)), count: 0
  end

  test "a latest bodyweight record is not shown as a weight personal best" do
    user = users(:one)
    user.workouts.create!(workout_attributes(weight: 80).merge(date: Date.yesterday))
    user.workouts.create!(workout_attributes(weight: nil))
    sign_in user
    get root_path, params: { exercise_id: exercises(:one).id }
    assert_response :success
    assert_select ".best-badge", count: 0
    assert_select ".growth-badge", count: 0
  end
end
