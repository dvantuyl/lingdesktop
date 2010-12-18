require "spec_helper"

shared_examples_for "All Contexts" do
  
  describe "#find_or_create" do   
    
    it "should only have one" do
      RDF_Context.find_or_create(:uri_esc => @context_one.uri_esc)
      
      RDF_Context.all(:uri_esc => @context_one.uri_esc).size.should == 1    
    end      
  end
  
  
  describe "#follow", :type => :transactional do
    before(:each) do
      @context_one.follow @context_two
    end
    
    it "context_one should be following context_two" do
      @context_one.following.should include(@context_two)
    end
    
    it "context_two should have context_one as one of its followers" do
      @context_two.followers.should include(@context_one)
    end
    
    it "context_one and context_two should have the same statements" do
      @subject = RDF_Resource.create(:uri_esc => "http://subject.test".uri_esc)
      @predicate_uri = "http://predicate.test"
      @object = RDF_Resource.create(:uri_esc => "http://object.test".uri_esc)
      
      @statement = RDF_Statement.init_by_quad(
        :subject => @subject,
        :predicate_uri_esc => @predicate_uri.uri_esc,
        :object => @object,
        :context => @context_two
      )
      @statement.save
      
      @context_one.statements.should include(@statement)
      @statement.remove_context(@context_two)
      @context_one.statements.should_not include(@statement)
    end
  end
  
  describe "#copy_from_context", :type => :transactional do
    before(:each) do
      @subject = RDF_Resource.create(:uri_esc => "http://subject.test".uri_esc)
      @predicate_uri = "http://predicate.test"
      @object = RDF_Resource.create(:uri_esc => "http://object.test".uri_esc)
      
      @statement = RDF_Statement.init_by_quad(
        :subject => @subject,
        :predicate_uri_esc => @predicate_uri.uri_esc,
        :object => @object,
        :context => @context_one
      )
      
      @context_two.copy_from_context(@context_one)
    end
    
    it "should have the same statements" do
      @context_one.statements.should == @context_two.statements
    end
    
  end
end

describe RDF_Context do
  before(:each) do
    @context_one = RDF_Context.create(:uri_esc => "http://context.one".uri_esc)
    @context_two = RDF_Context.create(:uri_esc => "http://context.two".uri_esc)
  end
  
  it_should_behave_like "All Contexts"
end