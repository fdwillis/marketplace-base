require "active_support"

@crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

namespace :email do

  desc "Email Pending Orders"
  task orders: :environment do
    User.all.each do |user|
    	orders = Order.all.where(merchant_id: user.id).where(paid: true).where(refunded: (false || nil)).where(tracking_number: nil).count
      if user.account_ready? && orders > 0
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
  		if user.account_ready? && refunds > 0
        Notify.refunds(user, refunds ).deliver_now
        puts Notify.refunds(user, refunds ).message
        puts "email to #{user.email}"
      end
  	end
  end
end

namespace :payout do
  include ActionView::Helpers::NumberHelper

  twilio_text = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
  
  task all: :environment do
    User.all.each do |user|
      crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
      
      if user.merchant_secret_key.present?  
        if user.admin?
          trans_amount = Stripe::Balance.retrieve()['available'][0].amount

          if trans_amount > 10000
            
            Stripe::Transfer.create(
              :amount => Stripe::Balance.retrieve()['available'][0].amount,
              :currency => "usd",
              :destination => crypt.decrypt_and_verify(user.stripe_account_id),
              :description => "Transfer for MarketplaceBase revenue"
            )
          end
        end

        User.decrypt_and_verify(user.merchant_secret_key)          

        if user.team_members.count >= 1
          bal = Stripe::Balance.retrieve()['available'][0].amount
          user.team_members.each_with_index do |member, index|
            if  bal > 10000  
              amounts = user.team_members.map{|t| ((Stripe::Balance.retrieve()['available'][0].amount * t.percent.to_i) / 100 )}
              
                Stripe::Transfer.create(
                  :amount => amounts[index],
                  :currency => "usd",
                  :destination => member.stripe_bank_id,
                  :description => "Transfer for MarketplaceBase revenue"
                )
              puts "Team Paid"
            else
              puts "No Team Payout"
            end
          end
        else
          amount = Stripe::Balance.retrieve()['available'][0].amount
          if  amount > 10000  
            Stripe::Transfer.create(
              :amount => amount,
              :currency => "usd",
              :destination => Stripe::Account.retrieve.bank_accounts.data[0].id,
              :description => "Transfer for MarketplaceBase revenue"
            )
            puts "Non-Team Paid"
          else
            puts "No non-team payout"
          end
        end
      else
        bal = Stripe::Balance.retrieve()['available'][0].amount
        if bal >= 10000  
          transfer = Stripe::Transfer.create(
            :amount => Stripe::Balance.retrieve()['available'][0].amount,
            :currency => "usd",
            :recipient => "self",
          )
          message = twilio_text.messages.create from: ENV['TWILIO_NUMBER'], to: User.find_by(role: 'admin').support_phone, body: "Transferred #{number_to_currency(transfer.amount/100)}"
          puts message.body
        end
      end
      Stripe.api_key = Rails.configuration.stripe[:secret_key]
    end
  end
end