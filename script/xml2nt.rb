#!/usr/bin/env ruby

require "rubygems"
require "rdf/raptor"
require "rdf/ntriples"

## IMPORT GOLD ##
owlgraph = RDF::Graph.load(
  File.expand_path('../../db/slash_gold-2009.owl', __FILE__), 
  {:format => :rdfxml}
)

RDF::Writer.open(File.expand_path('../../db/slash_gold-2009.nt', __FILE__)) do |writer|
   owlgraph.each_statement do |statement|
     writer << statement
   end
end

puts "RDFXML to ntriples conversion complete." 

