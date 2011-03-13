class LexiconsController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy]
  before_filter :init_context

  def index
    @lexicons = Lexicon.type.get_subjects(RDF.type => {:context => @context})
    

    render :json => {
          :data => (@lexicons.collect do |lexicon|
            lexicon.to_hash(
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
          :total => @lexicons.length
    }

  end

  def show
    @lexicon = Lexicon.find(:uri_esc => (RDF::LD.lexicons.to_s + "/" + params[:id]).uri_esc)

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => {
          :data => @lexicon.to_hash(
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
    @lexicon = Lexicon.create_in_context(@context)
    @lexicon.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @lexicon.to_hash(
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
    @lexicon = Lexicon.find(:uri_esc => (RDF::LD.lexicons.to_s + "/" + params[:id]).uri_esc)
    
    @lexicon.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @lexicon.to_hash(
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
    @lexicon = Lexicon.find(:uri_esc => (RDF::LD.lexicons.to_s + "/" + params[:id]).uri_esc)
    
    @lexicon.remove_context(@context)
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  
  def clone
    @lexicon = Lexicon.find(:uri_esc => (RDF::LD.lexicons.to_s + "/" + params[:id]).uri_esc)
    @from_context = RDF_Context.find(params[:from_id])
    
    if @from_context != current_user.context then
      @lexicon.copy_context(@from_context, current_user.context)
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