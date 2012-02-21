class SessionsController < ApplicationController
  skip_before_filter :authorize

  def new; end

  def create
    tracker_session = TrackerApi.login(username: params[:username], password: params[:password], api_token: params[:api_token])

    if tracker_session
      session[TrackerApi::API_TOKEN_KEY] = tracker_session
      redirect_to projects_path
    else
      redirect_to login_path, alert: "We were not able to authenticate you lah."
    end
  end

  def destroy
    session.clear
    redirect_to login_path, notice: 'Successfully logged out.'
  end
end
