class DoneIdeasController < ApplicationController
  before_filter :authenticate
  
  def create
    @idea = Idea.find(params[:id])
    current_user.mark_as_done!(@idea)
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @idea = Idea.find(params[:id])
    current_user.unmark_as_done!(@idea)
    respond_to do |format|
      format.js
    end
  end
end
