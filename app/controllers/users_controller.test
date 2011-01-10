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
        render :json => @user.to_hash
      end
    end
  end
  
  private

  def find_user
    
    # find current user
    if params[:id] == "current" then
      @user = current_user
    # find user by id
    else
      @user = User.find(:uri_esc => params[:id].uri_esc)
    end

    if @user.nil? then
      respond_to do |format|
        format.html #error.html.erb
        format.json do
          render :json => {:error => "User '#{params[:id]}' not found."}
        end
      end
    end
  end

end