<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- input xml is the output of the generated xml request -->

<!-- input: prototype to use to build the portlet -->
<!--        permissionsTree to add it to -->
<!--        ComponentLayout to add it to -->

     <xsl:param name="usingPrototypeId"/>
     <xsl:param name="inPermissionsTreeId"/>
     <xsl:param name="inComponentLayoutId"/>
     <xsl:param name="portletName"/>
     <xsl:param name="portletDesc"/>

<xsl:template match="/">

                <AddMetadata>

                <Metadata>

                <xsl:call-template name="buildBookmarksPortlet"/>

                </Metadata>
                <ReposId>$METAREPOSITORY</ReposId>
                <NS>SAS</NS>
                <Flags>268435456</Flags>
                <Options/>

                </AddMetadata>

</xsl:template>

<xsl:template name="buildBookmarksPortlet">

  <!-- $mainPortlet is not a reference to an xsl variable, it is the syntax passed to a metadata query
       as an id to use for intra-request object linking
    -->

  <PSPortlet portletType="Bookmarks" Id="$mainPortlet">
             <xsl:attribute name="Name"><xsl:value-of select="$portletName"/></xsl:attribute>
             <xsl:attribute name="Desc"><xsl:value-of select="$portletDesc"/></xsl:attribute>
     <PropertySets>
         <PropertySet Name="PORTLET_CONFIG_ROOT">
            <SetProperties>
                <Property Name="show-description" DefaultValue="true" SQLType="12"/>
                <Property Name="show-location" DefaultValue="true" SQLType="12"/>
            </SetProperties>
         </PropertySet>
     </PropertySets>
     <Groups>
        <Group Name="Portal Collection"><xsl:attribute name="Desc"><xsl:value-of select="$portletDesc"/></xsl:attribute>
             <Members>
                <Group ObjRef="$mainPortlet"/>
             </Members>          
        </Group>
     </Groups>
     <Trees>
        <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="$inPermissionsTreeId"/></xsl:attribute></Tree>
    </Trees>
    <UsingPrototype>
        <Prototype><xsl:attribute name="ObjRef"><xsl:value-of select="$usingPrototypeId"/></xsl:attribute></Prototype>
    </UsingPrototype>

    <LayoutComponents>
        <PSColumnLayoutComponent><xsl:attribute name="ObjRef"><xsl:value-of select="$inComponentLayoutId"/></xsl:attribute></PSColumnLayoutComponent>
    </LayoutComponents>
     

  <PSPortlet>

</xsl:template>

</xsl:stylesheet>

