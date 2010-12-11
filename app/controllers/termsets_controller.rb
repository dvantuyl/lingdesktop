##
# Termsets Controller
#
class TermsetsController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create]
  
  before_filter :init_context

  def index
    termsets = Termset.type.get_subjects(RDF.type => {:context => @context})
    
    respond_to do |format|
      format.json do
        render :json => (termsets.collect do |sc|
          sc.to_hash(
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

  def create
      termset = Termset.create_in_context(@context)
      termset.set(params, @context)
    
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
 
end