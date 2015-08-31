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
    crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    text_message = params[:Body].split
    
    if text_message[0].to_f >= 1
      phone_number = params[:From][2,params[:From].length]
      raiser_username = text_message[1].downcase
      amount = (text_message[0].gsub(/[^0-9]/i, '').to_i)

      if text_message[0].gsub(/[^0-9]/i, '').length < 3 
        stripe_amount = amount * 100
      else
        stripe_amount = amount
      end

      if text_message[2]  
        donation_type = text_message[2].downcase
        donation_plan = DonationPlan.find_by(amount: stripe_amount.to_f).uuid
      end
      donater = User.find_by(support_phone: phone_number)
      fundraiser = User.find_by(username: raiser_username)
      
      if fundraiser  
        if donater && donater.card?
          token = User.new_token(donater, crypt.decrypt_and_verify(donater.card_number))
          if !fundraiser.admin?
            stripe_account_id = crypt.decrypt_and_verify(fundraiser.stripe_account_id)

            if donation_type == 'monthly'  
              User.subscribe_to_fundraiser(fundraiser.merchant_secret_key, donater, token.id, stripe_account_id, donation_plan)
            else
              User.charge_n_process(fundraiser.merchant_secret_key, donater, stripe_amount, token.id, stripe_account_id )
            end
          else
            if donation_type == 'monthly'  
              User.subscribe_to_admin(donater, token.id, donation_plan )
            else
              User.charge_for_admin(donater, stripe_amount, token.id)
            end
          end

          fundraiser.text_lists.find_or_create_by(phone_number: phone_number)
          Stripe.api_key = Rails.configuration.stripe[:secret_key]
          # Twilio message to thank user for donation
          puts "Thanks for your $#{text_message[0]} donation to #{raiser_username}"
          return
        else
          # Link to enter card info and create user profile
          puts "Please follow link to enter CC details #{url_for controller: :donate, action: :donate, fundraiser_name: raiser_username, amount: stripe_amount, phone_number: phone_number, donation_plan: donation_plan}"
          return
        end
      else
        # twilio message to donater to check the username
        puts "Please enter a valid username to donate to"
        return
      end
    else
      #Twilio message back to donater
      puts "Please enter a dollar amount first, then username of the fundraiser"
      return
    end
  end
end

# Test CURL
  # Tracking
    # curl -X POST -d "msg[checkpoints][][message]=bar&msg[tracking_number]=1Z0F28171596013711&msg[checkpoints][][tag]=tag&msg[checkpoints][][checkpoint_time]=2014-05-02T16:24:38" http://localhost:3000/notifications
  # twilio
    # curl -X POST -d 'Body=90.30 admin&From=+14143997341' http://localhost:3000/notifications/twilio

# Send Twilio Message
  # twilio_text = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
  # message = twilio_text.messages.create from: ENV['TWILIO_NUMBER'], to: '4143997341', body: "Thanks for wanting to donate. https://www.google.com/ "
