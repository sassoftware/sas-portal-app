<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- input xml format is the Mod_Request xml format with context information
     about the request is in the NewMetadata section
-->

<xsl:template match="/">

 <xsl:variable name="id" select="/Mod_Request/NewMetadata/Id"/>


<GetMetadata>
 <Metadata>
 <PSPortalPage>
    <xsl:attribute name="Id"><xsl:value-of select="$id"/></xsl:attribute>
 </PSPortalPage>
 </Metadata>
 <NS>SAS</NS>
     <!-- 4 =  Template
     -->
 <Flags>4</Flags>
 <Options>
     <Templates>
         <PSPortalPage Id="" Name="" Desc="">
            <Keywords/>
            <Extensions/>
         </PSPortalPage>
         <Extension Id="" Name="" Value=""/>
         <Keyword Id="" Name=""/>
     </Templates>
  </Options>
 </GetMetadata>

</xsl:template>

</xsl:stylesheet>

