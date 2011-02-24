require 'development_mail_interceptor'

ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "wappa.be",
  :user_name            => "dan.persa@wappa.be",
  :password             => "Wcrxz70698",
  :authentication       => "plain",
#  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = "remindmetolive.heroku.com"
#ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
