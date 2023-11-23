<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="xml"/>

<xsl:param name="treeName"/>
<xsl:param name="treeId"/>

<xsl:template match="Prototype[Extensions/Extension[@Name='URI' and (@Value!='/sas/portlets/Bookmarks/display' and @Value!='/sas/portlets/Welcome/display')]]">

<xsl:variable name="portletType"><xsl:value-of select="substring-before(@Name,' ')"/></xsl:variable>
<xsl:variable name="prototypeId"><xsl:value-of select="@Id"/></xsl:variable>

<!-- TODO: Not sure how to get the name correctly, may need to be localized -->
<!--       For now, just use the portlet type -->

<xsl:variable name="portletName"><xsl:value-of select="$portletType"/></xsl:variable>
<!-- TODO: Not sure how to get the description correctly, may need to be localized -->
<!--       For now, just use the desc field from the prototype -->

<xsl:variable name="portletDesc"><xsl:value-of select="@Desc"/></xsl:variable>

                        <PSPortlet><xsl:attribute name="Name"><xsl:value-of select="$portletName"/></xsl:attribute>
                                   <xsl:attribute name="Desc"><xsl:value-of select="$portletDesc"/></xsl:attribute>
                                   <xsl:attribute name="portletType"><xsl:value-of select="$portletType"/></xsl:attribute>
                           <PropertySets>
                              <PropertySet Name="PORTLET_CONFIG_ROOT" Desc="" PropertySetName=""/>
                           </PropertySets>
                           <UsingPrototype>
                              <Prototype><xsl:attribute name="ObjRef"><xsl:value-of select="$prototypeId"/></xsl:attribute></Prototype>
                           </UsingPrototype>
                           <Trees>
                              <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="$treeId"/></xsl:attribute></Tree>
                           </Trees>
                         </PSPortlet>
  
</xsl:template>

<xsl:template match="*">

  <xsl:comment><xsl:text>skipped prototype:</xsl:text><xsl:value-of select="@Name"/></xsl:comment>

</xsl:template>

<xsl:template match="/">

<!-- For each protype, generate the appropriate portlet definition -->

<AddMetadata>

	<Metadata>

            <xsl:apply-templates select="/GetMetadataObjects/Objects/Tree/Members/Prototype"/>

	</Metadata>
	<ReposId>$METAREPOSITORY</ReposId>
	<NS>SAS</NS>
	<Flags>268435456</Flags>
	<Options/>

</AddMetadata>
  
</xsl:template>

</xsl:stylesheet>

