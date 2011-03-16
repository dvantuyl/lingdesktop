##
# Users Controller
#
# @example Do something
#   Gold Controller
#
class UsersController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy]
  before_filter :find_user, :only => [:show, :update, :destroy, :followers]
  before_filter :clean_checkboxes, :only => [:create, :update]

  def index
    
    @users = User.find(:all, :sort => {:name => :asc})
    
    total = @users.length
    @users = @users[params[:start].to_i, params[:limit].to_i] if(params[:start] && params[:limit])
    
    respond_to do |format|
      format.html #index.html.erb
      format.json do
        render :json => {
          :data => @users.collect {|user| user.to_hash},
          :total => total
        }
      end
    end
  end

  def show
        
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
    #TODO
  end
  
  def followers
    @followers = @user.context.followers
    
    total = @followers.length
    @followers = @followers[params[:start].to_i, params[:limit].to_i] if(params[:start] && params[:limit])
    
    # return json
    respond_to do |format|
      format.json do
        render :json => {
          :data => @followers.collect {|follower| follower.to_hash},
          :total => total
        }
      end
    end
  end
  
  private

  def find_user
    
    # find current user
    if params[:id] == "current" then
      @user = current_user if user_signed_in?

    # find user by id
    else
      @user = User.find(params[:id])
    end

  end
  
  def clean_checkboxes
    # clean is_admin checkbox
    if (params.has_key?(:is_admin) && params[:is_admin].empty?)
      params[:is_admin] = false
    elsif (params.has_key?(:is_admin) && params[:is_admin] == "true")
      params[:is_admin] = true
    end
    
    if (params.has_key?(:is_public) && params[:is_public].empty?)
      params[:is_public] = false
    elsif (params.has_key?(:is_public) && params[:is_public] == "true")
      params[:is_public] = true
    end
  end

end