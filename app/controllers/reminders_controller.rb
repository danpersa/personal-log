class RemindersController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy, :remind_me_too]
  before_filter :authorized_user, :only => :destroy
  before_filter :correct_user, :only => [:edit, :update]
  
  def remind_me_too
    @idea = Idea.find_by_id(params[:idea_id])
    if redirect_unless_public_idea @idea
      return
    end
    @title = "Remind me too"
    @reminder = Reminder.new
  end
  
  def destroy
    @reminder.destroy
    respond_to do |format|
       format.html { redirect_back_or root_path }
       format.js
     end
  end
  
  def create
    @idea = Idea.find_by_id(params[:idea][:id])
    # if the idea is not public and the logged user is not the owner of the idea, we can't create reminders
    if redirect_unless_public_idea @idea
      return
    end
    @reminder = current_user.reminders.build(params[:reminder])
    @reminder.idea = @idea
    if @reminder.save
      flash[:success] = "Reminder successfully created!"
      redirect_to root_path
      return
    end
    render :remind_me_too
  end
  
  private
  
  def redirect_unless_public_idea(idea)
    if idea.nil? or (idea.user != current_user and not idea.public?)
      flash[:error] = "You want to remind an idea that does not exist!"
      redirect_to root_path
      return true
    end
    false
  end
  
  def authorized_user
    @reminder = Reminder.find_by_id(params[:id])
    redirect_to root_path unless not @reminder.nil? and current_user?(@reminder.user)
  end
end
