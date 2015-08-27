class NotificationsController < ApplicationController
  protect_from_forgery :except => [:create, :twilio]

  def create
    render nothing: true, status: :ok, content_type: "application/json"
    @update = params['msg']
    @order = Order.find_by(tracking_number: @update['tracking_number'])
    @checkpoints = @update['checkpoints']
    @checkpoints.each do |chk|
      @order.shipping_updates.find_or_create_by(message: chk['message'], tag: chk['tag'], checkpoint_time: (chk['checkpoint_time']).to_date , order_id: @order.id)
    end
    @order.update_attributes(status: @order.shipping_updates.last.message)
  end
  def twilio
    render nothing: true, status: :ok, content_type: "application/xml"
    twilio_text = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

    text_message = params[:Body].split
    if text_message[0].to_f.is_a? Numeric
      phone_number = params[:From][2,params[:From].length]
      raiser_username = text_message[1].gsub(/[^a-z]/i, '').downcase
      stripe_amount = text_message[0].gsub(/[^0-9]/i, '').to_i
      donater = User.find_by(support_phone: phone_number)
      fundraiser = User.find_by(username: raiser_username)

      if donater && donater.card?
        @token = User.new_token(donater, @crypt.decrypt_and_verify(donater.card_number))
        if !fundraiser.admin?

          stripe_account_id = @crypt.decrypt_and_verify(fundraiser.stripe_account_id)

          @charge = User.charge_n_process(fundraiser.merchant_secret_key, donater, stripe_amount, @token.id, stripe_account_id )
        else
          User.charge_for_admin(donater, stripe_amount, @token.id)
        end
      end
    else
      #Twilio message back to donater
    end

    Stripe.api_key = Rails.configuration.stripe[:secret_key]

    debugger
    return
    if params[:Body]
      message = twilio_text.messages.create from: '+1(414)422-8186', to: params[:From], body: "Thanks for wanting to donate. https://www.google.com/ "
    end
  end
end




# Need to get or create shipping_update by order.tracking_number?
# 780995494278

# Test CURL
  # curl -X POST -d "msg[checkpoints][][message]=bar&msg[tracking_number]=1Z0F28171596013711&msg[checkpoints][][tag]=tag&msg[checkpoints][][checkpoint_time]=2014-05-02T16:24:38" http://localhost:3000/notifications
