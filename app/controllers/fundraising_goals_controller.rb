class FundraisingGoalsController < ApplicationController
  before_action :set_fundraising_goal, only: [:show, :edit, :update, :destroy]

  # GET /fundraising_goals
  # GET /fundraising_goals.json
  def index
    @fundraising_goals = FundraisingGoal.all
  end

  # GET /fundraising_goals/1
  # GET /fundraising_goals/1.json
  def show
    authorize @fundraising_goal
  end

  # GET /fundraising_goals/new
  def new
    @fundraising_goal = FundraisingGoal.new
    authorize @fundraising_goal
  end

  # GET /fundraising_goals/1/edit
  def edit
  end

  # POST /fundraising_goals
  # POST /fundraising_goals.json
  def create
    @fundraising_goal = current_user.fundraising_goals.build(fundraising_goal_params)

    respond_to do |format|
      if @fundraising_goal.save
        format.html { redirect_to @fundraising_goal, notice: 'Fundraising goal was successfully created.' }
        format.json { render :show, status: :created, location: @fundraising_goal }
      else
        format.html { render :new }
        format.json { render json: @fundraising_goal.errors, status: :unprocessable_entity }
      end
    end
    authorize @fundraising_goal
  end

  # PATCH/PUT /fundraising_goals/1
  # PATCH/PUT /fundraising_goals/1.json
  def update
    respond_to do |format|
      if @fundraising_goal.update(fundraising_goal_params)
        format.html { redirect_to @fundraising_goal, notice: 'Fundraising goal was successfully updated.' }
        format.json { render :show, status: :ok, location: @fundraising_goal }
      else
        format.html { render :edit }
        format.json { render json: @fundraising_goal.errors, status: :unprocessable_entity }
      end
    end
    authorize @fundraising_goal
  end

  # DELETE /fundraising_goals/1
  # DELETE /fundraising_goals/1.json
  def destroy
    @fundraising_goal.destroy
    respond_to do |format|
      format.html { redirect_to fundraising_goals_url, notice: 'Fundraising goal was successfully destroyed.' }
      format.json { head :no_content }
    end
    authorize @fundraising_goal
  end

  def donation_plan
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fundraising_goal
      @fundraising_goal = FundraisingGoal.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fundraising_goal_params
      params.require(:fundraising_goal).permit(:title, :description, :goal_amount, :backers, :uuid)
    end
end
