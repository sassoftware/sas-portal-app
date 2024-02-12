<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Main Entry Point -->

<xsl:template match="/">

<xsl:variable name="newName"><xsl:value-of select="Mod_Request/NewMetadata/Name"/></xsl:variable>
<xsl:variable name="newDesc"><xsl:value-of select="Mod_Request/NewMetadata/Desc"/></xsl:variable>
<xsl:variable name="newPageRank"><xsl:value-of select="Mod_Request/NewMetadata/PageRank"/></xsl:variable>
<xsl:variable name="passedScope"><xsl:value-of select="Mod_Request/NewMetadata/Scope"/></xsl:variable>
<xsl:variable name="newScope">
  <xsl:choose>
    <xsl:when test='$passedScope=0'>Available</xsl:when>
    <xsl:when test='$passedScope=1'>Default</xsl:when>
    <xsl:when test='$passedScope=2'>Persistent</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="defaultLayoutType">Column</xsl:variable>

<xsl:variable name="parentTreeId"><xsl:value-of select="Mod_Request/NewMetadata/ParentTreeId"/></xsl:variable>

<xsl:variable name="repositoryId"><xsl:value-of select="Mod_Request/NewMetadata/Metareposid"/></xsl:variable>

<xsl:variable name="newObjectId"><xsl:value-of select="substring-after($repositoryId,'.')"/>.$newObject</xsl:variable>

<!--  We need to get a few pieces of information from the retrieved metadata 
      1.  Is the ParentTree we are passed a user or group permissions tree
      2.  If a group tree, figure out based on the new metadata passed for scope (Available, Default, Persistent)
          what tree the content should be created in.
      3.  Regardless of what tree is passed in, we need to get the users tree and the pages and history groups
          within it.  If we are passed a user group as the parentTree, just use it.  Otherwise, find it.
-->
  <xsl:variable name="userTreeId" select="Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries/AccessControlEntry/Objects/Tree[Members/Group[@Name='DESKTOP_PORTALPAGES_GROUP']]/@Id"/>
  <xsl:variable name="userTreeName" select="/Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries//Tree[@Id=$userTreeId]/@Name"/>

<xsl:variable name="userDesktopPortalPagesGroupId" select="Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries/AccessControlEntry/Objects/Tree/Members/Group[@Name='DESKTOP_PORTALPAGES_GROUP']/@Id"/>
<xsl:variable name="userDesktopPortalPagesGroupName" select="Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries/AccessControlEntry/Objects/Tree/Members/Group[@Name='DESKTOP_PORTALPAGES_GROUP']/@Name"/>
<xsl:variable name="userDesktopPortalHistoryGroupId" select="Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries/AccessControlEntry/Objects/Tree/Members/Group[@Name='DESKTOP_PAGEHISTORY_GROUP']/@Id"/>
<xsl:variable name="userDesktopPortalHistoryGroupName" select="Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries/AccessControlEntry/Objects/Tree/Members/Group[@Name='DESKTOP_PAGEHISTORY_GROUP']/@Name"/>

<!--  Figure out what tree the page should be placed in
      Placing the Portal page into the right tree and groups can be a little tricky, here is what should happen
         - For a user specific page:  Tree=User's permission Tree 
                                      Pages Group=User's pages group 
                                    History Group=User's history group
         - For a group shared page:   Tree=The tree under the Group Permissions tree that corresponds to the sharing type
                                           Available = root Group Permissions tree
                                           Default   = Tree named Default which is a nested subtree of the root Group Permissions Tree
                                           Persistent  = Tree named Sticky which is a nested subtree of the root Group Permissions Tree
                                     Pages Group=Group Admin's User's pages group
                                   History Group=Group Admin's User's history group
    -->

