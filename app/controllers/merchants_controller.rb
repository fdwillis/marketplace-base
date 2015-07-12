class MerchantsController < ApplicationController
  def index
    @merchants = User.all.where.not(role:'buyer')
  end

  def show
    #Track for Merchant and Admin
    @name = User.friendly.find(params[:id]).name
    if User.friendly.find(params[:id]).merchant?
      @merchant = User.friendly.find(params[:id])
    else
      redirect_to root_path
      flash[:error] = "#{@name} is no longer selling items"
    end
  end
end
