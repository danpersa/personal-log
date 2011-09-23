class IdeasController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy, :show]
  before_filter :own_idea, :only => :destroy
  before_filter :own_idea_or_public, :only => [:show, :users]

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
    
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid => detail
      @feed_items = []
      @user = current_user
      render 'pages/home'
  end
  
  def update
    @idea = Idea.find(params[:id])
    @idea.idea_list_tokens = params[:idea][:idea_list_tokens]
    if @idea.save!
      flash[:success] = "Successfully updated idea!"
      redirect_to @idea
    else
      render :action => 'show'
    end
  end
  
  def show
    # the idea is searched in interceptor
    @user = current_user
    @reminders = Reminder.from_idea_by_user(@idea, current_user)
    redirect_to users_idea_path(@idea) if @reminders.empty?
  end
  
  def users
    # the idea is searched in interceptor
    @user = current_user
    @users = @idea.public_users(current_user).includes(:profile).paginate(:page => params[:page], :per_page => 10).all
  end

  def destroy
    @user = current_user
    # if the idea was not shared with other users, we destroy it
    unless @idea.shared_with_other_users?
      @idea.destroy
    else
      Idea.transaction do
        IdeaListOwnership.destroy_for_idea_of_user(@idea, @user)
        Reminder.destroy_for_idea_of_user(@idea, @user)
        @idea.donate_to_community!
      end
    end
    respond_to do |format|
       format.html { redirect_back_or root_path }
       format.js
     end
  end

  private

  def own_idea
    @idea = Idea.find_by_id(params[:id])
    redirect_to root_path unless not @idea.nil? and current_user?(@idea.user)
  end
  
  def own_idea_or_public
    @idea = Idea.find_by_id(params[:id])
    redirect_to root_path unless not @idea.nil? and current_user?(@idea.user) || @idea.public?
  end

end
