namespace :neo4j do
  
  desc "Delete the neo4j db"
  task :delete => :environment do
    FileUtils.rm_rf Neo4j::Config[:storage_path]
    raise "Can't delete db" if File.exist?(Neo4j::Config[:storage_path])
  end
  
  desc "Seed Neo4j store with GOLD ontology"
  task :gold => :environment do
    require "rdf/ntriples"

    ## IMPORT GOLD ##
    graph = RDF::Graph.load(
      File.expand_path('../../../db/slash_gold-2009.nt', __FILE__)
    )
    

    @ctx_node = User.find(:email => "gold@lingdesktop.org").context


    #find all owl classes
    graph.query([nil, RDF.type, RDF::OWL.Class]).each_subject do |gold_class_uri|

      Neo4j::Transaction.run do

        if gold_class_uri.uri? then
          
          gold_class_node = RDF_Resource.find_or_create(:uri_esc => gold_class_uri.uri_esc)
          print "LOAD owl:Class => #{gold_class_node.uri}\n\n"

          #load type
          owl_class_node = RDF_Resource.find_or_create(:uri_esc => RDF::OWL.Class.uri_esc)
          RDF_Statement.find_or_init(
            :subject => gold_class_node,
            :predicate_uri_esc => RDF.type.uri_esc,
            :object => owl_class_node, 
            :context => @ctx_node).save
          print "LOAD rdf:type => #{owl_class_node.uri}\n\n"

          #load label
          label = gold_class_uri.basename.gsub( /([A-Z])/ , ' \1' ).strip #split camel case
          label_node = RDF_Literal.find_or_create(:value => label, :lang => "en")
          RDF_Statement.find_or_init(
            :subject => gold_class_node, 
            :predicate_uri_esc => RDF::RDFS.label.uri_esc,
            :object => label_node,
            :context => @ctx_node).save
          print "LOAD rdfs:label => #{label_node.value}\n\n"

          #load comments
          graph.query([gold_class_uri, RDF::RDFS.comment, nil]).each_object do |comment_literal|
            comment = comment_literal.to_s.gsub( /(\"|@en|..xsd:anyURI)/ , "") #remove extra cruft
            comment_node = RDF_Literal.find_or_create(:value => comment, :lang => "en")
            RDF_Statement.find_or_init(
              :subject => gold_class_node,
              :predicate_uri_esc => RDF::RDFS.comment.uri_esc, 
              :object => comment_node,
              :context => @ctx_node).save
            print "LOAD rdfs:comment => #{comment_node.value}\n\n"
          end

          #load subClassOf
          graph.query([gold_class_uri, RDF::RDFS.subClassOf, nil]).each_object do |subClassOf_uri|
            subClassOf_node = RDF_Resource.find_or_create(:uri_esc => subClassOf_uri.uri_esc)
            RDF_Statement.find_or_init(
              :subject => gold_class_node, 
              :predicate_uri_esc => RDF::RDFS.subClassOf.uri_esc, 
              :object => subClassOf_node, 
              :context => @ctx_node).save
            print "LOAD rdfs:subClassOf => #{subClassOf_node.uri}\n\n"
          end

          #load instances
          graph.query([nil, RDF.type, gold_class_uri]).each_subject do |instance_uri|

            instance_node = RDF_Resource.find_or_create(:uri_esc => instance_uri.uri_esc)

            #load type
            RDF_Statement.find_or_init(
              :subject => instance_node, 
              :predicate_uri_esc => RDF.type.uri_esc, 
              :object => gold_class_node, 
              :context => @ctx_node).save

            #load label
            label = instance_uri.basename.gsub( /([A-Z])/ , ' \1' ).strip #split camel case
            label_node = RDF_Literal.find_or_create(:value => label, :lang => "en")
            RDF_Statement.find_or_init(
              :subject => instance_node, 
              :predicate_uri_esc => RDF::RDFS.label.uri_esc, 
              :object => label_node, 
              :context => @ctx_node).save

            #load comments
            graph.query([instance_uri, RDF::RDFS.comment, nil]).each_object do |comment_literal|
              comment = comment_literal.to_s.gsub( /(\"|@en|..xsd:anyURI)/ , "")  #remove extra cruft
              comment_node = RDF_Literal.find_or_create(:value => comment, :lang => "en")
              RDF_Statement.find_or_init(
                :subject => instance_node, 
                :predicate_uri_esc => RDF::RDFS.comment.uri_esc, 
                :object => comment_node,
                :context => @ctx_node).save
            end
          end
        end
      end
    end

    print "Finished seeding GOLD\n\n"
  end
  
  desc "Seed Neo4j store with users"
  task :users => :environment do
    
    Neo4j::Transaction.run do
      admin = User.new(
        :email => 'admin@lingdesktop.org',
        :name => 'Lingdesktop Admin',
        :is_admin => true,
        :is_public => false,
        :password => 'adminadmin',
        :password_confirmation => 'adminadmin'
      )
      admin.save
      
      demo = User.new(
        :email => 'demo@lingdesktop.org',
        :name => 'Lingdesktop Demo',
        :description => "Demonstration User for Lingdesktop",
        :is_admin => false,
        :is_public => true,
        :password => 'demodemo',
        :password_confirmation => 'demodemo'
      )
      demo.save
      
      gold = User.new(
        :email => 'gold@lingdesktop.org',
        :name => 'GOLD',
        :description => "General Ontology of Linguistic Description",
        :is_admin => false,
        :is_public => true,
        :password => 'goldgold',
        :password_confirmation => 'goldgold'
      )
      gold.save
      
      puts "New users created!"
      puts "-------------------------"
      puts admin.name
      puts '  Email    : ' << admin.email
      puts '  Password : ' << admin.password
      puts demo.name
      puts '  Email    : ' << demo.email
      puts '  Password : ' << demo.password

    end
  end
  
  desc "Seed Neo4j store with GOLD and admins"
  task :seed => [:delete, :users, :gold] do  
  end
  
end