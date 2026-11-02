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
    assert_text "55 kg"
    assert_text "スクワット"
    save_screenshot Rails.root.join("tmp/screenshots/detail-mobile.png")
    assert_no_horizontal_overflow
    click_link "記録を編集"
    within all("[data-workout-form-record]").first do
      within all("[data-workout-form-set]").first { click_button "セットを削除" }
    end
    within all("[data-workout-form-record]").last { click_button "この種目を削除" }
    puts "EDIT_FORM_DATA: #{page.evaluate_script('Array.from(new FormData(document.querySelector("form[data-controller=workout-form]")))').inspect}"
    puts "BROWSER_LOGS: #{page.driver.browser.logs.get(:browser).map(&:message).inspect}"
    save_screenshot Rails.root.join("tmp/screenshots/edit-mobile.png")
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

  test "guest can use charts profile and personal exercises" do
    visit new_user_session_path
    click_button "登録せずに体験する"
    assert_text "ゲスト体験中です"
    assert_selector "#weightProgressChart"
    assert page.evaluate_script("!!Chart.getChart(document.getElementById('weightProgressChart'))")
    save_screenshot Rails.root.join("tmp/screenshots/home-mobile.png")
    assert_no_horizontal_overflow

    within(".bottom-nav") { click_link "成長分析" }
    select "合計回数", from: "指標"
    click_button "表示を更新"
    assert_selector "canvas[data-unit='回']"
    assert_text "日別の記録"
    save_screenshot Rails.root.join("tmp/screenshots/analysis-mobile.png")
    assert_no_horizontal_overflow

    within(".bottom-nav") { click_link "マイページ" }
    click_link "プロフィールを編集"
    fill_in "名前", with: "テストゲスト"
    fill_in "月間目標（日数）", with: "15"
    attach_file "プロフィール画像", Rails.root.join("test/fixtures/files/avatar.png")
    click_button "変更を保存する"
    assert_text "テストゲスト"
    assert_text "月間目標：15日"
    assert_selector "img[alt='プロフィール画像']"

    click_link "自分の種目を管理"
    click_link "＋ 新しい種目を登録"
    fill_in "種目名", with: "ゲスト専用の種目"
    click_button "種目を登録する"
    assert_text "自分の種目を登録しました。"
    assert_text "ゲスト専用の種目"
    assert_no_horizontal_overflow

    visit root_path
    click_link "前回をコピー"
    assert_field "重量（kg）", with: "55.0", match: :first
    click_button "トレーニングを保存"
    assert_text "トレーニングを保存しました。"
    accept_confirm { click_button "この記録を削除" }
    assert_text "トレーニングを削除しました。"
    visit profile_path
    click_button "ログアウト"
    assert_current_path new_user_session_path
    assert_no_text "テストゲスト"
  end

  private

  def assert_no_horizontal_overflow
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
  end
end
