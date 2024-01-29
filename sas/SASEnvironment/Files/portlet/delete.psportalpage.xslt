<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Main Entry Point -->

<xsl:template match="/">

<!-- Scope is the type of removal to do 
     remove = just remove the page from my personal portal space
     delete = permanently delete the page
 -->
<xsl:variable name="newScope"><xsl:value-of select="Mod_Request/NewMetadata/Scope"/></xsl:variable>

<xsl:variable name="pageId"><xsl:value-of select="Mod_Request/NewMetadata/Id"/></xsl:variable>

    <TestMetadata>

      <Metadata>
           <PSPortalPage>
              <xsl:attribute name="Name"><xsl:value-of select="$pageName"/></xsl:attribute>
              <xsl:attribute name="Id"><xsl:value-of select="$pageId"/></xsl:attribute>
           </PSPortalPage>
      </Metadata>

      <NS>SAS</NS>
      <Flags>268435456</Flags>
      <Options/>

    </TestMetadata>

   </xsl:otherwise>
 </xsl:choose>

</xsl:template>

</xsl:stylesheet>

