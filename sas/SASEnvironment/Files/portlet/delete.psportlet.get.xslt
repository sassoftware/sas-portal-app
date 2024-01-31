<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- input xml format is the Mod_Request xml format with context information
     about the request is in the NewMetadata section
-->

<xsl:template match="/">

 <xsl:variable name="portletId" select="/Mod_Request/NewMetadata/Id"/>
 <xsl:variable name="reposId" select="/Mod_Request/NewMetadata/Metareposid"/>

<Multiple_Requests>
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
            <PropertySets/>
            <Extensions/>
            <Keywords/>
            <Layouts/>
            <Groups search="@Name='Portal Collection'"/>
         </PSPortlet>
         <PSColumnLayoutComponent Id="" Name="">
           <OwningPage/>
         </PSColumnLayoutComponent>
         <PSPortalPage Id="" Name=""/>
         <Tree Id="" Name="" TreeType="">
         </Tree>
         <Extension Id="" Name=""/>
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
 </GetMetadataObjects>

</Multiple_Requests> 
</xsl:template>

</xsl:stylesheet>

