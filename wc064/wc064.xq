xquery version "3.1";

(:
 : Module Name:     wc064.xq
 :
 : Module Version:  1.0.0
 :
 : Date:            March 17, 2020
 :
 : Copyright:
 :
 : Proprietary
 : Extensions:      none
 :
 : Module Overview: Links Western Americana EADs to METS files.
 :                  Matches component IDs from EAD to the METS
 :                  OBJID (the object identifier in Figgy).
                    Returns a
 :                  JSON file of triples which may be processed
 :                  into bulk ingest commands using the wc064-ingest.rb
 :                  script.
:)

(:~
 :  This module links Western Americana EADs to the METS files
 :  that contain metadata about the individual images in the
 :  albums.
 :
 :  @author Cliff Wulfman
 :  @since February 26, 2020
 :)

declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";


declare function local:verify-dao($dao)
{
 let $ark := substring-after(xs:string($dao/@xlink:href), "http://arks.princeton.edu/")
 let $mets := collection('/db/WA/wc064')//mets:mets[@OBJID=$ark]
  return boolean($mets)
};

let $assets := 
 for $dao in collection('/db/WA/wc064')//ead:dao
 let $item_id := xs:string($dao/ancestor::ead:c[@level="item"]/@id)
 let $ark := substring-after(xs:string($dao/@xlink:href), "http://arks.princeton.edu/")
 let $mets := collection('/db/WA/wc064')//mets:mets[@OBJID=$ark]
 let $flocats := $mets//mets:fileGrp[@USE="masters"]//mets:FLocat
 let $tiff := fn:substring-after(xs:string($flocats[1]/@xlink:href), 'diglibdata/')
 return
  <asset>
   <componentID>{$item_id}</componentID>
   <objid>{$ark}</objid>
   <tiff>{$tiff}</tiff>
  </asset>
  
  return
   <assets>{ $assets }</assets>
