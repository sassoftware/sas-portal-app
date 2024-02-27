<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Re-usable scripts -->
<!-- Set up the metadataContext variable -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.metadatacontext.xslt"/>
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/delete.all.routines.xslt"/>

<!-- Scope is the type of removal to do 
     remove = just remove the page from my personal portal space
     delete = permanently delete the page
     if scope=delete then check whether portlets on the page should also be deleted
      DeletePortletsOnPage = true, delete the portlets (but only the writeable ones)
                             false do not delete the portlets (NOTE: if no value is passed, false is the default!) 

     NOTE: This is a serious "gotcha" here.  Once a page is shared, it is linked into multiple
     user's permissions tree.  At that point, all of these trees play a role on the permissions of the
     tree and restrict who can actually write to/and thus delete, the actual page.  The net result is
     the only users that will end up having enough permissions is the sas administrators.

     The existing IDP would switch to a sas administrator to do this delete in one step, but we do 
     not escalate privileges within this app. Thus, what we will do here if we recognize this situation
     is to remove any references to this page from the current requesting user's tree, and we will mark 
     the tree "deleted".  A sas admin process will need to be run to clean these pages as an asynchronous process. 
 -->

<xsl:variable name="newScope"><xsl:value-of select="Mod_Request/NewMetadata/Scope"/></xsl:variable>

<xsl:variable name="pageId"><xsl:value-of select="Mod_Request/NewMetadata/Id"/></xsl:variable>

<xsl:variable name="deletePortletsOnPage"><xsl:value-of select="Mod_Request/NewMetadata/DeletePortletsOnPage"/></xsl:variable>


<xsl:variable name="reposIdPrefix" select="substring-before($pageId,'.')"/>

<!-- Define the lookup table of writeable trees -->

<xsl:key name="treeKey" match="Tree" use="@Id"/>
<!-- it doesnt say this anywhere in the xsl key doc, but the objects to use for the lookup table
     must be under a shared root object.  Thus, here we can only go to the AccessControlEntries
     level.  Fortunately, the only trees listed under here are the ones we want in our lookup table
  -->
<xsl:variable name="treeLookup" select="$metadataContext/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/AccessControlEntries"/>

<xsl:variable name="currentPageObject" select="$metadataContext/Multiple_Requests/GetMetadataObjects[2]/Objects/PSPortalPage"/>

<xsl:variable name="pageName" select="$currentPageObject/@Name"/>
<!-- Main Entry Point -->

<xsl:template match="/">

    <xsl:choose>
    <xsl:when test="$newScope='delete' or $newScope='remove'">

       <Multiple_Requests>
<xsl:comment>Removing references to this page from current user tree</xsl:comment>
           <!-- A remove is actually an updatemetadata request -->

           <xsl:comment>Include the phrase DeleteMetadata so the xsl checking thinks it worked</xsl:comment>

            <!-- Remove it from every group we can see -->

            <xsl:variable name="pagesGroupCount" select="count($metadataContext/Multiple_Requests/GetMetadataObjects[3]/Objects/PSPortalPage/Groups/Group)"/>

           <xsl:if test="$pagesGroupCount &gt; 0">

               <UpdateMetadata>

                 <Metadata>

                  <!--- Remove it from all the groups -->

                  <xsl:for-each select="$metadataContext/Multiple_Requests/GetMetadataObjects[3]/Objects/PSPortalPage/Groups/Group">

                      <xsl:variable name="pagesGroupId" select="@Id"/>

                      <Group><xsl:attribute name="Id"><xsl:value-of select="$pagesGroupId"/></xsl:attribute>
                         <Members Function="Remove">
                             <PSPortalPage><xsl:attribute name="Id"><xsl:value-of select="$pageId"/></xsl:attribute>
                             </PSPortalPage>
                         </Members>
                       </Group>
                  </xsl:for-each>

                 </Metadata>

                 <NS>SAS</NS>
                 <Flags>268435456</Flags>
                 <Options/>

               </UpdateMetadata>

           </xsl:if>

          <xsl:if test="$newScope='delete'">

             <xsl:apply-templates select="$currentPageObject"/>

          </xsl:if>
        </Multiple_Requests>
        </xsl:when>

    <xsl:otherwise>
       <message>ERROR:Invalid value for scope parameter, <xsl:value-of select="$newScope"/></message>
       </xsl:otherwise>
    </xsl:choose>

