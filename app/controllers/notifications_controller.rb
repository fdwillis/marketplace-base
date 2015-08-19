class NotificationsController < ApplicationController
  protect_from_forgery :except => [:create, :twilio]

  def create
    render nothing: true, status: :ok, content_type: "application/json"
    @update = params['msg']
    @order = Order.find_by(tracking_number: @update['tracking_number'])
    @checkpoints = @update['checkpoints']
    @checkpoints.each do |chk|
      @order.shipping_updates.find_or_create_by(message: chk['message'], tag: @update['tag'], checkpoint_time: (chk['checkpoint_time']).to_date , order_id: @order.id)
    end
    @order.update_attributes(status: @order.shipping_updates.last.message)
  end
  def twilio
    render nothing: true, status: :ok, content_type: "application/xml"
    if params[:Body]
      client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
      message = client.messages.create from: '+1(414)422-8186', to: params[:From], body: "Thanks for wanting to donate. https://www.google.com/ "
      render plain: message.status
    end
  end
end




# Need to get or create shipping_update by order.tracking_number?
# 780995494278