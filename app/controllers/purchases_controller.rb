class PurchasesController < ApplicationController
  before_filter :authenticate_user!
  caches_page :index, :show
  before_action :set_purchase, only: [:show]

  # GET /purchases
  # GET /purchases.json
  def index
    @purchases = Purchase.all.where(user_id: current_user.id).order("refunded DESC")
  end

  # GET /purchases/new
  def new
    @purchase = Purchase.new
  end

  # POST /purchases
  # POST /purchases.json
  def create
    @purchase = Purchase.new(purchase_params)
    if @purchase.save
      redirect_to @purchase, notice: 'Purchase was successfully created.'
    else
      render :new
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase
      @purchase = Purchase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_params
      params[:purchase]
    end
end
