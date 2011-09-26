class PagesController < ApplicationController
  
  include ApplicationHelper
  
  def home
    @title = "Home"
    if signed_in?
      store_current_page
      store_location
      init_feeds_table
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
