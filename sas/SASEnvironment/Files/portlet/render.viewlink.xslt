<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<!-- Common Setup -->

<!-- Set up the metadataContext variable -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.metadatacontext.xslt"/>
<!-- Set up the environment context variables -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.envcontext.xslt"/>

<!-- load the appropriate localizations -->

<xsl:variable name="localizationFile">
 <xsl:choose>
   <xsl:when test="/Mod_Request/NewMetadata/LocalizationFile"><xsl:value-of select="/Mod_Request/NewMetadata/LocalizationFile"/></xsl:when>
   <xsl:otherwise><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Global Variables -->

<xsl:variable name="path" select="/Mod_Request/NewMetadata/Path"/>

<!--  Main Template -->

<xsl:template match="/">

<xsl:apply-templates select="$metadataContext/GetMetadataObjects/Objects/*"/>

</xsl:template>

<xsl:template match="Document">

<html>

<head>
</head>
<body>

<script>
    window.onload = function() {
      location.replace("<xsl:value-of select="@URI"/>");
    };
</script>

</body>

</html>
</xsl:template>

</xsl:stylesheet>

