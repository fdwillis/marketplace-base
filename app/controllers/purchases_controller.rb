class PurchasesController < ApplicationController
  before_filter :authenticate_user!
  caches_page :index,
  
  # GET /purchases
  # GET /purchases.json
  def index
    @purchases = Purchase.all.where(user_id: current_user.id).order("refunded DESC")
  end
end
