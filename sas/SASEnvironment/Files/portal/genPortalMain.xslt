<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" encoding="UTF-8"/>

<xsl:param name="sastheme">SASTheme_default</xsl:param>
<xsl:param name="appLocEncoded"></xsl:param>

<!-- Strings to be localized -->

<xsl:param name="portalTitle">SAS &#174; Portal</xsl:param>

<xsl:param name="globalMenuBar_skipMenuBar">Skip Menu Bar</xsl:param>
<xsl:param name="portalCustomizationMenu">Customize</xsl:param>
<xsl:param name="portalCustomizationMenuTitle">Select to display the menu for portal customization</xsl:param>
<xsl:param name="portalOptionsMenu">Options</xsl:param>
<xsl:param name="portalOptionsMenuTitle">Select to display the options menu.</xsl:param>

<xsl:param name="portalSearchMenu">Search</xsl:param>
<xsl:param name="portalSearchMenuTitle">Select to go to the portal search page.</xsl:param>

<xsl:param name="portalLogoffMenu">Logoff</xsl:param>
<xsl:param name="portalLogoffMenuTitle">Log Off</xsl:param>

<xsl:param name="portalHelpMenu">Help</xsl:param>
<xsl:param name="portalHelpMenuTitle">Select to display the help menu.</xsl:param>

<xsl:param name="pageTabs_skipTabMenuTitle">Skip Tab Menu</xsl:param>

<xsl:param name="portletEditContent">Edit Content</xsl:param>

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  The main entry point

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->

<xsl:template match="/" name="main">
 
<!-- pass back the theme to use -->

<div id="sastheme" style="display: none"><xsl:value-of select="$sastheme"/></div>

