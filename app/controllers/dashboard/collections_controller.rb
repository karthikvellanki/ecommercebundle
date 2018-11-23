class Dashboard::CollectionsController < CollectionsController
  before_action :set_collection_and_authorize_user, only: [:show, :edit, :update, :destroy, :inventories]
  before_action :authenticate_user!
  before_action :authorize_user, only: [:inventories]
  layout 'dashboard_sidenav'

  # GET /collections
  # GET /collections.json
  def index
    @collections = Collection.where(user: current_user)
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
    @inventories = CollectionInventory.where(collection: @collection).map{|c| c.inventory}
  end

  def inventories
    inventories = CollectionInventory.where(collection: @collection).map{|c| c.inventory}
    if not params[:q].blank?
      inventories = inventories.select {|i| i.name and i.name.downcase.include? params[:q].downcase}
    end
    respond_to do |format|
      format.json do
        render json: inventories
      end
    end
  end

  # GET /collections/new
  def new
    @collection = Collection.new
    @collection.build_picture
  end

  # GET /collections/1/edit
  def edit
    if not @collection.picture.present?
      @collection.build_picture
    end
  end

  # POST /collections
  # POST /collections.json
  def create
    create_params = collection_params
    create_params[:user_id] = current_user.id
    @collection = Collection.new(create_params)

    respond_to do |format|
      if @collection.save
        format.html { redirect_to dashboard_collection_path(@collection), notice: 'Collection was successfully created.' }
        format.json { render json: @collection}
      else
        format.html { render :new }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1
  # PATCH/PUT /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to dashboard_collection_path(@collection), notice: 'Collection was successfully updated.' }
        format.json {  render json: @collection }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy
    CollectionInventory.where(collection: @collection).each do |c|
      i = c.inventory
      c.destroy
      i.destroy
    end
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: 'Collection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def destroy_multiple
    categories = Collection.where(user: current_user, :id => params[:collection_ids])
    categories.destroy_all

    respond_to do |format|
      format.html { redirect_to dashboard_collections_path, notice: 'Product Deleted' }
      format.json { head :no_content}
    end
  end

  private
    def authorize_user
      if params[:user_id] != current_user.id.to_s
        render json: {"error":"You are not authorized for this action"}, :status => 401 and return
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_collection_and_authorize_user
      @collection = Collection.find(params[:id])
      if @collection.user != current_user
        render json: {"error":"You are not authorized for this action"}, :status => 401 and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_params
      params.require(:collection).permit(:name,:description,:picture_id,:user_id,picture_attributes: [:picture_file])
    end
end
