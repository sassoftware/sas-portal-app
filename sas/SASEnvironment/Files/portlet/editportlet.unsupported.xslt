<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:param name="appLocEncoded"/>

<xsl:variable name="localizationDir">SASPortalApp/sas/SASEnvironment/Files/localization</xsl:variable>

<xsl:param name="localizationFile"><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:param>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Strings to be localized -->
<xsl:variable name="cancelButton" select="$localeXml/string[@key='cancelButton']/text()"/>
<xsl:variable name="portletEditNotSupported" select="$localeXml/string[@key='portletEditNotSupported']/text()"/>

<xsl:template match="/">

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="dataEntryBG">
<tbody>
<tr>
<td>
<p><xsl:value-of select="$portletEditNotSupported"/></p>

<table border="0" width="100%" cellspacing="0" cellpadding="6">

        <tbody><tr class="buttonBar">
            <td width="12">
            &#160;
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
</tbody>
</table>

</xsl:template>

</xsl:stylesheet>