<xsl:variable name="pageTreeId">
<xsl:choose>
  <xsl:when test="$userTreeId=$parentTreeId">
    <xsl:value-of select="$userTreeId"/> 
  </xsl:when>
  <xsl:otherwise>
    <xsl:choose>
      <xsl:when test="$newScope='Persistent'">
        <xsl:value-of select="/Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries//Tree[@Id=$parentTreeId]/SubTrees//Tree[@Name='Sticky']/@Id"/>
      </xsl:when>
      <xsl:when test="$newScope='Default'">
        <xsl:value-of select="/Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries//Tree[@Id=$parentTreeId]/SubTrees//Tree[@Name='Default']/@Id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$parentTreeId"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:variable name="pageTreeName" select="/Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries//Tree[@Id=$pageTreeId]/@Name"/>

 <!-- Check for the required information and if it isn't set, then fail the generation -->

 <xsl:choose>

   <xsl:when test="not($userTreeId) or not($newName) or not($pageTreeId) or not($userDesktopPortalPagesGroupId) or not($userDesktopPortalHistoryGroupId)">

         <xsl:text>&#10;</xsl:text><message>ERROR: Generation failed, some required information not found: userTreeId=<xsl:value-of select="$userTreeId"/>, newName=<xsl:value-of select="$newName"/>, pageTreeId=<xsl:value-of select="$pageTreeId"/>, userDesktopPortalPagesGroupId=<xsl:value-of select="$userDesktopPortalPagesGroupId"/>, userDesktopPortalHistoryGroupId=<xsl:value-of select="$userDesktopPortalHistoryGroupId"/> </message><xsl:text>&#10;</xsl:text>
   </xsl:when>

   <xsl:otherwise>

    <!-- NOTE: We use UpdateMetadata here so that we can both create new objects (those with and Id starting with $)
         and update existing objects.
    -->

    <!-- Placing the Portal page into the right tree and groups can be a little tricky, here is what should happen
         - For a user specific page:  Tree=User's permission Tree, Pages Group=User's pages group, History Group=User's history group
         - For a group shared page:  Tree=The tree under the Group Permissions tree that corresponds to the sharing type, Pages Group=Group Admin's User's pages group, History Group=Group Admin's User's history group
    -->
    <UpdateMetadata>

      <Metadata>
         <!-- Create a history group for this page and add it to the user DESKTOP_PAGEHISTORY_GROUP -->
         <xsl:variable name="newHistoryGroupId"><xsl:value-of select="substring-after($repositoryId,'.')"/>.$newHistoryGroupObject</xsl:variable>

         <Group>
           <xsl:attribute name="Name"><xsl:value-of select="$newName"/></xsl:attribute>
           <xsl:attribute name="Id"><xsl:value-of select="$newHistoryGroupId"/></xsl:attribute>
           <Groups>
              <Group>
                <xsl:attribute name="ObjRef"><xsl:value-of select="$userDesktopPortalHistoryGroupId"/></xsl:attribute>
                <xsl:attribute name="Name"><xsl:value-of select="$userDesktopPortalHistoryGroupName"/></xsl:attribute>
              </Group>
           </Groups>

           <!-- Add the new history group to the user's Home Tree -->

           <Trees>
              <Tree>
                 <xsl:attribute name="ObjRef"><xsl:value-of select="$userTreeId"/></xsl:attribute>
                 <xsl:attribute name="Name"><xsl:value-of select="$userTreeName"/></xsl:attribute>
              </Tree>
           </Trees>
         </Group>

         <PSPortalPage>
           <xsl:attribute name="Id"><xsl:value-of select="$newObjectId"/></xsl:attribute>
          
           <xsl:attribute name="Name"><xsl:value-of select="$newName"/></xsl:attribute>

           <xsl:if test="$newDesc">
              <xsl:attribute name="Desc"><xsl:value-of select="$newDesc"/></xsl:attribute>
              </xsl:if>

           <!-- Some default information -->
           <xsl:attribute name="NumberOfColumns">1</xsl:attribute>
           <xsl:attribute name="NumberOfRows">0</xsl:attribute>
           <xsl:attribute name="Type"><xsl:value-of select="defaultLayoutType"/></xsl:attribute>

           <Extensions>
                <xsl:variable name="newLayoutTypeId"><xsl:value-of select="substring-after($repositoryId,'.')"/>.$newLayoutTypeId</xsl:variable>
               <Extension Name="LayoutType">
                     <xsl:attribute name="Id"><xsl:value-of select="$newLayoutTypeId"/></xsl:attribute>
               </Extension>
               <xsl:if test="$newPageRank">
                  
                  <xsl:variable name="newPageRankId"><xsl:value-of select="substring-after($repositoryId,'.')"/>.$newPageRankObject</xsl:variable>
                  <Extension Name="PageRank">
                     <xsl:attribute name="Id"><xsl:value-of select="$newPageRankId"/></xsl:attribute>
                     <xsl:attribute name="Value"><xsl:value-of select="$newPageRank"/></xsl:attribute>
                  </Extension>   
                  </xsl:if>
               <!-- Add the appropriate extension for shared pages -->
               <xsl:if test="not($pageTreeId=$userTreeId)">
                   <xsl:variable name="newPageScopeId"><xsl:value-of select="substring-after($repositoryId,'.')"/>.$newScopeObject</xsl:variable>
                   <xsl:choose>
                      <xsl:when test="$newScope='Available'">
                          <Extension Name="SharedPageAvailable"> 
                            <xsl:attribute name="Id"><xsl:value-of select="$newPageScopeId"/></xsl:attribute>
                          </Extension>
                      </xsl:when>
                      <xsl:when test="$newScope='Default'">
                          <Extension Name="SharedPageDefault"> 
                            <xsl:attribute name="Id"><xsl:value-of select="$newPageScopeId"/></xsl:attribute>
                          </Extension>
                      </xsl:when>
                      <xsl:when test="$newScope='Persistent'">
                          <Extension Name="SharedPageSticky"> 
                            <xsl:attribute name="Id"><xsl:value-of select="$newPageScopeId"/></xsl:attribute>
                          </Extension>
                      </xsl:when>
                   </xsl:choose>
               </xsl:if>
           </Extensions>

           <Trees>
              <Tree>
                <!-- put the page into the correct tree
                  -->
                <xsl:attribute name="ObjRef"><xsl:value-of select="$pageTreeId"/></xsl:attribute>
                <xsl:attribute name="Name"><xsl:value-of select="$pageTreeName"/></xsl:attribute>
              </Tree>
           </Trees>

           <Groups>
               <!-- Add it to the list of portal pages for this user DESKTOP_PORTALPAGES_GROUP -->
               <Group>
                 <xsl:attribute name="ObjRef"><xsl:value-of select="$userDesktopPortalPagesGroupId"/></xsl:attribute>
                 <xsl:attribute name="Name"><xsl:value-of select="$userDesktopPortalPagesGroupName"/></xsl:attribute>
               </Group>
               <!-- add it to the new group created above under the user DESKTOP_PAGEHISTORY_GROUP -->

               <Group>
                 <xsl:attribute name="Name"><xsl:value-of select="$newName"/></xsl:attribute>
                 <xsl:attribute name="ObjRef"><xsl:value-of select="$newHistoryGroupId"/></xsl:attribute>
               </Group>
                 
           </Groups>

           <!-- Create an initial layout component -->

            <xsl:variable name="newLayoutComponentId"><xsl:value-of select="substring-after($repositoryId,'.')"/>.$newLayoutComponentObject</xsl:variable>
           <LayoutComponents>
              <PSColumnLayoutComponent Name="COLUMNLAYOUTCOMPONENT" NumberOfPortlets="0" ColumnWidth="100">
                 <xsl:attribute name="Id"><xsl:value-of select="$newLayoutComponentId"/></xsl:attribute>

              </PSColumnLayoutComponent>
           </LayoutComponents>
         </PSPortalPage>

      </Metadata>

      <NS>SAS</NS>
      <Flags>268435456</Flags>
      <Options/>

    </UpdateMetadata>

   </xsl:otherwise>
 </xsl:choose>

</xsl:template>

</xsl:stylesheet>

