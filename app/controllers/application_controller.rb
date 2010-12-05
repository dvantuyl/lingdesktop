class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected

  def current_user
    if session[:user_uri].nil? then
      @current_user = nil
    else
      @current_user ||= User.find(:uri_esc => session[:user_uri].uri_esc)
    end
    
    @current_user
  end

  def signed_in?
    !!current_user
  end

  helper_method :current_user, :signed_in?

  def current_user=(user)
    @current_user = user
    session[:user_uri] = user.uri
  end
end
