require "active_support"

@crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

namespace :tasks do

  desc "Create Recipients"
  task recipients: :environment do
    User.all.each do |user|
      if user.recipient?  
        @ssn = @crypt.decrypt_and_verify(user.tax_id)
        @account_number = @crypt.decrypt_and_verify(user.account_number)
      end
    end
    puts "Recipients Created"
  end


  desc "Payout every week"
  task payout: :environment do
    User.all.each do |user|
      if user.card?  
        @card = @crypt.decrypt_and_verify(user.card_number)
      end
    end
    puts "Payout Complete"
  end
end