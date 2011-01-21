##
# Users Controller
#
# @example Do something
#   Gold Controller
#
class UsersController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy]

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
    # build user URI
    uri = "http://purl.org/linguistics/lingdesktop/users/" +
          params[:email].gsub(/\./, "_dot_").gsub(/@/, "_at_")
    params[:uri_esc] = uri.uri_esc
    
    # clean is_admin checkbox
    if (params.has_key?(:is_admin) && params[:is_admin].empty?)
      params[:is_admin] = false
    elsif (params.has_key?(:is_admin) && params[:is_admin] == "true")
      params[:is_admin] = true
    end
    
    # Create new user
    user = User.new(params)

    # Output response
    respond_to do |format|
      format.json do
        if user.valid? then
          user.save
          render :json => {:success => true}
        else
          render :json => {:success => false, :errors => user.errors}
        end
      end
    end 
  end
  
  def update
    find_user
    
    # clean is_admin checkbox
    if (params.has_key?(:is_admin) && params[:is_admin].empty?)
      params[:is_admin] = false
    elsif (params.has_key?(:is_admin) && params[:is_admin] == "true")
      params[:is_admin] = true
    end
    
    # Update User
    @user.update_attributes(params)
    
    # Output response
    respond_to do |format|
      format.json do
        if @user.valid? then
          @user.save
          render :json => {:success => true}
        else
          render :json => {:success => false, :errors => @user.errors}
        end
      end
    end
    
  end
  
  def destroy
    find_user
  end
  
  private

  def find_user
    
    # find current user
    if params[:id] == "current" then
      @user = current_user if user_signed_in?

    # find user by id
    else
      @user = User.find(:uri_esc => (RDF::LD.users.to_s + "/" + params[:id]).uri_esc)
    end

  end

end