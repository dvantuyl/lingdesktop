require 'spec_helper'

describe GoldController do
  before(:each) do
    @literal = RDF_Literal.create(:lang => "en", :value => "English")
    @resource_one = RDF_Resource.create(:uri_esc => "http://test.one".uri_esc)
    @resource_two = RDF_Resource.create(:uri_esc => "http://test.two".uri_esc)
    @context = RDF_Context.create(:uri_esc => "http://context.test".uri_esc)
    @predicate_one = "http://predicate.one".uri_esc
    @predicate_two = "http://predicate.two".uri_esc
    @statement_one = RDF_Statement.create_by_quad(
      :subject => @resource_one,
      :predicate_uri_esc => @predicate_one,
      :object => @resource_two,
      :context => @context
    )
    @statement_two = RDF_Statement.create_by_quad(
      :subject => @resource_one,
      :predicate_uri_esc => @predicate_two,
      :object => @literal,
      :context => @context
    )
  end
  
  
end
