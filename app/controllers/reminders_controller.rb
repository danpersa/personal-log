class RemindersController < ApplicationController
  before_filter :authenticate, :only => [:index, :create, :destroy, :remind_me_too]
  before_filter :authorized_user, :only => :destroy
  before_filter :correct_user, :only => [:edit, :update]
  
  respond_to :html, :js
  
  @@items_per_page = 10
  
  def index
    @user = current_user
    @hide_sidebar = true
    @reminders = current_user.reminders.includes(:idea).all
    @date = params[:month] ? Date.parse(params[:month].gsub('-', '/')) : Date.today
  end
  
  def create
    @idea = Idea.find_by_id(params[:idea][:id])
    # if the idea is not public and the logged user is not the owner of the idea, we can't create reminders
    if redirect_unless_public_idea @idea
      return
    end
    @reminder = current_user.reminders.build(params[:reminder])
    @reminder.idea = @idea
    shared_idea = @idea.shared_by? current_user
    respond_to do |format|
      if @reminder.save
        flash[:success] = "Reminder successfully created!"
        format.html { redirect_back_or root_path }
      else
        format.html {
          render :layout => 'layouts/one_column', :template => 'reminders/remind_me_too'
        }
      end
      format.js {
        logger.debug "current page: " + current_page
        # we are on the users sharing an idea page
        if current_page.include? "ideas" and current_page.include? "users"
          respond_with(@reminder, :layout => !request.xhr?) do |format|
            format.js {
              path_hash = url_to_hash(current_page)
              page = path_hash[:page]
              unless shared_idea
                logger.debug "idea shared by current user"
                @user = current_user
                @users = @idea.public_users(current_user).includes(:profile).page(page).per(@@items_per_page).all
                @table_params = { :controller => "ideas",
                  :action => "users",
                  :id => @idea.id,
                  :page => page }
                @update_table_partial = 'users/table_and_toolbar_update'
              else
                logger.debug "idea not shared by current user"
                @update_table = false
              end
            }
          end
          # we are on the profile page of an user
        elsif current_page.include? "users"
          respond_with(@reminder, :layout => !request.xhr?) do |format|
            format.js {
              # we parse the current page path and extract the user on which profile page we are on
              path_hash = url_to_hash(current_page)
              user_id = path_hash[:id]
              @page = path_hash[:page]
              # if we edit our own profile
              if (user_id.to_i == current_user.id)
                logger.debug "own profile"
                @table_params = { :controller => "users",
                  :action => "show",
                  :id => user_id,
                  :page => @page }
                init_reminders_table_of current_user
              else
                @update_table = false
              end
            }
          end
          # we are on the home page
        elsif current_page == "/" or current_page.include? '/?page='
          respond_with(@reminder, :layout => !request.xhr?) do |format|
            format.js {
              @update_table_partial = 'feeds/table_update'
              path_hash = url_to_hash(current_page)
              params[:page] = path_hash[:page]
              init_feeds_table
            }
          end
          # we are on the reminders for an idea page
        elsif current_page.include? "ideas"
          respond_with(@reminder, :layout => !request.xhr?) do |format|
            format.js {
              logger.debug 'we are on the reminders for an idea page'
              path_hash = url_to_hash(current_page)
              idea_id = path_hash[:id]
              page = path_hash[:page]
              logger.debug 'idea_id ' + idea_id
              @table_params = { :controller => "ideas",
                :action => "show",
                :id => idea_id,
                :page => page }
              @update_table_partial = 'reminders/simple_table_update'
              @user = current_user
              @reminders = Reminder.from_idea_by_user(idea_id, current_user).page(page).per(@@items_per_page)
            }
          end
        end
      }
    end
  end
  
  def destroy
    @reminder.destroy
    respond_to do |format|
      format.html { redirect_back_or root_path }
      format.js {
        logger.debug "current page: " + current_page
        # we are on the profile page of the logged user
        if current_page.include? "users"
          path_hash = url_to_hash(current_page)
          user_id = path_hash[:id]
          @page = path_hash[:page]
          # if we edit our own profile
          logger.debug "own profile"
          @table_params = { :controller => "users",
            :action => "show",
            :id => user_id,
            :page => @page }
          init_reminders_table_of current_user
          # we are on the reminders for an idea page
        elsif current_page.include? "ideas"
          logger.debug 'we are on the reminders for an idea page'
          path_hash = url_to_hash(current_page)
          idea_id = path_hash[:id]
          page = path_hash[:page]
          @table_params = { :controller => "ideas",
            :action => "show",
            :id => idea_id,
            :page => page }
          @update_table_partial = 'reminders/simple_table_update'
          @user = current_user
          @reminders = Reminder.from_idea_by_user(idea_id, current_user).page(page).per(@@items_per_page)
        end  
      }
    end
  end
  
  def remind_me_too_user_profile
    @idea = Idea.find_by_id(params[:idea_id])
    if redirect_unless_public_idea @idea
      return
    end
    @title = "Remind me too"
    @reminder = Reminder.new
    @submit_button_name = "Create reminder"
    respond_with_remote_form
  end
  
  def remind_me_too
    @idea = Idea.find_by_id(params[:idea_id])
    if redirect_unless_public_idea @idea
      return
    end
    if @idea.shared_by? current_user
      logger.info  "idea is shared"
      @title = "Create new reminder"
    else
      logger.info  "idea is not shared"
      @title = "Remind me too"
    end  
    @reminder = Reminder.new
    @submit_button_name = "Create reminder"
    respond_with_remote_form
  end
  
  private
  
  def redirect_unless_public_idea(idea)
    if idea.nil? or (idea.user != current_user and not idea.public?)
      flash[:error] = "You want to remind an idea that does not exist!"
      redirect_to root_path
      return true
    end
    false
  end
  
  def authorized_user
    @reminder = Reminder.find_by_id(params[:id])
    redirect_to root_path unless not @reminder.nil? and current_user?(@reminder.user)
  end
end
