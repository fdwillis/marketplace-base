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
end







