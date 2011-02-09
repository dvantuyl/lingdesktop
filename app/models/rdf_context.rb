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
  #g
  # @return [String]  context uri of a named graph
  property :created_at
  property :name
  property :description
  property :is_public, :default => true
  
  validates :name, :presence => true
  
  has_n(:statements).from(RDF_Statement, :contexts)
  
  index :name
  index :is_public
    
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
  
  def copy_from_context(context_node)
    context_node.statements.each do |statement|
      statement.add_context(self)
    end
  end
  
  def resource_counts
    counts = {}
    
    #statements = self.incoming(:contexts).find{|node| node[:predicate_uri_esc] == RDF.type.uri_esc }
    
    self.statements.each do |statement|
      if statement.predicate_uri_esc == RDF.type.uri_esc then
        type = statement.object.localname.to_sym
        counts[type] = 0 unless counts.has_key?(type)
        counts[type] += 1
      end
    end
    
    return counts
  end
  
  def to_hash
    {
      :id => self.id,
      :name => self.name,
      :description => self.description,
      :is_public => self.is_public,
      :is_group => (self.class.to_s == "Group" ? true : false)
    }
  end
  
end
