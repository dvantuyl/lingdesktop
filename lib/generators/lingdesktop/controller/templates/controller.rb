class <%= controller_class_name %>Controller < ApplicationController
  around_filter Neo4j::Rails::Transaction, :only => [:create, :update, :destroy, :clone]

  # GET <%= route_url %>.json?start=0&limit=50&query=foo
  def index
    @<%= plural_name %> = <%= class_name %>.type.get_subjects(RDF.type => {:context => context}, :query => params[:query])
    
    # pageing filter
    total = @<%= plural_name %>.length
    @<%= plural_name %> = @<%= plural_name %>[params[:start].to_i, params[:limit].to_i] if(params[:start] && params[:limit])
    
    render :json => {
          :data => (@<%= plural_name %>.collect do |<%= singular_name %>|
            <%= singular_name %>.to_hash(
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

  # GET <%= route_url %>/1
  # GET <%= route_url %>/1.json
  def show
    @<%= singular_name %> = <%= class_name %>.find(:uri_esc => (RDF::LD.<%= plural_name %>.to_s + "/" + params[:id]).uri_esc)

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => {
          :data => @<%= singular_name %>.to_hash(
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

  # POST <%= route_url %>.json
  def create
    @<%= singular_name %> = <%= class_name %>.create_in_context(context)
    @<%= singular_name %>.set(params, @context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @<%= singular_name %>.to_hash(
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
  
  # PUT <%= route_url %>/1.json
  def update
    @<%= singular_name %> = <%= class_name %>.find(:uri_esc => (RDF::LD.<%= plural_name %>.to_s + "/" + params[:id]).uri_esc)
    
    @<%= singular_name %>.set(params, context)
  
    respond_to do |format|
      format.json do
        render :json => {
          :data => @<%= singular_name %>.to_hash(
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
  
  # DELETE <%= route_url %>/1.json
  def destroy
    @<%= singular_table_name %> = <%= class_name %>.find(:uri_esc => (RDF::LD.<%= plural_name %>.to_s + "/" + params[:id]).uri_esc)
    
    @<%= singular_name %>.remove_context(context)
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
  # POST <%= route_url %>/1/clone.json?from_id=2
  def clone
    @<%= singular_name %> = <%= class_name %>.find(:uri_esc => (RDF::LD.<%= plural_name %>.to_s + "/" + params[:id]).uri_esc)
    @from_context = RDF_Context.find(params[:from_id])
    
    if @from_context != current_user.context then
      @<%= singular_name %>.copy_context(@from_context, context)
    end
    
    respond_to do |format|
      format.json do
        render :json => {:success => true}
      end
    end
  end
  
end