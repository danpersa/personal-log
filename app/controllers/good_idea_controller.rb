class GoodIdeaController < ApplicationController
  before_filter :authenticate
  
  def create
    @idea = Idea.find(params[:good_idea][:idea_id])
    current_user.mark_as_good!(@idea)
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @idea = GoodIdea.find(params[:id]).idea
    current_user.unmark_as_good!(@idea)
    respond_to do |format|
      format.js
    end
  end
end