<table width="100%" cellpadding="0" cellspacing="0">
<tbody>
  <tr>
    <td valign="top">
    <a href="#skipBanner" title="Skip banner" tabindex="1"></a>
    <!-- Banner -->
    <div id="banner" class="banner_container"><xsl:attribute name="style">background-image:url(/<xsl:value-of select="$sastheme"/>/themes/default/images/BannerBackground.gif</xsl:attribute>

         <xsl:call-template name="Banner"/>

         <div id="tabs">

            <xsl:call-template name="genTabList"/>

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

<xsl:call-template name="genTabContent"/>
    
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
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
						<!--  Comment out Customize toolbar for now
						<a id="globalMenuBar_0_anchor" href="#"><xsl:attribute name="title"><xsl:value-of select="$portalCustomizationMenuTitle"/></xsl:attribute>
                                                <span><xsl:value-of select="$portalCustomizationMenu"/></span>
						<img class="SimpleMenuBarSubMenuIndicator SimpleMenuBarSubMenuIndicator_Banner_GlobalMenu_Look" src="/$sastheme/themes/default/images/MenuDownArrowBanner.gif" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/MenuDownArrowBanner.gif</xsl:attribute></img>
                                                </a>
                                                -->
                                                <!-- placeholder span, remove if customize uncommented -->
                                                <span>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
						<span class="SimpleMenuBarSeparator SimpleMenuBarSeparator_Banner_GlobalMenu_Look">|</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
                                                <!-- Comment out Options toolbar 
						<a id="globalMenuBar_2_anchor" href="#"><xsl:attribute name="title"><xsl:value-of select="$portalOptionsMenuTitle"/></xsl:attribute>
						<span>l:value-of select="$portalOptionsMenuTitle"/>/span>
						<img class="SimpleMenuBarSubMenuIndicator SimpleMenuBarSubMenuIndicator_Banner_GlobalMenu_Look" src="/$sastheme/themes/default/images/MenuDownArrowBanner.gif" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/MenuDownArrowBanner.gif</xsl:attribute></img>

                                                -->
                                                <!-- placeholder span, remove if Options uncommened -->
                                                <span>&#160;&#160;&#160;&#160;&#160;&#160;&#160;</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
						<span class="SimpleMenuBarSeparator SimpleMenuBarSeparator_Banner_GlobalMenu_Look">|</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
                                                <!-- Comment out search menu
						<a id="globalMenuBar_4_anchor" href="#"><xsl:attribute name="title"><xsl:value-of select="$portalSearchMenuTitle"/></xsl:attribute>
						<span><xsl:value-of select="$portalSearchMenu"/></span></a>
                                                -->
                                                <!-- span placeholder, remove if Search uncommented -->
                                                <span>&#160;&#160;&#160;&#160;&#160;&#160;</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
						<span class="SimpleMenuBarSeparator SimpleMenuBarSeparator_Banner_GlobalMenu_Look">|</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
                                                <!--  Comment out log off menu item
						<a id="globalMenuBar_6_anchor" href="#"><xsl:attribute name="title"><xsl:value-of select="$portalLogoffMenuTitle"/></xsl:attribute>
						<span><xsl:value-of select="$portalLogoffMenu"/></span></a>
                                                -->

                                                <!-- span placeholder, remove if Log Off menu uncommented -->
                                                <span>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
						<span class="SimpleMenuBarSeparator SimpleMenuBarSeparator_Banner_GlobalMenu_Look">|</span>
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
					</td>
					<td style="white-space: nowrap;" class="SimpleMenuBarItem SimpleMenuBarItem_Banner_GlobalMenu_Look">
                                                <img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
                                                <!-- Comment out help menu item 
						<a id="globalMenuBar_8_anchor" href="#"><xsl:attribute name="title"><xsl:value-of select="$portalHelpMenuTitle"/></xsl:attribute>
						<span><xsl:value-of select="$portalHelpMenu"/></span>
						<img class="SimpleMenuBarSubMenuIndicator SimpleMenuBarSubMenuIndicator_Banner_GlobalMenu_Look" src="/$sastheme/themes/default/images/MenuDownArrowBanner.gif" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/MenuDownArrowBanner.gif</xsl:attribute></img>
						</a>
                                                -->
                                                <!-- span placeholder, remove if Help menu item uncommented -->
                                                <span>&#160;&#160;&#160;&#160;&#160;&#160;</span>
						<img class="SimpleMenuBarItemSpacer SimpleMenuBarItemSpacer_Banner_GlobalMenu_Look" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/spacer.gif</xsl:attribute></img>
	         			</td>
		         		</tr>
					</tbody>
         			</table>
			</span>
			</td>
			</tr>
		</tbody>
		</table>

		<table cellpadding="0" cellspacing="0" width="100%">
			<tbody>
						<tr>
			<td nowrap="" id="bantitle" class="banner_title"><xsl:value-of select="$portalTitle"/></td>
			<td id="banbullet" class="banner_bullet"></td>
			<td nowrap="" id="bantitle2" class="banner_secondaryTitle"></td>
			<td align="right" id="banlogo" class="banner_logo" width="100%"><img width="62" height="24" border="0" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sastheme"/>/themes/default/images/logo.gif</xsl:attribute></img>
                        </td>
			<td class="banner_logoPadding">&#160;</td>
			</tr>
			</tbody>
			</table>
		<a name="skipBanner"></a>
		<!-- Page Menus -->
		<a href="pageTabs_skipTabMenu"><xsl:attribute name="title"><xsl:value-of select="pageTabs_skipTabMenuTitle"/></xsl:attribute></a> 

</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  This section of the templates is for generating the list of tabs.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->

<xsl:template name="genTabList">

   <!-- Loop over all the tabs on the page and create the tab structure -->
   <table id="pagetabs_Table" class="BannerTabMenuTable" cellspacing="0" cellpadding="0" border="0">
   <tbody>
   <tr>

   <xsl:for-each select="GetMetadataObjects/Objects/Group/Members/PSPortalPage">

           <td  class="BannerTabMenuTabCell portalBannerTabMenuTabCell" style="vertical-align: bottom">
                <button class="tab-button BannerTabButtonCenter" style="border-bottom: none">
                      <xsl:attribute name="onclick">showTab(event, '<xsl:value-of select="@Id"/>')</xsl:attribute>
                      <xsl:if test="position() = 1">
				           <xsl:attribute name="id">default-tab</xsl:attribute>
      				  </xsl:if>
                <span><xsl:value-of select="@Name"/></span></button>
           </td>

   </xsl:for-each>
   
   </tr>
   
   </tbody>
   </table>
 
</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    

  This section of the templates is for generating the actual tab content for each of the portal pages.
  
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->

<xsl:template name="genTabContent">

     <div id="pages">
       <xsl:apply-templates select="GetMetadataObjects/Objects/Group/Members/PSPortalPage"/>
     </div>

</xsl:template>

<!-- the default template if nothing else matches -->

<xsl:template match="*">

<p>hit default template</p>

</xsl:template>

<xsl:template match="Document">

<a><xsl:attribute name="href"><xsl:value-of select="@URI"/></xsl:attribute><xsl:value-of select="@Name"/></a>
  
</xsl:template>

<!-- Template to handle a reference to a Report (typically in bookmarks)-->

<xsl:template match="Transformation[@TransformRole='Report']">

<!-- Unfortunately, to display a report, you need the entire path to it, thus it is required to navigate the parent tree
     structure.
-->

   <xsl:variable name="reportSBIPURI">
        <xsl:text>SBIP://METASERVER</xsl:text>
		<xsl:for-each select="Trees//Tree">
			<xsl:sort select="position()" order="descending"/>
			<xsl:text>/</xsl:text><xsl:value-of select="@Name"/>
		</xsl:for-each>
		<xsl:text>/</xsl:text><xsl:value-of select="@Name"/>
   </xsl:variable>

    <xsl:call-template name="reportLink">
	    <xsl:with-param name="reportSBIPURI" select="$reportSBIPURI"/>
	</xsl:call-template>

</xsl:template>

<!-- there are several types of "collection" portlets, ex. collection, bookmarks, etc. 
     Each of these seem to store content in the same way, so have the common processing here
	 -->
<xsl:template name="processCollection">

      <xsl:variable name="numGroups">
	       <xsl:value-of select="count(Groups/Group)"/>
	   </xsl:variable>

	   <!-- The first member in the group seems to be a link back to itself, so skip that entry -->
	   <xsl:for-each select="Groups/Group">
	   
	   	  <xsl:variable name="numMembers">
	         <xsl:value-of select="count(Members/*)"/>
	      </xsl:variable>
	      
	      <xsl:for-each select="Members/*">
	             <xsl:if test="position() > 1">
	             <tr>
	             <td class="portletEntry" valign="top">
	             <xsl:apply-templates  select="."/>
	             </td>
	             </tr>
	             </xsl:if>
	         </xsl:for-each>
	         
	      <!-- If the portlet didn't have any members, add a few blank rows -->
	      
	      <xsl:if test="$numMembers = 1">
			 <xsl:call-template name="emptyPortlet"/>	         	      
	      </xsl:if>
	      
	   </xsl:for-each>

	      <xsl:if test="$numGroups = 0">
	         	      
			  <xsl:call-template name="emptyPortlet"/>

	      </xsl:if>	

</xsl:template>

<xsl:template name="collectionPortlet">

    <!-- Collection portlet, build a list of the links -->

    <!-- not yet convinced there won't be some differences in how the different collections are processed so keep this redirection template here-->

    <xsl:call-template name="processCollection"/>

</xsl:template>

<xsl:template name="bookmarksPortlet">

    <!-- Bookmark portlet, build a list of the links -->

    <!-- not yet convinced there won't be some differences in how the different collections are processed so keep this redirection template here-->

    <xsl:call-template name="processCollection"/>

</xsl:template>

<!-- Display URL portlet, display the referenced URL -->
<xsl:template name="displayURLPortlet">

   <!-- Get the property that has the URI in it -->
   <xsl:variable name="displayURI">

      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_DisplayURL']/@DefaultValue"/>

   </xsl:variable>

   <xsl:variable name="iframeHeight">

      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_Height']/@DefaultValue"/>

   </xsl:variable>


    <!-- If a URI is defined, show it, otherwise just render an empty portlet -->
	<xsl:choose >

    	<xsl:when test="$displayURI != ''">
   	        <tr>
	        <td class="portletEntry" valign="top">
			<iframe style="overflow: auto;width: 100%" frameborder="0" >
	        <xsl:attribute name="data-src"><xsl:value-of select="$displayURI"/></xsl:attribute>
			<xsl:if test="'$iframeHeight' != '' and $iframeHeight != 0">
                    <xsl:attribute name="height"><xsl:value-of select="$iframeHeight"/></xsl:attribute>
			</xsl:if>

			</iframe>
	        </td>
	        </tr>
			</xsl:when>
		<xsl:otherwise>
		   <xsl:call-template name="emptyPortlet"/>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template name="SASStoredProcessPortlet">

   <!-- Get the Stored Prcess reference and display it as if it was just a call to a url -->

   <xsl:variable name="stpSBIPURI">
      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='selectedFolderItem']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
	</xsl:variable>
   <xsl:variable name="stpPortletHeight">
      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='portletHeight']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
	</xsl:variable>

   <xsl:choose>
     <xsl:when test="$stpSBIPURI != ''">
         <tr>
	        <td class="portletEntry" valign="top">
			
			<xsl:variable name="stpProgram"><xsl:value-of select="encode-for-uri(substring-after($stpSBIPURI,'SBIP://METASERVER'))"/></xsl:variable>
			<!-- NOTE: Can't figure out how to pass an & in the value of an attribute, thus not including the _action parameter for now
			<xsl:variable name="stpURI"><xsl:text>/SASStoredProcess/do?_action=form,properties,execute,nobanner,newwindow&_program=</xsl:text><xsl:value-of select="$stpProgram"/></xsl:variable>
			-->
			
			<xsl:variable name="stpURI"><xsl:text>/SASStoredProcess/do?_program=</xsl:text><xsl:value-of select="$stpProgram"/></xsl:variable>
			<iframe style="overflow: auto;width: 100%" frameborder="0" >
            <xsl:attribute name="data-src"><xsl:value-of select="$stpURI"/></xsl:attribute>

			<xsl:choose>
			<xsl:when test="$stpPortletHeight != '' and $stpPortletHeight != 0">
	            <xsl:attribute name="height"><xsl:value-of select="$stpPortletHeight"/></xsl:attribute>
            </xsl:when>

			<xsl:otherwise>
			    <!-- set a default height -->
                 <xsl:attribute name="height">100</xsl:attribute>
			</xsl:otherwise>
			</xsl:choose>

            </iframe>

	        </td>
	        </tr>

	 </xsl:when>
	 <xsl:otherwise>
		   <xsl:call-template name="emptyPortlet"/>
	 </xsl:otherwise>

	 </xsl:choose>

