# require "active_support"

# @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

# namespace :tasks do

#   desc "Create Recipients"
#   task merchant_ready: :environment do
#     User.all.each do |user|
#       @user = if user.merchant_ready? && !user.stripe_account_id?
        
#         puts 'send an email'
#       end
#     end
#     puts "#{@user}"
#   end
# end

# namespace :keen do
# 	desc "Keen"
# 	task  keen: :environment do
# 		@order = Order.first
# 		Keen.publish("Orders", {
# 				marketplace_name: "MarketplaceBase",
#     		platform_for: 'apparel',
# 				ip_address: request.remote_ip,
#   			customer_zipcode: request.location.zipcode,
# 				customer_city: request.location.city ,
# 				customer_state: request.location.region_name,
# 				customer_country: request.location.country_name,
# 				order_year: Time.now.strftime("%Y").to_i,
# 				order_month: Time.now.strftime("%B").to_i,
# 				order_day: Time.now.strftime("%d").to_i,
# 				order_hour: Time.now.strftime("%H").to_i,
# 				order_minute: Time.now.strftime("%M").to_i,
# 				merchant_username: User.find(@order.merchant_id).username,
# 				customer_name: @order.user.legal_name,
# 				total_price: @order.total_price.to_f,
# 				shipping_price: @order.shipping_price.to_f,
# 				customer_sign_in_count: @order.user.sign_in_count,
# 				order_uuid: @order.uuid,
# 				submit_timestamp: @order.updated_at
# 			})
# 		@order.order_items.each do |oi|
# 			Keen.publish("Order Items", {
# 				marketplace_name: "MarketplaceBase",
#    			platform_for: 'apparel',
# 				ip_address: request.remote_ip,
#   			customer_zipcode: request.location.zipcode,
# 				customer_city: request.location.city ,
# 				customer_state: request.location.region_name,
# 				customer_country: request.location.country_name,
# 				order_year: Time.now.strftime("%Y").to_i,
# 				order_month: Time.now.strftime("%B").to_i,
# 				order_day: Time.now.strftime("%d").to_i,
# 				order_hour: Time.now.strftime("%H").to_i,
# 				order_minute: Time.now.strftime("%M").to_i,
# 				product_tags: oi.product_tags,
# 				price: oi.price.to_f,
# 				quantity: oi.quantity,
# 				total_price: oi.total_price.to_f,
# 				product_uuid: oi.product_uuid,
# 				order_uuid: oi.order.uuid,
# 				shipping_price: oi.shipping_price.to_f,
# 				merchant_username: User.find(@order.merchant_id).username,
#     		customer_name: @order.user.legal_name,
# 				order_item_id: oi.id,
# 				order_total_price: oi.total_price,
# 				})
# 		end
# 		@order.order_items.each do |oi|
# 			Product.find_by(uuid: oi.product_uuid).tags.each do |tag|
# 				Keen.publish("Tags On Ordered Items", {
# 					marketplace_name: "MarketplaceBase",
# 					tag: tag.name, 
# 					order_uuid: oi.order.uuid, 
# 					order_item_id: oi.id,
# 					order_item_product_uuid: oi.product_uuid,
# 					order_total_price: oi.order.total_price.to_f,
# 					order_item_total_price: oi.total_price.to_f, 
# 					})
# 			end
# 		end
# 	end
# 	puts "sent to keen"
# end


# # Most And Least Used Tags
# # ActsAsTaggableOn::Tag.most_used
# # ActsAsTaggableOn::Tag.least_used
