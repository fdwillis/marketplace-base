class PlansController < ApplicationController
	def index
		
	end
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
		  exitsting_plans = Stripe::Plan.all.data
		  if !exitsting_plans.map(&:amount).include? stripe_amount
		    # check stripe is plan exists, if not create one. 
		    stripe_plan = Stripe::Plan.create(
		    	:amount => stripe_amount,
		      :interval => 'month',
		      :name => plan[:name],
		      :currency => 'usd',
		      :id => plan[:uuid]
		    )
		  else
		  	redirect_to request.referrer
		  	flash[:error] = "You Have A Plan For This Amount"
		  	return
		  end

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
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    Stripe.api_key = @crypt.decrypt_and_verify(current_user.merchant_secret_key)

  	plan = Stripe::Plan.retrieve(params[:id])
		plan.delete
  	redirect_to request.referrer
  	flash[:notice] = "Successfully Deleted Donation Plan"

    current_user.donation_plans.find_by(uuid: params[:id]).delete
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
  end
end