</xsl:template>

<xsl:template name="reportLink">

  <xsl:param name = "reportSBIPURI" />

         <tr>
	        <td class="portletEntry" valign="top">
			
			<xsl:variable name="wrsProgram"><xsl:value-of select="encode-for-uri($reportSBIPURI)"/></xsl:variable>
			<xsl:variable name="wrsPath"><xsl:value-of select="substring-after($reportSBIPURI,'SBIP://METASERVER')"/></xsl:variable>

			<xsl:variable name="wrsURI"><xsl:text>/SASWebReportStudio/openRVUrl.do?rsRID=</xsl:text><xsl:value-of select="$wrsProgram"/></xsl:variable>

			<a><xsl:attribute name="href"><xsl:value-of select="$wrsURI"/></xsl:attribute><xsl:value-of select="$wrsPath"/></a>

			<!--
			<iframe style="overflow: auto;width: 100%" frameborder="0" >
            <xsl:attribute name="data-src"><xsl:value-of select="$wrsURI"/></xsl:attribute>
            </iframe>
			-->
			
	        </td>
	        </tr>

</xsl:template>

<xsl:template name="processReportPortlet">
  <xsl:param name = "reportSBIPURI" />

    <xsl:choose>
     <xsl:when test="'$reportSBIPURI' != ''">

	    <xsl:call-template name="reportLink">
		    <xsl:with-param name="reportSBIPURI" select="$reportSBIPURI"/>
		</xsl:call-template>


	 </xsl:when>
	 <xsl:otherwise>
		   <xsl:call-template name="emptyPortlet"/>
	 </xsl:otherwise>

   </xsl:choose>
