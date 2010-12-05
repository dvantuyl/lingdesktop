require "spec_helper"

describe RDF_Resource do
  
  describe "#find_or_create" do
  
    it "creates and returns node" do
      node = RDF_Resource.find_or_create(:uri_esc => "http://test.com".uri_esc)
      
      RDF_Resource.all.first.should be node
    end  

    
    context "when there is one with same uri" do
      before(:each) do
        @test = RDF_Resource.create(:uri_esc => "http://test.com".uri_esc)
      end
      
      it "should only have one" do
        node = RDF_Resource.find_or_create(:uri_esc => "http://test.com".uri_esc)    
        RDF_Resource.all.first.should be @test
      end     
    end
       
  end
  
  
  context "nodes found and " do
    before(:each) do
      @literal_en = RDF_Literal.create(:lang => "en", :value => "English")
      @literal_fr = RDF_Literal.create(:lang => "fr", :value => "French")
      @resource_test = RDF_Resource.create(:uri_esc => "http://test.com".uri_esc)
      @nodes = [@literal_en, @literal_fr, @resource_test]
    end
  
    describe "#filter_by_lang" do     
      it "should include 'English' Literal when filtering by 'en'" do
        RDF_Resource.filter_by_lang(@nodes, 'en').should include(@literal_en)
      end
      
      it "should not include 'French' Literal when filtering by 'en'" do
        RDF_Resource.filter_by_lang(@nodes, 'en').should_not include(@literal_fr)        
      end

      it "should not include a resource when filtering by 'en'" do
        RDF_Resource.filter_by_lang(@nodes, 'en').should_not include(@resource_test)        
      end     
    end
    
    describe "#filter_simple_value" do
      it "should only return lang values when the simple_value property is :lang" do
        RDF_Resource.filter_simple_value(@nodes, :lang).should include("en")
        RDF_Resource.filter_simple_value(@nodes, :lang).should include("fr")
        RDF_Resource.filter_simple_value(@nodes, :lang).size.should == 2
      end
    end
    
    describe "#filter_first" do
      it "should return the first node" do
        RDF_Resource.filter_first(@nodes).should be @literal_en
      end
    end
    
    describe "#filter_empty_xor" do
      it "should be False when result is empty and xor True" do
        RDF_Resource.filter_empty_xor([], true).should be false
      end
      it "should be True when result is empty and xor False" do
        RDF_Resource.filter_empty_xor([], false).should be true
      end
      it "should be True when result is not empty and xor True" do
        RDF_Resource.filter_empty_xor(@nodes, true).should be true
      end
      it "should be False when result is not empty and xor False" do
        RDF_Resource.filter_empty_xor(@nodes, false).should be false
      end
    end
    
    describe "#filter_results" do
      it "should return all nodes" do
        RDF_Resource.filter_results(@nodes, {}).size.should == 3
      end
    end
    
  end
  
  context "given statements in store " do
    before(:each) do
      @literal = RDF_Literal.create(:lang => "en", :value => "English")
      @resource_one = RDF_Resource.create(:uri_esc => "http://test.one".uri_esc)
      @resource_two = RDF_Resource.create(:uri_esc => "http://test.two".uri_esc)
      @context = RDF_Context.create(:uri_esc => "http://context.test".uri_esc)
      @predicate_one = "http://predicate.one"
      @predicate_two = "http://predicate.two".uri_esc
      @statement_one = RDF_Statement.create_by_quad(
        :subject => @resource_one,
        :predicate_uri_esc => @predicate_one.uri_esc,
        :object => @resource_two,
        :context => @context
      )
      @statement_two = RDF_Statement.create_by_quad(
        :subject => @resource_one,
        :predicate_uri_esc => @predicate_two.uri_esc,
        :object => @literal,
        :context => @context
      )
    end
    
    describe "#get_objects" do
      it "should include resource object" do
        @resource_one.get_objects(@predicate_one => {}).should include(@resource_two)
      end
      
      it "should include literal object" do
        @resource_one.get_objects(@predicate_two => {}).should include(@literal)
      end 
    end
    
    describe "#get_subjects" do
      it "should have one resource as subject" do
        @resource_two.get_subjects(@predicate_one => {}).should include(@resource_one)
      end
    end
    
    describe "#to_hash" do
      it "with no arguments should contain uri and localname" do
        @resource_one.to_hash[:uri].should == @resource_one.uri
        @resource_one.to_hash[:localname].should == @resource_one.localname
      end
      
      it "with predicate_one should include resource_two" do
        hash = @resource_one.to_hash(@predicate_one => {})
        hash[@predicate_one].should include(@resource_two.to_hash)
      end
      
      it "with predicate_one and predicate_two should include resource_two and literal" do
        hash = @resource_one.to_hash(@predicate_one => {}, @predicate_two => {})
        
        hash[@predicate_one].should include(@resource_two.to_hash)
        hash[@predicate_two].should include(@literal.to_hash)
      end
      
      
    end
  end
 
end