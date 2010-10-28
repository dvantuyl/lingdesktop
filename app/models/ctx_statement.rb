class CTX_Statement
  include Neo4j::NodeMixin

  attr_accessor :subject, :predicate, :object


  def self.find_or_create( triple, contexts=[] )
    statements = CTX_Statement.find( triple, contexts ) #find
    statements = [CTX_Statement.create( triple, contexts )] if statements.empty?   #or create
    return statements
  end


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

end