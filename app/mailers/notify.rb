class Notify < ApplicationMailer
	default from: "no-reply@marketplacebase.com", return_path: 'fdwillis7@gmail.com'

  def orders(user, number_pending_emails)
    @user = user
    @pending_count = number_pending_emails

    @mail = mail( to: user.email, subject: "Pending Orders: #{@pending_count}") do |format|
		  format.text
		  format.html
		end
  end

  def refunds(user, number_pending_emails)
    @user = user
    @pending_count = number_pending_emails

    @mail = mail( to: user.email, subject: "Pending Refunds: #{@pending_count}") do |format|
		  format.text
		  format.html
		end
  end

  def account_approved(user)
    @user = user
    @mail = mail(to: user.email, subject: "Business/Fundraising Account Approved") do |format|
      format.text
      format.html
    end
  end
end
