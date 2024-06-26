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

<!-- Strings to be localized -->
<xsl:variable name="okButton" select="$localeXml/string[@key='okButton']/text()"/>
<xsl:variable name="cancelButton" select="$localeXml/string[@key='cancelButton']/text()"/>

<xsl:variable name="portletEditItemName" select="$localeXml/string[@key='portletEditItemName']/text()"/>
<xsl:variable name="portletEditItemDescription" select="$localeXml/string[@key='portletEditItemDescription']/text()"/>
<xsl:variable name="portletEditItemURL" select="$localeXml/string[@key='portletEditItemURL']/text()"/>
<xsl:variable name="portletEditItemKeywords" select="$localeXml/string[@key='portletEditItemKeywords']/text()"/>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/form.functions.xslt"/>

<xsl:template match="/">

<xsl:call-template name="commonFormFunctions"/>

<xsl:variable name="mainObject" select="$metadataContext/GetMetadata/Metadata/Document"/>
<xsl:variable name="objectId" select="$mainObject/@Id"/>
<xsl:variable name="objectType" select="name($mainObject)"/>

<xsl:variable name="objectName" select="$mainObject/@Name"/>
<xsl:variable name="objectDesc" select="$mainObject/@Desc"/>
<xsl:variable name="objectURI" select="$mainObject/@URI"/>

<xsl:variable name="saveLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/updateItem')"/>

<!--  NOTE: We set up a hidden formResponse iframe to capture the result so that we can either display the results (if debugging) or simply cause a "go back" to happen after the form is submitted (by using the iframe onload function).  The event handler to handle this is in the CommonFormFunctions template -->

<form method="post" target="formResponse">
<xsl:attribute name="action"><xsl:value-of select="$saveLink"/></xsl:attribute>

    <input type="hidden" name="Id"><xsl:attribute name="value"><xsl:value-of select="$objectId"/></xsl:attribute></input>
    <input type="hidden" name="Type"><xsl:attribute name="value"><xsl:value-of select="$objectType"/></xsl:attribute></input>

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
     <td align="center" valign="center" colspan="3" width="100%">
     <div id="portal_message"></div>
     </td>

 </tr>
 <tr>
  <td>&#160;</td>
  <td align="center">
        <table border="0">
         <tbody><tr>
          <td nowrap="">
            <xsl:value-of select="$portletEditItemName"/>:
          </td>
          <td>&#160;</td>
          <td class="celljustifyleft" nowrap="">
            <input type="text" name="name" size="60" maxlength="60"><xsl:attribute name="value"><xsl:value-of select="$objectName"/></xsl:attribute></input>
          </td>
         </tr>
         <tr>
          <td nowrap="">
          </td>
         </tr>
         <tr></tr>
         <tr>
          <td nowrap="">
            <xsl:value-of select="$portletEditItemDescription"/>:
          </td>
          <td>&#160;</td>
          <td class="celljustifyleft" nowrap="">
            <input type="text" id="height" name="desc" size="60" maxlength="200"><xsl:attribute name="value"><xsl:value-of select="$objectDesc"/></xsl:attribute></input>
          </td>
         </tr>
         <tr>
          <td nowrap="">
          </td>
         </tr>

         <tr></tr>
         <tr>
          <td nowrap="">
            <xsl:value-of select="$portletEditItemURL"/>:
          </td>
          <td>&#160;</td>
          <td class="celljustifyleft" nowrap="">
            <input type="text" id="height" name="url" size="60" maxlength="1024"><xsl:attribute name="value"><xsl:value-of select="$objectURI"/></xsl:attribute></input>
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
                    <input class="button" type="submit" name="submit"  onclick='return submitDisableAllForms();'><xsl:attribute name="value"><xsl:value-of select="$okButton"/></xsl:attribute></input>
            </td>
            <td>
                    <input class="button" type="button" name="cancel" onclick='if (submitDisableAllForms()) history.go(-1); else return false;'><xsl:attribute name="value"><xsl:value-of select="$cancelButton"/></xsl:attribute></input>
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

  <!-- This iframe is here to capture the response from submitting the form -->
  
  <iframe id="formResponse" name="formResponse" style="display:none" width="100%">
  
  </iframe>

</xsl:template>

</xsl:stylesheet>

