<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- input xml format is the Mod_Request xml format with context information
     about the request is in the NewMetadata section
-->

<xsl:template match="/">

 <xsl:variable name="id" select="/Mod_Request/NewMetadata/Id"/>

<GetMetadata>
 <Metadata>
 <Document Name="" Desc="" URIType="" URI="" TextRole="" TextType="">
   <xsl:attribute name="Id"><xsl:value-of select="$id"/></xsl:attribute>
 </Document>
 </Metadata>
 <NS>SAS</NS>
 <Flags>0</Flags>
 <Options>
                </Options>
</GetMetadata>

</xsl:template>

</xsl:stylesheet>

