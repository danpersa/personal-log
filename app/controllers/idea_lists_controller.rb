class IdeaListsController < ApplicationController
  before_filter :authenticate, :only => [:index, :show, :new, :create, :edit, :update, :destroy, :add_idea]
  before_filter :own_idea_list, :only => [:show, :edit, :update, :destroy, :add_idea]
  before_filter :own_idea_or_public, :only => [:add_idea]
  
  respond_to :html, :js
  
  def index
    @user = current_user
    @idea_lists = IdeaList.where("lower(name) like lower(?)", "%#{params[:q]}%").owned_by(current_user)
    @idea_list = IdeaList.new
    @edit_idea_list = IdeaList.new
    @edit_idea_list.id = 0;
    @edit_idea_list.name = "";
    @title = "My idea lists"
    respond_to do |format|
      format.html {@idea_lists = @idea_lists.paginate(:page => params[:page])}
      format.json { render :json => @idea_lists.map(&:attributes) }
    end
  end
  
  def show
    @user = current_user
    @idea_list = IdeaList.find_by_id(params[:id])
    @own_ideas = Idea.owned_by(@user).contained_in_list(@idea_list).includes(:user).paginate(:page => params[:page])
    @title = "Show idea list"
  end
  
  def new
    @user = current_user
    @idea_list = IdeaList.new
    @title = "Create idea list"
    respond_with_remote_form
  end
  
  def create
    @idea_list = IdeaList.new(params[:idea_list])
    @idea_list.user = current_user

    respond_to do |format|
      if @idea_list.save
        format.html {
          flash[:success] = "Idea list successfully created"
          redirect_to idea_lists_path
        }
      else
        format.html {
          @title = "Create idea list"
          render :new 
        }
      end
      format.js { respond_with( @idea_list, :layout => !request.xhr? ) }
    end
  end
    
  def edit
    @user = current_user
    @title = "Update idea list"
    respond_with_remote_form
  end
  
  def update
    respond_to do |format|
      # the idea list is searched in the own_idea_list before interceptor
      if @idea_list.update_attributes params[:idea_list]
        format.html {
          flash[:success] = "Idea list successfully updated" 
          redirect_to idea_lists_path 
        }
      else
        format.html {
          @title = "Update idea list" 
          render :edit 
        }
      end
      format.js {
        @hide_buttons = true
        respond_with( @idea_list, :layout => !request.xhr? )
      }
    end
  end
  
  def destroy
    respond_to do |format|
      if @idea_list.destroy
        format.html {
          flash[:success] = "Idea list successfully deleted"
          redirect_to idea_lists_path 
        }
      else
        flash[:notice] = "Idea list was not successfully deleted"
        format.html { redirect_to idea_lists_path }
      end
      format.js
    end
  end
  
  def add_idea
    @idea_list_ownership = IdeaListOwnership.new
    @idea_list_ownership.idea = @idea
    @idea_list_ownership.idea_list = @idea_list
    
    respond_to do |format|
      if @idea_list_ownership.save
        format.html
      elsif
        format.html { redirect_to idea_lists_path }
      end
      format.js
    end
  end
  
  private
  
  def own_idea_or_public
    @idea = Idea.find_by_id(params[:idea_id])
    redirect_to idea_lists_path unless not @idea.nil? and current_user?(@idea.user) || @idea.public?
  end
  
  def own_idea_list
    @idea_list = IdeaList.find_by_id(params[:id])
    redirect_to idea_lists_path unless not @idea_list.nil? and current_user?(@idea_list.user)
  end
  
end
