class ChangePasswordsController < ApplicationController
  
    def change_password
    if request.get?
      @user = User.find_by_password_reset_code(params[:password_reset_code])
      if @user.nil?
        deny_access("You don't have a valid reset password link!")
        return
      end
      @user.updating_password = true
    end
    if request.post?
      @user = User.new()
    end
  end
  
end
