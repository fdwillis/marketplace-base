class Donation < ActiveRecord::Base
  belongs_to :user
  belongs_to :fundraising_goal

  def self.donations_to_keen(donation, ip_address, location)
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
      donation_year: Time.now.strftime("%Y").to_i,
      donation_month: Time.now.strftime("%B").to_i,
      donation_day: Time.now.strftime("%d").to_i,
      donation_hour: Time.now.strftime("%H").to_i,
      donation_minute: Time.now.strftime("%M").to_i,
      donation_plan_uuid: DonationPlan.find_by(uuid: donation.stripe_subscription_id),
	  })  
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
