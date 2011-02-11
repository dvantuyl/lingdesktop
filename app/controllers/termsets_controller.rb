##
# Termsets Controller
#
class TermsetsController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy, :clone]
  before_filter :init_context

  def index
    @termsets = Termset.type.get_subjects(RDF.type => {:context => @context})

    render :json => {
          :data => (@termsets.collect do |termset|
            termset.to_hash(
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
                :context => @context})
          end),
          :total => @termsets.length
    }

  end

  def tree
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
             :context => @context}).merge({
               
            "leaf" => false
             })
        end)
      end
    end
  end
  
  def show
    @termset = Termset.find(:uri_esc => (RDF::LD.termsets.to_s + "/" + params[:id]).uri_esc)
    @terms = @termset.get_subjects(RDF::GOLD.memberOf => {:context => @context})
    
    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => {
          :data => @termset.to_hash(
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
    @termset = Termset.create_in_context(@context)
    @termset.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  
  def update
    @termset = Termset.find(:uri_esc => (RDF::LD.termsets.to_s + "/" + params[:id]).uri_esc)
    @termset.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  def destroy
    @termset = Termset.find(:uri_esc => (RDF::LD.termsets.to_s + "/" + params[:id]).uri_esc)
    @termset.remove_context(@context)
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  def clone
    @termset = Termset.find(:uri_esc => (RDF::LD.termsets.to_s + "/" + params[:id]).uri_esc)
    @from_context = RDF_Context.find(params[:from_id])
    
    if @from_context != current_user.context then
      @termset.copy_context(@from_context, current_user.context)
    end
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  
  private
  
  def init_context
    if params.has_key?(:context_id) then
      @context = RDF_Context.find(params[:context_id])
    else
      @context = current_user.context
    end
  end
  
 
end