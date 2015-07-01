require "active_support"

@crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

namespace :tasks do

  desc "Create Recipients"
  task recipients: :environment do
    User.all.each do |user|
      if user.recipient? && (user.recipient_created.nil?)
        @ssn = @crypt.decrypt_and_verify(user.tax_id)
        @account_number = @crypt.decrypt_and_verify(user.account_number)
        recipient = Stripe::Recipient.create(
          name: user.legal_name,
          type: "individual",
          email: user.email,
          tax_id: @ssn,
          bank_account: {
            country: 'US',
            routing_number: user.routing_number,
            account_number: @account_number,
            } ,
        )
        user.update_attributes(recipient_created: true, stripe_recipient_id: recipient.id)
        user.save!
      end
    end
    puts "Recipients Created"
  end


  desc "Payout every week"
  task payout: :environment do
    User.all.each do |user|
      if user.stripe_recipient_id? && user.pending_payment >= 1
        transfer = Stripe::Transfer.create(
          :amount => (user.pending_payment * 50) / 100,
          :currency => "usd",
          :recipient => user.stripe_recipient_id,
          :description => "Transfer To Merchant #{user.legal_name}",
        )

        user.pending_payment -= transfer.amount
        user.save!

      end
    end
    puts "Payout Complete"
  end
end