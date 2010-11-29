##
# RDF Named Graph Statement Node
#
#                           [CTX_Context context_one]       [CTX_Context context_two]
#                                     ^                               ^
#                                     \                             /
#                                      \                          / 
#                                   :CTX_in                 :CTX_in
#                                        \                    /
#                                         \                 /
#                                          \              /
#                                           \           /
#  [RDF_Resource subject]---:RDFS_label--->[CTX_Statement]---:RDFS_label--->[RDF_Literal object]
#
# Public methods that should NEVER be called:
# * CTX_Statement.new(). Use the singleton method CTX_Statement.find_or_create(triple, contexts=[]) instead.
#
# @example Creating an RDF statement while making sure one with the same URI doesn't already exist
#   CTX_Statement.find_or_create([subject_node, :RDF_predicate, object_node], [ctx_node])
#
# @example Retrieving an array of statements with object as wildcard
#   CTX_Statement.find([subject_node, :RDF_predicate, nil])
#
# @example Retrieving an array of statements with subject as wildcard in contexts
#   CTX_Statement.find([nil, :RDF_predicate, object_node], [ctx_node_1, ctx_node_2])
#
class RDF_Statement < Neo4j::Rails::Model

  property :predicate
  property :created_at
  
  index :predicate
  
  has_one(:subject)
  has_one(:object)
  has_n(:contexts).to(RDF_Context)
  
  def self.create_by_quad( args )
    s, p, o, c = args[:subject], args[:predicate], args[:object], args[:context]

    if s.nil? || p.nil? || o.nil? || c.nil? then
      raise "Can not create statement with nil in quad"
    end

    #create statement and connect to subject and object
    statement = RDF_Statement.new(:predicate => p)
    statement.subject = s
    statement.object = o
    statement.contexts << c
    statement.save

    return statement
  end
  
  
  def self.find_by_quad( args )
    s, p, o, c = args[:subject], args[:predicate], args[:object], args[:context]
       
    return RDF_Statement.all(:predicate => p).collect do |statement|
      next unless s.nil? || statement.subject == s
      next unless o.nil? || statement.object == o
      next unless c.nil? || statement.contexts.to_a.include?(c)
      
      statement
    end  

  end
  

  # Singleton method for creating a RDF triple statement only if one isn't first found.
  # 
  # @param [Array(RDF_Resource, Symbol, RDF_Resource), Array(RDF_Resource, Symbol, RDF_Literal)]
  #   the rdf triple statement to either find or create.
  # @param [Array(CTX_Context,...)] the contexts to either find the statement in or add the statement to.
  # @return [CTX_Statement]
  #
  def self.find_or_create( args )
    return RDF_Statement.find_by_quad( args ).first || RDF_Statement.create_by_quad( args )
  end


end