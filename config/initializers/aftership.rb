Rails.configuration.aftership = {
  :secret_key      => ENV['AFTERSHIP_KEY']
}

AfterShip.api_key = Rails.configuration.aftership[:secret_key]