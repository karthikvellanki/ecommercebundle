class RequestsController < ApplicationController
  before_action :set_collection_and_authorize_user, only: [:show, :edit, :update, :destroy, :inventories]
  before_action :authenticate_user!
  before_action :authorize_user, only: [:inventories]
  layout 'dashboard_sidenav'

  def index
    
  end

end
