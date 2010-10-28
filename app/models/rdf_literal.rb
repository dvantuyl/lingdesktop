class RDF_Literal
  include Neo4j::NodeMixin

  property :value, :lang

  index :value, :lang

  def to_hash(args = [])
    {:value => self.value, :lang => self.lang}
  end

end