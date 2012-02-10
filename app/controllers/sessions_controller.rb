class SessionsController < ApplicationController
  skip_before_filter :authorize
  def new; end

  def create
    api_token = if params[:username].present? && params[:password].present?
                  TrackerApi.login(params[:username], params[:password])
                elsif params[:api_token].present?
                  TrackerApi.token = params[:api_token]
                end

    if api_token
      session[TrackerApi::API_TOKEN_KEY] = api_token
      redirect_to projects_path
    else
      flash[:alert] = "We were not able to authenticate you lah."
      redirect_to :root
    end
  end

  def destroy
    session[TrackerApi::API_TOKEN_KEY] = nil
    redirect_to login_path, notice: 'Successfully logged out.'
  end
end
