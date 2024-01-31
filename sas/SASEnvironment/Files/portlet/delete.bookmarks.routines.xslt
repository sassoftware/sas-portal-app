<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="PSPortlet[@portletType='Bookmarks']">

<xsl:apply-templates select="Extensions/*"/>
<xsl:apply-templates select="Keywords/*"/>
<xsl:apply-templates select="PropertySets/*"/>

<!--  Although several portlets use a Portal Collection group, each one
      has slightly different rules about what should be deleted in the 
      collection, in bookmarks, not deleting any
-->

<xsl:for-each select="Groups/Group[@Name='Portal Collection']">

  <Group>
    <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
  </Group>

</xsl:for-each>

<PSPortlet>
   <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
</PSPortlet>

</xsl:template>

</xsl:stylesheet>