</xsl:template>

<xsl:template match="PSPortalPage">

    <!-- Permanently Delete the Page -->

<xsl:variable name="pageId" select="@Id"/>

    <!-- If the page is already marked for deletion, then we have already processed this step, so just skip it now -->

    <xsl:if test="not(Extensions/Extension[@Name='MarkedForDeletion'])">

<xsl:comment>Page is to be deleted, delete it's contents</xsl:comment>

        <DeleteMetadata>

          <Metadata>

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

            <!-- Delete any history groups associated with this Page -->

            <xsl:for-each select="$metadataContext/Multiple_Requests/GetMetadataObjects[3]/Objects/PSPortalPage/Groups/Group[Groups//Group[@Name='DESKTOP_PAGEHISTORY_GROUP']]">
              <xsl:apply-templates select="."/>
            </xsl:for-each>

          </Metadata>

          <NS>SAS</NS>
          <Flags>268435456</Flags>
          <Options/>

        </DeleteMetadata>

    </xsl:if>

    <!-- If the page is a shared page, ie. could be linked into multiple trees, we won't have permissions to delete it, so 
         go ahead and just mark it for deletion.  Otherwise, actually delete it.

         There is a potential that even a shared page could be deleted if no user references it.  That seems like a
         rare situation, so you would have to run the admin page cleanup job anyway, so don't worry about handling this
         exception case.
     -->

    <xsl:choose>
      <xsl:when test="count(Extensions/Extension[@Name='SharedPageAvailable' or @Name='SharedPageDefault' or @Name='SharedPageSticky']) &gt; 0">
<xsl:comment>Page is a shared page, see if we need to mark it for deletion</xsl:comment>

          <!-- If it's already marked for deletion, nothing else to do, otherwise mark it -->

          <xsl:if test="not(Extensions/Extension[@Name='MarkedForDeletion'])">
<xsl:comment>Page needs to be marked for deletion</xsl:comment>

           <xsl:comment>Include the phrase DeleteMetadata so the xsl checking thinks it worked</xsl:comment>

           <UpdateMetadata>

             <Metadata>
                <xsl:variable name="deleteExtensionId"><xsl:value-of select="$reposIdPrefix"/>.$deleteExtension</xsl:variable>
                <Extension name="MarkedForDeletion" value="true">
                   <xsl:attribute name="Id"><xsl:value-of select="$deleteExtensionId"/></xsl:attribute>
                   <OwningObject>
                     <PSPortalPage>
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$pageId"/></xsl:attribute>
                     </PSPortalPage>
                   </OwningObject>
                </Extension>
             </Metadata>

             <NS>SAS</NS>
             <Flags>268435456</Flags>
             <Options/>

           </UpdateMetadata>

          </xsl:if>

      </xsl:when>
      <xsl:otherwise>

<xsl:comment>Page should be deleted</xsl:comment>
        <DeleteMetadata>

          <Metadata>

            <PSPortalPage>
               <xsl:attribute name="Name"><xsl:value-of select="$pageName"/></xsl:attribute>
               <xsl:attribute name="Id"><xsl:value-of select="$pageId"/></xsl:attribute>
            </PSPortalPage>

          </Metadata>

          <NS>SAS</NS>
          <Flags>268435456</Flags>
          <Options/>

        </DeleteMetadata>

      </xsl:otherwise>

    </xsl:choose>

</xsl:template>

<xsl:template name="PSPortlet">

<xsl:message>ERROR: in generic psportlet delete template, portlet type=<xsl:value-of select="portletType"/></xsl:message>
</xsl:template>

</xsl:stylesheet>

