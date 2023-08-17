<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<xsl:template match="/">

  <!-- pass back the theme to use -->
<div id="sastheme" style="display: none">SASTheme_default</div>

  <xsl:apply-templates select="GetMetadata/Metadata/PSPortlet"/>

</xsl:template>

<xsl:template match="PSPortlet">

<!-- Banner -->
<div id="banner" style="background-image:url(/SASTheme_default/themes/default/images/BannerBackground.gif)" class="banner_container">
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
        <td nowrap="" id="bantitle" class="banner_title">Edit Portlet Content</td>
        <td id="banbullet" class="banner_bullet">•</td>
        <td nowrap="" id="bantitle2" class="banner_secondaryTitle"><xsl:value-of select="@Name"/></td>
        <td align="right" id="banlogo" class="banner_logo" width="100%"><img src="logo.gif" width="62" height="24" border="0" alt=""/></td>
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
