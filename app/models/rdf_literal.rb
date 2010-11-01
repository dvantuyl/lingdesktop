class RDF_Literal < Neo4jNode

  property :value, :lang

  index :value, :lang

  def to_hash(args = [])
    {:value => self.value, :lang => self.lang}
  end

end
