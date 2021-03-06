# to simply load this from the console:
# . .\transform.ps1
# !!!! notice the space after the first "dot"

# then call like so:
# Convert-WithXslt "c:\...\full_path" "c:\...\full_path" "c:\...\full_path"
# !!!!notice full path is required 
# !!!and no parens or commas are used when calling powershell functions

function Convert-WithXslt($originalXmlFilePath, $xslFilePath, $outputFilePath)
{
write-host test
write-host "`$originalXmlFilePath: " $originalXmlFilePath
write-host "`$xslFilePath: " $xslFilePath
write-host "`$outputFilePath: " $outputFilePath

   ## Simplistic error handling

   $xslFilePath = resolve-path $xslFilePath

   if( -not (test-path $xslFilePath) ) { throw "Can't find the XSL file" }

   $originalXmlFilePath = resolve-path $originalXmlFilePath

   if( -not (test-path $originalXmlFilePath) ) { throw "Can't find the XML file" }

   #$outputFilePath = resolve-path $outputFilePath

   #if( -not (test-path (split-path $originalXmlFilePath)) ) { throw "Can't find the output folder" }

 

   ## Get an XSL Transform object (try for the new .Net 3.5 version first)

   $EAP = $ErrorActionPreference

   $ErrorActionPreference = "SilentlyContinue"

   $script:xslt = new-object system.xml.xsl.xslcompiledtransform

   trap [System.Management.Automation.PSArgumentException]

   {  # no 3.5, use the slower 2.0 one

      $ErrorActionPreference = $EAP

      $script:xslt = new-object system.xml.xsl.xsltransform

   }

   $ErrorActionPreference = $EAP

   

   ## load xslt file

   $xslt.load( $xslFilePath )

     

   ## transform

   $xslt.Transform( $originalXmlFilePath, $outputFilePath )
   
   invoke-item $outputFilePath

}

 