</xsl:template>

<xsl:template name="ReportLocalPortlet">

   <!-- Get the Report reference.  At least for now, just make it a link that can be launched.  Ultimately, it would be nice if we could 
        show the report in place, but can't find a way to do that yet.
    -->

   <xsl:variable name="wrsSBIPURI">
      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='SELECTED_REPORT']/@DefaultValue"/>
	</xsl:variable>
    
	<xsl:call-template name="processReportPortlet">
	   <xsl:with-param name="reportSBIPURI" select="$wrsSBIPURI"/>
	</xsl:call-template>
 
</xsl:template>

<xsl:template name="SASReportPortlet">

   <!-- Get the Report reference.  At least for now, just make it a link that can be launched.  Ultimately, it would be nice if we could 
        show the report in place, but can't find a way to do that yet.
    -->

   <xsl:variable name="wrsSBIPURI">
      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='selectedFolderItem']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
	</xsl:variable>

 	<xsl:call-template name="processReportPortlet">
	   <xsl:with-param name="reportSBIPURI" select="$wrsSBIPURI"/>
	</xsl:call-template>
   
</xsl:template>

<xsl:template name="emptyPortlet">

	             <tr>
	             <td class="portletEntry" valign="top">
	             <br/>
	             </td>
	             </tr>
	      
	             <tr>
	             <td class="portletEntry" valign="top">
	             <br/>
	             </td>
	             </tr>


