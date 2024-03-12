<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:param name="reposName">Foundation</xsl:param>
<xsl:param name="userName"/>
<xsl:param name="userId"/>

<!-- Input format is the getRepositories xml format -->

<xsl:template match='/'>

<xsl:variable name="reposId"><xsl:value-of select="GetRepositories/Repositories/Repository[@Name=$reposName]/@Id"/></xsl:variable>

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
         <Tree Id="" Name="" TreeType=""/>
     </Templates>
  </Options>
 </GetMetadataObjects>
 <GetMetadataObjects>
  <ReposId><xsl:value-of select="$reposId"/></ReposId>
  <Type>Group</Type>
  <ns>SAS</ns>
   <!-- 256 = GetMetadata
        128 = XMLSelect
         16 = Include subtypes
          4 =  Template
   67108864 = No timestamp format (used so you can sort the objects by timestamp)
   -->
  <Flags>67109268</Flags>
  <Options>
      <XMLSelect search="@Name='DESKTOP_PORTALPAGES_GROUP' "/>
      <Templates>
         <Group>
            <Members/>
         </Group>
         <PSPortalPage Id="" Name="" Type="" NumberOfColumns="" NumberOfRows="" PreferredHeight="" PreferredWidth="" MetadataCreated="">
             <!-- 
             <Trees search="Tree[@TreeType='Permissions Tree' or @TreeType=' Permissions Tree']"/>
             -->
                    
             <Trees/>
             <LayoutComponents/>
             <Extensions/>
         </PSPortalPage>
         <PSColumnLayoutComponent Id="" Name="" NumberOfPortlets="" ColumnWidth="">
            <Portlets/>
         </PSColumnLayoutComponent>
         <PSPortlet Id="" Name="" portletType="" >
            <Groups/>
            <PropertySets/>
            <Trees/>
         </PSPortlet>
         <PropertySet Id="" Name="">
           <SetProperties/>
           <PropertySets/>
         </PropertySet>
         <Property Id="" Name="" SQLType="" DefaultValue=""/>
         <Extension Id="" Name="" Value=""/>
         <Document Id="" Name="" URIType="" URI="" TextRole="" TextType="" Desc="" />
         <Transformation Id="" Name="" TransformRole="">
            <Trees/>
         </Transformation>
         <Tree Id="" Name="" TreeType="">
         <ParentTree/>
         </Tree>
      </Templates>
  </Options>
 </GetMetadataObjects>
</Multiple_Requests>

</xsl:template>

</xsl:stylesheet>

