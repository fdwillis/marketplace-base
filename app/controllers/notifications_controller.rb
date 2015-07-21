class NotificationsController < ApplicationController
  protect_from_forgery :except => :create

  def create
    @update = params['msg']
    @purchase = Purchase.find_by(tracking_number: @update['tracking_number'])
    @checkpoints = @update['checkpoints']
    @checkpoints.each do |chk|
      ShippingUpdate.find_or_create_by(message: chk['message'], purchase_id: @purchase.id)
    end
  end
end




# Need to get or create shipping_update by purchase.tracking_number?
# 780995494278