<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:param name="treeName"/>
<xsl:param name="function"/>

<!-- input is response from running getStandardPages.xslt -->

<!-- - - - - - - - - - - - - - - - - - - -
      Main Entry Point
- - - - - - - - - - - - - - - - - - - - - - -->

<!-- TODO List: 

     - any difference if default page is grid layout instead of column layout?
     - Verify how to get default names, etc. of created pages and portlets from prototype info
     - make this a multi-purpose template 1) create standard pages 2) create page 3) create portlet
       - wanting to do this to keep all of the page and portlet creation templates in one place
         and can't find a reasonable way to do xsl:include and still provide the admin an easy way
         to manage the directory structure.
-->

<xsl:template match="/">

    <xsl:choose>

      <xsl:when test="$function='standardpages'">

         <xsl:variable name="parentTree" select="/Multiple_Requests/GetMetadataObjects[2]/Objects/Tree"/>

         <xsl:choose>

            <xsl:when test="count($parentTree/Members/PSPortalPage)=0">
               <xsl:call-template name="buildStandardPages"/>
            </xsl:when>
            <xsl:otherwise>
               <message>ERROR: Permissions tree already contains pages so can't create initial pages</message>
            </xsl:otherwise>

         </xsl:choose>

      </xsl:when>
      <xsl:otherwise>
         <message>ERROR: Invalid function, $function, passed to template.</message>
      </xsl:otherwise>

    </xsl:choose>

</xsl:template>

<xsl:template name="buildStandardPages">

    <!-- input is response from running getStandardPages.xslt -->

    <!--  For each portal page template, create the portal page -->

    <AddMetadata>

        <Metadata>

            <!-- Add the Sticky Pages -->

            <xsl:apply-templates select="/Multiple_Requests/GetMetadataObjects[1]/Objects/Tree/SubTrees/Tree[@Name='RolesTree']/SubTrees/Tree[@Name='DefaultRole']/SubTrees/Tree[@Name='DESKTOP_PROFILE']/SubTrees/Tree[@Name='Sticky']/SubTrees//Tree[@TreeType='PortalPageTemplate']">
            </xsl:apply-templates>
            <xsl:apply-templates select="/Multiple_Requests/GetMetadataObjects[1]/Objects/Tree/SubTrees/Tree[@Name='RolesTree']/SubTrees/Tree[@Name='DefaultRole']/SubTrees/Tree[@Name='DESKTOP_PROFILE']/SubTrees/Tree[@Name='Default']/SubTrees//Tree[@TreeType='PortalPageTemplate']">
            </xsl:apply-templates>

        </Metadata>
        <ReposId>$METAREPOSITORY</ReposId>
        <NS>SAS</NS>
        <Flags>268435456</Flags>
        <Options/>

    </AddMetadata>

</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - -
      Template to process a Page Template
- - - - - - - - - - - - - - - - - - - - - - -->

<xsl:template match="Tree[@TreeType='PortalPageTemplate']">

    <xsl:variable name="parentTree" select="/Multiple_Requests/GetMetadataObjects[2]/Objects/Tree"/>
    <xsl:variable name="parentTreeId" select="$parentTree/@Id"/>
    <xsl:variable name="parentTreeName" select="$parentTree/@Name"/>

