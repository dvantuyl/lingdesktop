require "spec_helper"

describe Termset do
  before(:each) do
    RDF_Resource.create(:uri_esc => RDF::GOLD.Termset.uri_esc)
    @context = RDF_Context.create(:uri_esc => "http://context.test".uri_esc)
  end
  
  describe "#gen_uri_esc" do
    
    it "size should not equal 0" do
      Termset.gen_uri_esc.size.should_not == 0
    end
    
  end
  
  describe "#create_in_context" do
    
    it "should have" do
      termset = Termset.create_in_context(@context)
      
      RDF_Statement.find_by_quad(
        :subject => termset,
        :predictate_uri_esc => RDF.type.uri_esc,
        :context => @context
      ).first.object.uri.should == RDF::GOLD.Termset.to_s  
    end
  end
  
end