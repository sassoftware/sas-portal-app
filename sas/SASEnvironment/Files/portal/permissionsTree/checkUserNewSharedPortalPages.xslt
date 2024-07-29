<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- This request will get the list of new shared pages given a timeframe 

     Since this request is done at every logon, it needs to be as fast as possible.
-->

<xsl:param name="startDT">.</xsl:param>
<xsl:param name="endDT">.</xsl:param>

<xsl:param name="treeName"/>
<xsl:param name="reposName"/>

<!--  We only care about pages that are "Shared".  All of those pages have one of the following named Extensions
      on them:

      - SharedPageSticky
      - SharedPageDefault
      - SharedPageAvailable

      Since the extensions are created at the same time as the page, we can speed up the search by just checking for
      Extension objects with one of those names and created within the timerange passed.
-->

<xsl:template match="/">

<GetMetadataObjects>
 <ReposId>$METAREPOSITORY</ReposId>  
 <Type>Extension</Type>
 <ns>SAS</ns>
     <!-- 128 = XMLSelect
     -->
 <Flags>128</Flags>
 <Options>

   <xsl:variable name="start"><xsl:value-of select="normalize-space($startDT)"/></xsl:variable>
   <xsl:variable name="end"><xsl:value-of select="normalize-space($endDT)"/></xsl:variable>

   <xsl:variable name="timeFilter">

   <xsl:choose>

   <xsl:when test="not($start='.') and not($end='.')">(@MetadataCreated GT '<xsl:value-of select="$start"/>' and @MetadataCreated LE '<xsl:value-of select="$end"/>')</xsl:when>
   <xsl:when test="$start='.' and not($end='.')">(@MetadataCreated LE '<xsl:value-of select="$end"/>')</xsl:when>
   <xsl:when test="not($start='.') and $end='.'">(@MetadataCreated GT '<xsl:value-of select="$start"/>')</xsl:when>
   <xsl:otherwise></xsl:otherwise>

   </xsl:choose>

   </xsl:variable>

   <xsl:variable name="pageFilter">(@Name='SharedPageSticky' or @Name='SharedPageDefault' or @Name='SharedPageAvailable')</xsl:variable>

   <xsl:choose>
       <xsl:when test="not($timeFilter='')">
           <XMLSelect><xsl:attribute name="search">*[<xsl:value-of select="$timeFilter"/> and <xsl:value-of select="$pageFilter"/>]</xsl:attribute></XMLSelect>
       </xsl:when>
       <xsl:otherwise>
           <XMLSelect><xsl:attribute name="search">*[<xsl:value-of select="$pageFilter"/>]</xsl:attribute></XMLSelect>
       </xsl:otherwise>
          
   </xsl:choose>

  </Options>
</GetMetadataObjects>

</xsl:template>

</xsl:stylesheet>

