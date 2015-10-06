class Refund < ActiveRecord::Base
  belongs_to :order
  has_many :returned_products, dependent: :destroy

  accepts_nested_attributes_for :returned_products, reject_if: :all_blank, allow_destroy: true

  validates_numericality_of :amount, greater_than_or_equal_to: 0, presence: true

  protected
  	def self.returns_to_keen(refund, refund_amount)
  		order = refund.order
      if order.application_fee.present?
    		Keen.publish("Refunds", {
          marketplace_name: ENV["MARKETPLACE_NAME"],
          platform_for: 'apparel', 
          year: Time.now.strftime("%Y").to_i,
          month: DateTime.now.to_date.strftime("%B"),
          day: Time.now.strftime("%d").to_i,
          day_of_week: DateTime.now.to_date.strftime("%A"),
          hour: Time.now.strftime("%H").to_i,
          minute: Time.now.strftime("%M").to_i,
          refund_amount: refund_amount, 
          merchant_id: order.merchant_id,
          customer_id: order.user_id,
          order_uuid: order.uuid,
          timestamp: Time.now,
          application_fee: ((Stripe::ApplicationFee.retrieve(order.application_fee).amount).to_f / 100),
          })
      else
        Keen.publish("Refunds", {
    			marketplace_name: ENV["MARKETPLACE_NAME"],
          platform_for: 'apparel', 
          year: Time.now.strftime("%Y").to_i,
          month: DateTime.now.to_date.strftime("%B"),
          day: Time.now.strftime("%d").to_i,
          day_of_week: DateTime.now.to_date.strftime("%A"),
          hour: Time.now.strftime("%H").to_i,
          minute: Time.now.strftime("%M").to_i,
          refund_amount: refund_amount, 
          merchant_id: order.merchant_id,
          customer_id: order.user_id,
          order_uuid: order.uuid,
          timestamp: Time.now,
    			})
      end
  	end
end
