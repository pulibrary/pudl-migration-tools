#!/usr/bin/env ruby

ENV['RAILS_ENV'] = 'production'
ENV['HONEYBADGER_API_KEY'] = ''
require '/opt/figgy/current/config/environment'
require 'optparse'

def update_record(c_id, ark)
  db = Valkyrie::MetadataAdapter.find(:indexing_persister)
  disk = Valkyrie::StorageAdapter.find(:disk)
  csp = ChangeSetPersister.new(metadata_adapter: db, storage_adapter: disk)
  resource = db.query_service.custom_queries.find_by_property(property: :identifier, value: ark)
  cs = DynamicChangeSet.new(resource)
  cs.validate(source_metadata_identifier: [c_id])
#  cs.validate(archival_collection_code: c_code) # don't need to do this done by the persister
  cs.sync
  csp.save(change_set: cs)
end


options = {}

OptionParser.new do |parser|
  parser.on('-a', '--ark ARK', 'ark of resource') do |v|
    options[:ark] = v
  end
  parser.on('-i', '--id ID', 'id of EAD component') do |v|
    options[:c_id] = v
  end
end.parse!

update_record(options[:c_id], options[:ark])
