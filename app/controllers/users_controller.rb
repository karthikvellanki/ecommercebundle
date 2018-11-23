class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:check_user, :auth_token]
  skip_before_filter  :verify_authenticity_token
  before_action :user_profile, except: [:auth_token,:authenticated_user_auth_token, :profile, :update_payment]
  before_action :authorize_user, only: [:show, :update]
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @plans = Stripe::Plan.all
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
      	if params[:domain].present?
      		@user.provider.update!(domain_name: params[:domain])
      	end	
        format.html { redirect_to :back, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def payments
    @user = current_user
    @bank_account = BankAccount.where(user: @user).first
  end

  def update_payment
    client = Plaid::Client.new(env: :development,
                      client_id: '59c520a0bdc6a40ac87ed50c',
                      secret: '2a3e9b59ecb215c481260c8be730ab',
                      public_key: '059ec707e448737f37de0c3e624d16')

    # client = Plaid::Client.new(env: :production,
    #                   client_id: '5ab9fbe4bdc6a44328030e79',
    #                   secret: '0bdb0385b303031536bd5cbc48f288',
    #                   public_key: 'c32b5bd4114d555153aa6b7b7fbb6a')

    exchange_token_response = client.item.public_token.exchange(params[:public_token])
    access_token = exchange_token_response['access_token']
    stripe_response = client.processor.stripe.bank_account_token.create(access_token, params[:account_id])
    bank_account_token = stripe_response['stripe_bank_account_token']

    @bank_account = BankAccount.where(user: current_user).first_or_create
    @bank_account.name = params[:name]
    @bank_account.stripe_customer_token = bank_account_token
    @bank_account.save
  end

  def verify_payment
    @bank_account = BankAccount.where(user: @user).first
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def check_user
    if User.find_by(email: params[:user][:email]).present?
      render nothing:true, status: :ok
    else
      render nothing:true, status: :not_found
    end
  end

  def auth_token
    user = User.find_for_database_authentication(email: params[:email])
    if not user.nil? and user.valid_password?(params[:password])
      render json: {"token": user.auth_token,"user":user.id_dict}
    else
      render json: {errors: ['Invalid Username/Password']}, status: :unauthorized
    end
  end

  def authenticated_user_auth_token
    render json: {"token": current_user.auth_token,"user":current_user.id_dict}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def authorize_user
      if @user.id != current_user.id
        redirect_to "/", notice: 'You are not allowed the given operation' and return
      end
    end

    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :mobile, :sex, :company, :location, :avatar, :email, :shipping_choice, :shipping_account_number, :shippers_name)
    end
end
