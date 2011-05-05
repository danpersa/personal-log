class PagesController < ApplicationController
  def home
    @title = "Home"
    if signed_in?
      @idea = Idea.new
      @reminder = Reminder.new
      @feed_items = current_user.feed.limit(50)
      @public_reminders_for_idea_group_by_user = {}
      @feed_items.each do |idea|
        @public_reminders_for_idea_group_by_user[idea] = Reminder.public_or_users_reminders_for_idea_group_by_user(idea, current_user)
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
