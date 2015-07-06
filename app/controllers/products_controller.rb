class ProductsController < ApplicationController
  before_filter :authenticate_user!, except: :index
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all.where(pending: false)
    @pendings = Product.all.where(pending: true)
    authorize @products
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = Product.find(params[:id])
    authorize @product
  end

  # GET /products/new
  def new
    if current_user.stripe_account_id? || current_user.admin?
      @product = Product.new
      authorize @product
    else
      redirect_to edit_user_registration_path
      flash[:error] = "Link Bank Account & Seller Info"
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.friendly.find(params[:id])
    authorize @product
  end

  # POST /products
  # POST /products.json
  def create
    @product = current_user.products.build(product_params)
    if @product.save
      @product.update_attributes(pending: true)
      redirect_to @product
      flash[:alert] ='Product is now pending'
    else
      flash[:error] = "Error creating Product. Try again"
      render :new
    end
    authorize @product
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      flash[:error] = "Error saving Product. Try again"
      render :edit
    end
    authorize @product
  end

  def approve
    @instance = ResumeSkill.find(params[:id])
    @instance.update_attributes(pending: false)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:product_image, :title, :price, :uuid)
    end
end
