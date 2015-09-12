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
    if !@user.admin?  
      @mail = mail(to: user.email, subject: "Business/Fundraising Account Approved") do |format|
        format.text
        format.html
      end
    end
  end

  def email_blast(sender_email, emails, subject, body)
    @body = body
    emails.each do |email|
      @email = email
      @mail = mail(from: sender_email, to: email, subject: subject) do |format|
        format.text
        format.html
      end
    end
  end
end
