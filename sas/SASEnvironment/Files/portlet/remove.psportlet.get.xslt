<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- input xml format is the Mod_Request xml format with context information
     about the request is in the NewMetadata section
-->

<xsl:template match="/">

 <xsl:variable name="userName" select="/Mod_Request/NewMetadata/Metaperson"/>
 <xsl:variable name="reposId" select="/Mod_Request/NewMetadata/Metareposid"/>
 <xsl:variable name="portletId" select="/Mod_Request/NewMetadata/Id"/>

 <!-- Get the information about what Permission Trees this user has write access to.  
      Get some additional details about the contents of the tree, so we know whether it is a user
      or group permissions tree.
 -->
<Multiple_Requests>
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
  <GetMetadataObjects>
  <ReposId><xsl:value-of select="$reposId"/></ReposId>
  <Type>PSPortlet</Type>
  <ns>SAS</ns>
     <!-- 256 = GetMetadata
          128 = XMLSelect
            4 =  Template
     -->
  <Flags>388</Flags>
  <Options>
     <XMLSelect>
        <xsl:attribute name="search">@Id='<xsl:value-of select="$portletId"/>'</xsl:attribute>
     </XMLSelect>
     <Templates>
         <PSPortlet Id="" Name="" PortletType="">
            <Trees/>
            <LayoutComponents/>
         </PSPortlet>
         <Tree Id="" Name="" TreeType=""/>
         <PSColumnLayoutComponent  Id="" Name=""/>
     </Templates>
  </Options>
 </GetMetadataObjects>

</Multiple_Requests> 
</xsl:template>

</xsl:stylesheet>

