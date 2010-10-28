class RDF_Resource
  include Neo4j::NodeMixin

  property :uri

  index :uri

  def self.find_or_create(uri)
    return RDF_Resource.find(:uri => uri).first || RDF_Resource.new(:uri => uri)
  end

  def get(predicate_and_args)
    predicate, args = predicate_and_args.first

    #get subjects
    if args[:subjects] then
      if args[:first] then
         return CTX_Statement.find([nil, predicate, self], args[:contexts]).first.subject
      elsif args[:boolean] then
         return CTX_Statement.find([nil, predicate, self], args[:contexts]).empty?
      else
        return CTX_Statement.find([nil, predicate, self], args[:contexts]).collect do |st|
          st.subject
        end
      end

    #get objects
    else
      if args[:first] then
         return CTX_Statement.find([self, predicate, nil], args[:contexts]).first.object
      elsif args[:boolean] then
         return  CTX_Statement.find([nil, predicate, self], args[:contexts]).empty?
      else
        return CTX_Statement.find([self, predicate, nil], args[:contexts]).collect do |st|
          st.object
        end
      end
    end

  end


  def to_hash(args = [])
    resource_hash = {:uri => self.uri}

    args.each do |predicate_and_args|
      predicate, args = predicate_and_args

      # handle local values
      if predicate == :localname then
        result = self.uri.gsub(/([^\/]*\/|[^#]*#)/, "")

      # traverse surounding nodes
      else
        result = self.get(predicate => args)
      end

      #set the name or rename the key of the hash
      name = args[:rename] || predicate

      # handle array result
      if result.kind_of?(Array) then
        resource_hash.merge!({name => result.collect{|r| r.to_hash(args[:args])}})

      # handle boolean result
      elsif result.kind_of?(TrueClass) || result.kind_of?(FalseClass) then
        resource_hash.merge!({name => result})

      # handle string result
      elsif result.kind_of?(String) then
        resource_hash.merge!({name => result})

      # handle rdf result
      else
        if args[:simple_value] then
          resource_hash.merge!({name => result[args[:simple_value]]})
        else
          resource_hash.merge!({name => result.to_hash(args[:args])})
        end
      end
    end

    return resource_hash
  end

end