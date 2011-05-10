class IdeasController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy, :show]
  before_filter :own_idea, :only => :destroy
  before_filter :own_idea_or_public, :only => :show

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
  
  def show
    # the idea is searched in interceptor
    @user = current_user
    @users = @idea.public_users(current_user).includes(:profile).paginate(:page => params[:page], :per_page => 10)
  end

  def destroy
    @idea.destroy
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
