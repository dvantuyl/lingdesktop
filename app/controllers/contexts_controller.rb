##
# Contexts Controller
#
class ContextsController < ApplicationController
  
  # GET /contexts
  def index
    
    # retrieve contexts
    @contexts = RDF_Context.find(
      :all, 
      :conditions => {:is_public => true}, 
      :sort => {:name => :asc}
    )
    
    # return json
    render :json => {
      :data => @contexts.collect {|context| context.to_hash},
      :total => @contexts.count
    }
  end
  
  
  def show
    
    # retrieve context
    @context = RDF_Context.find(params[:id])
        
    if @context then
      respond_to do |format|
        format.html #show.html.erb
        format.json do
          render :json => {
            :data => @context.to_hash,
            :success => true
          }
        end
      end
    else
      respond_to do |format|
        format.html do
          render :status => 404
        end
        format.json do
          render :json => {
            :success => false
          }
        end
      end       
    end
  end
  
end