</xsl:template>

<xsl:template match="PSPortlet">

   <xsl:variable select="@Name" name="portletName"/>

   <!--  It looks like when there isn't a portlet in a given cell in the layout, a place holder portlet
         is put there.  Ignore those.
     -->
   <xsl:choose>     

	   <xsl:when test="@Name = 'PlaceHolder'">
	    <!-- Placeholder porlets seem to be put in place to occupy the space in the layout -->
	    <!-- So that the formatting comes out correctly, need to build the table but hide it-->

		   <table cellpadding="2" cellspacing="0" width="100%" style="border:none">
   			<th align="left" style="border:none;background:transparent;color:transparent">
	   			<xsl:value-of select="$portletName"/>
   			</th>
    		<xsl:call-template name="emptyPortlet"/>
			</table>

		</xsl:when>
		<xsl:otherwise>

		   <!-- Non-placeholder portlets -->
           <xsl:variable name="portletType" select="@portletType"/>
		   <xsl:variable name="portletId" select="@Id"/>

		   <table cellpadding="2" cellspacing="0" width="100%" class="portletTableBorder">
		   <tr>
   			<th align="left" class="tableHeader portletTableHeader">
	   			<xsl:value-of select="$portletName"/>
   			</th>
			<th align="right" class="portletTableHeaderRight">
	   				<table cellpadding="0" cellspacing="0" border="0">
                        <tbody>
							<tr>
                                <td nowrap="" valign="middle"><i><font size="1"> </font></i></td>
                                <td></td>
                                <td nowrap="" valign="middle">
								<img src="images/PortletPipe.gif" alt="" width="1" height="15" valign="middle" border="0"/>
								</td>
								<td nowrap="" valign="middle">
								<!--
								<xsl:variable name="editLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services%2FeditPortletContents&amp;id=',$portletId,'&amp;portletType=',$portletType)"/>
                                                                -->
								<xsl:variable name="editLink" select="concat('editPortletContents.html?id=',$portletId,'&amp;portletType=',$portletType)"/>

										<a target="_self" onclick="editPortlet"><xsl:attribute name="href"><xsl:value-of select="$editLink"/></xsl:attribute>
                                        <img src="images/PortletNote.gif" valign="middle" border="0"><xsl:attribute name="alt"><xsl:value-of select="$portletEditContent"/></xsl:attribute><xsl:attribute name="title"><xsl:value-of select="$portletEditContent"/></xsl:attribute></img>
                                        </a>
								</td>
							</tr>
                        </tbody>
					</table>
            </th>
            </tr>
			<xsl:choose>

		  		<xsl:when test="@portletType='Collection'">
    	       	<xsl:call-template name="collectionPortlet"/>
      			</xsl:when>
	  			<xsl:when test="@portletType='DisplayURL'">
           			<xsl:call-template name="displayURLPortlet"/>
    			</xsl:when>
	  			<xsl:when test="@portletType='SASStoredProcess'">
           			<xsl:call-template name="SASStoredProcessPortlet"/>
    			</xsl:when>
	  			<xsl:when test="@portletType='SASReportPortlet'">
           			<xsl:call-template name="SASReportPortlet"/>
    			</xsl:when>
	  			<xsl:when test="@portletType='Report'">
           			<xsl:call-template name="ReportLocalPortlet"/>
    			</xsl:when>
	  			<xsl:when test="@portletType='Bookmarks'">
           			<xsl:call-template name="bookmarksPortlet"/>
    			</xsl:when>

	   			<xsl:otherwise>
		    		<!-- currently unsupported portlet type, render an empty portlet -->
		    		<xsl:call-template name="emptyPortlet"/>
		  		</xsl:otherwise>
			</xsl:choose>

	   		</table>
	   </xsl:otherwise>

	</xsl:choose>