<xsl:comment>NOTE: parentTreeId=<xsl:value-of select="$parentTreeId"/></xsl:comment>
<xsl:comment>>NOTE: parentTreeName=<xsl:value-of select="$parentTreeName"/></xsl:comment>

    <xsl:variable name="pagesGroupId" select="/Multiple_Requests/GetMetadataObjects[2]/Objects/Tree/Members/Group[@Name='DESKTOP_PORTALPAGES_GROUP']/@Id"/>
    <xsl:variable name="pagesGroupName" select="/Multiple_Requests/GetMetadataObjects[2]/Objects/Tree/Members/Group[@Name='DESKTOP_PORTALPAGES_GROUP']/@Name"/>
    <xsl:variable name="historyGroupId" select="/Multiple_Requests/GetMetadataObjects[2]/Objects/Tree/Members/Group[@Name='DESKTOP_PAGEHISTORY_GROUP']/@Id"/>
    <xsl:variable name="historyGroupName" select="/Multiple_Requests/GetMetadataObjects[2]/Objects/Tree/Members/Group[@Name='DESKTOP_PAGEHISTORY_GROUP']/@Name"/>

    <xsl:if test="not($parentTreeId)">
       <message>ERROR: Parent Tree Id not found in input xml file.</message>
    </xsl:if>

    <xsl:if test="not($treeName)">
       <message>ERROR: Input tree name not set.</message>
    </xsl:if>

    <xsl:if test="not($pagesGroupId)">
       <message>ERROR: Portal Page group not found in permission tree, is tree initialized?.</message>
    </xsl:if>
    <xsl:if test="not($historyGroupId)">
       <message>ERROR: Portal Page History group not found in permission tree, is tree initialized?.</message>
    </xsl:if>


    <xsl:variable name="pageName"><xsl:value-of select="@Name"/></xsl:variable>
    <xsl:variable name="pageDesc"><xsl:value-of select="@Desc"/></xsl:variable>

    <xsl:text>&#xa;</xsl:text><xsl:comment>PortalPageTemplate: Found template <xsl:value-of select="$pageName"/>,<xsl:value-of select="@Desc"/></xsl:comment><xsl:text>&#xa;</xsl:text>

      <!-- Generate Note: Including the Name attribute on objects referenced through ObjRef doesn't change the processing, but it makes it much easier
                          to validate that the correct associations are being made, thus including Name attributes on object references
       -->

    <xsl:variable name="newPageId" select="concat('$',generate-id(.))"/>

    <!-- I don't see how the template would set anything other than Column as the type of layout, but putting it here as a variable in case
         it's figured out later that it can be set to something else
      -->

    <xsl:variable name="pageLayoutType">Column</xsl:variable>

    <PSPortalPage>
      <!-- Generate a unique id for this page so that we can link to it later when adding it to a group -->
      <xsl:attribute name="Id"><xsl:value-of select="$newPageId"/></xsl:attribute>
      <xsl:attribute name="Name"><xsl:value-of select="$pageName"/></xsl:attribute>
      <xsl:attribute name="Desc"><xsl:value-of select="$pageDesc"/></xsl:attribute>

      <xsl:attribute name="NumberOfColumns"><xsl:value-of select="count(SubTrees/Tree[@TreeType='PortalPageColumnTemplate'])"/></xsl:attribute>
      <xsl:attribute name="Type"><xsl:value-of select="$pageLayoutType"/></xsl:attribute>

      <!-- I don't see how these attributes get their values, but I see them on pages that the IDP creates itself, so setting them here. -->

      <xsl:variable name="pageRank">100</xsl:variable>

      <Extensions>
          <Extension Name="PageRank"><xsl:attribute name="Value"><xsl:value-of select="$pageRank"/></xsl:attribute></Extension>
          <Extension Name="LayoutType"><xsl:attribute name="Value"><xsl:value-of select="$pageLayoutType"/></xsl:attribute></Extension>
      </Extensions>

      <UsingPrototype>
        <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="@Id"/></xsl:attribute><xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute>
        </Tree>
      </UsingPrototype>

      <Trees>
        <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="$parentTreeId"/></xsl:attribute><xsl:attribute name="Name"><xsl:value-of select="$parentTreeName"/></xsl:attribute>
        </Tree>
      </Trees>

      <!-- Link it into the portal pages group 
           NOTE: Linking it in the history group is done below as a seperate top level AddMetadata object 
        -->

      <Groups>
          <Group>
             <xsl:attribute name="ObjRef"><xsl:value-of select="$pagesGroupId"/></xsl:attribute>
             <xsl:attribute name="Name"><xsl:value-of select="$pagesGroupName"/></xsl:attribute>
          </Group>
      </Groups>
      
      <!-- Add the layout and contents to the page -->

      <LayoutComponents>
         <xsl:call-template name="createPageLayout">

            <xsl:with-param name="parentTree" select="$parentTree"/>
            <xsl:with-param name="newPageId"><xsl:value-of select="$newPageId"/></xsl:with-param>

         </xsl:call-template>

      </LayoutComponents>

    </PSPortalPage>

    <xsl:comment>Create the Page History group and link in both the prototype and the new page</xsl:comment>

    <Group><xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute><xsl:attribute name="Desc"><xsl:value-of select="@Desc"/></xsl:attribute>
        <Groups>
           <Group><xsl:attribute name="ObjRef"><xsl:value-of select="$historyGroupId"/></xsl:attribute><xsl:attribute name="Name"><xsl:value-of select="$historyGroupName"/></xsl:attribute></Group>
        </Groups>

        <Trees>
          <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="$parentTreeId"/></xsl:attribute><xsl:attribute name="Name"><xsl:value-of select="$parentTreeName"/></xsl:attribute>
          </Tree>
        </Trees>

        <Members>
          <!-- First link in the prototype -->
          <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="@Id"/></xsl:attribute><xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute></Tree>
          <PSPortalPage><xsl:attribute name="ObjRef"><xsl:value-of select="$newPageId"/></xsl:attribute><xsl:attribute name="Name">
                        <xsl:value-of select="$pageName"/></xsl:attribute>
          </PSPortalPage>
        </Members>

    </Group>

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
           <xsl:attribute name="ColumnWidth"><xsl:value-of select="columnWidth"/></xsl:attribute>
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

