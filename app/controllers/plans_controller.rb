class PlansController < ApplicationController
  def create

  	debugger
  	redirect_to request.referrer
  	return

		if params[:user][:donation_plans_attributes]
      Stripe.api_key = Rails.configuration.stripe[:secret_key]

      donation_plans = params[:user][:donation_plans_attributes]

      donation_plans.each do |plan|
        @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
        Stripe.api_key = @crypt.decrypt_and_verify(current_user.merchant_secret_key)

        # check stripe is plan exists, if not create one. 
        Stripe::Plan.create(
          :amount => ((plan[1]['amount'].to_f) * 100).to_i,
          :interval => 'month',
          :name => plan[1]['name'],
          :currency => 'usd',
          :id => plan[1]['uuid']
        )
      end
      Stripe.api_key = Rails.configuration.stripe[:secret_key]
    end
  end

  def destroy
  	debugger
  	redirect_to request.referrer
  	return
  end
end
