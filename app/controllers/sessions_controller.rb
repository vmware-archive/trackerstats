class SessionsController < ApplicationController
  def new; end

  def create
    if params[:api_token].present?
      session[:api_token] = params[:api_token]
      redirect_to projects_path
    else
      flash[:alert] = "Please enter your Pivotal Tracker API token."
      render :new
    end
  end
end
