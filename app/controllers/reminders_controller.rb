class RemindersController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => :destroy
  before_filter :correct_user, :only => [:edit, :update]
  
  def destroy
    @reminder.destroy
    respond_to do |format|
       format.html { redirect_back_or root_path }
       format.js
     end
  end
  
  private
  
  def authorized_user
    @reminder = Reminder.find(params[:id])
    redirect_to root_path unless current_user?(@reminder.user)
  end
end
