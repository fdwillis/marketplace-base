if Rails.env.development?
  Rails.configuration.twilio = {
    :account_sid => ENV['TWILIO_ACCOUNT_SID'],
    :auth_token      => ENV['TWILIO_AUTH_TOKEN']
  }
elsif Rails.env.production?
  Rails.configuration.twilio = {
    :account_sid => ENV['TWILIO_ACCOUNT_SID'],
    :auth_token      => ENV['TWILIO_AUTH_TOKEN']
  }
end  

