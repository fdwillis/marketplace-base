class RefundsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @refunds = Purchase.all.where(merchant_id: current_user.id).where(status: "Pending Refund")
  end
  def create
    #Test refund for admin, might need to filter because admin doesnt have merchant_secret field
    #Track With Keen "refund requests"
    # let merchants handle refunds
    purchase = Purchase.find_by(stripe_charge_id: params[:refund_id])
    purchase.update_attributes(status: "Pending Refund")
    redirect_to purchases_path, alert: "Your Refund Is Pending"
  end
  def update
    #Track With Keen "refunds fullfilled"
    @crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])
    Stripe.api_key = @crypt.decrypt_and_verify(Product.find_by(uuid: params[:uuid]).user.merchant_secret_key)
    ch = Stripe::Charge.retrieve(params[:refund_id])
    refund = ch.refunds.create(refund_application_fee: true, amount: ((params[:price].to_i * 95) / 100))
    purchase = Purchase.find_by(stripe_charge_id: params[:refund_id])
    purchase.update_attributes(status: "Refunded", refunded: true)
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    redirect_to refunds_path, notice: "Refund Fullfilled"
  end
end
