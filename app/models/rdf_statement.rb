##
# RDF Named Graph Statement Node
#
#                           [RDF_Context context_one]       [RDF_Context context_two]
#                                     ^                               ^
#                                     \                             /
#                                      \                          / 
#                                   :context                 :context
#                                        \                    /
#                                         \                 /
#                                          \              /
#                                           \           /
#  [RDF_Resource subject]<---:subject---[RDF_Statement predicate]---:object--->[RDF_Literal object]
#
class RDF_Statement < Neo4j::Rails::Model

  property :predicate_uri_esc
  property :created_at
  
  index :predicate_uri_esc
  
  has_one(:subject)
  has_one(:object)
  has_n(:contexts).to(RDF_Context)
  
  def predicate_uri
    self[:predicate_uri_esc].uri_unesc
  end
  
  
  def self.create_by_quad( args )
    s, p, o, c = args[:subject], args[:predicate_uri_esc], args[:object], args[:context]

    if s.nil? || p.nil? || o.nil? || c.nil? then
      raise "Can not create statement with nil in quad"
    end

    #create statement and connect to subject and object
    statement = RDF_Statement.new(:predicate_uri_esc => p)
    statement.subject = s
    statement.object = o
    statement.contexts << c
    statement.save

    return statement
  end
  
  
  def self.find_by_quad( args )
    s, p, o, c = args[:subject], args[:predicate_uri_esc], args[:object], args[:context]
    
    statements = []   
    RDF_Statement.all(:predicate_uri_esc => p).each do |statement|
      next unless s.nil? || statement.subject == s
      next unless o.nil? || statement.object == o
      next unless c.nil? || statement.contexts.to_a.include?(c)
      
      statements.push(statement)
    end 
    
    return statements 

  end
  

  # Singleton method for creating a RDF triple statement only if one isn't first found.
  # 
  # @param [Hash] the rdf quad to either find or create.
  # @option [RDF_Resource]              :subject    (nil)
  # @option [URI, #to_s]                :predicate
  # @option [RDF_Resource, RDF_Literal] :object     (nil)
  # @option [RDF_Context]               :context    (nil)   
  #
  # @return [RDF_Statement]
  #
  def self.find_or_create( args )
    #TODO dont create new one if cant find with a given context, just add context if can find triple
    
    return RDF_Statement.find_by_quad( args ).first || RDF_Statement.create_by_quad( args )
  end


end