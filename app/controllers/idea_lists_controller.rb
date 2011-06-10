class IdeaListsController < ApplicationController
  before_filter :authenticate, :only => [:index]
  before_filter :own_idea, :only => :destroy
  
  respond_to :html, :js
  
  def index
    @idea_lists = IdeaList.where("lower(name) like lower(?)", "%#{params[:q]}%").owned_by(current_user)
    @idea_list = IdeaList.new
    respond_to do |format|
      format.html {@idea_lists = @idea_lists.paginate(:page => params[:page])}
      format.json { render :json => @idea_lists.map(&:attributes) }
    end
  end
  
  def create
    @idea_list = IdeaList.new(params[:idea_list])
    @idea_list.user = current_user
        
    flash[:success] = "Idea list successfully created" if @idea_list.save
    respond_with( @idea_list, :layout => !request.xhr? )
  end
  
  def destroy
    if @idea_list.destroy
      flash[:success] = "Idea list successfully deleted"
    end
    respond_to do |format|
       format.html { redirect_to idea_lists_path }
       format.js
     end
  end
  
  private
  
  def own_idea
    @idea_list = IdeaList.find_by_id(params[:id])
    redirect_to idea_lists_path unless not @idea_list.nil? and current_user?(@idea_list.user)
  end
  
end
