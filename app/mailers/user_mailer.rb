class UserMailer < ActionMailer::Base
  default :from => "register@remindmetolive.com"
  
  def registration_confirmation(user)
    @user = user
    attachments["rails.png"] = File.read("#{Rails.root}/public/images/rails.png")
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Registered")
  end
  
  def reset_password(user)
    @user = user
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Reset Password")
  end
end
