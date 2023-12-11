<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" encoding="UTF-8"/>

<xsl:param name="locale" select="en_us"/>

<xsl:variable name="localizationDir">SASPortalApp/sas/SASEnvironment/Files/localization</xsl:variable>

<xsl:param name="localizationFile"><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:param>

<xsl:param name="sastheme">default</xsl:param>
<xsl:variable name="sasthemeContextRoot">SASTheme_<xsl:value-of select="$sastheme"/></xsl:variable>

<xsl:param name="appLocEncoded"></xsl:param>
<xsl:param name="errorCode"/>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Strings to be localized -->

<!-- include shared files -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portal/genPortalBanner.xslt"/>

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  The main entry point

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->
<xsl:template match="/" name="main">

<html>

  <head>
    <meta charset="utf-8" http-equiv="X-UA-Compatible" content="IE=edge" />

    <script src="init.js?v=24"></script>
    <script>loadScripts();</script>

  </head>

  <body class="workarea">

  <xsl:call-template name="genErrorPageContent"/>

  </body>
</html>

</xsl:template>

<xsl:template name="genTabList">

   <table id="pagetabs_Table" class="BannerTabMenuTable" cellspacing="0" cellpadding="0" border="0">
   <tbody>
   <tr>

          <!-- Build a dummy tab so that something displays -->
          <xsl:variable name="dummyTabName"><xsl:value-of select="$localeXml/string[@key='ErrorLabel']/text()"/></xsl:variable>

          <xsl:variable name="dummyTabId">0</xsl:variable>
          <xsl:variable name="dummyContentId">content_<xsl:value-of select="$dummyTabId"/></xsl:variable>

          <td id="0_TabCell" class="BannerTabMenuActiveTabCell">

              <table border="0" cellspacing="0" cellpadding="0" id="0" class="buttonContainer default-tab"><xsl:attribute name="onclick">showTab(event, '<xsl:value-of select="$dummyContentId"/>')</xsl:attribute>
                <tbody>
                   <tr>
                                   <xsl:call-template name="buildTab">
                                      <xsl:with-param name="tabId"><xsl:value-of select="$dummyTabId"/></xsl:with-param>
                                      <xsl:with-param name="tabName"><xsl:value-of select="$dummyTabName"/></xsl:with-param>
                                      <xsl:with-param name="tabPosition"><xsl:value-of select="1"/></xsl:with-param>
                                   </xsl:call-template>
                   </tr>
                </tbody>
              </table>
          </td>

   </tr>

   </tbody>
   </table>

</xsl:template>

<xsl:template name="genErrorPageContent">

	<!-- pass back the theme to use -->

	<div id="sastheme" style="display: none"><xsl:value-of select="$sastheme"/></div>

	<xsl:call-template name="genBanner">
	  <xsl:with-param name="includeTabs">1</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="genErrorPage"/>

</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  Generate the error response

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->
<xsl:template name="genErrorPage">

<xsl:message>in genErrorPage</xsl:message>

<div id="pages">

           <div class="tabcontent" id="content_0">
           <!-- table cellpadding="2" cellspacing="0" width="100%" class="portletTableBorder" -->
           <table cellpadding="2" cellspacing="0" width="100%">

                <tr valign="top">
                <td width="100%">

                   <xsl:variable name="errorMessage">

                   <xsl:choose>
                     <xsl:when test="$errorCode=-1001">
                       <xsl:value-of select="$localeXml/string[@key='noUserPermissionTree']/text()"/>
                       </xsl:when>
                     <xsl:when test="$errorCode=-1002">
                       <xsl:value-of select="$localeXml/string[@key='noNewUserInit']/text()"/>
                       </xsl:when>
                     <xsl:otherwise>
                       <xsl:value-of select="$localeXml/string[@key='genericError']/text()"/>
                       </xsl:otherwise>
                       
                   </xsl:choose>

                   </xsl:variable>

                   <b><xsl:value-of select="$errorMessage"/></b>
                </td>
                </tr>

           </table>

           </div>
</div>

</xsl:template>

</xsl:stylesheet>

