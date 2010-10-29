class GoldController < ApplicationController

  around_filter :neo4j_transaction, :only => [:show, :subclasses, :instances]


  def show
    find_resource

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => @resource.to_hash(
           :RDF_type => {:first => true, :args => {:localname => {}}},
           :RDFS_label => {:first => true, :in_contexts => @contexts},
           :RDFS_comment => {:all => true, :in_contexts => @contexts})
           
      end
    end
  end


  def subclasses
    find_resource

    subs = @resource.get(:RDFS_subClassOf => {:subjects => true})

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => (subs.collect do |sc|
          sc.to_hash(
           :RDF_type => {:first => true, :simple_value => :uri, :in_contexts => @contexts},
           :RDFS_label => {:first => true, :simple_value => :value, :in_contexts => @contexts},
           :RDFS_label => {:first => true, :rename => "text", :simple_value => :value, :in_contexts => @contexts},
           :RDFS_subClassOf => {:boolean => true, :rename => "leaf", :in_contexts => @contexts},
           :localname => {})
          end
        )

      end
    end
  end


  def instances

  end


  private

  def find_resource

    @resource = RDF_Resource.find(:uri => GOLD[params[:id]].to_s).first

    if @resource then

    else
      respond_to do |format|
        format.html #show.html.erb
        format.json do
          render :json => {:error => "Resource '#{params[:id]}' not found."}
        end
      end
    end
  end


  def init_contexts
    @contexts = [CTX_Context.find(:uri => "http://purl.org/linguistics/gold").first]
  end


  def neo4j_transaction
    Neo4j::Transaction.new
      init_contexts
      yield
    Neo4j::Transaction.finish
  end

end
