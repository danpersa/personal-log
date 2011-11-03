class PagesController < ApplicationController
  layout "main"
  
  include ApplicationHelper
  
  def home
    @title = "Home"
    if signed_in?
      store_current_page
      store_location
      @idea = Idea.new
      @remind_me_too_location = HOME_PAGE_LOCATION
      @reminder = Reminder.new
      init_feeds_table
      render :layout => "application"
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
