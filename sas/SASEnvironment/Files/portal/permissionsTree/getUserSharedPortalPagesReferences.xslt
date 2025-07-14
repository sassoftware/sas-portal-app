<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- This request will get the list of new shared pages given a timeframe and
     the user's existing portal pages so that this output can be taken and
     the shared pages added to the user's portal 

     NOTE: (this note left here for historical reasons, although it is now incorrect, see the next NOTE for the current stance)
    
     There shouldn't be a case where a page matches the new datetime criteria and
     exists in the user's list of portal pages.  However, going to be extra careful and
     get the existing list so they can be compared on the add just to make sure.

     NOTE: (Current!)

     There is a situation where the page matches the new datetime criteria AND already exists in the 
     user's list of portal pages.  This can happen if a page is created, given an initial group to share with it and 
     a "scope" (available, default, persistent) and then the scope is changed by the content admin.   

     See chart in createUserSharedPortalPages.xslt for the state transitions.

-->

<xsl:param name="startDT">.</xsl:param>
<xsl:param name="endDT">.</xsl:param>
<xsl:param name="retrieveFullHistory">0</xsl:param>
<xsl:param name="treeName"/>
<xsl:param name="reposName"/>

<xsl:template match="/">

<!-- Expect the input xml to be the response xml from getRepositories method -->

<xsl:variable name="reposId"><xsl:value-of select="GetRepositories/Repositories/Repository[@Name=$reposName]/@Id"/></xsl:variable>

<Multiple_Requests>
<GetMetadataObjects>
 <ReposId><xsl:value-of select="$reposId"/></ReposId>  
 <Type>Extension</Type>
 <ns>SAS</ns>
     <!-- 256 = GetMetadata
          128 = XMLSelect
            4 =  Template
     -->
 <Flags>388</Flags>
 <Options>

   <!-- We only want to retrieve pages that were created in the passed time interval and those that have one of the "SharedPage" extensions.  

        NOTE: We need to be careful with this query.  If an admin changes sharing after the initial page was created, the page object itself
        may not be updated, only the extension object would be created/updated.  Thus, we have to find the new shared extensions and then get
        the pages from that query (ie. don't assume that the pages and extensions were created at the same time).
   -->
     
   <xsl:variable name="start"><xsl:value-of select="normalize-space($startDT)"/></xsl:variable>
   <xsl:variable name="end"><xsl:value-of select="normalize-space($endDT)"/></xsl:variable>

   <xsl:variable name="timeFilter">
   <xsl:choose>
	   <xsl:when test="not($start='.') and not($end='.')">@MetadataCreated GT '<xsl:value-of select="$start"/>' and @MetadataCreated LE '<xsl:value-of select="$end"/>'</xsl:when>
	   <xsl:when test="$start='.' and not($end='.')">@MetadataCreated LE '<xsl:value-of select="$end"/>'</xsl:when>
	   <xsl:when test="not($start='.') and $end='.'">@MetadataCreated GT '<xsl:value-of select="$start"/>'</xsl:when>
	   <xsl:otherwise></xsl:otherwise>
   </xsl:choose>
   </xsl:variable>

   <!-- Shared Available Pages are not automatically linked to the user's portal, so don't include those in the hunt for new pages!
     -->

   <xsl:variable name="pageFilter">@Name='SharedPageSticky' or @Name='SharedPageDefault'</xsl:variable>

   <xsl:choose>
     <xsl:when test="not($timeFilter='')">
       <XMLSelect><xsl:attribute name="search">*[(<xsl:value-of select="$timeFilter"/>) and (<xsl:value-of select="$pageFilter"/>)]</xsl:attribute></XMLSelect>
     </xsl:when>
     <xsl:otherwise>
       <XMLSelect><xsl:attribute name="search">*[(<xsl:value-of select="$pageFilter"/>)]</xsl:attribute></XMLSelect>
     </xsl:otherwise>
   </xsl:choose>

   <Templates>
       <Extension Id="" Name="" Value="" MetadataCreated="">
         <OwningObject search="PSPortalPage"/>
       </Extension>
       <PSPortalPage Id="" Name="" MetadataCreated=""/>
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

<xsl:if test="$retrieveFullHistory=1">
<xsl:message>Retrieving full history references</xsl:message>
        <!-- Get the user's history pages 

             Note: When doing a "fast check" only the root history group is needed.
                   However, when the "full check" is run, the entire history is needed.

                   Note that "fast check" can be satisfied by the previous queries and doesn't
                   need this additional one.  Thus, we only include this query if needed to minimize
                   processing time.
        -->

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

                 <Members search="Group[@Name='DESKTOP_PAGEHISTORY_GROUP']"/>

               </Tree>

               <Group  Id="" Name="">
                  <Members/>
               </Group> 
               <PSPortalPage Id="" Name="" MetadataCreated=""/>
           </Templates>
          </Options>
        </GetMetadataObjects>

</xsl:if>

</Multiple_Requests>

</xsl:template>

</xsl:stylesheet>

