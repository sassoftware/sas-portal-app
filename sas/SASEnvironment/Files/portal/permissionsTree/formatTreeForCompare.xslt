<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes"/>

<xsl:template match="@Id">
  <!-- don't output Id attribute -->
  <xsl:message>Found Id, skipping</xsl:message>
</xsl:template>

<xsl:template match="@*">
  <xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="*">
    <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<xsl:template match="comment()|processing-instruction()">
    <xsl:copy/>

</xsl:template>

</xsl:stylesheet>
