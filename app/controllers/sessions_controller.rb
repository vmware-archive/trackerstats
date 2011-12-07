class SessionsController < ApplicationController
  def new; end

  def create
    api_token = if params[:username].present? && params[:password].present?
                  PivotalTracker::Client.token(params[:username], params[:password])
                elsif params[:api_token].present?
                  params[:api_token]
                end

    if api_token
      session[:api_token] = api_token
      redirect_to projects_path
    else
      flash[:alert] = "We were not able to authenticate you lah."
      redirect_to :root
    end
  end
end
