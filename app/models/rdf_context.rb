##
# Context reference node for a named RDF graph
# 
# Public methods that should NEVER be called:
# * CTX_Context.new(). Use the singleton method CTX_Context.find_or_create(:uri => uri) instead.
#
# @example Creating a context while making sure one with the same URI doesn't already exist
#   context_node = CTX_Context.find_or_create(:uri => "http://purl.org/linguistics/gold")
#
# @example Finding a context node by it's URI
#   context_node = CTX_Context.find(:uri => "http://purl.org/linguistics/gold").first
#
# @example Get all CTX_Statement nodes in this context.
#   context_node.rels.incoming(:CTX_in).nodes
class RDF_Context < Neo4j::Model

  # The uri property is utilized as an id of this node. Each CTX_Context should have a unique uri.
  #
  # @return [String]  context uri of a named graph
  property :created_at
  property :uri_esc
  index :uri_esc
  
  has_n(:statements).from(RDF_Statement, :contexts)
  
  validates :uri_esc, :presence => true, :uniqueness => true

  def uri
    self[:uri_esc].uri_unesc
  end
  
  
  def localname
    self.uri.gsub(/([^\/]*\/|[^#]*#)/, "")
  end
  
  
  def followers
    self.incoming(:follows).to_a
  end

  
  def following
    self.outgoing(:follows).to_a
  end


  def follow(context_node)
    self.outgoing(:follows) << context_node unless self.following.include?(context_node)
  end
  
  
  def unfollow(context_node)
    self.rels(:follows).outgoing.to_other(context_node).del
  end


  def statements
    self.incoming(:contexts).to_a
  end


  # Singleton method for creating a context only if one isn't found.
  # 
  # @param [String]  URI of the context
  # @return [CTX_Context]
  def self.find_or_create(args)
    RDF_Context.find(args) || RDF_Context.create(args)
  end
    
  
  def copy_from_context(context_node)
    context_node.statements.each do |statement|
      statement.add_context(self)
    end
  end
  
end
