<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- These setup steps will set up any information that we may need about the environment
     being executed in, including the metadata repository information, current sas theme being used,
     and the localization file to reference
-->

<xsl:variable name="reposName">
 <xsl:choose>
   <xsl:when test="/Mod_Request/NewMetadata/Metarepos">
     <xsl:value-of select="/Mod_Request/NewMetadata/Metarepos"/>
   </xsl:when>
   <xsl:otherwise>Foundation</xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<xsl:variable name="reposId" select="/Mod_Request/NewMetadata/Metareposid"/>

<xsl:variable name="appLocEncoded" select="/Mod_Request/NewMetadata/AppLocEncoded"/>

<xsl:variable name="sastheme">
 <xsl:choose>
   <xsl:when test="/Mod_Request/NewMetadata/SASTheme">
     <xsl:value-of select="/Mod_Request/NewMetadata/SASTheme"/>
   </xsl:when>
   <xsl:otherwise>default</xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<xsl:variable name="sasthemeContextRoot">SASTheme_<xsl:value-of select="$sastheme"/></xsl:variable>

<xsl:variable name="localizationDir">SASPortalApp/sas/SASEnvironment/Files/localization</xsl:variable>

<xsl:variable name="envMetaperson" select="/Mod_Request/NewMetadata/Metaperson"/>

</xsl:stylesheet>
