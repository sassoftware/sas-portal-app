<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- input xml format is the Mod_Request xml format with context information
     about the request is in the NewMetadata section
-->

<xsl:template match="/">

 <xsl:variable name="id" select="/Mod_Request/NewMetadata/Id"/>


<GetMetadata>
 <Metadata>
 <PSPortalPage>
    <xsl:attribute name="Id"><xsl:value-of select="$id"/></xsl:attribute>
 </PSPortalPage>
 </Metadata>
 <NS>SAS</NS>
     <!-- 4 =  Template
     -->
 <Flags>4</Flags>
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
         <Document Id="" Name=""/>
     </Templates>
  </Options>
 </GetMetadata>

</xsl:template>

</xsl:stylesheet>

