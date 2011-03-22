class ResetPasswordsController < ApplicationController

  before_filter :not_authenticate

  def new
    @reset_password = ResetPassword.new
    @title = "Reset Password"
  end

  def create
    @reset_password = ResetPassword.new(params[:reset_password])
    logger.info "create"
    if @reset_password.valid?
      user = User.find_by_email(@reset_password.email)
      user.reset_password
      flash[:success] = "The reset password instructions were sent to your email address!"
      redirect_to signin_path
    else
      @title = "Reset Password"
      render 'new'
    end
  end
end
