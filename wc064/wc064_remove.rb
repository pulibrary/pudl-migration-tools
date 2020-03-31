#!/usr/bin/env ruby

# Remove all wc064 assets from repository (prior to re-ingesting).

ENV['RAILS_ENV'] = 'production'
ENV['HONEYBADGER_API_KEY'] = ''
require '/opt/figgy/current/config/environment'
require 'optparse'

require 'json'

csp = ScannedResourcesController.change_set_persister

assets = JSON.parse File.read(options[:json])

assets['asset'].each do |asset|
  resource = db.query_service.custom_queries.find_by_property(property: :identifier, value: asset['objid']).first  
  cs = DynamicChangeSet.new(resource)
  raise "no resource for #{asset['objid']}" unless resource
  puts "deleting resource for #{asset['objid']}"
#  csp.delete(change_set: cs)
end



