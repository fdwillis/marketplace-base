require "active_support"

@crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

namespace :email do

  desc "Email Pending Orders"
  task orders: :environment do
    User.all.each do |user|
    	orders = Order.all.where(merchant_id: user.id).where(paid: true).where(refunded: (false || nil)).where(tracking_number: nil).count
      if user.merchant_ready? && orders > 0
        Notify.orders(user, orders ).deliver_now
        puts Notify.orders(user, orders ).message
        puts "email to #{user.email}"
      end
    end
  end

  desc "Email Pending Refunds"
  task refunds: :environment do
  	User.all.each do |user|
  		refunds = Refund.all.where(merchant_id: user.id).where(status: "Pending").count
  		if user.merchant_ready? && refunds > 0
        Notify.refunds(user, refunds ).deliver_now
        puts Notify.refunds(user, refunds ).message
        puts "email to #{user.email}"
      end
  	end
  end
end

namespace :payout do
  task teams: :environment do
    User.all.each do |user|
      crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

      if !user.team_members.empty? && user.admin?
        trans_amount = ((Stripe::Balance.retrieve()['available'][0].amount * 1) / 100).to_i

        if trans_amount > 0
          
          Stripe::Transfer.create(
            :amount => trans_amount,
            :currency => "usd",
            :destination => crypt.decrypt_and_verify(user.stripe_account_id),
            :description => "Transfer for MarketplaceBase revenue"
          )
        end
        User.decrypt_and_verify(user.merchant_secret_key)          
        bal = Stripe::Balance.retrieve()['available'][0].amount
        amounts = user.team_members.map{|t| ((bal * t.percent.to_i) / 100 )}
        
        user.team_members.each_with_index do |member, index|
          debugger
          Stripe::Transfer.create(
            :amount => amounts[index],
            :currency => "usd",
            :destination => member.stripe_bank_id,
            :description => "Transfer for MarketplaceBase revenue"
          )
        end
      elsif !user.team_members.empty? && !user.admin?
        debugger
        User.decrypt_and_verify(user.merchant_secret_key)          
        bal = 100000 #Stripe::Balance.retrieve()['available'][0].amount
        amounts = user.team_members.map{|t| ((bal * t.percent.to_i) / 100 )}
        
        user.team_members.each_with_index do |member, index|
          debugger
          Stripe::Transfer.create(
            :amount => amounts[index],
            :currency => "usd",
            :destination => member.stripe_bank_id,
            :description => "Transfer for MarketplaceBase revenue"
          )
        end
      end
      Stripe.api_key = Rails.configuration.stripe[:secret_key]
    end
  end
end