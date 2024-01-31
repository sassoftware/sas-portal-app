<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>
<xsl:param name="itemName"/>

<xsl:param name="appLocEncoded"></xsl:param>

<xsl:param name="sastheme">default</xsl:param>
<xsl:variable name="sasthemeContextRoot">SASTheme_<xsl:value-of select="$sastheme"/></xsl:variable>

<xsl:param name="locale" select="en_us"/>

<xsl:variable name="localizationDir">SASPortalApp/sas/SASEnvironment/Files/localization</xsl:variable>

<xsl:param name="localizationFile"><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:param>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Strings to be localized -->
<xsl:variable name="portletItemEditTitle" select="$localeXml/string[@key='portletItemEditTitle']/text()"/>
<xsl:variable name="portalValueUnknown" select="$localeXml/string[@key='portalValueUnknown']/text()"/>

<xsl:template match="/">

  <!-- pass back the theme to use -->
<div id="sastheme" style="display: none"><xsl:value-of select="$sastheme"/></div>

  <xsl:choose>

    <xsl:when test="count(GetMetadata/Metadata/*)>0">

       <xsl:apply-templates select="GetMetadata/Metadata/*"/>

     </xsl:when>

     <xsl:otherwise>
        <xsl:call-template name="noobjects"/>
     </xsl:otherwise>

  </xsl:choose>

</xsl:template>

<xsl:template name="noobjects">

   <xsl:variable name="newType" select="Mod_Request/NewMetadata/Type"/>
   <xsl:variable name="newPortletType" select="Mod_Request/NewMetadata/PortletType"/>

   <xsl:variable name="noObjectBannerName">
     <xsl:choose>
        <xsl:when test="$newType = 'PSPortlet' and $newPortletType"><xsl:value-of select="$newPortletType"/></xsl:when>
        <xsl:when test="$newType"><xsl:value-of select="$newType"/></xsl:when>
        <xsl:otherwise/>
     </xsl:choose>
   </xsl:variable>

   <xsl:call-template name="genBanner">
     <xsl:with-param name="bannerItemName"><xsl:value-of select="$noObjectBannerName"/></xsl:with-param>
     <xsl:with-param name="editTitle"><xsl:value-of select="$portletItemEditTitle"/></xsl:with-param>
   </xsl:call-template>

</xsl:template>

<xsl:template match="PSPortlet">

   <xsl:variable name="portletEditTitle" select="$localeXml/string[@key='portletEditContentTitle']/text()"/>
   <xsl:call-template name="genBanner">

      <xsl:with-param name="bannerItemName"><xsl:value-of select="@Name"/></xsl:with-param>
      <xsl:with-param name="editTitle"><xsl:value-of select="$portletEditTitle"/></xsl:with-param>

   </xsl:call-template>

</xsl:template>

<xsl:template match="Document">

   <xsl:variable name="portletItemEditTitle" select="$localeXml/string[@key='portletItemEditTitle']/text()"/>

   <xsl:call-template name="genBanner">

      <xsl:with-param name="bannerItemName"><xsl:value-of select="@Name"/></xsl:with-param>
      <xsl:with-param name="editTitle"><xsl:value-of select="$portletItemEditTitle"/></xsl:with-param>

   </xsl:call-template>
</xsl:template>

<xsl:template name="genBanner">
<xsl:param name="bannerItemName"/>
<xsl:param name="editTitle"/>

<xsl:variable name="useItemName">
  <xsl:choose>
     <xsl:when test="$bannerItemName"><xsl:value-of select="$bannerItemName"/></xsl:when>
     <xsl:when test="$itemName"><xsl:value-of select="$itemName"/></xsl:when>
     <xsl:otherwise><xsl:value-of select="$portalValueUnknown"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Banner -->
<div id="banner" class="banner_container"><xsl:attribute name="style">background-image:url(/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerBackground.gif</xsl:attribute>
    <div class="banner_utilitybar_overlay">&#160;</div>
    <table class="banner_utilitybar" cellpadding="0" cellspacing="0" width="100%">
      <tbody><tr valign="top">
        <td class="banner_utilitybar_navigation" width="40%" align="left">
            &#160;   </td>
        <!-- old style options menu, replaced with global menu bar 
        <td class="banner_utilitybar_navigation"  align="right"> 
        </td> -->
        <td class="banner_userrole" nowrap="" align="center" width="20%">
        </td>
	<td width="40%" align="right" valign="top">
	<a name="globalMenuBar_skipMenuBar"></a>
	</td>

        <td width="1%">&#160;</td>
      </tr>
    </tbody>

    </table>
    <table cellpadding="0" cellspacing="0" width="100%">
      <tbody><tr>
        <td nowrap="" id="bantitle" class="banner_title"><xsl:value-of select="$editTitle"/></td>
        <td id="banbullet" class="banner_bullet">•</td>
        <td nowrap="" id="bantitle2" class="banner_secondaryTitle"><xsl:value-of select="$useItemName"/></td>
        <td align="right" id="banlogo" class="banner_logo" width="100%"><img width="62" height="24" border="0" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/logo.gif</xsl:attribute></img></td>
        <td class="banner_logoPadding">&#160;</td>
      </tr>
    </tbody>
    </table>

        <a name="skipBanner"></a>
        <table class="secondaryMenuTable" width="100%" cellspacing="0" cellpadding="0">
            <tbody><tr>
                    <td class="secondaryMenuRow" align="left" height="5"></td>
            </tr>
        </tbody>
        </table>

</div>

</xsl:template>
</xsl:stylesheet>
