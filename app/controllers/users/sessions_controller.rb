class Users::SessionsController < Devise::SessionsController
  def destroy
    guest = current_user if current_user&.guest?
    super
    guest&.destroy!
  end
end
