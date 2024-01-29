<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Main Entry Point -->

<xsl:template match="/">

<xsl:variable name="newName"><xsl:value-of select="Mod_Request/NewMetadata/Name"/></xsl:variable>
<xsl:variable name="newDesc"><xsl:value-of select="Mod_Request/NewMetadata/Desc"/></xsl:variable>
<xsl:variable name="newURI"><xsl:value-of select="Mod_Request/NewMetadata/URI"/></xsl:variable>
<xsl:variable name="newContentType">
  <xsl:choose>
    <xsl:when test="Mod_Request/NewMetadata/ContentType='Application'">Portal Web Application</xsl:when>
    <xsl:when test="Mod_Request/NewMetadata/ContentType='Channel'">Syndication Channel</xsl:when>
    <xsl:when test="Mod_Request/NewMetadata/ContentType='Link'">Portal Link</xsl:when>
    <xsl:otherwise></xsl:otherwise>
  </xsl:choose>

</xsl:variable>

<xsl:variable name="existingItemGroupType"><xsl:value-of select="Mod_Request/NewMetadata/RelatedType"/></xsl:variable>
<xsl:variable name="existingItemGroupId"><xsl:value-of select="Mod_Request/NewMetadata/RelatedId"/></xsl:variable>

<xsl:variable name="parentTreeId"><xsl:value-of select="Mod_Request/NewMetadata/ParentTreeId"/></xsl:variable>

<xsl:variable name="repositoryId">
  <xsl:choose>
    <xsl:when test="$parentTreeId"><xsl:value-of select="substring-before($parentTreeId,'.')"/></xsl:when>
    <xsl:when test="$existingItemGroupId"><xsl:value-of select="substring-before($existingItemGroupId,'.')"/></xsl:when>
    <xsl:otherwise></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="newObjectId"><xsl:value-of select="$repositoryId"/>.$newDocument</xsl:variable>

    <!-- NOTE: We use UpdateMetadata here so that we can both create new objects (those with and Id starting with $)
         and update existing objects.
    -->

    <UpdateMetadata>

      <Metadata>

         <Document>
           <xsl:attribute name="Id"><xsl:value-of select="$newObjectId"/></xsl:attribute>
           
           <xsl:if test="$newName">
              <xsl:attribute name="Name"><xsl:value-of select="$newName"/></xsl:attribute>
              </xsl:if>

           <xsl:if test="$newDesc">
              <xsl:attribute name="Desc"><xsl:value-of select="$newDesc"/></xsl:attribute>
              </xsl:if>

           <xsl:if test="$newURI">
              <xsl:attribute name="URI"><xsl:value-of select="$newURI"/></xsl:attribute>
              </xsl:if>
           <xsl:if test="$newContentType">
              <xsl:attribute name="TextRole"><xsl:value-of select="$newContentType"/></xsl:attribute>
              </xsl:if>

         </Document>

         <xsl:if test="$existingItemGroupId">
            <xsl:element name="{$existingItemGroupType}">
               <xsl:attribute name="Id"><xsl:value-of select="$existingItemGroupId"/></xsl:attribute>
               <Members function="append">
                   <Document>
                     <xsl:attribute name="ObjRef"><xsl:value-of select="$newObjectId"/></xsl:attribute>
                   </Document>
               </Members>
            </xsl:element>
         </xsl:if>

         <xsl:if test="$parentTreeId">
            <Tree>
               <xsl:attribute name="Id"><xsl:value-of select="$parentTreeId"/></xsl:attribute>
               <Members function="append">
                   <Document>
                     <xsl:attribute name="ObjRef"><xsl:value-of select="$newObjectId"/></xsl:attribute>
                   </Document>
               </Members>
            </Tree>

         </xsl:if>

      </Metadata>

      <NS>SAS</NS>
      <Flags>268435456</Flags>
      <Options/>

    </UpdateMetadata>

</xsl:template>

</xsl:stylesheet>

