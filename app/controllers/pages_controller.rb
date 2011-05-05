class PagesController < ApplicationController
  def home
    @title = "Home"
    if signed_in?
      @idea = Idea.new
      @reminder = Reminder.new
      @feed_items = current_user.feed.limit(50)
      @users_with_public_or_own_reminders_for_idea = {}
      @users_with_public_or_own_reminders_for_idea_count = {}
      @newest_public_or_own_reminder_for_idea = {}
      @feed_items.each do |idea|
        @users_with_public_or_own_reminders_for_idea[idea] = User.users_with_public_or_own_reminders_for_idea(idea, current_user).includes(:profile).limit(2).all
        @users_with_public_or_own_reminders_for_idea_count[idea] = User.users_with_public_or_own_reminders_for_idea(idea, current_user).count("distinct users.id")
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
