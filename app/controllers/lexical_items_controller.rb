class LexicalItemsController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy, :clone]
  before_filter :init_context

  # GET /lexical_items.json
  def index
    @lexical_items = LexicalItem.type.get_subjects(RDF.type => {:context => @context})
    
    render :json => {
          :data => (@lexical_items.collect do |lexical_item|
            lexical_item.to_hash(
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
          :total => @lexical_items.length
    }

  end

  # GET /lexical_items/1
  # GET /lexical_items/1.json
  def show
    @lexical_item = LexicalItem.find(:uri_esc => (RDF::LD.lexical_items.to_s + "/" + params[:id]).uri_esc)

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => {
          :data => @lexical_item.to_hash(
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

  # POST /lexical_items.json
  def create
    @lexical_item = LexicalItem.create_in_context(@context)
    @lexical_item.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @lexical_item.to_hash(
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
  
  # PUT /lexical_items/1.json
  def update
    @lexical_item = LexicalItem.find(:uri_esc => (RDF::LD.lexical_items.to_s + "/" + params[:id]).uri_esc)
    
    @lexical_item.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @lexical_item.to_hash(
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
  
  # DELETE /lexical_items/1.json
  def destroy
    @lexical_item = LexicalItem.find(:uri_esc => (RDF::LD.lexical_items.to_s + "/" + params[:id]).uri_esc)
    
    @lexical_item.remove_context(@context)
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  
  def clone
    @lexical_item = LexicalItem.find(:uri_esc => (RDF::LD.lexical_items.to_s + "/" + params[:id]).uri_esc)
    @from_context = RDF_Context.find(params[:from_id])
    
    if @from_context != current_user.context then
      @lexical_item.copy_context(@from_context, current_user.context)
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