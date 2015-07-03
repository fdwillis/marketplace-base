class MerchantsController < ApplicationController
  def index
    @merchants = User.all
  end

  def show
    @merchant = User.find(params[:id])
  end
end
