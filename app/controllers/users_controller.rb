##
# Users Controller
#
# @example Do something
#   Gold Controller
#
class UsersController < ApplicationController

  around_filter :neo4j_transaction, :only => [:show]


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
      @user = User.find(:uri => params[:id]).first
    end

    if !@user then
      respond_to do |format|
        format.html #error.html.erb
        format.json do
          render :json => {:error => "User '#{params[:id]}' not found."}
        end
      end
    end
  end


  def neo4j_transaction
    Neo4j::Transaction.new
      yield
    Neo4j::Transaction.finish
  end
end