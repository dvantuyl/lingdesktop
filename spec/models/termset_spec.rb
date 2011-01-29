require "spec_helper"

describe Termset do
  before(:each) do
    @context = RDF_Context.create(:name => "context one")
  end
  
  describe "#gen_uri_esc" do
    
    it "size should not equal 0" do
      Termset.gen_uri_esc.size.should_not == 0
    end
    
  end
  
  describe "#create_in_context", :type => :transactional do

    it "should have type" do
      
      termset = Termset.create_in_context(@context)
      
      hash = termset.to_hash("rdf:type" => {:first => true})
      hash["rdf:type"][:uri].should == RDF::GOLD.Termset.to_s  
    end
  end
  
  
  describe "#set_label", :type => :transactional  do
   
    it "should have label" do
      termset = Termset.create_in_context(@context)
      termset.set_label("label", @context)
      
      hash = termset.to_hash("rdfs:label" => {:first => true})
      hash["rdfs:label"][:value].should == "label"
    end
    
    it "should update label" do
      termset = Termset.create_in_context(@context)
      termset.set_label("test one", @context)
      termset.set_label("test two", @context)
      
      hash = termset.to_hash("rdfs:label" => {})
      hash["rdfs:label"].size.should == 1
      hash["rdfs:label"].first[:value].should == "test two"
    end
  end
  
  describe "#set_comment", :type => :transactional  do
   
    it "should have comment" do
      termset = Termset.create_in_context(@context)
      termset.set_comment("comment", @context)
      
      hash = termset.to_hash("rdfs:comment" => {:first => true})
      hash["rdfs:comment"][:value].should == "comment"
    end
    
    it "should update comment" do
      termset = Termset.create_in_context(@context)
      termset.set_comment("test one", @context)
      termset.set_comment("test two", @context)
      
      hash = termset.to_hash("rdfs:comment" => {})
      hash["rdfs:comment"].size.should == 1
      hash["rdfs:comment"].first[:value].should == "test two"
    end
  end
  
  describe "#set", :type => :transactional do
    it "should have a label and comment" do
      termset = Termset.create_in_context(@context)
      termset.set({
        "rdfs:label" => "label",
        "rdfs:comment" => "comment"
      }, @context)
      
      finish_tx
      hash = termset.to_hash(
        "rdfs:label" => {
          :first => true,
          :simple_value => :value,
          :context => @context
        },
        
        "rdfs:comment" => {
          :first => true,
          :simple_value => :value,
          :context => @context
        }  
      )
      
      hash["rdfs:label"].should == "label"
      hash["rdfs:comment"].should == "comment"
    end
  end

end