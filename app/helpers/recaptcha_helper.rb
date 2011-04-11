module RecaptchaHelper

  
  #try and verify the captcha response. Then give out a message to flash
  def verify_recaptcha(remote_ip, params)
    
    unless PersonalLog::Application.config.recaptcha[:enable]
      return true
    end

    responce = Net::HTTP.post_form(URI.parse(PersonalLog::Application.config.recaptcha[:api_server_url]),
      { :privatekey => PersonalLog::Application.config.recaptcha[:private_key],
        :remoteip => remote_ip,
        :challenge => params[:recaptcha_challenge_field],
        :response => params[:recaptcha_response_field] })
      
    result = { :status => responce.body.split("\n")[0], 
               :error_code => responce.body.split("\n")[1] }

    if result[:error_code] == "incorrect-captcha-sol"
      flash[:alert] = "The CAPTCHA solution was incorrect. Please re-try"
      return false
    elsif result[:error_code] == 'success'
      return true
    elsif
      flash[:alert] = "There has been a unexpected error with the application. Please contact the administrator. error code: #{result[:error_code]}"
      return false
    end
    return true
  end

end