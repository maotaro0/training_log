class ApplicationController < ActionController::Base
  before_action :basic_auth
  before_action :protect_private_responses
  before_action :expire_guest_session

  private

  def expire_guest_session
    if current_user&.guest? && current_user.guest_expires_at && current_user.guest_expires_at <= Time.current
      guest = current_user
      sign_out current_user
      guest.destroy!
      redirect_to new_user_session_path, alert: "ゲスト利用の期限が切れました。もう一度ゲストログインできます。"
    end
  end

  def basic_auth
    return unless ENV["BASIC_AUTH_ENABLED"] == "true"

    authenticate_or_request_with_http_basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, ENV.fetch("BASIC_AUTH_USER")) &
        ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch("BASIC_AUTH_PASSWORD"))
    end
  end

  def protect_private_responses
    response.headers["Cache-Control"] = "no-store"
  end
end
