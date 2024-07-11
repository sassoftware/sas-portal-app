<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- input xml format is the Mod_Request xml format with context information
     about the request is in the NewMetadata section
-->

<xsl:template match="/">

  <!-- Sample values of parameters
    path=/Shared Data/folder1/folder2
    objectFilter=StoredProcess,Report,InformationMap
  -->

 <!--  Normally, we would get the object and traverse the requested content in one call.  However, in this specific case
       since we are getting a tree, if we were to try to get it's subtrees and members in one call, we navigate all the hierarchy below it, ie. very expensive.
       Thus, what we will do here is get the specific tree that matches the passed search criteria.
  -->
 <xsl:variable name="path" select="/Mod_Request/NewMetadata/Path"/>
 <xsl:variable name="objectFilter" select="/Mod_Request/NewMetadata/ObjectFilter"/>
 <xsl:variable name="reposId" select="/Mod_Request/NewMetadata/Metareposid"/>

 <!--  If we are passed a blank path or a path='/', then we have to get the "root" of the SAS Content tree, which is actually a SoftwareComponent
  -->

 <xsl:choose>

 <xsl:when test="not($path) or $path='/'">

      <GetMetadataObjects>
      <ReposId><xsl:value-of select="$reposId"/></ReposId>
      <Type>SoftwareComponent</Type>
      <ns>SAS</ns>
         <!-- 128 = XMLSelect
         -->
      <Flags>128</Flags>
      <Options>
         <XMLSelect>
            <xsl:attribute name="search">@Name='BIP Service'</xsl:attribute>
         </XMLSelect>
      </Options>
     </GetMetadataObjects>

 </xsl:when>

 <xsl:otherwise>

     <GetMetadataObjects>
      <ReposId><xsl:value-of select="$reposId"/></ReposId>
      <Type>Tree</Type>
      <ns>SAS</ns>
         <!-- 128 = XMLSelect
         -->
      <Flags>128</Flags>
      <Options>
         <XMLSelect>
             <xsl:variable name="folderNamesWithBlank" select="tokenize($path,'/')"/>
             <xsl:variable name="folderNames" select="$folderNamesWithBlank[normalize-space()]"/>         

             <xsl:variable name="searchCriteria">
             <xsl:for-each select="$folderNames">
               <xsl:sort select="position()" order="descending"/>
                <xsl:choose>
                <xsl:when test="position() = 1">*[@Name='<xsl:value-of select="."/>']<xsl:if test="position() = last()">[SoftwareComponents/SoftwareComponent[@Name='BIP Service']]</xsl:if></xsl:when>
                <xsl:when test="position() = 2"><xsl:if test=".">[ParentTree/Tree[@Name='<xsl:value-of select="."/>']<xsl:if test="position() = last()">]</xsl:if></xsl:if>
                </xsl:when>
                <xsl:when test="position() = last()"><xsl:if test=".">/ParentTree/Tree[@Name='<xsl:value-of select="."/>']</xsl:if>]</xsl:when>
                <xsl:otherwise>/ParentTree/Tree[@Name='<xsl:value-of select="."/>']</xsl:otherwise>
              </xsl:choose>
             
             
             </xsl:for-each>
             </xsl:variable>
     
            <xsl:attribute name="search"><xsl:value-of select="$searchCriteria"/></xsl:attribute>
         </XMLSelect>
      </Options>
     </GetMetadataObjects>

 </xsl:otherwise>

 </xsl:choose>
 
</xsl:template>

</xsl:stylesheet>

