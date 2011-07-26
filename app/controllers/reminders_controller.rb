class RemindersController < ApplicationController
  before_filter :authenticate, :only => [:index, :create, :destroy, :remind_me_too]
  before_filter :authorized_user, :only => :destroy
  before_filter :correct_user, :only => [:edit, :update]
  
  respond_to :html, :js
  
  def index
    @user = current_user
    @reminders = current_user.reminders.includes(:idea).all
    @date = params[:month] ? Date.parse(params[:month].gsub('-', '/')) : Date.today
  end
  
  def create
    @idea = Idea.find_by_id(params[:idea][:id])
    # if the idea is not public and the logged user is not the owner of the idea, we can't create reminders
    if redirect_unless_public_idea @idea
      return
    end
    @reminder = current_user.reminders.build(params[:reminder])
    @reminder.idea = @idea
    respond_to do |format|
      if @reminder.save
        flash[:success] = "Reminder successfully created!"
        format.html { redirect_to root_path }
      else
        format.html {
          render :remind_me_too
        }
      end
      format.js {
        respond_with( @reminder, :layout => !request.xhr? ) 
      }
    end
  end
  
  def destroy
    @reminder.destroy
    respond_to do |format|
       format.html { redirect_back_or root_path }
       format.js
     end
  end
  
  def remind_me_too
    @idea = Idea.find_by_id(params[:idea_id])
    if redirect_unless_public_idea @idea
      return
    end
    @title = "Remind me too"
    @reminder = Reminder.new
    @submit_button_name = "Create reminder"
    respond_with_remote_form
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
