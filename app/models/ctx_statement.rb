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
class CTX_Statement < Neo4jNode

  attr_accessor :subject, :predicate, :object

  # Singleton method for creating a RDF triple statement only if one isn't first found.
  # 
  # @param [Array(RDF_Resource, Symbol, RDF_Resource), Array(RDF_Resource, Symbol, RDF_Literal)]
  #   the rdf triple statement to either find or create.
  # @param [Array(CTX_Context,...)] the contexts to either find the statement in or add the statement to.
  # @return [CTX_Statement]
  #
  def self.find_or_create( triple, contexts=[] )
    statement = CTX_Statement.find( triple, contexts ).first #find
    statement = CTX_Statement.create( triple, contexts ) if statement.nil?   #or create
    return statement
  end

  # Finds statements. Subject or Object can be wildcard by replacing with nil.
  # 
  # @param [Array(RDF_Resource, Symbol, nil), Array(nil, Symbol, RDF_Literal)]
  #   the rdf triple statements to find.
  # @param [Array(CTX_Context,...)] the contexts to find the statement in.
  # @return [Array(CTX_Statement,...)]
  #
  def self.find( triple, contexts=[] )
    s, p, o = triple
    statements = []

    #find [s, p, o]
    if !s.nil? && !p.nil? && !o.nil? then
      s.outgoing(p).depth(2).each_with_position do |n, tp|
          if n.neo_id == o.neo_id then
            statement = tp.previous_node
            statement.from_hash({:subject => s, :predicate => p, :object => o})
            statements.push(statement)
          end
      end
    
    #find [s, p, nil]
    elsif !s.nil? && !p.nil? then
      s.outgoing(p).depth(2).each_with_position do |n, tp|
          if tp.previous_node.kind_of?(CTX_Statement) then
            statement = tp.previous_node
            statement.from_hash({:subject => s, :predicate => p, :object => n})
            statements.push(statement)
          end
      end

    #find [nil, p, o]
    elsif !p.nil? && !o.nil? then
      o.incoming(p).depth(2).each_with_position do |n, tp|
        if tp.previous_node.kind_of?(CTX_Statement) then
          statement = tp.previous_node
          statement.from_hash({:subject => n, :predicate => p, :object => o})
          statements.push(statement)
        end
      end
    else
      raise "Can not find statement with nil value in [#{s}, #{p}, #{o}]"
    end

    #filter statements in contexts
    if !contexts.nil? && !contexts.empty? then
      statements_in_contexts = []

      #check each statement
      statements.each do |statement|
        statement.outgoing(:CTX_in).each do |context|
            statements_in_contexts.push(statement)  if contexts.include?(context)
        end
      end

      statements = statements_in_contexts
    end

    return statements
  end
  

  def add_context( context )
    self.rels.outgoing(:CTX_in) << context
  end


  def remove_context( context )

    #delete rel to context from statement
    self.rels.outgoing(:CTX_in)[context].delete

    #delete statement if it's not in any context
    if self.rels.outgoing(:CTX_in).empty? then

       #delete incoming rels
       self.rels.incomming.each do |rel|
          subject_node = rel.start_node
          rel.delete

          #if the subject_node is orphaned then delete it
          node.delete if node.rels.both.empty?
       end

       #delete outgoing rels
       self.rels.outgoing.each do |rel|
          object_node = rel.end_node
          rel.delete

          #if the object node is orphaned then delete it
          node.delete if node.rels.both.empty?
       end
    end
  end
  
  def from_hash(triple)
    self.subject = triple[:subject]
    self.predicate = triple[:predicate]
    self.object = triple[:object]
  end
   
  
  def self.create( triple, contexts=[] )
    s, p, o = triple

    raise "Can not create statement with nil in triple" if s.nil? or p.nil? or o.nil?

    #create statement and connect to subject and object
    statement = CTX_Statement.new() do |st|
      s.rels.outgoing(p) << st
      o.rels.incoming(p) << st
    end

    # add statement to contexts
    contexts.each{|context| statement.add_context(context)} unless contexts.nil?

    #store triple nodes in statement instance
    statement.from_hash({:subject => s, :predicate => p, :object => o})

    return statement
  end

end