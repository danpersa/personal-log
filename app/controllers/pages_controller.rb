class PagesController < ApplicationController
  
  include ApplicationHelper
  
  @@items_per_page = 20
  
  def home
    @title = "Home"
    if signed_in?
      # we create the pagination
      @feed_items = pagination(current_user.feed, @@items_per_page)
      # other variables
      @idea = Idea.new
      @reminder = Reminder.new
      @users_with_public_or_own_reminders_for_idea = {}
      @users_with_public_or_own_reminders_for_idea_count = {}
      @newest_public_or_own_reminder_for_idea = {}
      @feed_items.each do |idea|
        @users_with_public_or_own_reminders_for_idea[idea] = User.users_with_public_or_own_reminders_for_idea(idea, current_user).includes(:profile).limit(2).all
        # TODO user count instead of all.size
        @users_with_public_or_own_reminders_for_idea_count[idea] = User.users_with_public_or_own_reminders_for_idea(idea, current_user).all.size
        
        logger.info "@users_with_public_or_own_reminders_for_idea_count[idea] "
        logger.info @users_with_public_or_own_reminders_for_idea_count[idea]
        
        @newest_public_or_own_reminder_for_idea[idea] = Reminder.newest_public_or_own_reminder_for_idea(idea, current_user).first
      end
      @user = current_user
    end
  end

  def contact
    @title = 'Contact'
  end

  def about
    @title = 'About'
  end

  def help
    @title = 'Help'
  end
  
  def reset_password_mail_sent
    @title = 'Reset Password Mail Sent'
  end
end
