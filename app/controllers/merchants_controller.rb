class MerchantsController < ApplicationController
  def index
    no_buyers = User.joins(:roles).where.not(roles: {title: 'buyer'})
    @merchants = no_buyers.where(account_approved: true)
    @pending = no_buyers.where(account_approved: false)
  end

  def show
    #Track for Merchant and Admin
    @name = User.friendly.find(params[:id]).name
    if User.friendly.find(params[:id]).account_approved? || User.friendly.find(params[:id]).admin?
      @merchant = User.friendly.find(params[:id])
      @products = @merchant.products.where(active:true)
      if current_user != @merchant || !current_user
        if current_user
          User.profile_views(current_user.id, request.remote_ip, request.location.data, @merchant)
        else
          User.profile_views(0, request.remote_ip, request.location.data, @merchant)
        end
      end
    else
      redirect_to root_path
      flash[:error] = "#{@name} is no longer selling items"
    end
  end

  def approve_merchant
    @merchant = User.find_by(username: params[:username])
    @merchant.update_attributes(account_approved: true )
    redirect_to merchants_path
    flash[:notice] = "#{@merchant.username.capitalize}'s Account Was Approved"
  end
end
