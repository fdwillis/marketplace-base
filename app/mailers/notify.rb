class Notify < ApplicationMailer
	default from: "no-reply@marketplacebase.com", return_path: 'fdwillis7@gmail.com'

  def pending_orders(user, number_pending_emails)
    @user = user
    @pending_count = number_pending_emails

    @mail = mail( to: 'fdwillis7@gmail.com', subject: "Pending Orders: #{@pending_count}") do |format|
		  format.text
		  format.html
		end
  end
end
