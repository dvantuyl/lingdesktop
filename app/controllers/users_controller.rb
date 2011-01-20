##
# Users Controller
#
# @example Do something
#   Gold Controller
#
class UsersController < ApplicationController

  def index
    
    @users = User.find(:all, :sort => {:name => :asc})
    
    respond_to do |format|
      format.html #index.html.erb
      format.json do
        render :json => {
          :data => @users.collect {|user| user.to_hash},
          :total => @users.length
        }
      end
    end
  end

  def show
    find_user

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        if !@user.nil? then
          render :json => {:success => true, :data => @user.to_hash}
        else
          render :json => {:success => false, :error => "User '#{params[:id]}' not found."}
        end
      end
    end
  end
  
  def create
    
    uri = "http://purl.org/linguistics/lingdesktop/users/" +
      params[:user][:email].split("@").last +
      "/" +
      params[:user][:email].split("@").first
      
    resource.uri_esc = uri.uri_esc
    
    if resource.save

    else
      clean_up_passwords(resource)
    end
  end
  
  private

  def find_user
    
    # find current user
    if params[:id] == "current" then
      @user = current_user if user_signed_in?

    # find user by id
    else
      @user = User.find(:uri_esc => params[:id].uri_esc)
    end

  end

end