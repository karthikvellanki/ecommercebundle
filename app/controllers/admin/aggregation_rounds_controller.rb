class Admin::AggregationRoundsController < AggregationRoundsController
  before_action :set_aggregation_round, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :require_admin
  layout 'sidenav'

  # GET /aggregation_rounds
  # GET /aggregation_rounds.json
  def index
    @aggregation_rounds = AggregationRound.all
  end

  # GET /aggregation_rounds/1
  # GET /aggregation_rounds/1.json
  def show
  end

  # GET /aggregation_rounds/new
  def new
    @aggregation_round = AggregationRound.new
  end

  # GET /aggregation_rounds/1/edit
  def edit
  end

  # POST /aggregation_rounds
  # POST /aggregation_rounds.json
  def create
    @aggregation_round = AggregationRound.new(aggregation_round_params)

    respond_to do |format|
      if @aggregation_round.save
        format.html { redirect_to admin_aggregation_round_path(@aggregation_round), notice: 'Aggregation round was successfully created.' }
        format.json { render :show, status: :created, location: @aggregation_round }
      else
        format.html { render :new }
        format.json { render json: @aggregation_round.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /aggregation_rounds/1
  # PATCH/PUT /aggregation_rounds/1.json
  def update
    respond_to do |format|
      if @aggregation_round.update(aggregation_round_params)
        format.html { redirect_to admin_aggregation_round_path(@aggregation_round), notice: 'Aggregation round was successfully updated.' }
        format.json { render :show, status: :ok, location: @aggregation_round }
      else
        format.html { render :edit }
        format.json { render json: @aggregation_round.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /aggregation_rounds/1
  # DELETE /aggregation_rounds/1.json
  def destroy
    @aggregation_round.destroy
    respond_to do |format|
      format.html { redirect_to admin_aggregation_rounds_path, notice: 'Aggregation round was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aggregation_round
      @aggregation_round = AggregationRound.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def aggregation_round_params
      params.require(:aggregation_round).permit(:start_date, :end_date, :qty_limit, :product_id)
    end
end
