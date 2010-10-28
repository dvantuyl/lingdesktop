# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

##IMPORT GOLD##
require "rdf/raptor"
graph = RDF::Graph.load("http://linguistics-ontology.org/gold.rdf")
GOLD = "http://purl.org/linguistics/gold"

#find all owl classes
graph.query([nil, RDF.type, RDF::OWL.Class]).each_subject do |gold_class_uri|

  Neo4j::Transaction.run do

    ctx_node = CTX_Context.find_or_create("http://purl.org/linguistics/gold")
    gold_class_node = RDF_Resource.find_or_create(gold_class_uri.to_s)
    print "LOAD owl:Class => #{gold_class_node.uri}\n\n"

    #load type
    owl_class_node = RDF_Resource.find_or_create(RDF::OWL.Class.to_s)
    CTX_Statement.find_or_create([gold_class_node, :RDF_type, owl_class_node], [ctx_node])
    print "LOAD rdf:type => #{owl_class_node.uri}\n\n"

    #load label
    label = gold_class_uri.basename.gsub( /([A-Z])/ , ' \1' ).strip #split camel case
    label_node = RDF_Literal.new(:value => label, :lang => "en")
    CTX_Statement.find_or_create([gold_class_node, :RDFS_label, label_node], [ctx_node])
    print "LOAD rdfs:label => #{label_node.value}\n\n"

    #load comments
    graph.query([gold_class_uri, RDF::RDFS.comment, nil]).each_object do |comment_literal|
      comment = comment_literal.to_s.gsub( /(\"|@en|..xsd:anyURI)/ , "") #remove extra cruft
      comment_node = RDF_Literal.new(:value => comment, :lang => "en")
      CTX_Statement.find_or_create([gold_class_node, :RDFS_comment, comment_node],[ctx_node])
      print "LOAD rdfs:comment => #{comment_node.value}\n\n"
    end

    #load subClassOf
    graph.query([gold_class_uri, RDF::RDFS.subClassOf, nil]).each_object do |subClassOf_uri|
      subClassOf_node = RDF_Resource.find_or_create(subClassOf_uri.to_s)
      CTX_Statement.find_or_create([gold_class_node, :RDFS_subClassOf, subClassOf_node], [ctx_node])
      print "LOAD rdfs:subClassOf => #{subClassOf_node.uri}\n\n"
    end

    #load instances
    graph.query([nil, RDF.type, gold_class_uri]).each_subject do |instance_uri|

      instance_node = RDF_Resource.find_or_create(instance_uri.to_s)

      #load type
      CTX_Statement.find_or_create([instance_node, :RDF_type, gold_class_node], [ctx_node])

      #load label
      label = instance_uri.basename.gsub( /([A-Z])/ , ' \1' ).strip #split camel case
      label_node = RDF_Literal.new(:value => label, :lang => "en")
      CTX_Statement.find_or_create([instance_node, :RDFS_label, label_node], [ctx_node])

      #load comments
      graph.query([instance_uri, RDF::RDFS.comment, nil]).each_object do |comment_literal|
        comment = comment_literal.to_s.gsub( /(\"|@en|..xsd:anyURI)/ , "")  #remove extra cruft
        comment_node = RDF_Literal.new(:value => comment, :lang => "en")
        CTX_Statement.find_or_create([instance_node, :RDFS_comment, comment_node],[ctx_node])
      end
    end

  end
end

print "Finished parsing\n\n"



