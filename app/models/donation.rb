class Donation < ActiveRecord::Base
  belongs_to :user
  belongs_to :fundraising_goal
  protected
	  def self.donations_to_keen(donation, ip_address, location, web_or_text)
	  	# One time or subscription plan
			if web_or_text == 'text'
				Keen.publish("Donations", {
			    marketplace_name: "MarketplaceBase",
			    platform_for: 'donations',
			    donation_amount: (donation.amount / 100).to_f,
			    donation_type: donation.donation_type,
			    ip_address: ip_address, 
			    customer_id: donation.user_id,
			    customer_current_zipcode: location["zipcode"],
		      customer_current_city: location["city"] ,
		      customer_current_state: location["region_name"],
		      customer_current_country: location["country_name"],
		      customer_sign_in_count: donation.user.sign_in_count,
		      year: Time.now.strftime("%Y").to_i,
		      month: DateTime.now.to_date.strftime("%B"),
		      day: Time.now.strftime("%d").to_i,
		      day_of_week: DateTime.now.to_date.strftime("%A"),
		      hour: Time.now.strftime("%H").to_i,
		      minute: Time.now.strftime("%M").to_i,
		      donation_plan_uuid: donation.stripe_subscription_id,
		      application_fee: donation.application_fee,
		      timestamp: Time.now,
		      donate_by: web_or_text,
			  })  
		  else	
				if !donation.application_fee.nil?  
				  Keen.publish("Donations", {
				    marketplace_name: "MarketplaceBase",
				    platform_for: 'donations',
				    donation_amount: (donation.amount / 100).to_f,
				    donation_type: donation.donation_type,
				    ip_address: ip_address, 
				    customer_id: donation.user_id,
				    fundraising_goal_uuid: donation.fundraising_goal.uuid,
				    merchant_id: donation.fundraising_goal.user_id,
				    customer_current_zipcode: location["zipcode"],
			      customer_current_city: location["city"] ,
			      customer_current_state: location["region_name"],
			      customer_current_country: location["country_name"],
			      customer_sign_in_count: donation.user.sign_in_count,
			      year: Time.now.strftime("%Y").to_i,
			      month: DateTime.now.to_date.strftime("%B"),
			      day: Time.now.strftime("%d").to_i,
			      day_of_week: DateTime.now.to_date.strftime("%A"),
			      hour: Time.now.strftime("%H").to_i,
			      minute: Time.now.strftime("%M").to_i,
			      donation_plan_uuid: donation.stripe_subscription_id,
			      application_fee: donation.application_fee,
			      timestamp: Time.now,
			      donate_by: web_or_text,
				  })  
				else
				  Keen.publish("Donations", {
				    marketplace_name: "MarketplaceBase",
				    platform_for: 'donations',
				    donation_amount: (donation.amount / 100).to_f,
				    donation_type: donation.donation_type,
				    ip_address: ip_address, 
				    customer_id: donation.user_id,
				    fundraising_goal_uuid: donation.fundraising_goal.uuid,
				    merchant_id: donation.fundraising_goal.user_id,
				    customer_current_zipcode: location["zipcode"],
			      customer_current_city: location["city"] ,
			      customer_current_state: location["region_name"],
			      customer_current_country: location["country_name"],
			      customer_sign_in_count: donation.user.sign_in_count,
			      year: Time.now.strftime("%Y").to_i,
			      month: DateTime.now.to_date.strftime("%B"),
			      day: Time.now.strftime("%d").to_i,
			      day_of_week: DateTime.now.to_date.strftime("%A"),
			      hour: Time.now.strftime("%H").to_i,
			      minute: Time.now.strftime("%M").to_i,
			      donation_plan_uuid: donation.stripe_subscription_id,
			      timestamp: Time.now,
			      donate_by: web_or_text,
			    })
				end
				#tags on each fundraising goal
				if !donation.fundraising_goal.tags.empty?  
				  donation.fundraising_goal.tags.each do |tag|
					  Keen.publish("Tags On Fundraising Goals", {
					  	marketplace_name: "MarketplaceBase", 
					  	platform_for: 'donations', 
					  	tag: tag.name,
					  	fundraising_goal_uuid: donation.fundraising_goal.uuid,
					  	donation_amount: (donation.amount / 100).to_f,
					  	fundraising_goal_amount: donation.fundraising_goal.goal_amount,
					  	donation_uuid: donation.uuid,
					  	donation_type: donation.donation_type,
					  	})
				  end
				else
				  donation.fundraising_goal.tags.each do |tag|
					  Keen.publish("Tags On Fundraising Goals", {
					  	marketplace_name: "MarketplaceBase", 
					  	platform_for: 'donations', 
					  	tag: "None",
					  	fundraising_goal_uuid: donation.fundraising_goal.uuid,
					  	donation_amount: (donation.amount / 100).to_f,
					  	fundraising_goal_amount: donation.fundraising_goal.goal_amount,
					  	donation_uuid: donation.uuid,
					  	donation_type: donation.donation_type,
					  	})
				  end
			  end
			end
	  end

	  def self.monthly_canceled(donation)
	  	if !donation.application_fee.nil?
		  	Keen.publish("Cancel Monthly Donation", {
		  		marketplace_name: "MarketplaceBase",
	        platform_for: 'donations',
	        donation_amount: (donation.amount / 100).to_f,
			    donation_type: donation.donation_type,
			    customer_id: donation.user_id,
			    fundraising_goal_uuid: donation.fundraising_goal.uuid,
			    merchant_id: donation.fundraising_goal.user_id,
		      year: Time.now.strftime("%Y").to_i,
		      month: DateTime.now.to_date.strftime("%B"),
		      day: Time.now.strftime("%d").to_i,
		      day_of_week: DateTime.now.to_date.strftime("%A"),
		      hour: Time.now.strftime("%H").to_i,
		      minute: Time.now.strftime("%M").to_i,
		      donation_plan_uuid: donation.stripe_subscription_id,
		      application_fee: donation.application_fee,
		      timestamp: Time.now,
		  		})
		  else
		  	Keen.publish("Cancel Monthly Donation", {
		  		marketplace_name: "MarketplaceBase",
	        platform_for: 'donations',
	        donation_amount: (donation.amount / 100).to_f,
			    donation_type: donation.donation_type,
			    customer_id: donation.user_id,
			    fundraising_goal_uuid: donation.fundraising_goal.uuid,
			    merchant_id: donation.fundraising_goal.user_id,
		      year: Time.now.strftime("%Y").to_i,
		      month: DateTime.now.to_date.strftime("%B"),
		      day: Time.now.strftime("%d").to_i,
		      day_of_week: DateTime.now.to_date.strftime("%A"),
		      hour: Time.now.strftime("%H").to_i,
		      minute: Time.now.strftime("%M").to_i,
		      donation_plan_uuid: donation.stripe_subscription_id,
		      timestamp: Time.now,
		  		})
		  end
	  end
end
