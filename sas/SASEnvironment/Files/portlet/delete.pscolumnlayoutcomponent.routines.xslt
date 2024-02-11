<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="PSColumnLayoutComponent">

<PSColumnLayoutComponent>
   <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
</PSColumnLayoutComponent>

</xsl:template>

</xsl:stylesheet>

