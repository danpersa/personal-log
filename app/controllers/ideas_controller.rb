class IdeasController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => :destroy
  before_filter :correct_user, :only => [:edit, :update]

  def create
  	@idea  = current_user.ideas.build(params[:idea])
    @reminder = current_user.reminders.build(params[:reminder])
  	Idea.transaction do
  	  if @idea.valid?
  	    @idea.save!
  	    @reminder.idea = @idea
  	    if @reminder.save!
    	    flash[:success] = "Idea created!"
          redirect_to root_path
          return
        end
      else
        @reminder.valid?
      end
    end

    @feed_items = []
    @user = current_user
    render 'pages/home'
    
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
      @feed_items = []
      @user = current_user
      render 'pages/home'
  end

  def destroy
    @idea.destroy
    respond_to do |format|
       format.html { redirect_back_or root_path }
       format.js
     end
  end

  private

  def authorized_user
    @idea = Idea.find(params[:id])
    redirect_to root_path unless current_user?(@idea.user)
  end

end
