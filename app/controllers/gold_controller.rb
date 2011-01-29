##
# Gold Controller
#
class GoldController < ApplicationController
  before_filter :init_context, :only => [:show, :subclasses, :individuals, :followers]

  def show
    @resource = RDF_Resource.find(:uri_esc => RDF::GOLD[params[:id]].uri_esc)
    
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
             :lang => @lang, 
             :first => true,
             :simple_value => :value,
             :context => @context},
           
           "rdfs:comment" => {
             :lang => @lang,
             :first => true,
             :simple_value => :value,
             :context => @context}),
             
           :success => true
         }
      end
    end
  end


  def subclasses
    @resource = RDF_Resource.find(:uri_esc => RDF::GOLD[params[:id]].uri_esc)
    @subclasses = @resource.get_subjects(RDF::RDFS.subClassOf => {:context => @context})

    respond_to do |format|
      format.html #subclasses.html.erb
      format.json do
        render :json => (@subclasses.collect do |sc|
          sc.to_hash(
           "rdf:type" => {
             :first => true, 
             :simple_value => :uri, 
             :context => @context},
             
           "rdfs:label" => {
             :lang => @lang, 
             :first => true, 
             :simple_value => :value, 
             :context => @context},
             
           "text" => {
             :predicate => RDF::RDFS.label,
             :lang => @lang, 
             :first => true, 
             :simple_value => :value, 
             :context => @context},
             
           "leaf" => {
             :predicate => RDF::RDFS.subClassOf,
             :subjects => true, 
             :empty_xor => false, 
             :context => @context})
        end)
      end
    end
  end


  def individuals
    @resource = RDF_Resource.find(:uri_esc => RDF::GOLD[params[:id]].uri_esc)
    @individuals = @resource.get_subjects(RDF.type => {:context => @context})
    
    respond_to do |format|
      format.html #individuals.html.erb
      format.json do 
        render :json => ({
          :data => (@individuals.collect do |ind|
            ind.to_hash(
              "rdf:type" => {
                :first => true, 
                :simple_value => :uri, 
                :context => @context},
                
              "rdfs:label" => {
                :lang => @lang, 
                :first => true, 
                :simple_value => :value, 
                :context => @context},
                
              "rdfs:comment" => {
                :first => true, 
                :simple_value => :value, 
                :lang => @lang, 
                :context => @context})
          end),
          :total => @individuals.length
        })
      end
    end
  end


  private

  def init_context
    @lang = "en"
    @context = User.find(:email => "gold@lingdesktop.org").context
  end

end
