class GuestSessionsController < ApplicationController
  def create
    return redirect_to root_path if user_signed_in?
    GuestAccount.cleanup!
    sign_in GuestAccount.create!
    redirect_to root_path, notice: "ゲストでログインしました。記録はログアウト時に削除されます。"
  end
end
