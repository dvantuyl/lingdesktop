require "spec_helper"

describe RDF_Context do
  before(:each) do
    @test_uri = "http://test.com"
    @context = RDF_Context.new(:uri => @test_uri)
  end
  

  it "is valid with a uri" do
    @context.should be_valid
  end  
  
  it "is not valid without a uri" do
    @context.uri = nil
    @context.should_not be_valid
  end
  
  it "has an unencoded uri"
  
  
  
  describe "#create" do
    it "creates a new context with a uri" do
      context = RDF_Context.create(:uri => "")
    end
  end
  
  
  describe "#find" do
    #before(:each) do
    #  @context = RDF_Context.create(:uri => "http://test.com")
    #end
    
    #it "finds the node based on a uri" do
    #  RDF_Context.find(:uri => "http://test.com").should == @context
    #end
  end

  
end