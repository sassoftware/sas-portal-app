<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- input is response from running getUserSharedPortalPagesReferences.xslt -->

<!-- There is some nuance here that has to be handled.
 
     It is possible that a page was discovered to be added that may already exist for the user, here
     are the possibilities.

     Previous Scope | New Scope | Result
     - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     available      | available | no change (would not have triggered a new page being discovered)
     available      | default   | page could exist, if so, leave it, if not add it
     available      | persistent| page could exist, if so, leave it, if not add it
     default        | available | page could exist, if so, leave it, if not don't add it
     default        | default   | no change (would not have triggered a new page being discovered)
     default        | persistent| page could exist, if so, leave it, if not, add it
     persistent     | available | page will exist
     persistent     | default   | page will exist
     persistent     | persistent| no change (would not have triggered a new page being discovered)

     While not processed by this code, there is also a possibility that a content admin stops sharing
     a page, thus leaving relationships within the users' portal to that page, but the permissions
     on the page will stop the page from being retieved.

     NOTE: The get request does not include Available pages since they won't automatically be added 
           to the user's portal content.  Thus, the rows above where New Scope = available do not
           need to be handled here.

     Syncing Group Content
     - - - - - - - - - - - - - - - - - - - - -

     There are 2 ways that a user can get access to shared pages:

     1. A group that they are already in has new pages added to it
     2. A user is added to a group (that has pages)

     In the case #2, there is no page updates so we have to get all of the pages the user can see
     and see which ones and add them to user area (if they don't exist). This process is run on a repeating
     schedule.  There is a special case here that has to be handled.   If the shared page is of type "default", meaning
     it is automatically added to the user's portal area when the page is created for the group, it can be "removed"
     from the user's portal area by the user.  The next time the "full" sync process runs, that page will show up again as
     needing to be added to the user's portal area.  In this case, we should NOT add it back to the user's portal area.

     It is difficult to determine this situation.  The only indication we have that this might have happened is that there
     is a history group with the same name as the page, but has no page members.  Note that since page names are not unique,
     there could be a history group that existed for another page that had the same name.  However, we don't have any other way
     of determining this situation so we will go with this check.

     To give us some options if this situation exists, this stylesheet will take a parameter that indicates how to deal with 
     default pages that don't exist in that user's profile area.

-->

<xsl:param name="forceDefaultPageAdd">1</xsl:param>

<!-- - - - - - - - - - - - - - - - - - - -
      Main Entry Point
- - - - - - - - - - - - - - - - - - - - - - -->

<xsl:template match="/">
    <UpdateMetadata>

        <Metadata>

            <xsl:apply-templates select="/Multiple_Requests/GetMetadataObjects[1]/Objects/Extension/OwningObject/PSPortalPage">
            </xsl:apply-templates>

        </Metadata>
        <NS>SAS</NS>
        <!-- OMI_TRUSTED_CLIENT Flag -->
        <Flags>268435456</Flags>
        <Options/>

    </UpdateMetadata>

</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - -

    Found a Portal Page to add

- - - - - - - - - - - - - - - - - - - - - - -->
<xsl:template match="PSPortalPage">

    <xsl:variable name="parentTree" select="/Multiple_Requests/GetMetadataObjects[2]/Objects/Tree"/>
    <xsl:variable name="parentTreeId" select="$parentTree/@Id"/>
    <xsl:variable name="parentTreeName" select="$parentTree/@Name"/>

    
    <xsl:variable name="pagesGroup" select="$parentTree/Members/Group[@Name='DESKTOP_PORTALPAGES_GROUP']"/>
    <xsl:variable name="pagesGroupId" select="$pagesGroup/@Id"/>
    <xsl:variable name="pagesGroupName" select="$pagesGroup/@Name"/>
    <xsl:variable name="historyGroup" select="/Multiple_Requests/GetMetadataObjects[2]/Objects/Tree/Members/Group[@Name='DESKTOP_PAGEHISTORY_GROUP']"/>
    <xsl:variable name="historyGroupId" select="$historyGroup/@Id"/>
    <xsl:variable name="historyGroupName" select="$historyGroup/@Name"/>

    <xsl:if test="not($parentTreeId)">
       <message>ERROR: Parent Tree Id not found in input xml file.</message>
    </xsl:if>

    <xsl:if test="not($pagesGroupId)">
       <message>ERROR: Portal Page group not found in permission tree, is tree initialized?.</message>
    </xsl:if>
    <xsl:if test="not($historyGroupId)">
       <message>ERROR: Portal Page History group not found in permission tree, is tree initialized?.</message>
    </xsl:if>

    <xsl:variable name="newPageId"><xsl:value-of select="@Id"/></xsl:variable>
    <xsl:variable name="pageName"><xsl:value-of select="@Name"/></xsl:variable>

      <!-- General Note: Including the Name attribute on objects referenced through ObjRef doesn't change the processing, but it makes it much easier
                          to validate that the correct associations are being made, thus including Name attributes on object references
       -->
    
    <xsl:variable name="existingPage" select="$pagesGroup/Members/PSPortalPage[@Id=$newPageId]/@Id"/>

    <!--  We should never add a new reference to a page that the user still has in their page list.
          We may be passed a page to add that we may/may not have added and deleted before.
          If it looks like we have added and deleted it before (ie. the group name matches and the history group doesn't have any members), then don't add it.
          The forceDefaultPageAdd parameter can be set to always force a page to be added, even if we would have met the criteria for the add then delete scenario.        

          NOTE: The 3rd GetMetadataObjects query may not exist in the passed xml if we are doing a "fast check".  However the reference in the 2nd query results does
                not include the members of the history group (which is what is needed here).  Make sure to use the correct history group reference.  Also note that the
                3rd query should only be returning the History Group Member of our Permissions tree, so no need to check the name of the group during this processing.
    -->
    
    <xsl:variable name="existingHistoryGroupId" select="/Multiple_Requests/GetMetadataObjects[3]/Objects/Tree/Members/Group/Members/Group[@Name=$pageName and not(Members/*)]/@Id"/>

    <xsl:if test="not($existingPage) and (not($existingHistoryGroupId) or $forceDefaultPageAdd=1)">

        <!-- Add the shared page to the list of portal pages for this user -->

        <Group><xsl:attribute name="Id"><xsl:value-of select="$pagesGroupId"/></xsl:attribute>
               <xsl:attribute name="Name"><xsl:value-of select="$pagesGroupName"/></xsl:attribute>

           <Members Function="Append">
             <PSPortalPage><xsl:attribute name="ObjRef"><xsl:value-of select="$newPageId"/></xsl:attribute>
                           <xsl:attribute name="Name"><xsl:value-of select="$pageName"/></xsl:attribute>

             </PSPortalPage>
           </Members>

        </Group>

        <xsl:comment>Create the Page History group and link in the shared page</xsl:comment><xsl:text>&#xa;</xsl:text>

        <!-- UpdateMetadata can create objects if the passed Id is in the form <reposid>.$<uniqueId>, so create that format of Id now for the new history group
             There is no significance to using part of the page Id as the group Id, other than in this request, we know it will be unique.
          -->

        <xsl:variable name="reposPrefix" select="substring-before($newPageId,'.')"/>
        <xsl:variable name="pageSuffix" select="substring-after($newPageId,'.')"/>

        <!-- It's possible that this page was linked before and then removed from the user's tree.  In this case, the
             history group will already exist.  The only way to know if this history group was related to this page is
             to see if the names are the same.  That seems error prone and there sequences where you are going to end 
             up with multiple history groups for the same page anyway, so we aren't going to try to re-use an existing
             group.  When finding the history group for this page, we only look to see which one has this page as a 
             member, so the multiples shouldn't impact that.
        -->
        <Group><xsl:attribute name="Id"><xsl:value-of select="$reposPrefix"/>.$<xsl:value-of select="$pageSuffix"/></xsl:attribute><xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute><xsl:attribute name="Desc"><xsl:value-of select="@Desc"/></xsl:attribute>
            <Groups>
               <Group><xsl:attribute name="ObjRef"><xsl:value-of select="$historyGroupId"/></xsl:attribute><xsl:attribute name="Name"><xsl:value-of select="$historyGroupName"/></xsl:attribute></Group>
            </Groups>

            <Trees>
              <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="$parentTreeId"/></xsl:attribute><xsl:attribute name="Name"><xsl:value-of select="$parentTreeName"/></xsl:attribute>
              </Tree>
            </Trees>

            <Members>
              <PSPortalPage><xsl:attribute name="ObjRef"><xsl:value-of select="$newPageId"/></xsl:attribute><xsl:attribute name="Name">
                            <xsl:value-of select="$pageName"/></xsl:attribute>
              </PSPortalPage>
            </Members>

        </Group>

    </xsl:if>

</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - -
      Create the Layout details for the Passed Portal Page
- - - - - - - - - - - - - - - - - - - - - - -->

<xsl:template name="createPageLayout">

    <xsl:param name="parentTree"/>
    <xsl:param name="newPageId"/>

    <xsl:variable name="parentTreeId" select="$parentTree/@Id"/>
    <xsl:variable name="parentTreeName" select="$parentTree/@Name"/>

<xsl:comment>NOTE: parentTreeId=<xsl:value-of select="$parentTreeId"/></xsl:comment>
<xsl:comment>NOTE: parentTreeName=<xsl:value-of select="$parentTreeName"/></xsl:comment>

    <xsl:variable name="numberOfColumns" select="count(SubTrees/Tree[@TreeType='PortalPageColumnTemplate'])"/>

    <xsl:for-each select="SubTrees/Tree[@TreeType='PortalPageColumnTemplate']">

       <xsl:variable name="newLayoutId" select="generate-id(.)"/>

       <xsl:variable name="columnWidth">

          <xsl:choose>
             <xsl:when test="$numberOfColumns=1">100</xsl:when>
             <xsl:when test="$numberOfColumns=2">50</xsl:when>
             <xsl:when test="$numberOfColumns=3">33</xsl:when>
             <xsl:otherwise>
                 <message>ERROR: Unhandled number of columns, <xsl:value-of select="$numberOfColumns"/>, specified.</message>
             </xsl:otherwise>

          </xsl:choose>

       </xsl:variable>

       <PSColumnLayoutComponent Name="COLUMNLAYOUTCOMPONENT">
           <xsl:attribute name="ColumnWidth"><xsl:value-of select="columWidth"/></xsl:attribute>
           <xsl:attribute name="NumberOfPortlets"><xsl:value-of select="count(Members/Group)"/></xsl:attribute>
             
         <Portlets>
             <xsl:for-each select="Members/Group">
                <xsl:call-template name="createColumnPortlets">

                    <xsl:with-param name="parentTree" select="$parentTree"/>
                    <!-- indicate to the create portlet templates that it has already been associated with a column layout -->
                    <xsl:with-param name="layoutId"/>

                </xsl:call-template>

             </xsl:for-each>

         </Portlets>

       </PSColumnLayoutComponent>
    </xsl:for-each>
 
</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - -
      Create the content for the passed portal page column
- - - - - - - - - - - - - - - - - - - - - - -->

<xsl:template name="createColumnPortlets">

    <xsl:param name="parentTree"/>
    <xsl:param name="layoutId"/>

    <xsl:variable name="portletName"><xsl:value-of select="substring-before(@Desc,',')"/></xsl:variable>
    <xsl:variable name="portletDesc"><xsl:value-of select="substring-after(@Desc,',')"/></xsl:variable>

    <xsl:for-each select="Members/Prototype">

         <xsl:call-template name="buildPortlet">

            <xsl:with-param name="parentTree" select="$parentTree"/>
            <xsl:with-param name="prototype" select="."/>
            <xsl:with-param name="layoutId" select="$layoutId"/>
            <xsl:with-param name="portletName" select="$portletName"/>
            <xsl:with-param name="portletDesc" select="$portletDesc"/>

         </xsl:call-template>

    </xsl:for-each>

</xsl:template>

<xsl:template name="buildPortlet">

    <xsl:param name="prototype"/>
    <xsl:param name="parentTree"/>
    <xsl:param name="layoutId"/>
    <xsl:param name="portletName"/>
    <xsl:param name="portletDesc"/>

    <xsl:variable name="parentTreeId" select="$parentTree/@Id"/>
    <xsl:variable name="parentTreeName" select="$parentTree/@Name"/>

<xsl:comment>NOTE: parentTreeId=<xsl:value-of select="$parentTreeId"/></xsl:comment>
<xsl:comment>NOTE: parentTreeName=<xsl:value-of select="$parentTreeName"/></xsl:comment>
    <!-- The portlet information is based on the information in the prototype.
         This is the best I can tell about how to populate the different fields.
      -->

    <xsl:variable name="prototypeId"><xsl:value-of select="$prototype/@Id"/></xsl:variable>
    <xsl:variable name="prototypeName"><xsl:value-of select="$prototype/@Name"/></xsl:variable>

    <!-- The URI extension of the prototype has a syntax that looks like:
         /sas/portlets/<portlettype>/display

         pull the portlet type information out of the value.

      -->

    <xsl:variable name="portletType"><xsl:value-of select="substring-before(substring-after($prototype/Extensions/Extension[@Name='URI']/@Value,'/sas/portlets/'),'/')"/></xsl:variable>

    <!-- Build the common portlet information then call the template specific to that type of portlet -->

    <PSPortlet>
        <xsl:attribute name="Name"><xsl:value-of select="$portletName"/></xsl:attribute>
        <xsl:attribute name="Desc"><xsl:value-of select="$portletDesc"/></xsl:attribute>
        <xsl:attribute name="PortletType"><xsl:value-of select="$portletType"/></xsl:attribute>

      <Trees>
          <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="$parentTreeId"/></xsl:attribute>
                <xsl:attribute name="Name"><xsl:value-of select="$parentTreeName"/></xsl:attribute>
          </Tree>
      </Trees>
      <UsingPrototype>
         <Prototype><xsl:attribute name="ObjRef"><xsl:value-of select="$prototypeId"/></xsl:attribute>
                    <xsl:attribute name="Name"><xsl:value-of select="$prototypeName"/></xsl:attribute>
         </Prototype>
      </UsingPrototype>

      <!-- If it hasn't already been connected to a layout, do it now 
           A missing value for layoutId indicates it has already been connected -->

      <xsl:if test="$layoutId">

          <LayoutComponents> 
             <PSColumnLayoutComponent><xsl:attribute name="ObjRef"><xsl:value-of select="$layoutId"/></xsl:attribute>
             </PSColumnLayoutComponent>
          </LayoutComponents>

      </xsl:if>
       
      <xsl:choose>

        <xsl:when test="$portletType='Collection'">

            <xsl:call-template name="buildCollectionPortlet">

                 <xsl:with-param name="parentTree" select="$parentTree"/>
                 <xsl:with-param name="prototype" select="Members/Prototype[1]"/>

            </xsl:call-template>

        </xsl:when>

        <xsl:when test="$portletType='Bookmarks'">

            <xsl:call-template name="buildBookmarksPortlet">

                 <xsl:with-param name="parentTree" select="$parentTree"/>
                 <xsl:with-param name="prototype" select="Members/Prototype[1]"/>

            </xsl:call-template>

        </xsl:when>

        <xsl:otherwise>
               <message>ERROR:adding of $portletType portlet not currently supported.</message>

        </xsl:otherwise>

      </xsl:choose>

    </PSPortlet>

</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - -
      Collection portlet - add details
- - - - - - - - - - - - - - - - - - - - - - -->

<xsl:template name="buildCollectionPortlet">

    <xsl:param name="parentTree"/>
    <xsl:param name="prototypeNode"/>

    <xsl:variable name="parentTreeId" select="$parentTree/@Id"/>
    <xsl:variable name="parentTreeName" select="$parentTree/@Name"/>

<xsl:comment>NOTE: parentTreeId=<xsl:value-of select="$parentTreeId"/></xsl:comment>
<xsl:comment>NOTE: parentTreeName=<xsl:value-of select="$parentTreeName"/></xsl:comment>

    <PropertySets>
       <PropertySet Name="PORTLET_CONFIG_ROOT">
           <SetProperties>
              <Property Name="show-description" SQLType="12" UseValueOnly="0" DefaultValue="true"/>
              <Property Name="show-location" SQLType="12" UseValueOnly="0" DefaultValue="true"/>
              <Property Name="ascending-packageSortOrder" SQLType="12" UseValueOnly="0" DefaultValue="UsePreferences"/>
           </SetProperties>
       </PropertySet>

    </PropertySets>

    <Groups>
      <Group Name="Portal Collection">
        <Trees>
           <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="$parentTreeId"/></xsl:attribute>
                 <xsl:attribute name="Name"><xsl:value-of select="$parentTreeName"/></xsl:attribute>
           </Tree>
        </Trees>
      </Group>
    </Groups>

</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - -
      Bookmarks portlet - add details
- - - - - - - - - - - - - - - - - - - - - - -->
<xsl:template name="buildBookmarksPortlet">

    <xsl:param name="parentTree"/>
    <xsl:param name="prototypeNode"/>

    <xsl:variable name="parentTreeId" select="$parentTree/@Id"/>
    <xsl:variable name="parentTreeName" select="$parentTree/@Name"/>

<xsl:comment>NOTE: parentTreeId=<xsl:value-of select="$parentTreeId"/></xsl:comment>
<xsl:comment>NOTE: parentTreeName=<xsl:value-of select="$parentTreeName"/></xsl:comment>
    <PropertySets>
       <PropertySet Name="PORTLET_CONFIG_ROOT">
           <SetProperties>
              <Property Name="show-description" SQLType="12" UseValueOnly="0" DefaultValue="true"/>
              <Property Name="show-location" SQLType="12" UseValueOnly="0" DefaultValue="true"/>
           </SetProperties>
       </PropertySet>

    </PropertySets>

    <Groups>
      <Group Name="Portal Collection">
        <Trees>
           <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="$parentTreeId"/></xsl:attribute>
                 <xsl:attribute name="Name"><xsl:value-of select="$parentTreeName"/></xsl:attribute>
           </Tree>
        </Trees>
      </Group>
    </Groups>

</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - -
      DEBUG: Tree object catch-all, should not be getting here!
- - - - - - - - - - - - - - - - - - - - - - -->

<xsl:template match="Tree">

  <xsl:text>&#xa;</xsl:text><xsl:comment>Tree: Found tree <xsl:value-of select="@Name"/>,<xsl:value-of select="@TreeType"/></xsl:comment><xsl:text>&#xa;</xsl:text>

</xsl:template>

</xsl:stylesheet>

