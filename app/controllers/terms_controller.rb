##
# Termsets Controller
#
class TermsController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy, :clone]
  before_filter :init_context

  def index
    @terms = Term.type.get_subjects(RDF.type => {:context => @context})
    
    total = @terms.length
    @terms = @terms[params[:start].to_i, params[:limit].to_i] if(params[:start] && params[:limit])
    

    render :json => {
          :data => (@terms.collect do |term|
            term.to_hash(
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
          :total => total
    }

  end

  def show
    @term = Term.find(:uri_esc => (RDF::LD.terms.to_s + "/" + params[:id]).uri_esc)
    @meaning_nodes = @term.get_objects(RDF::GOLD.hasMeaning => {:context => @context})

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => {
          :data => @term.to_hash(
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
    @term = Term.create_in_context(@context)
    @term.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @term.to_hash(
            "rdfs:label" => { 
              :first => true,
              :simple_value => :value,
              :context => @context}
            ), 
          :success => true
        }
      end
    end
  end
  
  
  def update
    @term = Term.find(:uri_esc => (RDF::LD.terms.to_s + "/" + params[:id]).uri_esc)
    
    @term.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @term.to_hash(
            "rdfs:label" => { 
              :first => true,
              :simple_value => :value,
              :context => @context}
            ), 
          :success => true
        }
      end
    end
  end
  
  def destroy
    @term = Term.find(:uri_esc => (RDF::LD.terms.to_s + "/" + params[:id]).uri_esc)
    
    @term.remove_context(@context)
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  def hasMeaning
    @term = Term.find(:uri_esc => (RDF::LD.terms.to_s + "/" + params[:id]).uri_esc)
    @meaning_nodes = @term.get_objects(RDF::GOLD.hasMeaning => {:context => @context})
    
    respond_to do |format|
      format.html #individuals.html.erb
      format.json do 
        render :json => ({
          :data => (@meaning_nodes.collect do |node|
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
          :total => @meaning_nodes.length
        })
      end
    end
  end
  
  def clone
    @term = Term.find(:uri_esc => (RDF::LD.terms.to_s + "/" + params[:id]).uri_esc)
    @from_context = RDF_Context.find(params[:from_id])
    
    if @from_context != current_user.context then
      @term.copy_context(@from_context, current_user.context)
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

    @gold_context = RDF_Context.find(:uri_esc =>"http://purl.org/linguistics/gold".uri_esc)
  end
  
end