require "spec_helper"

describe RDF_Literal do
  
  describe "#find_or_create" do
   
    context "when there is no other with lang and value" do
      
      it "creates and returns node" do
        node = RDF_Literal.find_or_create(:lang => 'en', :value => 'testone')
        
        RDF_Literal.all.first.should == node
      end
      
    end
    
    context "when there is one with same lang and value" do
      before(:each) do
        @test = RDF_Literal.create(:lang => 'en', :value => 'test one')
      end
      
      it "should only have one" do
        node = RDF_Literal.find_or_create(:lang => 'en', :value => 'test one')
        
        RDF_Literal.all.first.should == @test
      end
      
    end
       
  end
 
end