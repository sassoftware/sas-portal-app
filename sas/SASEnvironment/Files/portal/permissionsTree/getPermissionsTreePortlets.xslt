<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Get the list of portlets in this permissions tree (if any) 
  -->

<xsl:param name="treeName"/>

<xsl:template match="/">

<GetMetadataObjects>
                                <ReposId>$METAREPOSITORY</ReposId>
                                <Type>Tree</Type>
                                <ns>SAS</ns>
                                <!-- 256 = GetMetadata
                                     128 = XMLSelect
                                       4 =  Template
                                -->
                                <Flags>388</Flags>
                                <Options>
                     <XMLSelect><xsl:attribute name="search">@Name='<xsl:value-of select="$treeName"/>'</xsl:attribute></XMLSelect>
                     <Templates>
                        <Tree Id="" Name="">
                          <Members search="PSPortlet"/>
                        </Tree>
                        <PSPortlet Id="" Name="" portletType=""/>
                     </Templates>
                </Options>
</GetMetadataObjects>

</xsl:template>

</xsl:stylesheet>

