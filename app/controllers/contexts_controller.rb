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
    ).to_a
    
    total = @contexts.length
    @contexts = @contexts[params[:start].to_i, params[:limit].to_i] if(params[:start] && params[:limit])
    
    # return json
    render :json => {
      :data => @contexts.collect {|context| context.to_hash},
      :total => total
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
        format.rdf do
          render :text => (
            RDF::Writer.for(:ntriples).buffer do |writer|
              @context.statements.each do |statement|
                writer << statement.rdf
              end
            end
          )
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