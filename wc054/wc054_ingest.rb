# frozen_string_literal: true

# Generate a shell script that runs the bulk:ingest rake task for each
# component image from Western Americana WC054.  The input to this
# script is a json-formatted file containing the mappings of EAD
# component ids, METS OBJID, and path to the TIFF image.

# example:
# ruby wc054-ingest.rb -r assets.json -d /mnt/diglibdata > wc054.sh

require 'optparse'
require 'json'

# default collection to id on staging
options = {
  collection: 'e201720c-e1bb-48eb-854d-5bc0aa6f57c',
  model: 'ScannedResource',
  root: '/mnt/diglibdata',
  filter: '.tif'
}

OptionParser.new do |parser|
  parser.banner = 'Usage: wc054-ingest.rb -r assets.json -d /mnt/diglibdata -c mycollectionid -f .tif > wc054.sh'

  parser.on('-r', '--resources FILEPATH', 'path to JSON file of resources') do |v|
    options[:json] = v
  end

  parser.on('-c', '--collection STRING', 'Figgy ID of collection') do |v|
    options[:collection] = v
  end

  parser.on('-d', '--imagedir PATH', 'root of image path') do |v|
    options[:root] = v
  end

  parser.on('-f', '--filter ', 'root of image path') do |v|
    options[:root] = v
  end
end.parse!

unless File.exist?(options[:json])
  raise ArgumentError, "#{options[:json]} doesn't exist"
end

assets = JSON.parse File.read(options[:json])

assets['asset'].each do |asset|
  dir = options[:root] + '/' + File.dirname(asset['tiff'])
  bib = asset['componentID']
  objid = asset['objid']
  command = "DIR=#{dir} BIB=#{bib} OBJID=#{objid} COLL=#{options[:collection]} FILTER=#{options[:filter]} MODEL=#{options[:model]} bundle exec rake bulk:ingest "
  puts command
end
