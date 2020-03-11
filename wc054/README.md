# Migrating WC054

*The problem:* Identical with WC055.

*Solution:* modified the regular expressions to match the MODS shelf locator and the EAD container strings and generated an assets.json file of tuples; fed these to the shell-script generator to produce a shell script that invokes bulk:ingest on each image. (Did not need to delete pre-existing figgy objects, as there were none.)

``` shell
ruby wc054-ingest.rb -r assets.json -d /mnt/diglibdata > ingest-wc054.sh | sh
```

*Next steps/improvements:*
	* if WC064 turns out to be the same problem, take the time to implement a more generic solution.
