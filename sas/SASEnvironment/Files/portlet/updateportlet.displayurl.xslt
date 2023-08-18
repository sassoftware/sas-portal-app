<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:param name="portletHeight"/>
<xsl:param name="portletURL"/>

<xsl:template match="/">

<xsl:variable name="portletId" select="GetMetadata/Metadata/PSPortlet/@Id"/>
<xsl:variable name="portletType" select="GetMetadata/Metadata/PSPortlet/@PortletType"/>

<xsl:variable name="oldPortletHeight" select="GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_Height']/@DefaultValue"/>
<xsl:variable name="portletHeightId" select="GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_Height']/@Id"/>

<xsl:variable name="oldPortletURL" select="GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_DisplayURL']/@DefaultValue"/>
<xsl:variable name="portletURLId" select="GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_DisplayURL']/@Id"/>

<UpdateMetadata>

  <Metadata>

    <Property><xsl:attribute name="Id"><xsl:value-of select="$portletHeightId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$portletHeight"/></xsl:attribute></Property>
    <Property><xsl:attribute name="Id"><xsl:value-of select="$portletURLId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$portletURL"/></xsl:attribute></Property>

  </Metadata>

  <NS>SAS</NS>
  <Flags>268435456</Flags>
  <Options/>

</UpdateMetadata>

</xsl:template>

</xsl:stylesheet>

