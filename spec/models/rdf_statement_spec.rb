require "spec_helper"

describe RDF_Statement do
  before(:each) do
    @subject = RDF_Resource.create(:uri_esc => "http://test.subject".uri_esc)
    @predicate = "http://test.predicate".uri_esc
    @object = RDF_Resource.create(:uri_esc => "http://test.object".uri_esc)
    @context = RDF_Context.create(:uri_esc => "http://test.context".uri_esc)
  end
  
  describe "#create_by_quad" do
   
   it "should create and return quad" do
     
     node = RDF_Statement.create_by_quad(
        :subject => @subject,
        :predicate_uri_esc => @predicate,
        :object => @object,
        :context => @context
     )
     
     RDF_Statement.all.first.should == node
     node.subject.should == @subject
     node.predicate.should == @predicate
     node.object.should == @object
     node.contexts.to_a.should include(@context)    
   end    
  end
  
  context "statement exists in neo4j store" do
    before(:each) do
      @statement = RDF_Statement.create_by_quad(
          :subject => @subject,
          :predicate_uri_esc => @predicate,
          :object => @object,
          :context => @context
       )
    end
    
    describe "#find_by_quad" do
    
      it "should find a statment by subject, predicate, object, context" do
        RDF_Statement.find_by_quad(
          :subject => @subject,
          :predicate_uri_esc => @predicate,
          :object => @object,
          :context => @context
        ).should include(@statement)
      end
      
      it "should find a statment by predicate, object, context" do
        RDF_Statement.find_by_quad(
          :predicate_uri_esc => @predicate,
          :object => @object,
          :context => @context
        ).should include(@statement)
      end
      
      it "should find a statment by subject, predicate, context" do
        RDF_Statement.find_by_quad(
          :subject => @subject,
          :predicate_uri_esc => @predicate,
          :context => @context
        ).should include(@statement)
      end
      
      it "should find a statment by subject, predicate, object" do
        RDF_Statement.find_by_quad(
          :subject => @subject,
          :predicate_uri_esc => @predicate,
          :object => @object
        ).should include(@statement)
      end
      
      it "should find a statment by predicate, context" do
        RDF_Statement.find_by_quad(
          :predicate_uri_esc => @predicate,
          :context => @context
        ).should include(@statement)
      end
      
      it "should find a statment by subject, predicate" do
        RDF_Statement.find_by_quad(
          :subject => @subject,
          :predicate_uri_esc => @predicate
        ).should include(@statement)
      end
      
      it "should find a statment by predicate, object" do
        RDF_Statement.find_by_quad(
          :predicate_uri_esc => @predicate,
          :object => @object
        ).should include(@statement)
      end
    end
    
    describe "#find_or_create" do
      
      it "should find and not create when one exists" do
        RDF_Statement.find_or_create(
          :subject => @subject,
          :predicate_uri_esc => @predicate,
          :object => @object,
          :context => @context
        ).should == @statement
        
        RDF_Statement.all.size.should == 1
      end
      
      it "should create when the statement doesn't exist" do
        subject = RDF_Resource.create(:uri_esc => "http://test.two")
        
        RDF_Statement.find_or_create(
          :subject => subject,
          :predicate_uri_esc => @predicate,
          :object => @object,
          :context => @context
        ).should_not == @statement
        
        RDF_Statement.all.size.should == 2
      end
      
      
    end
  end
  
end