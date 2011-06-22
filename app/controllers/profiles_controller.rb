class ProfilesController < ApplicationController
  before_filter :authenticate, :only => [:edit, :create, :update]
  before_filter :correct_user, :only => [:edit, :create, :update]
  
  def edit
    @profile = Profile.find_by_user_id(current_user.id)
    if @profile.nil?
      @profile = Profile.new
    end
    @title = "Update public profile"
  end

  def create
    @profile = Profile.new(params[:profile])
    @profile.user_id = current_user.id
    save_profile
  end

  def update
    @profile = Profile.find_by_user_id(current_user.id)
    @profile.attributes = params[:profile]
    # if the profile is empty, we destroy it
    if @profile.empty?
      Profile.destroy @profile.id
      redirect_to_edit_with_flash
      return
    end
    save_profile
  end

  private
  
  def save_profile
    # we only save the profile if it is not empty
    if !@profile.empty? 
      if @profile.save
        redirect_to_edit_with_flash
        return
      else
        @title = "Update public profile"
        render :edit
      end
    else
      redirect_to_edit_with_flash
      return
    end
  end
  
  def redirect_to_edit_with_flash
    flash[:success] = "Profile successfully updated"
    redirect_to edit_user_profile_path(current_user)
  end

  def correct_user
    @user = User.find_by_id(params[:user_id])
    redirect_to(edit_user_profile_path(current_user)) unless not @user.nil? and current_user?(@user)
  end
end
