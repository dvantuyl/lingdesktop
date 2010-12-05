##
# Test Comment for Gold Controller
#
# @example Do something
#   Gold Controller
#
class GoldController < ApplicationController
  before_filter :init_contexts

  def show
    find_resource

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => @resource.to_hash(
         "RDF.type" => {
           :first => true,
           :context => @context},
           
         "RDF::RDFS.label" => {
           :lang => @lang, 
           :first => true, 
           :context => @context},
           
         "RDF::RDFS.comment" => {
           :lang => @lang, 
           :context => @context})
      end
    end
  end


  def subclasses
    find_resource

    @subclasses = @resource.get_subjects(RDF::RDFS.subClassOf => {:context => @context})

    respond_to do |format|
      format.html #subclasses.html.erb
      format.json do
        render :json => (@subclasses.collect do |sc|
          sc.to_hash(
           "RDF.type" => {
             :first => true, 
             :simple_value => :uri, 
             :context => @context},
             
           "RDF::RDFS.label" => {
             :lang => @lang, 
             :first => true, 
             :simple_value => :value, 
             :context => @context},
             
           "text"=> {
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
    find_resource
    
    @individuals = @resource.get_subjects(RDF.type => {:context => @context})
    
    respond_to do |format|
      format.html #individuals.html.erb
      format.json do 
        render :json => ({
          :data => (@individuals.collect do |ind|
            ind.to_hash(
              RDF.type => {
                :first => true, 
                :simple_value => :uri, 
                :context => @context},
                
              RDF::RDFS.label => {
                :lang => @lang, 
                :first => true, 
                :simple_value => :value, 
                :context => @context},
                
              RDF::RDFS.comment => {
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

  def init_contexts
    @lang = "en"
    @context = RDF_Context.find(:uri_esc =>"http://purl.org/linguistics/gold".uri_esc)
  end

  def find_resource
    gold_ns = RDF::Vocabulary.new("http://purl.org/linguistics/gold/")
    @resource = RDF_Resource.find(:uri_esc => gold_ns[params[:id]].uri_esc)

    if @resource.nil? then
      respond_to do |format|
        format.html #error.html.erb
        format.json do
          render :json => {:error => "Resource '#{params[:id]}' not found."}
        end
      end
    end
    
  end




end
