class PurchasesController < ApplicationController
  before_filter :authenticate_user!  

  #Track for admin?
  def index
    @purchases = Purchase.all.where(user_id: current_user.id).order("refunded ASC")
  end
end
