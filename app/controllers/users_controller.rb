class UsersController < ApplicationController
  
  include RecaptchaHelper
  
  before_filter :authenticate, :except => [:show, :new, :create, :activate, :reset_password, :change_reseted_password]
  before_filter :activate_user, :except => [:show, :new, :create, :activate, :reset_password, :change_reseted_password]
  before_filter :existing_user, :only => [:show, :edit, :update, :destroy, :following, :followers, :ideas]
  before_filter :correct_user, :only => [:edit, :update, :ideas]
  before_filter :admin_or_correct_user, :only => :destroy
  before_filter :not_authenticate, :only => [:change_reseted_password]

  @@items_per_page = 10
  
  def index
    @user = current_user
    @title = "All users"
    @users = User.page(params[:page])
  end

  def show
    @page = params[:page]
    init_reminders_table_of @user
    # we store the location so we can be redirected here after reminder delete
    store_location
    store_current_page
    @remind_me_too_location = USER_PROFILE_LOCATION
    @title = @user.name
  end

  def new
    @user = User.new
    @title = "Sign up"
    render :layout => "one_column"
  end

  def create
    @user = User.new(params[:user])
    
    unless verify_recaptcha(request.remote_ip, params)
      @title = "Sign up"
      # we trigger the validation manually
      @user.valid?
      @user.errors[:recaptcha] = "The CAPTCHA solution was incorrect. Please re-try"
      render :layout => "one_column", :template => 'users/new'
      return
    end
    
    if @user.save
      flash[:success] = "Please follow the steps from the email we sent you to activate your account!!"
      redirect_to signin_path
    else
      @title = "Sign up"
      render :new
    end
  end

  def edit
    @title = "Edit user"
    # the user is searched in the existing_user before interceptor
  end

  def update
    # the user is searched in the existing_user before interceptor
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render :edit
    end
  end

  def destroy
    if (current_user?(@user))
      delete_own_account = true
    end
    # the user is searched in the existing_user before interceptor
    @user.destroy
    if (delete_own_account)
      flash[:success] = "Your account was successfully deleted!"
      redirect_to root_path
    else
      flash[:success] = "User destroyed."
      redirect_to users_path
    end
  end
  
  def following
    # the user is searched in the existing_user before interceptor
    @title = "Following"
    @users = @user.following.page(params[:page])
    render 'show_follow'
  end

  def followers
    # the user is searched in the existing_user before interceptor
    @title = "Followers"
    @users = @user.followers.page(params[:page])
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
  
  # page displaying the ideas of the current user
  def ideas
    @ideas = Idea.owned_by(@user).includes(:user).page(params[:page]).per(@@items_per_page)
    # we store the location so we can be redirected here after idea delete
    store_location
    store_current_page
  end

  private 

  def existing_user
    @user = User.find_by_id(params[:id])
    redirect_to(root_path) unless not @user.nil?
  end

  def correct_user
    redirect_to(root_path) unless current_user?(@user)
  end
  
  def admin_or_correct_user
    redirect_to(root_path) unless current_user.admin? or current_user?(@user)  
  end
end
