class IdeaListsController < ApplicationController
  before_filter :authenticate, :only => [:index]
  
  respond_to :html, :js
  
  def index
    @idea_lists = IdeaList.where("name like ?", "%#{params[:q]}%").owned_by(current_user)
    @idea_list = IdeaList.new
    respond_to do |format|
      format.html {@idea_lists = @idea_lists.paginate(:page => params[:page])}
      format.json { render :json => @idea_lists.map(&:attributes) }
    end
  end
  
  def create
    @idea_list = IdeaList.new(params[:idea_list])
    @idea_list.user = current_user
        
    flash[:notice] = "Idea list successfully created" if @idea_list.save
    respond_with( @idea_list, :layout => !request.xhr? )
  end
  
end
