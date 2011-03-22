class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create, :activate, :reset_password]
  before_filter :activate_user, :except => [:show, :new, :create, :activate, :reset_password]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy


  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end    

  def new
    @user = User.new
    @title = "Sign up"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Please follow the steps from the email we sent you to activate your account!"
      redirect_to signin_path
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def edit
    @title = "Edit user"
  end

  def update
    @user = User.find(params[:id])
    @user.updating_password = true
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end
  
  def activate
    if signed_in?
      if !activated?
        deny_access("Please activate your account before before you sign in!")
        return
      else
       redirect_to current_user
       return
      end 
    end
    activated_user = User.find_by_activation_code(params[:activation_code])
    if activated_user != nil && !activated_user.activated?
      activated_user.activate!
      sign_in activated_user
      flash[:success] = "Welcome to Remind Me To Live!"
      redirect_to root_path
      return
    end
    if activated_user != nil && activated_user.activated?
      deny_access("Your account has already been activated!")
      return
    end
    redirect_to signin_path
  end
  
  def change_password
    
  end
  


  private 


  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end
