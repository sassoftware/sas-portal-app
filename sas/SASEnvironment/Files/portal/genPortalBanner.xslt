<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" encoding="UTF-8"/>
<!-- The following parameters can be passed -->
<!-- includeTabs = should this template include an area to generate tabs? 
                   1 = call the genTabList template (must be defined in the including file
                   0 = (default) do not call genTabList template
-->

<!-- The following variables must be set by the including file -->

<!-- localeXml = the file containing the appropriate localizations -->
<!-- sastheme  = the name of the sas theme to use -->
<!-- sasthemeContextRoot = the the web server context root of the SAS theme application -->

<!-- Strings to be localized -->
<xsl:variable name="portalTitle" select="$localeXml/string[@key='portalTitle']/text()"/>

<xsl:variable name="globalMenuBar_skipMenuBar" select="$localeXml/string[@key='globalMenuBar_skipMenuBar']/text()"/>
<xsl:variable name="portalCustomizationMenu" select="$localeXml/string[@key='portalCustomizationMenu']/text()"/>
<xsl:variable name="portalCustomizationMenuTitle" select="$localeXml/string[@key='portalCustomizationMenuTitle']/text()"/>
<xsl:variable name="portalOptionsMenu" select="$localeXml/string[@key='portalOptionsMenu']/text()"/>
<xsl:variable name="portalOptionsMenuTitle" select="$localeXml/string[@key='portalOptionsMenuTitle']/text()"/>

<xsl:variable name="portalSearchMenu" select="$localeXml/string[@key='portalSearchMenu']/text()"/>
<xsl:variable name="portalSearchMenuTitle" select="$localeXml/string[@key='portalSearchMenuTitle']/text()"/>

<xsl:variable name="portalLogoffMenu" select="$localeXml/string[@key='portalLogoffMenu']/text()"/>
<xsl:variable name="portalLogoffMenuTitle" select="$localeXml/string[@key='portalLogoffMenuTitle']/text()"/>

<xsl:variable name="portalHelpMenu" select="$localeXml/string[@key='portalHelpMenu']/text()"/>
<xsl:variable name="portalHelpMenuTitle" select="$localeXml/string[@key='portalHelpMenuTitle']/text()"/>

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  This section of the templates is for generating a tab

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->
<xsl:template name="buildTab">
  <xsl:param name="tabId"/>
  <xsl:param name="tabName"/>
  <xsl:param name="tabPosition"/>

   <!--  This is a complicated way of doing tabs, but it is done this way so that existing SAS Themes will still properly render -->

   <!--  The left part of the tab -->

   <td valign="top" align="left">
       <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_l</xsl:attribute>
       <xsl:choose>

         <xsl:when test="$tabPosition = 1">
             <xsl:attribute name="class">BannerTabButtonLeftActive</xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
             <xsl:attribute name="class">BannerTabButtonLeft</xsl:attribute>
         </xsl:otherwise>
       </xsl:choose>

         <img border="0">
              <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_l_img</xsl:attribute>

               <xsl:choose>

                 <xsl:when test="tabPosition = 1">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonLeftActive.gif</xsl:attribute>
                 </xsl:when>
                 <xsl:otherwise>
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonLeft.gif</xsl:attribute>
                 </xsl:otherwise>

               </xsl:choose>

         </img>
   </td>

   <!-- The center part of the tab -->

   <td nowrap="nowrap" align="center">

       <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_c</xsl:attribute>

       <xsl:choose>
       <xsl:when test="tabPosition = 1">
             <xsl:attribute name="class">BannerTabButtonCenterActive</xsl:attribute>
             <xsl:attribute name="style">background-image: url(&quot;/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonCenterActive.gif&quot;);</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
             <xsl:attribute name="class">BannerTabButtonCenter</xsl:attribute>
             <xsl:attribute name="style">background-image: url(&quot;/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonCenter.gif&quot;);</xsl:attribute>
       </xsl:otherwise>
       </xsl:choose>

      <button  type="button" style="background-color: transparent;border-style: none;">
            <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_button</xsl:attribute>
             <xsl:attribute name="title"><xsl:value-of select="$tabName"/></xsl:attribute>

             <span>
                 <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_label</xsl:attribute>
                 <xsl:value-of select="$tabName"/>
             </span>
     </button>
   </td>

   <!-- the right part of the tab -->

   <td valign="top" align="right">
       <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_r</xsl:attribute>
       <xsl:choose>

         <xsl:when test="tabPosition = 1">
             <xsl:attribute name="class">BannerTabButtonRightActive</xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
             <xsl:attribute name="class">BannerTabButtonRight</xsl:attribute>
         </xsl:otherwise>
       </xsl:choose>
      <img alt="" border="0">
              <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_r_img</xsl:attribute>
               <xsl:choose>
                 <xsl:when test="tabPosition = 1">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonRightActive.gif</xsl:attribute>
                 </xsl:when>
                 <xsl:otherwise>
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonRight.gif</xsl:attribute>
                 </xsl:otherwise>
               </xsl:choose>

         </img>

   </td>

</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  Generate the banner section of the page 

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->

<xsl:template name="Banner">

		<div class="banner_utilitybar_overlay">&#160;</div>
		<table class="banner_utilitybar" cellpadding="0" cellspacing="0" width="100%">
		<tbody>
			<tr valign="top">
			<td class="banner_utilitybar_navigation" width="40%" align="left">
				&#160;   </td>
			<td class="banner_userrole" nowrap="" align="center" width="20%"> </td>
			<td width="40%" align="right" valign="top">
				<a href="#globalMenuBar_skipMenuBar"><xsl:attribute name="title"><xsl:value-of select="$globalMenuBar_skipMenuBar"/></xsl:attribute></a>
	
         			<span class="SimpleMenuBar SimpleMenuBar_Banner_GlobalMenu_Look" id="globalMenuBar">
				<table cellpadding="4" cellspacing="1">
				<tbody>
				<tr>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
						<!--  Comment out Customize toolbar for now
						<a id="globalMenuBar_0_anchor" href="#"><xsl:attribute name="title"><xsl:value-of select="$portalCustomizationMenuTitle"/></xsl:attribute>
                                                <span><xsl:value-of select="$portalCustomizationMenu"/></span>
						<img class="SimpleMenuBarSubMenuIndicator SimpleMenuBarSubMenuIndicator_Banner_GlobalMenu_Look" src="/$sastheme/themes/<xsl:value-of select="$sastheme"/>/images/MenuDownArrowBanner.gif" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/MenuDownArrowBanner.gif</xsl:attribute></img>
                                                </a>
                                                -->
                                                <!-- placeholder span, remove if customize uncommented -->
                                                <span>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
						<span class="SimpleMenuBarSeparator SimpleMenuBarSeparator_Banner_GlobalMenu_Look">|</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
                                                <!-- Comment out Options toolbar 
						<a id="globalMenuBar_2_anchor" href="#"><xsl:attribute name="title"><xsl:value-of select="$portalOptionsMenuTitle"/></xsl:attribute>
						<span>l:value-of select="$portalOptionsMenuTitle"/>/span>
						<img class="SimpleMenuBarSubMenuIndicator SimpleMenuBarSubMenuIndicator_Banner_GlobalMenu_Look" src="/$sastheme/themes/<xsl:value-of select="$sastheme"/>/images/MenuDownArrowBanner.gif" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/MenuDownArrowBanner.gif</xsl:attribute></img>

                                                -->
                                                <!-- placeholder span, remove if Options uncommened -->
                                                <span>&#160;&#160;&#160;&#160;&#160;&#160;&#160;</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
						<span class="SimpleMenuBarSeparator SimpleMenuBarSeparator_Banner_GlobalMenu_Look">|</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
                                                <!-- Comment out search menu
						<a id="globalMenuBar_4_anchor" href="#"><xsl:attribute name="title"><xsl:value-of select="$portalSearchMenuTitle"/></xsl:attribute>
						<span><xsl:value-of select="$portalSearchMenu"/></span></a>
                                                -->
                                                <!-- span placeholder, remove if Search uncommented -->
                                                <span>&#160;&#160;&#160;&#160;&#160;&#160;</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
						<span class="SimpleMenuBarSeparator SimpleMenuBarSeparator_Banner_GlobalMenu_Look">|</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
						<a id="globalMenuBar_6_anchor" href="/SASLogon/logout"><xsl:attribute name="title"><xsl:value-of select="$portalLogoffMenuTitle"/></xsl:attribute>
						<span><xsl:value-of select="$portalLogoffMenu"/></span></a>

                                                <!-- span placeholder, remove if Log Off menu uncommented -->
                                                <span>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
						<span class="SimpleMenuBarSeparator SimpleMenuBarSeparator_Banner_GlobalMenu_Look">|</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
                                                <!-- Comment out help menu item 
						<a id="globalMenuBar_8_anchor" href="#"><xsl:attribute name="title"><xsl:value-of select="$portalHelpMenuTitle"/></xsl:attribute>
						<span><xsl:value-of select="$portalHelpMenu"/></span>
						<img class="SimpleMenuBarSubMenuIndicator SimpleMenuBarSubMenuIndicator_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/MenuDownArrowBanner.gif</xsl:attribute></img>
						</a>
                                                -->
                                                <!-- span placeholder, remove if Help menu item uncommented -->
                                                <span>&#160;&#160;&#160;&#160;&#160;&#160;</span>
						<img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/spacer.gif</xsl:attribute></img>
	         			</td>
		         		</tr>
					</tbody>
         			</table>
			</span>
                        <a name="globalMenuBar_skipMenuBar"></a> 
			</td>
                        <td width="1%">&#160;</td>
			</tr>
		</tbody>
		</table>

		<table cellpadding="0" cellspacing="0" width="100%">
			<tbody>
						<tr>
			<td nowrap="" id="bantitle" class="banner_title"><xsl:value-of select="$portalTitle"/></td>
			<td id="banbullet" class="banner_bullet"></td>
			<td nowrap="" id="bantitle2" class="banner_secondaryTitle"></td>
			<td align="right" id="banlogo" class="banner_logo" width="100%"><img width="62" height="24" border="0" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/logo.gif</xsl:attribute></img>
                        </td>
			<td class="banner_logoPadding">&#160;</td>
			</tr>
			</tbody>
			</table>

</xsl:template>

<xsl:template name="genBanner">

<xsl:param name="includeTabs">0</xsl:param>

<table width="100%" cellpadding="0" cellspacing="0">
<tbody>
  <tr>
    <td valign="top">
    <a href="#skipBanner" title="Skip banner" tabindex="1"></a>
    <!-- Banner -->
    <div id="banner" class="banner_container"><xsl:attribute name="style">background-image:url(/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerBackground.gif</xsl:attribute>

         <xsl:call-template name="Banner"/>

                <a name="skipBanner"></a>
                <!-- Page Menus -->
                <a href="pageTabs_skipTabMenu"><xsl:attribute name="title"><xsl:value-of select="pageTabs_skipTabMenuTitle"/></xsl:attribute></a>

         <div id="tabs">
            <xsl:if test="$includeTabs=1">
               <xsl:call-template name="genTabList"/>
            </xsl:if>

         </div>

         <a name="pageTabs_skipTabMenu"></a>
         <table class="secondaryMenuTable" width="100%" cellspacing="0" cellpadding="0">
             <tbody><tr>
                    <td class="secondaryMenuRow" align="left" height="5"></td>
                   </tr>
             </tbody>
         </table>

    </div>

    </td>
</tr>
</tbody>
</table>

</xsl:template>

</xsl:stylesheet>
