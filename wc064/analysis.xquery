xquery version "3.1";


declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare option exist:serialize "method=xhtml media-type=application/xhtml+html";

declare function local:verify-dao($dao)
{
 let $ark := fn:analyze-string(xs:string($dao/@xlink:href), "^http://arks.princeton.edu/(ark.*?)$")//fn:group[1]/text()
 let $mets := collection('/db/WA/wc064')//mets:mets[@OBJID=$ark]
  return boolean($mets)
};

let $items := collection('/db/WA/wc064')//ead:c[@level = 'item']
let $mods := collection('/db/WA/wc064')//mods:mods
let $mets := collection('/db/WA/wc064')//mets:mets
let $no-folder := $items[not(.//ead:container[@type = 'folder'])]

let $sample-dao := $items[1]//ead:dao

let $target-cs :=
 for $c in $items[not(local:verify-dao(.//ead:dao))]
 return $c

return
 <html>
  <head>
   <title>WC064 stats</title>
   <style>
   <![CDATA[
   table {
  border-collapse: collapse;
}

table, th, td {
  border: 1px solid black;
}

th, td {
  padding: 15px;
  text-align: left;
}
   ]]>
   </style>
  </head>
  <body>
   <h1>Top-Level Counts</h1>
   <p>There are {count($items)} item-level containers in the EAD.</p> 
   
   <ul>
    <li>One of them ({$no-folder/ead:did/ead:unitid/text()}, &quot;{xs:string($no-folder/ead:did/ead:unittitle)}&quot;) lacks a folder container</li>
    
    <li>{ count($items) - count($items//ead:unitid[@type = 'accessionnumber']) } items in the EAD lack accession numbers</li>
    
    <li>{ count($items[.//ead:did/ead:dao]) } have &lt;dao&gt; elements with links to arks.</li>
   </ul>
   
   <p>Both record types (METS and EAD) have elements representing accession numbers; unfortunately, the counts differ.</p>

   <table>
    <caption>Accession number counts for METS and EAD</caption>
    <thead>
     <tr>
      <th></th>
      <th>EAD</th>
      <th>METS/MODS</th>
     </tr>
    </thead>
    <tbody>
     <tr>
      <th># of accession numbers</th>
      <th>{ count($items//ead:unitid[@type = 'accessionnumber']) }</th>
      <th>{ count($mods/mods:identifier[@type="localAccession"]) }</th>
     </tr>
    </tbody>
   </table>
   
   <p>There are { count($mets) } METS elements, but { count($mets[count(.//mets:fileGrp[@USE="masters"]//mets:file) > 1]) } have more than one image file (not counting thumbnails). Note that the number of dao elements ({ count($items[.//ead:did/ead:dao]) }) is the same as the number of METS files ({ count($mets) }), suggesting that all of the extant METS have already been ingested.   
   </p>
   
   <p>That leaves {count($items) - count($mets)} EAD items without matching METS.</p>
   <table>
    <caption>EAD items without matching METS</caption>
   <thead>
    <tr>
     <th>item id</th>
     <th>unit id</th>
     <th>unit title</th>
    </tr>
   </thead>
   <tbody>
      {
    for $c in $target-cs
    return
    <tr>
     <td>{ xs:string($c/@id) }</td>
     <td>{ xs:string($c/ead:did/ead:unitid) }</td>
     <td>{ xs:string($c/ead:did/ead:unittitle) }</td>
    </tr>
    }
   </tbody>
   </table>
 
  </body>
 </html>
