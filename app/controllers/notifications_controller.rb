class NotificationsController < ApplicationController
  protect_from_forgery :except => :create

  def create
    @update = params['msg']
    @purchase = Purchase.find_by(tracking_number: @update['tracking_number'])
    @purchase.shipping_updates.create(message: @update['checkpoints']['message'])
    render status: :ok
    render nothing: true
  end
end




# Need to get or create shipping_update by purchase.tracking_number?
# 780995494278