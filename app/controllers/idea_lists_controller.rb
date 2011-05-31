class IdeaListsController < ApplicationController
  
  
  def index
    @idea_lists = IdeaList.where("name like ?", "%#{params[:q]}%")
    respond_to do |format|
      format.html
      format.json { render :json => @idea_lists.map(&:attributes) }
    end
  end
  
end
