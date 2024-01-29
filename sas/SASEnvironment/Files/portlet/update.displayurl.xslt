<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:template match="/">

<xsl:variable name="portletId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/@Id"/>
<xsl:variable name="portletType" select="Mod_Request/GetMetadata/Metadata/PSPortlet/@PortletType"/>

<xsl:variable name="portletHeightId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_Height']/@Id"/>
<xsl:variable name="oldPortletHeight" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_Height']/@DefaultValue"/>
<xsl:variable name="newPortletHeight">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/PortletHeight"><xsl:value-of select="Mod_Request/NewMetadata/PortletHeight"/></xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldPortletHeight"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="portletURLId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_DisplayURL']/@Id"/>

<xsl:variable name="oldPortletURL" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_DisplayURL']/@DefaultValue"/>

<xsl:variable name="newPortletURL">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/PortletURL"><xsl:value-of select="Mod_Request/NewMetadata/PortletURL"/></xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldPortletURL"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:choose>

  <xsl:when test="not($oldPortletHeight = $newPortletHeight) or not($oldPortletURL = $newPortletURL)">

    <UpdateMetadata>

      <Metadata>

        <xsl:if test="not($oldPortletHeight=$newPortletHeight)">

           <Property><xsl:attribute name="Id"><xsl:value-of select="$portletHeightId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$newPortletHeight"/></xsl:attribute></Property>
        </xsl:if>

        <xsl:if test="not($oldPortletURL=$newPortletURL)">
        <Property><xsl:attribute name="Id"><xsl:value-of select="$portletURLId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$newPortletURL"/></xsl:attribute></Property>

        </xsl:if>

      </Metadata>

      <NS>SAS</NS>
      <Flags>268435456</Flags>
      <Options/>

    </UpdateMetadata>

  </xsl:when>

  <xsl:otherwise>
     <Root/>
     <xsl:comment>NOTE: No update required.</xsl:comment>
  </xsl:otherwise>

 </xsl:choose>

</xsl:template>

</xsl:stylesheet>

