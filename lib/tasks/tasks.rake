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