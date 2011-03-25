class ChangePasswordsController < ApplicationController

  before_filter :not_authenticate
  def edit
    @change_password = ChangePassword.new({:password_reset_code => params[:id]})
    @user = User.find_by_password_reset_code(@change_password.password_reset_code)
    if @user.nil?
      deny_access("You don't have a valid reset password link!")
      return
    end
    @title = "Change Password"
  end

  def create
    # we create the change password object
    @change_password = ChangePassword.new(params[:change_password])
    # we look for a user with that password_reset_code
    @user = User.find_by_password_reset_code(@change_password.password_reset_code)
    # if we don't find an user with that password_reset_code
    if @user.nil?
      # maybe someone is trying to update another user's password
      deny_access("You don't have a valid reset password link!")
      return
    end
    # the link has expired
    if @user.reset_password_expired?
      redirect_to reset_passwords_path, :notice => "Your reset password link has expired! Please use the reset password feature again!"
      return
    end 
    # if the new password is valid
    if @change_password.valid?
      flash[:success] = "Your password was successfully changed!"
      # we update the user
      @user.updating_password = true
      @user.password = @change_password.password
      @user.password_confirmation = @change_password.password_confirmation
      # we don't let a password reset code to be used twice
      @user.password_reset_code = nil
      @user.reset_password_mail_sent_at = nil
      @user.save!
      redirect_to signin_path
    else
      @title = "Change Password"
      render 'edit'
    end
  end

end
