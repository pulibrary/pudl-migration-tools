# Migrating WC055

*The problem:* The asset is a two-volume album of photographs. There is an EAD for the album, MODS records for every photograph, and METS records for every image. Ingest all the images into Figgy in such a way that each image is linked to its proper EAD container.

The text in each EAD container is regular, as is the text in the shelfLocator in each MODS record. Regularize these strings and use them to perform a join on the records. Using these joins, use the existing bulk:ingest rake task to ingest the TIF images in each image directory, using the EAD component ID as the BIB id and the METS OBJID (an ark) as the identifier.

*Solution implementation:* Because all the metadata is XML, use XQuery to perform the join and generate a join set of (container id, object id, TIF file) tuples (assets.json). Because there is an existing rake task (bulk:ingest) to ingest a single directory of images via an invocation of IngestFolderJob, write a simple Ruby script to generate an invocation of bulk:rake for each set. Run the resulting shell script to perform the ingestion.

``` shell
bundle exec rake bulk:remove CODE=WC055
ruby wc055-ingest.rb -r assets.json -d /mnt/diglibdata > ingest-wc055.sh | sh
```

*Next steps/improvements:*
  * write a new rake task that processes a tuple set
  * implement the join function as a Ruby script that takes an EAD file and a folder of METS files as arguments.
