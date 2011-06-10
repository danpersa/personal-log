class IdeaListsController < ApplicationController
  before_filter :authenticate, :only => [:index, :show, :create, :update, :destroy]
  before_filter :own_idea_list, :only => [:show, :update, :destroy]
  
  respond_to :html, :js
  
  def index
    @idea_lists = IdeaList.where("lower(name) like lower(?)", "%#{params[:q]}%").owned_by(current_user)
    @idea_list = IdeaList.new
    @edit_idea_list = IdeaList.new
    @edit_idea_list.id = 0;
    @edit_idea_list.name = "";
    respond_to do |format|
      format.html {@idea_lists = @idea_lists.paginate(:page => params[:page])}
      format.json { render :json => @idea_lists.map(&:attributes) }
    end
  end
  
  def show
    
  end
  
  def create
    @idea_list = IdeaList.new(params[:idea_list])
    @idea_list.user = current_user

    if @idea_list.save
      flash[:success] = "Idea list successfully created"
    else
      flash[:notice] = "Idea list wasn't created"
    end

    respond_to do |format|
      format.html { redirect_to idea_lists_path }
      format.js { respond_with( @idea_list, :layout => !request.xhr? ) }        
    end
  end
  
  def update
    # the idea list is searched in the own_idea_list before interceptor
    if @idea_list.update_attributes(params[:idea_list])
      flash[:success] = "Idea list successfully updated"
    else
      flash[:notice] = "Idea list wasn't updated"
    end
    
    respond_to do |format|
      format.html { redirect_to idea_lists_path }
      format.js { respond_with( @idea_list, :layout => !request.xhr? ) }        
    end
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
  
  def own_idea_list
    @idea_list = IdeaList.find_by_id(params[:id])
    redirect_to idea_lists_path unless not @idea_list.nil? and current_user?(@idea_list.user)
  end
  
end
