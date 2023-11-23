<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- This request will get the list of new shared pages given a timeframe and
     the user's existing portal pages so that this output can be taken and
     the shared pages added to the user's portal 

     NOTE: There shouldn't be a case where a page matches the new datetime criteria and
     exists in the user's list of portal pages.  However, going to be extra careful and
     get the existing list so they can be compared on the add just to make sure.

-->

<xsl:param name="startDT">.</xsl:param>
<xsl:param name="endDT">.</xsl:param>

<xsl:param name="treeName"/>
<xsl:param name="reposName"/>

<xsl:template match="/">

<!-- Expect the input xml to be the response xml from getRepositories method -->

<xsl:variable name="reposId"><xsl:value-of select="GetRepositories/Repositories/Repository[@Name=$reposName]/@Id"/></xsl:variable>

<Multiple_Requests>
<GetMetadataObjects>
 <ReposId><xsl:value-of select="$reposId"/></ReposId>  
 <Type>PSPortalPage</Type>
 <ns>SAS</ns>
     <!-- 256 = GetMetadata
          128 = XMLSelect
            4 =  Template
     -->
 <Flags>388</Flags>
 <Options>

   <!-- We only want to retrieve pages that were created in the passed time interval and those that have one of the "SharedPage" extensions -->
     
   <xsl:variable name="start"><xsl:value-of select="normalize-space($startDT)"/></xsl:variable>
   <xsl:variable name="end"><xsl:value-of select="normalize-space($endDT)"/></xsl:variable>

   <xsl:variable name="timeFilter">
   <xsl:choose>
	   <xsl:when test="not($start='.') and not($end='.')">[@MetadataCreated GT '<xsl:value-of select="$start"/>' and @MetadataCreated LE '<xsl:value-of select="$end"/>']</xsl:when>
	   <xsl:when test="$start='.' and not($end='.')">[@MetadataCreated LE '<xsl:value-of select="$end"/>']</xsl:when>
	   <xsl:when test="not($start='.') and $end='.'">[@MetadataCreated GT '<xsl:value-of select="$start"/>']</xsl:when>
	   <xsl:otherwise></xsl:otherwise>
   </xsl:choose>
   </xsl:variable>

   <xsl:variable name="pageFilter">[Extensions/Extension[@Name='SharedPageSticky' or @Name='SharedPageDefault' or @Name='SharedPageAvailable']</xsl:variable>

   <XMLSelect><xsl:attribute name="search">*<xsl:value-of select="$timeFilter"/><xsl:value-of select="$pageFilter"/></xsl:attribute></XMLSelect>


   <Templates>
       <PSPortalPage Id="" Name="" MetadataCreated="">
          <Extensions search="Extension[@Name='SharedPageSticky' or @Name='SharedPageDefault' or @Name='SharedPageAvailable']"/>
       </PSPortalPage>
       <Extension Id="" Name="" Value=""/>
   </Templates>
  </Options>
</GetMetadataObjects>

<!-- Get the user's list of existing pages -->

<GetMetadataObjects>
 <ReposId><xsl:value-of select="$reposId"/></ReposId>
 <Type>Tree</Type>
 <ns>SAS</ns>
     <!-- 256 = GetMetadata
          128 = XMLSelect
            4 =  Template
     -->
 <Flags>388</Flags>
 <Options>
   <XMLSelect>
       <xsl:attribute name="search">@Name='<xsl:value-of select="$treeName"/>'</xsl:attribute>

   </XMLSelect>

   <Templates>
       <Tree Id="" Name="">

         <Members search="Group[@Name='DESKTOP_PORTALPAGES_GROUP' or @Name='DESKTOP_PAGEHISTORY_GROUP']"/>

       </Tree>

       <Group  Id="" Name="">
          <Members search="PSPortalPage"/>
       </Group> 
       <PSPortalPage Id="" Name="" MetadataCreated=""/>
   </Templates>
  </Options>
</GetMetadataObjects>

</Multiple_Requests>

</xsl:template>

</xsl:stylesheet>

