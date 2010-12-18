require "spec_helper"

describe RDF_Statement do

  
  describe "#init_by_quad" do
    before(:each) do
      @subject = RDF_Resource.create(:uri_esc => "http://test.subject".uri_esc)
      @predicate = "http://test.predicate"
      @object = RDF_Resource.create(:uri_esc => "http://test.object".uri_esc)
      @context = RDF_Context.create(:uri_esc => "http://test.context".uri_esc)
    end
   
   it "should create and return quad" do
     
     node = RDF_Statement.init_by_quad(
        :subject => @subject,
        :predicate_uri_esc => @predicate.uri_esc,
        :object => @object,
        :context => @context
     )
     node.save
     
     RDF_Statement.all.first.should == node
     node.subject.should == @subject
     node.predicate_uri.should == @predicate
     node.object.should == @object
     node.contexts.should include(@context)    
   end    
  end
  
  context "statement exists in neo4j store" do
    before(:each) do
      @subject = RDF_Resource.create(:uri_esc => "http://test.subject".uri_esc)
      @predicate = "http://test.predicate"
      @object = RDF_Resource.create(:uri_esc => "http://test.object".uri_esc)
      @context = RDF_Context.create(:uri_esc => "http://test.context".uri_esc)
      @context_two = RDF_Context.create(:uri_esc => "http://test.context.two".uri_esc)
      @statement = RDF_Statement.init_by_quad(
          :subject => @subject,
          :predicate_uri_esc => @predicate.uri_esc,
          :object => @object,
          :context => @context
       )
       @statement.save
    end
    
    describe "#find_by_quad" do
    
      it "should find a statment by subject, predicate, object, context" do
        RDF_Statement.find_by_quad(
          :subject => @subject,
          :predicate_uri_esc => @predicate.uri_esc,
          :object => @object,
          :context => @context
        ).should include(@statement)
      end
      
      it "should find a statment by predicate, object, context" do
        RDF_Statement.find_by_quad(
          :predicate_uri_esc => @predicate.uri_esc,
          :object => @object,
          :context => @context
        ).should include(@statement)
      end
      
      it "should find a statment by subject, predicate, context" do
        RDF_Statement.find_by_quad(
          :subject => @subject,
          :predicate_uri_esc => @predicate.uri_esc,
          :context => @context
        ).should include(@statement)
      end
      
      it "should find a statment by subject, predicate, object" do
        RDF_Statement.find_by_quad(
          :subject => @subject,
          :predicate_uri_esc => @predicate.uri_esc,
          :object => @object
        ).should include(@statement)
      end
      
      it "should find a statment by predicate, context" do
        RDF_Statement.find_by_quad(
          :predicate_uri_esc => @predicate.uri_esc,
          :context => @context
        ).should include(@statement)
      end
      
      it "should find a statment by subject, predicate" do
        RDF_Statement.find_by_quad(
          :subject => @subject,
          :predicate_uri_esc => @predicate.uri_esc
        ).should include(@statement)
      end
      
      it "should find a statment by predicate, object" do
        RDF_Statement.find_by_quad(
          :predicate_uri_esc => @predicate.uri_esc,
          :object => @object
        ).should include(@statement)
      end
    end
    
    describe "#find_or_init", :type => :transactional do
      
      it "should find and not create when one exists" do
        @new_statement = RDF_Statement.find_or_init(
          :subject => @subject,
          :predicate_uri_esc => @predicate.uri_esc,
          :object => @object,
          :context => @context
        )
        
        finish_tx
        @new_statement.should == @statement
        RDF_Statement.all.size.should == 1
        @new_statement.contexts.size.should == 1
      end
      
      it "should create when the statement doesn't exist" do
        subject = RDF_Resource.create(:uri_esc => "http://test.two".uri_esc)
        
        @new_statement = RDF_Statement.find_or_init(
          :subject => subject,
          :predicate_uri_esc => @predicate.uri_esc,
          :object => @object,
          :context => @context
        )
        @new_statement.save
        
        finish_tx
        @new_statement.should_not == @statement
        
        RDF_Statement.all.size.should == 2
      end
      
      it "should find the statement and add context_two" do
        @new_statement = RDF_Statement.find_or_init(
          :subject => @subject,
          :predicate_uri_esc => @predicate.uri_esc,
          :object => @object,
          :context => @context_two
        )
        
        finish_tx
        @new_statement.should == @statement
        RDF_Statement.all.size.should == 1
        @new_statement.contexts.should include(@context)
        @new_statement.contexts.should include(@context_two)
      end
      
    end
    
    describe "link test", :type => :transactional do
      
      it "should link both ways to RDF_Resource" do
        sub = RDF_Resource.create(:uri_esc => "http://subject.test".uri_esc)
        obj = RDF_Resource.create(:uri_esc => "http://object.test".uri_esc)
        con = RDF_Context.create(:uri_esc => "http://context.test".uri_esc)
        st = RDF_Statement.init_by_quad(
          :subject => sub,
          :predicate_uri_esc => "http://predicate.test".uri_esc,
          :object => obj,
          :context => con
        )
        st.save
        
        sub.incoming(:subject).to_a.should == [st]
      end     
    end  
  end
  
  describe "#remove_context", :type => :transactional  do
    before(:each) do
      @subject = RDF_Resource.create(:uri_esc => "http://test.subject".uri_esc)
      @predicate = "http://test.predicate"
      @object = RDF_Resource.create(:uri_esc => "http://test.object".uri_esc)
      @context = RDF_Context.create(:uri_esc => "http://test.context".uri_esc)
      @context_two = RDF_Context.create(:uri_esc => "http://test.context_two".uri_esc)
      @statement_one = RDF_Statement.init_by_quad(
          :subject => @subject,
          :predicate_uri_esc => @predicate.uri_esc,
          :object => @object,
          :context => @context
       )
       @statement_one.add_context @context_two
       @statement_one.save
    end

    it "should not include context" do
      @statement_one.contexts.should include(@context)
      @statement_one.remove_context(@context)
      
      @statement_one.contexts.should_not include(@context)
    end
    
    it "should not be destroyed if has at least one context" do
      @statement_one.remove_context(@context)
      
      @statement_one.contexts.size.should == 1
      Neo4j::Node.load(@statement_one.neo_id).should_not be nil      
    end
    
    
    it "should be destroyed since it isn't in a context" do
      @statement_one.remove_context(@context)
      @statement_one.remove_context(@context_two)
      
      @statement_one.contexts.size.should == 0
      Neo4j::Node.load(@statement_one.neo_id).should be nil
    end
    
    it "should destroy the subject and object if they have been oprhaned" do      
      @statement_one.remove_context(@context)
      @statement_one.remove_context(@context_two, {:subject => true, :object => true})
      
      finish_tx
      Neo4j::Node.load(@subject.neo_id).should be nil
      Neo4j::Node.load(@object.neo_id).should be nil
    end
    
    it "should not cleanup without cleanup arguments" do      
      @statement_one.remove_context(@context)
      @statement_one.remove_context(@context_two)
      
      finish_tx
      Neo4j::Node.load(@subject.neo_id).should_not be nil
      Neo4j::Node.load(@object.neo_id).should_not be nil
    end
    
    it "should not destroy subject if it hasn't been orphaned" do
      @subject_two = RDF_Resource.create(:uri_esc => "http://test.subject.two".uri_esc)
      @statement_two = RDF_Statement.init_by_quad(
          :subject => @subject_two,
          :predicate_uri_esc => @predicate.uri_esc,
          :object => @subject,
          :context => @context
       )
       @statement_two.save
       @statement_two.remove_context(@context, {:subject => true, :object => true})
       
       finish_tx
       Neo4j::Node.load(@subject_two.neo_id).should be nil
       Neo4j::Node.load(@subject.neo_id).should_not be nil
    end
  end
  
end