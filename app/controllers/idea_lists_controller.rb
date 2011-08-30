class IdeaListsController < ApplicationController
  before_filter :authenticate, :only => [:index, :show, :new, :create, :edit, :update, :destroy, :add_idea]
  before_filter :own_idea_list, :only => [:show, :edit, :update, :destroy, :add_idea]
  before_filter :own_idea_or_public, :only => [:add_idea]
  
  respond_to :html, :js
  
  @@items_per_page = 5
  
  def index
    @user = current_user
    @idea_list = IdeaList.new
    @edit_idea_list = IdeaList.new
    @edit_idea_list.id = 0;
    @edit_idea_list.name = "";
    @title = "My idea lists"
    respond_to do |format|
      format.html {
        init_idea_lists_with_pagination
      }
      format.json {
        @idea_lists = IdeaList.where("lower(name) like lower(?)", "%#{params[:q]}%").owned_by(current_user) 
        render :json => @idea_lists.map(&:attributes) 
      }
      format.js {
        init_idea_lists_with_pagination
      }
    end
  end
  
  def show
    @user = current_user
    @idea_list = IdeaList.find_by_id(params[:id])
    @own_ideas = Idea.owned_by(@user).contained_in_list(@idea_list).includes(:user).paginate(:per_page => @@items_per_page, :page => params[:page])
    @title = "Show idea list"
    # we store the location so we can be redirected here after idea delete
    store_location
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
        flash[:success] = "Idea list successfully created"
        format.html {
          redirect_to idea_lists_path
        }
        format.js {
          init_idea_lists_with_pagination
          respond_with( @idea_list, :layout => !request.xhr? ) 
        }
      else
        format.html {
          @title = "Create idea list"
          render :new 
        }
        format.js {
          respond_with( @idea_list, :layout => !request.xhr? ) }
      end
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
        flash[:success] = "Idea list successfully updated"
        format.html { 
          redirect_to idea_lists_path 
        }
        format.js {
          init_idea_lists_with_pagination
          @hide_buttons = true
          respond_with( @idea_list, :layout => !request.xhr? )
        }
      else
        format.html {
          @title = "Update idea list" 
          render :edit 
        }
        format.js {
          @hide_buttons = true
          respond_with( @idea_list, :layout => !request.xhr? )
        }
      end
    end
  end
  
  def destroy
    respond_to do |format|
      if @idea_list.destroy
        flash[:success] = "Idea list successfully deleted"
        format.html {
          redirect_to idea_lists_path 
        }
      else
        flash[:notice] = "Idea list was not successfully deleted"
        format.html { 
          redirect_to idea_lists_path 
        }
      end
      format.js {
        init_idea_lists_with_pagination
      }
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
  
  def init_idea_lists_with_pagination
    @idea_lists = IdeaList.owned_by(current_user)
    with_pagination
  end
  
  def with_pagination
    @idea_lists = @idea_lists.paginate(:per_page => @@items_per_page, :page => params[:page])
  end
  
  def own_idea_or_public
    @idea = Idea.find_by_id(params[:idea_id])
    redirect_to idea_lists_path unless not @idea.nil? and current_user?(@idea.user) || @idea.public?
  end
  
  def own_idea_list
    @idea_list = IdeaList.find_by_id(params[:id])
    redirect_to idea_lists_path unless not @idea_list.nil? and current_user?(@idea_list.user)
  end
  
end
