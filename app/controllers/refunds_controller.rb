class RefundsController < ApplicationController
  before_filter :authenticate_user!
  def create
    ch = Stripe::Charge.retrieve(params[:refund_id])
    refund = ch.refunds.create
    purchase = Purchase.find_by(stripe_charge_id: params[:refund_id])
    purchase.update_attributes(refunded: true)
    redirect_to purchases_path, notice: "Your Purchase Will Be Refunded"
  end
end
