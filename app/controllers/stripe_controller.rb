class StripeController < ApplicationController
  before_action :authenticate_user!

  # Connect yourself to a Stripe account.
  # Only works on the currently logged in user.
  # See app/services/stripe_oauth.rb for #oauth_url details.
  def oauth
    connector = StripeOauth.new( current_user )
    url, error = connector.oauth_url( redirect_uri: stripe_confirm_url )

    if url.nil?
      flash[:error] = error
      redirect_to user_path( current_user )
    else
      redirect_to url
    end
  end

  # Confirm a connection to a Stripe account.
  # Only works on the currently logged in user.
  # See app/services/stripe_connect.rb for #verify! details.
  def confirm
    connector = StripeOauth.new( current_user )
    if params[:code]
      # If we got a 'code' parameter. Then the
      # connection was completed by the user.
      connector.verify!( params[:code] )

    elsif params[:error]
      # If we have an 'error' parameter, it's because the
      # user denied the connection request. Other errors
      # are handled at #oauth_url generation time.
      flash[:error] = "Authorization request denied."
    end

    redirect_to profile_admin_users_path
  end

  # Deauthorize the application from accessing
  # the connected Stripe account.
  # Only works on the currently logged in user.
  def deauthorize
    connector = StripeOauth.new( current_user )
    connector.deauthorize!
    flash[:notice] = "Account disconnected from Stripe."
    redirect_to user_path( current_user )
  end



end
