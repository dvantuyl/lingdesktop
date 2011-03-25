class HumanLanguageVarietiesController < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy, :clone]
  before_filter :authenticate_user!, :only => [:create, :update, :destroy, :clone]

  # GET /human_language_varieties.json?start=0&limit=50
  def index
    @human_language_varieties = HumanLanguageVariety.type.get_subjects(RDF.type => {:context => context, :query_begin => params[:query]})
    
    # pageing filter
    total = @human_language_varieties.length
    @human_language_varieties = @human_language_varieties[params[:start].to_i, params[:limit].to_i] if(params[:start] && params[:limit])
    
    render :json => {
          :data => (@human_language_varieties.collect do |human_language_variety|
            human_language_variety.to_hash(
              "rdf:type" => {
                :first => true,
                :simple_value => :uri,
                :context => context},

              "rdfs:label" => { 
                :first => true,
                :simple_value => :value,
                :context => context},
              
              "text" => {
                   :predicate => RDF::RDFS.label,
                   :first => true, 
                   :simple_value => :value, 
                   :context => context}
                )
          end),
          :total => total
    }

  end

  # GET /human_language_varieties/1
  # GET /human_language_varieties/1.json
  def show
    @human_language_variety = HumanLanguageVariety.find(:uri_esc => (RDF::LD.human_language_varieties.to_s + "/" + params[:id]).uri_esc)

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => {
          :data => @human_language_variety.to_hash(
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

  # POST /human_language_varieties.json
  def create
    @human_language_variety = HumanLanguageVariety.create_in_context(context)
    @human_language_variety.set(params, context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @human_language_variety.to_hash(
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
  
  # PUT /human_language_varieties/1.json
  def update
    @human_language_variety = HumanLanguageVariety.find(:uri_esc => (RDF::LD.human_language_varieties.to_s + "/" + params[:id]).uri_esc)
    
    @human_language_variety.set(params, context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @human_language_variety.to_hash(
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
  
  # DELETE /human_language_varieties/1.json
  def destroy
    @human_language_variety = HumanLanguageVariety.find(:uri_esc => (RDF::LD.human_language_varieties.to_s + "/" + params[:id]).uri_esc)
    
    @human_language_variety.remove_context(context)
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  # POST /human_language_varieties/1/clone.json?from_id=2
  def clone
    @human_language_variety = HumanLanguageVariety.find(:uri_esc => (RDF::LD.human_language_varieties.to_s + "/" + params[:id]).uri_esc)
    @from_context = RDF_Context.find(params[:from_id])
    
    if @from_context != current_user.context then
      @human_language_variety.copy_context(@from_context, context)
    end
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
end