##
# Groups Controller
#
class GroupsController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy]
  
  # GET /users/1/groups
  # GET /groups
  def index
    
    # retrieve groups
    if params.has_key?(:user_id) then
      user = User.find(params[:user_id])
      @groups = user.groups
    else
      @groups = Group.find(:all, :sort => {:name => :asc})
    end
    
    # return json
    render :json => {
      :data => @groups.collect {|group| group.to_hash},
      :total => @groups.count
    }
  end
  
  
  def show
    
    # retrieve group
    @group = Group.find(params[:id])
    
    # return json      
    if @group then
      render :json => {
        :data => @group.to_hash,
        :success => true
      }
    else
      render :json => {
        :success => false
      }          
    end

  
  end
  
  def create
    @group = Group.new(
      :name => params[:name],
      :description => params[:description],
      :curator => current_user)
    @group.set_members(params[:members])

    #render json
    if @group.save then
      render :json => {
        :success => true
      }
    else
      render :json => {
        :success => false,
        :errors => @group.errors
      }          
    end
  end
  
  def update
    @group = Group.find(params[:id])
    @group.update_attributes(
      :name => params[:name],
      :description => params[:description])
    @group.set_members(params[:members])
    
    if @group.save then
      render :json => {
        :success => true
      }
    else
      render :json => {
        :success => false,
        :errors => @group.errors
      }
    end
  end
  
  def delete
    
  end
  
  def members
    @group = Group.find(params[:id])
    
    # return json       
    if @group then
      render :json => {
        :data => @group.members.collect {|member| member.to_hash},
        :total => @group.members.count,
        :success => true
      }
    else
      render :json => {
        :success => false
      }          
    end  
  end
  
end