class LexicalizedConceptsController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy, :clone]
  before_filter :authenticate_user!, :only => [:create, :update, :destroy, :clone]

  # GET /lexicalized_concepts.json?start=0&limit=50&query=foo
  def index
    @lexicalized_concepts = LexicalizedConcept.type.get_subjects(RDF.type => {:context => context}, :query => params[:query])
    
    # pageing filter
    total = @lexicalized_concepts.length
    @lexicalized_concepts = @lexicalized_concepts[params[:start].to_i, params[:limit].to_i] if(params[:start] && params[:limit])
    
    render :json => {
          :data => (@lexicalized_concepts.collect do |lexicalized_concept|
            lexicalized_concept.to_hash(
              "rdf:type" => {
                :first => true,
                :simple_value => :uri,
                :context => context},

              "rdfs:label" => { 
                :first => true,
                :simple_value => :value,
                :context => context},

              "rdfs:comment" => {
                :first => true,
                :simple_value => :value,
                :context => context})
          end),
          :total => total
    }

  end

  # GET /lexicalized_concepts/1
  # GET /lexicalized_concepts/1.json
  def show
    @lexicalized_concept = LexicalizedConcept.find(:uri_esc => (RDF::LD.lexicalized_concepts.to_s + "/" + params[:id]).uri_esc)

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => {
          :data => @lexicalized_concept.to_hash(
           "rdf:type" => {
             :first => true,
             :simple_value => :uri,
             :context => context},
           
           "rdfs:label" => { 
             :first => true,
             :simple_value => :value,
             :context => context},
           
           "rdfs:comment" => {
             :first => true,
             :simple_value => :value,
             :context => context}),

           :success => true
        }
      end
    end
  end

  # POST /lexicalized_concepts.json
  def create
    @lexicalized_concept = LexicalizedConcept.create_in_context(context)
    @lexicalized_concept.set(params, context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @lexicalized_concept.to_hash(
            "rdfs:label" => { 
              :first => true,
              :simple_value => :value,
              :context => context}
            ), 
          :success => true
        }
      end
    end
  end
  
  # PUT /lexicalized_concepts/1.json
  def update
    @lexicalized_concept = LexicalizedConcept.find(:uri_esc => (RDF::LD.lexicalized_concepts.to_s + "/" + params[:id]).uri_esc)
    
    @lexicalized_concept.set(params, context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @lexicalized_concept.to_hash(
            "rdfs:label" => { 
              :first => true,
              :simple_value => :value,
              :context => context}
            ), 
          :success => true
        }
      end
    end
  end
  
  # DELETE /lexicalized_concepts/1.json
  def destroy
    @lexicalized_concept = LexicalizedConcept.find(:uri_esc => (RDF::LD.lexicalized_concepts.to_s + "/" + params[:id]).uri_esc)
    
    @lexicalized_concept.remove_context(context)
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  # POST /lexicalized_concepts/1/clone.json?from_id=2
  def clone
    @lexicalized_concept = LexicalizedConcept.find(:uri_esc => (RDF::LD.lexicalized_concepts.to_s + "/" + params[:id]).uri_esc)
    @from_context = RDF_Context.find(params[:from_id])
    
    if @from_context != current_user.context then
      @lexicalized_concept.copy_context(@from_context, context)
    end
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
end