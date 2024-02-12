<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="PSPortlet[@portletType='SASReportPortlet']">

<xsl:apply-templates select="Extensions/*"/>
<xsl:apply-templates select="Keywords/*"/>
<xsl:apply-templates select="PropertySets/*"/>

<PSPortlet>
   <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
</PSPortlet>

</xsl:template>

</xsl:stylesheet>

