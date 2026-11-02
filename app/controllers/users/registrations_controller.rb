class Users::RegistrationsController < Devise::RegistrationsController
  before_action :prevent_guest_changes, only: [:edit, :update]

  private

  def prevent_guest_changes
    if current_user&.guest?
      redirect_to profile_path, alert: "ゲストのアカウント情報は変更できません。一度ログアウトして新規登録してください。"
    end
  end
end
