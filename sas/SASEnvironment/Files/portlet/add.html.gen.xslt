<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<!-- Input xml format is the add parameter format, see the buildAddParameters sas macro
  -->

<xsl:param name="appLocEncoded"></xsl:param>

<xsl:param name="sastheme">default</xsl:param>
<xsl:variable name="sasthemeContextRoot">SASTheme_<xsl:value-of select="$sastheme"/></xsl:variable>

<xsl:param name="locale" select="en_us"/>

<xsl:variable name="localizationDir">SASPortalApp/sas/SASEnvironment/Files/localization</xsl:variable>

<xsl:param name="localizationFile"><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:param>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Strings to be localized -->
<xsl:variable name="portletItemAddTitle" select="$localeXml/string[@key='portletItemAddTitle']/text()"/>

<!-- Global Variables -->
<xsl:variable name="tabCount" select="count(Mod_Request/NewMetadata/Tabs/Tab)"/>

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portal/buildBannerTab.xslt"/>

<xsl:template match="/">

  <xsl:variable name="itemType" select="Mod_Request/NewMetadata/Type"/>

  <!-- pass back the theme to use -->
<div id="sastheme" style="display: none"><xsl:value-of select="$sastheme"/></div>

   <xsl:variable name="portletAddTitle" select="$localeXml/string[@key='portletItemAddTitle']/text()"/>
   <xsl:call-template name="genBanner">

      <xsl:with-param name="itemName"><xsl:value-of select="$itemType"/></xsl:with-param>
      <xsl:with-param name="addTitle"><xsl:value-of select="$portletAddTitle"/></xsl:with-param>

   </xsl:call-template>

</xsl:template>

<xsl:template name="genBanner">
<xsl:param name="itemName"/>
<xsl:param name="addTitle"/>

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
        <td nowrap="" id="bantitle" class="banner_title"><xsl:value-of select="$addTitle"/></td>
        <td id="banbullet" class="banner_bullet">•</td>
        <td nowrap="" id="bantitle2" class="banner_secondaryTitle"><xsl:value-of select="$itemName"/></td>
        <td align="right" id="banlogo" class="banner_logo" width="100%"><img width="62" height="24" border="0" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/logo.gif</xsl:attribute></img></td>
        <td class="banner_logoPadding">&#160;</td>
      </tr>
    </tbody>
    </table>

        <xsl:if test="not($tabCount='0')">

         <div id="tabs">
              <xsl:call-template name="genTabList"/>
         </div>

        </xsl:if>

        <a name="skipBanner"></a>
        <table class="secondaryMenuTable" width="100%" cellspacing="0" cellpadding="0">
            <tbody><tr>
                    <td class="secondaryMenuRow" align="left" height="5"></td>
            </tr>
        </tbody>
        </table>

</div>

</xsl:template>

<xsl:template name="genTabList">

   <table id="pagetabs_Table" class="BannerTabMenuTable" cellspacing="0" cellpadding="0" border="0">
   <tbody>
   <tr>

        <xsl:for-each select="Mod_Request/NewMetadata/Tabs/Tab">
          <xsl:variable name="tabNumberId">page_<xsl:value-of select="@Id"/></xsl:variable>
          <xsl:variable name="nameKey" select="@NameKey"/>
          <xsl:variable name="tabName" select="$localeXml/string[@key=$nameKey]/text()"/>

          <td>
                <xsl:attribute name="id"><xsl:value-of select="$tabNumberId"/>_TabCell</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="position() = 1">
                       <xsl:attribute name="class">BannerTabMenuActiveTabCell</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                       <xsl:attribute name="class">BannerTabMenuTabCell</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>

                <table border="0" cellspacing="0" cellpadding="0">
                       <xsl:attribute name="id"><xsl:value-of select="$tabNumberId"/></xsl:attribute>
                       <xsl:attribute name="onclick">showTab(event, '<xsl:value-of select="@Id"/>')</xsl:attribute>

                       <!-- Mark the first tab to display so that the javascript can find it and display it -->
                       <xsl:choose>

                         <xsl:when test="position() = 1">
                             <xsl:attribute name="class">buttonContainer default-tab</xsl:attribute>
                         </xsl:when>
                         <xsl:otherwise>
                             <xsl:attribute name="class">buttonContainer</xsl:attribute>
                         </xsl:otherwise>
                       </xsl:choose>
                       <tbody>
                          <tr>
                             <xsl:call-template name="buildTab">
                                <xsl:with-param name="tabId"><xsl:value-of select="$tabNumberId"/></xsl:with-param>
                                <xsl:with-param name="tabName"><xsl:value-of select="$tabName"/></xsl:with-param>
                                <xsl:with-param name="tabPosition"><xsl:value-of select="position()"/></xsl:with-param>
                              </xsl:call-template>

                          </tr>
                        </tbody>
                   </table>

          </td>

       </xsl:for-each>

   </tr>

   </tbody>
   </table>

</xsl:template>

</xsl:stylesheet>
