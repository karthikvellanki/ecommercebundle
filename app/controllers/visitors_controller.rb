class VisitorsController < ApplicationController
layout "visitor"
  # GET /user_onboards
  # GET /user_onboards.json
  def index
    @categories = Category.all
		if current_user.present?
      if current_user.is_provider
        redirect_to admin_products_path
      elsif params[:provider_id].present?
        redirect_to categories_path
      end
    end
    @new_user = User.new
  end

  # GET /user_onboards/1
  # GET /user_onboards/1.json
  def show
  end

  # GET /user_onboards/new
  def new
  end

  # GET /user_onboards/1/edit
  def edit
  end

  # POST /user_onboards
  # POST /user_onboards.json
  def create

  end

  # PATCH/PUT /user_onboards/1
  # PATCH/PUT /user_onboards/1.json
  def update

  end

  def destroy

  end

  def privacy
    render layout: false
  end

  def terms
    render layout: false
  end

  def supplier

  end

  def send_message
      from_param = params[:name]
      email_param = params[:email]
      message_param = params[:message]
      VisitorsContactUsJob.perform_now(from_param, email_param, message_param)
  end

end
