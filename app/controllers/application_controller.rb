class ApplicationController < ActionController::Base
  before_action :basic_auth
  before_action :protect_private_responses

  private

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
