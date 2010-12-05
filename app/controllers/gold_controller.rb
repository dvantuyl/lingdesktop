##
# Test Comment for Gold Controller
#
# @example Do something
#   Gold Controller
#
class GoldController < ApplicationController

  def show
    find_resource

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => @resource.to_hash(
         :RDF_type => {
           :first => true, 
           :args => {:localname => {}}},
           
         :RDFS_label => {
           :lang => @lang, 
           :first => true, 
           :context => @context},
           
         :RDFS_comment => {
           :lang => @lang, 
           :context => @context})
      end
    end
  end


  def subclasses
    find_resource

    @subclasses = @resource.get_subjects(:RDFS_subClassOf => {:context => @context})

    respond_to do |format|
      format.html #subclasses.html.erb
      format.json do
        render :json => (@subclasses.collect do |sc|
          sc.to_hash(
           :RDF_type => {
             :first => true, 
             :simple_value => :uri, 
             :context => @context},
             
           :RDFS_label => {
             :lang => @lang, 
             :first => true, 
             :simple_value => :value, 
             :context => @context},
             
           :RDFS_label => {
             :rename_key => "text", 
             :lang => @lang, 
             :first => true, 
             :simple_value => :value, 
             :context => @context},
             
           :RDFS_subClassOf => {
             :rename_key => "leaf", 
             :subjects => true, 
             :empty_xor => false, 
             :context => @context},
             
           :localname => {})
        end)
      end
    end
  end


  def individuals
    find_resource
    
    @individuals = @resource.get_subjects(:RDF_type => {:context => @context})
    
    respond_to do |format|
      format.html #individuals.html.erb
      format.json do 
        render :json => ({
          :data => (@individuals.collect do |ind|
            ind.to_hash(
              :RDF_type => {
                :first => true, 
                :simple_value => :uri, 
                :context => @context},
                
              :RDFS_label => {
                :lang => @lang, 
                :first => true, 
                :simple_value => :value, 
                :context => @context},
                
              :RDFS_comment => {
                :first => true, 
                :simple_value => :value, 
                :lang => @lang, 
                :context => @context},
                
              :localname => {})
          end),
          :total => @individuals.length
        })
      end
    end
  end


  private

  def init_contexts
    @lang = "en"
    @context = RDF_Context.find(:uri => RDF_Context.escape_uri("http://purl.org/linguistics/gold")).first
  end

  def find_resource
    gold_ns = RDF::Vocabulary.new("http://purl.org/linguistics/gold/")
    uri = RDF_Resource.escape_uri(gold_ns[params[:id]].to_s)
    @resource = RDF_Resource.find(:uri => uri)

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
