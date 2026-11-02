require "application_system_test_case"

class WorkoutsTest < ApplicationSystemTestCase
  test "record multiple sets and edit them on a phone width" do
    login_as users(:one), scope: :user
    visit new_workout_path
    select "ベンチプレス", from: "種目名"
    fill_in "重量（kg）", with: "60"
    fill_in "回数", with: "10"
    click_button "＋ セットを追加"
    within all("[data-workout-form-set]").last do
      fill_in "重量（kg）", with: "55"
      fill_in "回数", with: "12"
    end
    click_button "＋ 種目を追加"
    within all("[data-workout-form-record]").last do
      select "スクワット", from: "種目名"
      fill_in "重量（kg）", with: "80"
      fill_in "回数", with: "8"
    end
    save_screenshot Rails.root.join("tmp/screenshots/new-mobile.png")
    assert_no_horizontal_overflow
    click_button "トレーニングを保存"
    assert_text "トレーニングを保存しました。"
    assert_text "60 kg"
    assert_text "スクワット"
    save_screenshot Rails.root.join("tmp/screenshots/detail-mobile.png")
    assert_no_horizontal_overflow
    click_link "記録を編集"
    within all("[data-workout-form-record]").first do
      within all("[data-workout-form-set]").first { click_button "セットを削除" }
    end
    within all("[data-workout-form-record]").last { click_button "この種目を削除" }
    click_button "変更を保存"
    assert_text "トレーニングを更新しました。"
    assert_text "55 kg"
    assert_no_text "60 kg"
    assert_no_text "スクワット"
    visit workouts_path
    assert_text "トレーニング履歴"
    save_screenshot Rails.root.join("tmp/screenshots/history-mobile.png")
    assert_no_horizontal_overflow
  end

  private

  def assert_no_horizontal_overflow
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
  end
end
