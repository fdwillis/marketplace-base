class RefundsController < ApplicationController
  before_filter :authenticate_user!
  def create
    #Track With Keen
    ch = Stripe::Charge.retrieve(params[:refund_id])
    refund = ch.refunds.create

    purchase = Purchase.find_by(stripe_charge_id: params[:refund_id])
    purchase.update_attributes(refunded: true)

    price = purchase.price
    merchant60 = (price * 60) / 100
    admin40 = price - merchant60

    merchant = User.find(purchase.merchant_id)
    admin = User.find_by(role: 'admin')

    merchant.pending_payment -= merchant60
    merchant.save!

    admin.pending_payment -= admin40
    admin.save!

    redirect_to purchases_path, notice: "Your Purchase Will Be Refunded"
  end
end
