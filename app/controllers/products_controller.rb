class ProductsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_action :set_product, only: [:show, :edit, :update, :destroy]


#Track For Admin & Merchant on Show page for 'Product Views'

  def index
    @products = Product.all.where(active: true).page(params[:page]).per_page(5)
    @pendings = Product.all.where(active: false)
    @current_orders = current_user.orders.where(status: "Pending Submission").where(active: true)
    authorize @products
  end

  def show
    @product = Product.find(params[:id])
    authorize @product
  end

  def new
    if current_user.merchant_ready? || current_user.admin?
      @product = Product.new
      authorize @product
    else
      redirect_to edit_user_registration_path
      flash[:error] = "You Are Missing Bank Account and or Seller Info"
    end
  end

  def edit
    @product = Product.friendly.find(params[:id])
    authorize @product
  end

  def create
    @product = current_user.products.build(product_params)
    if @product.save
      if !current_user.admin?
        @product.update_attributes(active: false)
        flash[:alert] ="Product #{@product.title} is now pending"
      else
        @product.update_attributes(active: true)
        flash[:notice] ='Product created'
      end
      redirect_to @product
    else
      flash[:error] = "Error creating Product. Try again"
      render :new
    end
    authorize @product
  end

  def update
    if @product.update(product_params)
      if @product.quantity > 0
        @product.update_attributes(status: nil)
      end
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      flash[:error] = "Error saving Product. Try again"
      render :edit
    end
    authorize @product
  end

  def approve
    @instance = ResumeSkill.find(params[:id])
    @instance.update_attributes(active: true)
  end

  private
    def set_product
      @product = Product.friendly.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:quantity, :tag_list, :description, :active, :product_image, :title, :price, :uuid, shipping_options_attributes: [:id, :title, :price, :_destroy])
    end
end
