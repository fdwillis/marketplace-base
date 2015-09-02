class PlansController < ApplicationController
  def create
  	
  	amount = (params[:dplan][:amount].gsub(/[^0-9]/i, '').to_i)
    if params[:dplan][:amount].include?(".")
      stripe_amount = amount
    else
      stripe_amount = amount * 100
    end

    plan = params[:dplan]

    Stripe.api_key = Rails.configuration.stripe[:secret_key]

    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    Stripe.api_key = @crypt.decrypt_and_verify(current_user.merchant_secret_key)

	  begin  
	    # check stripe is plan exists, if not create one. 
	    stripe_plan = Stripe::Plan.create(
	    	:amount => amount,
	      :interval => 'month',
	      :name => plan[:name],
	      :currency => 'usd',
	      :id => plan[:uuid]
	    )

	    current_user.donation_plans.create(stripe_subscription_id: stripe_plan.id, currency: 'usd', amount: plan[:amount], uuid: plan[:uuid], name: plan[:name], interval: 'monthly')
	    Stripe.api_key = Rails.configuration.stripe[:secret_key]
	    redirect_to request.referrer
	    flash[:notice] = "You Created Plan #{plan[:name]}"
	  rescue => e
	  	redirect_to request.referrer
	  	flash[:error] = "#{e}"
	  end
  end

  def destroy
  	debugger
  	redirect_to request.referrer
  	return
  end
end

