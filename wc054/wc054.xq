xquery version "3.1";

(:
 : Module Name:     wc054.xq
 :
 : Module Version:  1.0.0
 :
 : Date:            March 10, 2020
 :
 : Copyright:
 :
 : Proprietary
 : Extensions:      none
 :
 : Module Overview: Links Western Americana EADs to METS files.
 :                  Matches component IDs from EAD to the METS
 :                  OBJID (the object identifier in Figgy) and
 :                  the path to the TIFF image file.  Returns a
 :                  JSON file of triples which may be processed
 :                  into bulk ingest commands using the wc055-ingest.rb
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

(:~
 : Parse an EAD container string representation into a simple format
 : that can be compared with the a MODS shelf locator.
 :
 : Sample input: Volume Album 1, leaf 5, photograph j
 : Output: 1.5.j
 :
 : @param $string a string of the form Volume Folio N, Leaf N, Photograph W
 : @return a string of the form i.i.w
 :)
declare function local:ead2loc($string as xs:string)
as xs:string
{
 let $hit := fn:analyze-string($string, ".*?Album\s+([0-9]).*?leaf\s+([0-9]+).*?photograph\s+([a-zA-Z]+)")
 return $hit//fn:group[1] || "." || $hit//fn:group[2] || "." || lower-case($hit//fn:group[3])
};

(:~
 : Parse an MODS shelf locator string representation into a simple format
 : that can be compared with the an EAD container.
 :
 : Sample input: (WA) WC055, Folio 1, Leaf 1, Photograph a
 : Output: 1.1.a
 :
 : @param $string a string of the form Volume Folio N, Leaf N, Photograph W
 : @return a string of the form i.i.w
 :)
 declare function local:mods2loc($string as xs:string)
as xs:string
{
 let $hit := fn:analyze-string($string, ".*?Album\s+([0-9]),.*?leaf\s+([0-9]+),.*?photograph\s+([a-zA-Z]+)")
  return $hit//fn:group[1] || "." || $hit//fn:group[2] || "." || lower-case($hit//fn:group[3])
};


let $ead_items := collection('/db/WC054')//ead:c[@level='file']
let $mods := collection('/db/WC054/wc054/4584826')//mods:mods
let $assets :=
 for $e in $ead_items
  let $container_id := local:ead2loc($e/ead:did/ead:container[@type='item']/text())
  for $m in $mods
   let $shelf_locator := local:mods2loc($m//mods:shelfLocator/text())
   where $container_id = $shelf_locator
    let $flocat := $m/ancestor::mets:mets//mets:fileGrp[@USE="masters"]//mets:FLocat
    let $tiff := fn:substring-after(xs:string($flocat/@xlink:href), 'diglibdata/')
    let $objid := xs:string($m/ancestor::mets:mets/@OBJID)
   return
     <asset>
      <componentID>{xs:string($e/@id)}</componentID>
      <objid>{$objid}</objid>
      <tiff>{$tiff}</tiff>
     </asset>

return <assets>{$assets}</assets>
