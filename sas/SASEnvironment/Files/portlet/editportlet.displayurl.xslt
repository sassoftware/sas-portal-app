<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:param name="appLocEncoded"/>

<xsl:variable name="localizationDir">SASPortalApp/sas/SASEnvironment/Files/localization</xsl:variable>

<xsl:param name="localizationFile"><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:param>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Strings to be localized -->
<xsl:variable name="saveButton" select="$localeXml/string[@key='saveButton']/text()"/>
<xsl:variable name="cancelButton" select="$localeXml/string[@key='cancelButton']/text()"/>
<xsl:variable name="portletEditDisplayURLHeight" select="$localeXml/string[@key='portletEditDisplayURLHeight']/text()"/>

<xsl:variable name="portletEditDisplayURLUrl" select="$localeXml/string[@key='portletEditDisplayURLUrl']/text()"/>

<xsl:template match="/">

<xsl:variable name="portletId" select="GetMetadata/Metadata/PSPortlet/@Id"/>
<xsl:variable name="portletType" select="GetMetadata/Metadata/PSPortlet/@PortletType"/>

<xsl:variable name="portletHeight" select="GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_Height']/@DefaultValue"/>
<xsl:variable name="portletURL" select="GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_DisplayURL']/@DefaultValue"/>

<xsl:variable name="saveLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/savePortletContentsDisplayURL&amp;id=',$portletId,'&amp;portletType=',$portletType)"/>

<form method="post"><xsl:attribute name="action"><xsl:value-of select="$saveLink"/></xsl:attribute>

<xsl:variable name="portletHeight" select="GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_Height']/@DefaultValue"/>
<xsl:variable name="portletURL" select="GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_DisplayURL']/@DefaultValue"/>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataEntryBG">
<tbody>
<tr>
<td>
<table border="0" cellpadding="2" cellspacing="0">

 <tbody>
  <tr>
  <td colspan="3">&#160;</td>
 </tr>
 <tr>
  <td>&#160;</td>
  <td align="center">
        <table border="0">
         <tbody><tr>
          <td nowrap="">
            <xsl:value-of select="$portletEditDisplayURLUrl"/>:
          </td>
          <td>&#160;</td>
          <td class="celljustifyleft" nowrap="">
            <input type="text" name="portletURL" size="60"><xsl:attribute name="value"><xsl:value-of select="$portletURL"/></xsl:attribute></input>
          </td>
         </tr>
         <tr>
          <td nowrap="">
          </td>
         </tr><tr></tr>
         <tr>
          <td nowrap="">
            <xsl:value-of select="$portletEditDisplayURLHeight"/>:
          </td>
          <td>&#160;</td>
          <td class="celljustifyleft" nowrap="">
            <input type="text" id="height" name="portletHeight" size="4"><xsl:attribute name="value"><xsl:value-of select="$portletHeight"/></xsl:attribute></input>
          </td>
         </tr>
        </tbody></table>
  </td>
 </tr>
 <tr>
 <td>&#160;</td>
 </tr>
</tbody>

</table>

<table border="0" width="100%" cellspacing="0" cellpadding="6">

            <tbody><tr class="buttonBar">
            <td width="12">
            &#160;
            </td>
            <td>
                    <input class="button" type="submit" name="submit"><xsl:attribute name="value"><xsl:value-of select="$saveButton"/></xsl:attribute></input>
            </td>
            <td>
                    <input class="button" type="button" name="cancel" onclick="history.back()"><xsl:attribute name="value"><xsl:value-of select="$cancelButton"/></xsl:attribute></input>
            </td>
            <td width="100%">
            &#160;
            </td>
            </tr>
</tbody>
</table>
</td>
</tr>
</tbody></table>
</form>

</xsl:template>

</xsl:stylesheet>

