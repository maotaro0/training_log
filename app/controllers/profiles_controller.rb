class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  def show; end
  def edit; end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path, notice: "プロフィールを更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def avatar
    return head :not_found unless @profile.avatar?
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["Content-Security-Policy"] = "default-src 'none'"
    send_data @profile.avatar_data, type: @profile.avatar_content_type, disposition: "inline"
  end

  private

  def set_profile
    @profile = current_user.profile || current_user.build_profile
  end

  def profile_params
    params.require(:profile).permit(:name, :monthly_goal, :avatar, :remove_avatar)
  end
end
