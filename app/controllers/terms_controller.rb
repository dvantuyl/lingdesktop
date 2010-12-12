##
# Termsets Controller
#
class TermsController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy]
  before_filter :find_resource, :only => [:show, :update, :destroy, :hasMeaning]
  before_filter :init_context

  def index
    termset = Termset.find(:uri_esc => (RDF::LD.termsets.to_s + "/" + params[:termset_id]).uri_esc)
    terms = termset.get_subjects(RDF::GOLD.memberOf => {:context => @context})
    
    respond_to do |format|
      format.json do
        render :json => (terms.collect do |term|
          term.to_hash(
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
             :context => @context}).merge({
            
           "leaf" => true
               
            })
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
             :context => @context},
             
            "gold:abbreviation" => {
              :first => true,
              :simple_value => :value,
              :context => @context
            }),
             
           :success => true
        }
      end
    end
  end


  def create
    @resource = Term.create_in_context(@context)
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
  
  def hasMeaning
    meaning_nodes = @resource.get_objects(RDF::GOLD.hasMeaning => {:context => @context})
    
    respond_to do |format|
      format.html #individuals.html.erb
      format.json do 
        render :json => ({
          :data => (meaning_nodes.collect do |node|
            node.to_hash(
              "rdf:type" => {
                :first => true, 
                :simple_value => :uri, 
                :context => @gold_context},
                
              "rdfs:label" => { 
                :first => true, 
                :simple_value => :value, 
                :context => @gold_context},
                
              "rdfs:comment" => {
                :first => true, 
                :simple_value => :value, 
                :context => @gold_context})
          end),
          :total => meaning_nodes.length
        })
      end
    end
  end
  
  
  private
  
  def init_context
    @context = current_user
    @gold_context = RDF_Context.find(:uri_esc =>"http://purl.org/linguistics/gold".uri_esc)
  end
  
  def find_resource
    
    @resource = Term.find(:uri_esc => (RDF::LD.terms.to_s + "/" + params[:id]).uri_esc)


    if @resource.nil? then
      respond_to do |format|
        format.html #error.html.erb
        format.json do
          render :json => {:error => "Term '#{params[:id]}' not found."}
        end
      end
    end
    
  end
 
end