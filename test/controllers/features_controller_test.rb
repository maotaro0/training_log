require "test_helper"

class FeaturesControllerTest < ActionDispatch::IntegrationTest
  test "guest login creates isolated data and logout removes it" do
    assert_difference "User.count", 1 do
      post guest_sign_in_path
    end
    guest = User.find_by!(guest: true)
    assert_equal 3, guest.workouts.count
    assert_redirected_to root_path
    get root_path
    assert_response :success
    get edit_user_registration_path
    assert_redirected_to profile_path
    delete destroy_user_session_path
    assert_not User.exists?(guest.id)
    assert_not Workout.where(user_id: guest.id).exists?
  end

  test "expired guest accounts are removed with their records" do
    guest = GuestAccount.create!
    guest.update!(guest_expires_at: 1.minute.ago)
    GuestAccount.cleanup!
    assert_not User.exists?(guest.id)
    assert_not Workout.where(user_id: guest.id).exists?
  end

  test "guest sessions expire even without a new guest login" do
    guest = GuestAccount.create!
    sign_in guest
    guest.update!(guest_expires_at: 1.minute.ago)
    get root_path
    assert_redirected_to new_user_session_path
    assert_not User.exists?(guest.id)
  end

  test "analysis renders selected period and never exposes another user's private exercise" do
    sign_in users(:one)
    get analysis_path, params: { exercise_id: exercises(:private).id, period: "all", metric: "reps" }
    assert_response :success
    assert_select "option", text: "個人の種目", count: 0
    assert_select "h1", text: "成長分析"
    assert_select "canvas[data-unit='回']"
  end

  test "profile image and goal can be saved and removed" do
    sign_in users(:one)
    upload = fixture_file_upload("avatar.png", "image/png")
    patch profile_path, params: { profile: { name: "テスト", monthly_goal: 15, avatar: upload } }
    assert_redirected_to profile_path
    assert_equal 15, users(:one).reload.profile.monthly_goal
    get avatar_profile_path
    assert_response :success
    assert_equal "image/png", response.media_type
    assert_equal "nosniff", response.headers["X-Content-Type-Options"]
    sign_out users(:one)
    sign_in users(:two)
    get avatar_profile_path
    assert_response :not_found
    sign_in users(:one)
    patch profile_path, params: { profile: { remove_avatar: "1" } }
    assert_not users(:one).reload.profile.avatar?
  end

  test "invalid profile values and non-image uploads show errors" do
    sign_in users(:one)
    upload = fixture_file_upload("not-image.txt", "image/png")
    patch profile_path, params: { profile: { monthly_goal: 0, avatar: upload } }
    assert_response :unprocessable_entity
    assert_select "[role=alert]"
    assert_nil users(:one).reload.profile
  end

  test "password reset is unavailable and users are told before registering" do
    get new_user_registration_path
    assert_response :success
    assert_match "再設定できない", response.body
    assert_select "a[href='/users/password/new']", count: 0
    get "/users/password/new"
    assert_response :not_found
  end

  test "real registration login and logout work" do
    post user_registration_path, params: { user: { email: "new@example.com", password: "password1234", password_confirmation: "password1234" } }
    assert_redirected_to root_path
    delete destroy_user_session_path
    post user_session_path, params: { user: { email: "new@example.com", password: "password1234" } }
    assert_redirected_to root_path
    get root_path
    assert_response :success
  end
end
