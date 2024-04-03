<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- input xml format is the Mod_Request xml format with context information
     about the request is in the NewMetadata section
-->

<xsl:template match="/">

 <xsl:variable name="id" select="/Mod_Request/NewMetadata/Id"/>
 <xsl:variable name="userName" select="/Mod_Request/NewMetadata/Metaperson"/>
 <xsl:variable name="reposId" select="/Mod_Request/NewMetadata/Metareposid"/>

<Multiple_Requests>

 <!-- Get the information about what Permission Trees this user has write access to.  They should only
      be trying to add to one of these trees (otherwise, it should fail).
      Get some additional details about the contents of the tree, so we know whether it is a user
      or group permissions tree.
 -->

 <GetMetadataObjects>
  <ReposId><xsl:value-of select="$reposId"/></ReposId>
  <Type>Person</Type>
  <ns>SAS</ns>
     <!-- 256 = GetMetadata
          128 = XMLSelect
            4 =  Template
     -->
  <Flags>388</Flags>
  <Options>
     <XMLSelect>
        <xsl:attribute name="search">@Name='<xsl:value-of select="$userName"/>'</xsl:attribute>
     </XMLSelect>
     <Templates>
        <Person Id="" Name="">
          <!-- the content administrator must be explicitly tied to a permissions tree
          and must have writemetadata permission -->

           <AccessControlEntries search="AccessControlEntry[Objects/Tree[@TreeType=' Permissions Tree' or @TreeType='Permissions Tree']][Permissions/Permission[@Name='WriteMetadata' and @Type='GRANT']]"/>
        </Person>
        <AccessControlEntry Id="" Name="">
                <!-- We don't need the permission object since we already filtered to just get WriteMetadata -->
                <!-- weirdly, the TreeType has in it a leading space sometimes -->
             <Objects/>
         </AccessControlEntry>
         <Tree Id="" Name="" TreeType="">
            <!-- This member search should only be filled in for a users tree -->
            <Members search="Group[@Name='DESKTOP_PORTALPAGES_GROUP' or @Name='DESKTOP_PAGEHISTORY_GROUP']"/>
            <!-- SubTrees will be filled in for Group trees -->
            <SubTrees/>
         </Tree>
         <Group Id="" Name=""/>
     </Templates>
  </Options>
 </GetMetadataObjects>

<GetMetadata>
 <Metadata>
 <PSPortalPage>
    <xsl:attribute name="Id"><xsl:value-of select="$id"/></xsl:attribute>
 </PSPortalPage>
 </Metadata>
 <NS>SAS</NS>
     <!-- 4 =  Template
         16 =  Include Subtypes (to pick up Root template below)
     -->
 <Flags>20</Flags>
 <Options>
     <Templates>
         <PSPortalPage Id="" Name="" Desc="" NumberOfColumns="" NumberOfRows="" Type="">
            <LayoutComponents/>
            <Keywords/>
            <Extensions/>
            <Trees/>
         </PSPortalPage>
         <PSColumnLayoutComponent  Id="" Name="" ColumnWidth="" NumberOfPortlets="">
            <Portlets/>
         </PSColumnLayoutComponent>
         <PSPortlet Id="" Name="" PortletType="">
            <Trees/>
            <PropertySets/>
            <Extensions/>
            <Keywords/>
            <Groups search="@Name='Portal Collection'"/>
         </PSPortlet>
         <Tree Id="" Name="" TreeType="">
         </Tree>
         <Extension Id="" Name="" Value=""/>
         <Keyword Id="" Name=""/>
         <PropertySet Id="" Name="">
            <SetProperties/>
            <Extensions/>
         </PropertySet>
         <Property Id="" Name="">
         </Property>
         <Group Id="" Name="">
            <Members/>
         </Group>
         <Document Id="" Name=""> 
            <Trees/>
         </Document>
         <!-- Since almost anything can be put into a collection, and when if we move the portlet, we also
              have to move the linked items, but only those in the same tree, we have to get the Trees relationship
              for all unknown items
         -->
         <Root Id="" Name="">
            <Trees/>
         </Root>
     </Templates>
  </Options>
 </GetMetadata>

</Multiple_Requests>

</xsl:template>

</xsl:stylesheet>

