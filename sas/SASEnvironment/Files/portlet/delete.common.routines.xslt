<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="Keyword">

<Keyword>
  <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
</Keyword>

</xsl:template>

<xsl:template match="Extension">

<Extension>
  <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
</Extension>

</xsl:template>


<xsl:template match="PropertySet">

<xsl:apply-templates select="SetProperties/*"/>
<xsl:apply-templates select="Extensions/*"/>

<PropertySet>
  <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
</PropertySet>

</xsl:template>

<xsl:template match="Property">

<Property>
  <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
</Property>

</xsl:template>

<xsl:template match="Document">

<Document>
  <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
</Document>

</xsl:template>

<xsl:template match="Group">

<Group>
  <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
</Group>

</xsl:template>

</xsl:stylesheet>

