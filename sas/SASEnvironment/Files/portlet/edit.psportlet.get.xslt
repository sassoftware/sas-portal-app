<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- input xml format is the Mod_Request xml format with context information
     about the request is in the NewMetadata section
-->

<xsl:template match="/">

 <xsl:variable name="id" select="/Mod_Request/NewMetadata/Id"/>

<GetMetadata>
 <Metadata>
 <PSPortlet PortletType="" Name="">
   <xsl:attribute name="Id"><xsl:value-of select="$id"/></xsl:attribute>
 </PSPortlet>
 </Metadata>
 <NS>SAS</NS>
 <Flags>20</Flags>
 <Options>
                     <Templates>
                        <PSPortlet Id="" Name="" PortletType="">
                           <Groups/>
                           <PropertySets/>
                           <Trees/>
                        </PSPortlet>
                        <Group>
                           <Members/>
                        </Group>
                        <PropertySet Id="" Name="">
                          <SetProperties/>
                          <PropertySets/>
                        </PropertySet>
                        <Property Id="" Name="" SQLType="" DefaultValue=""/>
                        <Extension Id="" Name="" Value=""/>
                        <Document Id="" Name="" URIType="" URI="" TextRole="" TextType=""/>
                        <Transformation Id="" Name="" TransformRole="">
                           <Trees/>
                        </Transformation>
                        <Tree Id="" Name="">
                          <ParentTree/>
                        </Tree>
                     </Templates>
                </Options>
</GetMetadata>

</xsl:template>

</xsl:stylesheet>

