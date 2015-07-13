require "active_support"

@crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

namespace :tasks do

  desc "Create Recipients"
  task merchant_ready: :environment do
    User.all.each do |user|
      @user = if user.merchant_ready? && !user.stripe_account_id?
        
        puts 'send an email'
      end
    end
    puts "#{@user}"
  end

  task update_balance: :environment do
    User.all.each do |user|
      if user.merchant?
        @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
        Stripe.api_key = @crypt.decrypt_and_verify(user.merchant_secret_key)
        pending_payment = Stripe::Balance.retrieve.pending[0].amount
        available_balance = Stripe::Balance.retrieve.available[0].amount
        transfer = Stripe::Transfer.all.data[0]
        # Transfer.create(user_id: user.id, marketplace_stripe_id: user.marketplace_stripe_id, date_created: transfer.created, amount: transfer.amount, status: Time.at(transfer.status).to_date)
        user.update_attributes(pending_payment: pending_payment, available_balance: available_balance)
      end
    end
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    puts "Updated Balance & Transfers"
  end
end


# Most And Least Used Tags
# ActsAsTaggableOn::Tag.most_used
# ActsAsTaggableOn::Tag.least_used
