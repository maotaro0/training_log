require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "dashboard uses only the current user's records" do
    sign_in users(:one)
    get root_path
    assert_response :success
    assert_select "h1", text: "ジムログ"
    assert_select "a[href=?]", workout_path(workouts(:two)), count: 0
  end
end
