class TransfersController < ApplicationController
  def index
    @transfers = Transfer.all.where(marketplace_stripe_id: current_user.marketplace_stripe_id)
  end
end
