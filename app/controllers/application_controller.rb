class ApplicationController < ActionController::Base
  before_filter :authorize
  protect_from_forgery

protected
  def authorized?
    !session[TrackerApi::API_TOKEN_KEY].nil?
  end
  helper_method :authorized?

  def authorize
    redirect_to login_path unless self.authorized?
  end
end
