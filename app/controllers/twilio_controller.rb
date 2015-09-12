class TwilioController < ApplicationController
 
  def text_blast
    twilio_text = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    message = params[:text_blast][:message]

    blast_list = current_user.text_lists

    if message && blast_list.count >= 50
      blast_list.each do |num| 

        price = 1 * blast_list.count

        token = User.new_token(current_user, crypt.decrypt_and_verify(current_user.card_number))

        User.charge_for_admin(current_user, price, token.id)

        twilio_text.messages.create from: ENV['TWILIO_NUMBER'], to: num.phone_number, body: message
      end
    else
      redirect_to request.referrer
      flash[:error] = "You Need At Least 50 Numbers For Text Blasts"
    end
  end

  def email_blast

  end
end
