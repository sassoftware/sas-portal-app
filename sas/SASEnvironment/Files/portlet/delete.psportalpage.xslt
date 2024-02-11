<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/delete.all.routines.xslt"/>

<!-- Scope is the type of removal to do 
     remove = just remove the page from my personal portal space
     delete = permanently delete the page
     if scope=delete then check whether portlets on the page should also be deleted
      DeletePortletsOnPage = true, delete the portlets (but only the writeable ones)
                             false do not delete the portlets
 -->
<xsl:variable name="newScope"><xsl:value-of select="Mod_Request/NewMetadata/Scope"/></xsl:variable>

<xsl:variable name="pageId"><xsl:value-of select="Mod_Request/NewMetadata/Id"/></xsl:variable>

<xsl:variable name="deletePortletsOnPage"><xsl:value-of select="Mod_Request/NewMetadata/DeletePortletsOnPage"/></xsl:variable>

<xsl:variable name="currentPageObject" select="/Mod_Request/Multiple_Requests/GetMetadataObjects[2]/Objects/PSPortalPage"/>

<xsl:variable name="pageName" select="$currentPageObject/@Name"/>

<!-- Define the lookup table of writeable trees -->

<xsl:key name="treeKey" match="Tree" use="@Id"/>
<!-- it doesnt say this anywhere in the xsl key doc, but the objects to use for the lookup table
     must be under a shared root object.  Thus, here we can only go to the AccessControlEntries
     level.  Fortunately, the only trees listed under here are the ones we want in our lookup table
  -->
<xsl:variable name="treeLookup" select="/Mod_Request/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/AccessControlEntries"/>

<!-- Main Entry Point -->

<xsl:template match="/">

    <xsl:choose>
      <xsl:when test="$newScope='remove'">

       <!-- A remove is actually an updatemetadata request -->

       <xsl:comment>Include the phrase DeleteMetadata so the xsl checking thinks it worked</xsl:comment>

       <UpdateMetadata>

         <Metadata>

          <!--- Just remove it from the desktop pages member list -->

          <xsl:variable name="pagesGroupId" select="/Mod_Request/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/AccessControlEntries/AccessControlEntry/Objects/Tree/Members/Group[@Name='DESKTOP_PORTALPAGES_GROUP']/@Id"/>

          <Group><xsl:attribute name="Id"><xsl:value-of select="$pagesGroupId"/></xsl:attribute>
             <Members Function="Remove">
                 <PSPortalPage><xsl:attribute name="Id"><xsl:value-of select="$pageId"/></xsl:attribute>
                 </PSPortalPage>
             </Members>
           </Group>

         </Metadata>

         <NS>SAS</NS>
         <Flags>268435456</Flags>
         <Options/>

       </UpdateMetadata>

      </xsl:when>

      <xsl:when test="$newScope='delete'">

       <DeleteMetadata>

         <Metadata>

         <xsl:apply-templates select="$currentPageObject"/>

         </Metadata>

         <NS>SAS</NS>
         <Flags>268435456</Flags>
         <Options/>

       </DeleteMetadata>
       </xsl:when>

    <xsl:otherwise>
       <xsl:comment>Invalid value for scope parameter, <xsl:value-of select="$newScope"/></xsl:comment>
       </xsl:otherwise>
    </xsl:choose>

</xsl:template>

<xsl:template match="PSPortalPage">

               <!-- Permanently Delete the Page -->

               <xsl:apply-templates select="Extensions/*"/>
               <xsl:apply-templates select="Keywords/*"/>

               <!-- Delete the portlets on the page? -->

               <xsl:if test="$deletePortletsOnPage='true'">

                  <!-- Calculate the list of portlets that are writeable and execute the delete
                       template specific to that type of object
                  -->
     
                  <xsl:for-each select="LayoutComponents/*/Portlets/*">

                       <!-- Only want to include in the list the portlets that we have write access to.  Thus, we have to look up
                            the parent tree in the list of writeable trees to determine applicability
                       -->

                       <xsl:variable name="portletPermissionsTree" select="Trees/Tree"/>
                       <xsl:variable name="portletPermissionsTreeId" select="$portletPermissionsTree/@Id"/>

                       <xsl:variable name="portletPermissionsTreeKey" select="key('treeKey',$portletPermissionsTreeId,$treeLookup)/@Name"/>

                       <xsl:variable name="portletIsWriteable">
                         <xsl:choose>
                           <xsl:when test="$portletPermissionsTreeKey">1</xsl:when>
                           <xsl:otherwise>0</xsl:otherwise>
                         </xsl:choose>
                       </xsl:variable>

                       <xsl:if test="$portletIsWriteable='1'">
                         <xsl:apply-templates select="."/>
                       </xsl:if>
                  </xsl:for-each>

                </xsl:if>

               <xsl:apply-templates select="LayoutComponents/*"/>

               <PSPortalPage>
                  <xsl:attribute name="Name"><xsl:value-of select="$pageName"/></xsl:attribute>
                  <xsl:attribute name="Id"><xsl:value-of select="$pageId"/></xsl:attribute>
               </PSPortalPage>

</xsl:template>

<xsl:template name="PSPortlet">

<xsl:message>ERROR: in generic psportlet delete template, portlet type=<xsl:value-of select="portletType"/></xsl:message>
</xsl:template>

</xsl:stylesheet>

