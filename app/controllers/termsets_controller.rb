##
# Termsets Controller
#
class TermsetsController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy]
  before_filter :find_resource, :only => [:show, :update, :destroy]
  before_filter :init_context

  def index
    termsets = Termset.type.get_subjects(RDF.type => {:context => @context})
    
    respond_to do |format|
      format.json do
        render :json => (termsets.collect do |termset|
          termset.to_hash(
           "rdf:type" => {
             :first => true, 
             :simple_value => :uri,
             :context => @context},

           "rdfs:label" => {
             :first => true, 
             :simple_value => :value, 
             :context => @context},

           "text"=> {
             :predicate => RDF::RDFS.label,
             :first => true, 
             :simple_value => :value, 
             :context => @context},

            "leaf" => {
              :predicate => RDF::GOLD.hasTerm, 
              :empty_xor => false, 
              :context => @context})
        end)
      end
    end
  end
  
  def show
    
    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => {
          :data => @resource.to_hash(
           "rdf:type" => {
             :first => true,
             :simple_value => :uri,
             :context => @context},
           
           "rdfs:label" => { 
             :first => true,
             :simple_value => :value,
             :context => @context},
           
           "rdfs:comment" => {
             :first => true,
             :simple_value => :value,
             :context => @context}),
             
           :success => true
        }
      end
    end
  end


  def create
    @resource = Termset.create_in_context(@context)
    @resource.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  
  def update
    @resource.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  def destroy
    @resource.remove_context(@context)
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  
  private
  
  def init_context
    @context = current_user
  end
  
  def find_resource
    
    @resource = Termset.find(:uri_esc => (RDF::LD.termsets.to_s + "/" + params[:id]).uri_esc)


    if @resource.nil? then
      respond_to do |format|
        format.html #error.html.erb
        format.json do
          render :json => {:error => "Resource '#{params[:id]}' not found."}
        end
      end
    end
    
  end
 
end