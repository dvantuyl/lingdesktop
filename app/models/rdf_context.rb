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
class RDF_Context < Neo4j::Rails::Model

  # The uri property is utilized as an id of this node. Each CTX_Context should have a unique uri.
  #
  # @return [String]  context uri of a named graph
  property :created_at
  property :uri_esc
  index :uri_esc
  
  validates :uri_esc, :presence => true, :uniqueness => true

  def uri
    self[:uri_esc].uri_unesc
  end

  # Singleton method for creating a context only if one isn't found.
  # 
  # @param [String]  URI of the context
  # @return [CTX_Context]
  def self.find_or_create(args)
    RDF_Context.find(args) || RDF_Context.create(args)
  end
  
end
