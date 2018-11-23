class SupplierCategoriesController < ApplicationController
  before_action :set_supplier_category, only: [:show, :edit, :update, :destroy]

  # GET /supplier_categories
  # GET /supplier_categories.json
  def index
    @supplier_categories = SupplierCategory.all
  end

  # GET /supplier_categories/1
  # GET /supplier_categories/1.json
  def show
  end

  # GET /supplier_categories/new
  def new
    @supplier_category = SupplierCategory.new
  end

  # GET /supplier_categories/1/edit
  def edit
  end

  # POST /supplier_categories
  # POST /supplier_categories.json
  def create
    @supplier_category = SupplierCategory.new(supplier_category_params)

    respond_to do |format|
      if @supplier_category.save
        format.html { redirect_to @supplier_category, notice: 'Supplier category was successfully created.' }
        format.json { render :show, status: :created, location: @supplier_category }
      else
        format.html { render :new }
        format.json { render json: @supplier_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /supplier_categories/1
  # PATCH/PUT /supplier_categories/1.json
  def update
    respond_to do |format|
      if @supplier_category.update(supplier_category_params)
        format.html { redirect_to @supplier_category, notice: 'Supplier category was successfully updated.' }
        format.json { render :show, status: :ok, location: @supplier_category }
      else
        format.html { render :edit }
        format.json { render json: @supplier_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /supplier_categories/1
  # DELETE /supplier_categories/1.json
  def destroy
    @supplier_category.destroy
    respond_to do |format|
      format.html { redirect_to supplier_categories_url, notice: 'Supplier category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier_category
      @supplier_category = SupplierCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_category_params
      params.require(:supplier_category).permit(:name, :description, :image, :parent_id)
    end
end
