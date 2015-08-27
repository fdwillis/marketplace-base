require "active_support"

@crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

namespace :email do

  desc "Create Recipients"
  task pending_orders: :environment do
    User.all.each do |user|
    	pending_orders = Order.all.where(merchant_id: user.id).where(paid: true).where(refunded: (false || nil)).where(tracking_number: nil).count
      if user.merchant_ready? && pending_orders > 0
        Notify.pending_orders(user, pending_orders ).deliver_now
        puts Notify.pending_orders(user, pending_orders ).message
        puts "email to #{user.email}"
      end
    end
  end
end