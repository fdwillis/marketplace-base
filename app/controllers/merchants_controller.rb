class MerchantsController < ApplicationController
  def index
    @merchants = User.all.where.not(role:'buyer')
  end

  def show
    @merchant = User.friendly.find(params[:id])
  end
end
