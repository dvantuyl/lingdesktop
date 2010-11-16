# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
##   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

##IMPORT GOLD##
require "rdf/raptor"

GOLD = "http://purl.org/linguistics/gold"

graph = RDF::Graph.load(
  File.expand_path('../slash_gold-2009.owl', __FILE__), 
  {:format => :rdfxml}
)

#find all owl classes
graph.query([nil, RDF.type, RDF::OWL.Class]).each_subject do |gold_class_uri|

  Neo4j::Transaction.run do
    
    if gold_class_uri.uri? then
      ctx_node = RDF_Context.find_or_create(:uri => "http://purl.org/linguistics/gold")
      gold_class_node = RDF_Resource.find_or_create(:uri => gold_class_uri.to_s)
      print "LOAD owl:Class => #{gold_class_node.uri}\n\n"

      #load type
      owl_class_node = RDF_Resource.find_or_create(:uri => RDF::OWL.Class.to_s)
      RDF_Statement.find_or_create(
        :subject => gold_class_node,
        :predicate => :RDF_type,
        :object => owl_class_node, 
        :context => ctx_node)
      print "LOAD rdf:type => #{owl_class_node.uri}\n\n"

      #load label
      label = gold_class_uri.basename.gsub( /([A-Z])/ , ' \1' ).strip #split camel case
      label_node = RDF_Literal.find_or_create(:value => label, :lang => "en")
      RDF_Statement.find_or_create(
        :subject => gold_class_node, 
        :predicate => :RDFS_label,
        :object => label_node,
        :context => ctx_node)
      print "LOAD rdfs:label => #{label_node.value}\n\n"

      #load comments
      graph.query([gold_class_uri, RDF::RDFS.comment, nil]).each_object do |comment_literal|
        comment = comment_literal.to_s.gsub( /(\"|@en|..xsd:anyURI)/ , "") #remove extra cruft
        comment_node = RDF_Literal.find_or_create(:value => comment, :lang => "en")
        RDF_Statement.find_or_create(
          :subject => gold_class_node,
          :predicate => :RDFS_comment, 
          :object => comment_node,
          :context => ctx_node)
        print "LOAD rdfs:comment => #{comment_node.value}\n\n"
      end

      #load subClassOf
      graph.query([gold_class_uri, RDF::RDFS.subClassOf, nil]).each_object do |subClassOf_uri|
        subClassOf_node = RDF_Resource.find_or_create(:uri => subClassOf_uri.to_s)
        RDF_Statement.find_or_create(
          :subject => gold_class_node, 
          :predicate => :RDFS_subClassOf, 
          :object => subClassOf_node, 
          :context => ctx_node)
        print "LOAD rdfs:subClassOf => #{subClassOf_node.uri}\n\n"
      end

      #load instances
      graph.query([nil, RDF.type, gold_class_uri]).each_subject do |instance_uri|

        instance_node = RDF_Resource.find_or_create(:uri => instance_uri.to_s)

        #load type
        RDF_Statement.find_or_create(
          :subject => instance_node, 
          :predicate => :RDF_type, 
          :object => gold_class_node, 
          :context => ctx_node)

        #load label
        label = instance_uri.basename.gsub( /([A-Z])/ , ' \1' ).strip #split camel case
        label_node = RDF_Literal.find_or_create(:value => label, :lang => "en")
        RDF_Statement.find_or_create(
          :subject => instance_node, 
          :predicate => :RDFS_label, 
          :object => label_node, 
          :context => ctx_node)

        #load comments
        graph.query([instance_uri, RDF::RDFS.comment, nil]).each_object do |comment_literal|
          comment = comment_literal.to_s.gsub( /(\"|@en|..xsd:anyURI)/ , "")  #remove extra cruft
          comment_node = RDF_Literal.find_or_create(:value => comment, :lang => "en")
          RDF_Statement.find_or_create(
            :subject => instance_node, 
            :predicate => :RDFS_comment, 
            :object => comment_node,
            :context => ctx_node)
        end
      end
    end
  end
end

print "Finished parsing\n\n"



