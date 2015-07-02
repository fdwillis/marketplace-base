class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@marketplacebase.com"
  layout 'mailer'

  def payout(user)
    @user = user
    mail( to: @user.email, subject: "MarketplaceBase Payout") do |format|
      format.text
      format.html
    end
  end
end