</xsl:template>

<!--  Render the Column of the page -->

<xsl:template match="PSColumnLayoutComponent">

   <xsl:apply-templates select="Portlets/PSPortlet"/>
   
</xsl:template>

<!-- Render the page -->

<xsl:template match="PSPortalPage">

	   <div class="tabcontent"><xsl:attribute name="id"><xsl:value-of select="@Id"/></xsl:attribute>
	   
	   <!--  Get what type of layout it has, 1, 2 or 3 columns -->
	   
	   <xsl:variable name="numColumns">
	      <xsl:value-of select="count(LayoutComponents/PSColumnLayoutComponent)"/>
	   </xsl:variable>
	
	   <!-- table cellpadding="2" cellspacing="0" width="100%" class="portletTableBorder" -->
	   <table cellpadding="2" cellspacing="0" width="100%">
	   
	   <xsl:choose>
	      <xsl:when test="$numColumns = 1">
	        <tr valign="top">
	        <td><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[1]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[1]"/>
	        </td>
	        </tr>
	      </xsl:when>
	      <xsl:when test="$numColumns = 2">
	        <tr valign="top">
	        <td align="top"><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[1]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[1]"/></td>
	        <td alight="top"><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[2]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[2]"/></td>
	        </tr>
	      </xsl:when>
	      <xsl:when test="$numColumns = 3">
	        <tr valign="top">
   	        <td><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[1]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[1]"/></td>
	        <td><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[2]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[2]"/></td>
	        <td><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[3]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[3]"/></td>
	        </tr>
	      </xsl:when>
	      <xsl:otherwise>
	        <p>unknown columns</p>
	      </xsl:otherwise>
	
	   </xsl:choose>
	   
	   </table>
	   
	   </div>
</xsl:template>

</xsl:stylesheet>
