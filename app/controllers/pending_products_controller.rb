class PendingProductsController < ApplicationController

  def index
    @pendings = Product.all.where(active: false)
  end

  def approve_product
    @instance = Product.find(params[:id])
    @instance.update_attributes(active: true)
    flash[:notice] = 'Item Approved'
    redirect_to pending_products_path
  end
end
