class PendingProductsController < ApplicationController

  def index
    @pendings = Product.all.where(pending: true)
  end

  def approve_product
    @instance = Product.find(params[:id])
    @instance.update_attributes(pending: false)
    flash[:notice] = 'Item Approved'
    redirect_to root_path
  end

end
