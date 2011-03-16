#!/usr/bin/env ruby

require "rubygems"
require "rdf"
require "rdf/raptor"
require "rdf/ntriples"

puts RDF::Raptor.available? 

## IMPORT GOLD ##
owlgraph = RDF::Graph.load("db/load/gold-2010.rdf")


RDF::Writer.open("db/load/gold-2010.nt") do |writer|
  owlgraph.each_statement do |statement|
    writer << statement
  end
end




puts "RDFXML to ntriples conversion complete." 

