class LexicalItemsController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy, :clone]

  
  # GET /lexical_items.json?start=0&limit=50&query=foo
  # GET /lexicons/1/lexical_items.json?start=0&limit=50&query=foo
  def index
    
    if params.has_key?(:lexicon_id)
      lexicon = Lexicon.find(:uri_esc => (RDF::LD.lexicons.to_s + "/" + params[:lexicon_id]).uri_esc)
      @lexical_items = lexicon.get_subjects(RDF::GOLD.memberOf => {:context => context}, :query => params[:query])
    else
      @lexical_items = LexicalItem.type.get_subjects(RDF.type => {:context => context}, :query => params[:query])
    end
    
    # pageing filter
    total = @lexical_items.length
    @lexical_items = @lexical_items[params[:start].to_i, params[:limit].to_i] if(params[:start] && params[:limit])
    
    render :json => {
          :data => (@lexical_items.collect do |lexical_item|
            lexical_item.to_hash(
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

  # POST /lexical_items.json
  def create
    @lexical_item = LexicalItem.create_in_context(context)
    
    params.merge!({"gold:memberOf" => params[:lexicon_id]}) if params.has_key?(:lexicon_id)
    
    @lexical_item.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @lexical_item.to_hash(
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
  
  # PUT /lexical_items/1.json
  def update
    @lexical_item = LexicalItem.find(:uri_esc => (RDF::LD.lexical_items.to_s + "/" + params[:id]).uri_esc)
    
    params.merge!({"gold:memberOf" => params[:lexicon_id]}) if params.has_key?(:lexicon_id)
    
    @lexical_item.set(params, context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @lexical_item.to_hash(
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
  
  # DELETE /lexical_items/1.json
  def destroy
    @lexical_item = LexicalItem.find(:uri_esc => (RDF::LD.lexical_items.to_s + "/" + params[:id]).uri_esc)
    
    @lexical_item.remove_context(context)
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  # POST /lexical_items/1/clone.json?from_id=2
  def clone
    @lexical_item = LexicalItem.find(:uri_esc => (RDF::LD.lexical_items.to_s + "/" + params[:id]).uri_esc)
    @from_context = RDF_Context.find(params[:from_id])
    
    if @from_context != current_user.context then
      @lexical_item.copy_context(@from_context, context)
    end
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
end