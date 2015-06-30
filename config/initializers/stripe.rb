if Rails.env.development?
  Rails.configuration.stripe = {
    :publishable_key => ENV['PUBLISHABLE_KEY_TEST'],
    :secret_key      => ENV['SECRET_KEY_TEST']
  }
elsif Rails.env.production?
  Rails.configuration.stripe = {
    :publishable_key => ENV['PUBLISHABLE_KEY_LIVE'],
    :secret_key      => ENV['SECRET_KEY_LIVE']
  }
end  

Stripe.api_key = Rails.configuration.stripe[:secret_key]