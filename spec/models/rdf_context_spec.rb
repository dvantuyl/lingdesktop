require "spec_helper"

describe RDF_Context do
  
  describe "#find_or_create" do

    context "when there is no other with uri" do
      
      it "creates and returns node" do
        node = RDF_Context.find_or_create(:uri => "http://test.com".uri_encode)
        
        RDF_Context.all.first.should == node
      end
      
    end
    
    context "when there is one with same uri" do
      before(:each) do
        @test = RDF_Context.create(:uri => "http://test.com".uri_encode)
      end
      
      it "should only have one" do
        node = RDF_Context.find_or_create(:uri => "http://test.com".uri_encode)
        
        RDF_Context.all.first.should == @test
      end
      
    end
       
  end
 
end