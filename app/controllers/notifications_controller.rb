class NotificationsController < ApplicationController
  protect_from_forgery :except => :create

  def create
    render status: :ok
    @update = params[:msg]
    @purchase = Purchase.find_by(tracking_number: @update['tracking_number'])
    @purchase.shipping_update.find_or_create_by_tag_and_message_and_checkpoint_time(tag: @update['checkpoints']['tag'], message: @update['checkpoints']['message'], checkpoint_time: @update['checkpoints']['checkpoint_time'])
    render nothing: true
  end
end




# Need to get or create shipping_update by purchase.tracking_number?
# 780995494279