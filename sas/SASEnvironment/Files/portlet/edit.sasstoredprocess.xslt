<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

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

<xsl:variable name="saveButton" select="$localeXml/string[@key='saveButton']/text()"/>
<xsl:variable name="cancelButton" select="$localeXml/string[@key='cancelButton']/text()"/>
<xsl:variable name="portletEditSASStoredProcessHeight" select="$localeXml/string[@key='portletEditSASStoredProcessHeight']/text()"/>

<xsl:variable name="portletEditSASStoredProcessUri" select="$localeXml/string[@key='portletEditSASStoredProcessUri']/text()"/>
<xsl:variable name="portletEditCollectionShowFormLabel" select="$localeXml/string[@key='portletEditCollectionShowFormLabel']/text()"/>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/form.functions.xslt"/>

<xsl:template match="/">

<xsl:call-template name="commonFormFunctions"/>
<xsl:call-template name="thisPageScripts"/>


<xsl:variable name="portletObject" select="$metadataContext/GetMetadata/Metadata/PSPortlet"/>
<xsl:variable name="portletId" select="$portletObject/@Id"/>
<xsl:variable name="portletType" select="$portletObject/@PortletType"/>
<xsl:variable name="parentTreeId" select="$portletObject/Trees/Tree/@Id"/>

<!-- Properties -->

<xsl:variable name="configPropertySet" select="$portletObject/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']"/>
<xsl:variable name="configPropertySetId" select="$configPropertySet/@Id"/>

<xsl:variable name="configProperties" select="$configPropertySet/SetProperties"/>
<xsl:variable name="configPropertySets" select="$configPropertySet/PropertySets"/>

<xsl:variable name="portletHeight" select="$configPropertySets/PropertySet[@Name='portletHeight']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>

<xsl:variable name="showForm" select="$configProperties/Property[@Name='show-form']/@DefaultValue"/>

<!--  The URI we store has the prefix SBIP://METASERVER on it.  No need to force the user to enter that, just have them enter the full path -->

<xsl:variable name="portletURI" select="$configPropertySets/PropertySet[@Name='selectedFolderItem']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
<xsl:variable name="portletPath" select="substring-after($portletURI,'SBIP://METASERVER')"/>

<xsl:variable name="portletURIFolder" select="$configPropertySets/PropertySet[@Name='selectedFolder']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
<xsl:variable name="portletPathFolder" select="substring-after($portletURIFolder,'SBIP://METASERVER')"/>

<xsl:variable name="portletPrompts" select="$configPropertySets/PropertySet[@Name='promptNames']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>

<xsl:variable name="saveLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/updateItem&amp;id=',$portletId,'&amp;portletType=',$portletType,'&amp;type=PSPortlet')"/>

<!--  NOTE: We set up a hidden formResponse iframe to capture the result so that we can either display the results (if debugging) or simply cause a "go back" to happen after the form is submitted (by using the iframe onload function).  The event handler to handle this is in the CommonFormFunctions template -->

<form method="post" target="formResponse">
<xsl:attribute name="action"><xsl:value-of select="$saveLink"/></xsl:attribute>

    <xsl:if test="$parentTreeId">
       <input type="hidden" name="parentTreeId"><xsl:attribute name="value"><xsl:value-of select="$parentTreeId"/></xsl:attribute></input>
    </xsl:if>

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
            <xsl:value-of select="$portletEditSASStoredProcessUri"/>:
          </td>
          <td>&#160;</td>
          <td class="celljustifyleft" nowrap="">
            <input type="text" name="portletPath" size="60"><xsl:attribute name="value"><xsl:value-of select="$portletPath"/></xsl:attribute></input>
          </td>
         </tr>
         <tr>
          <td nowrap="">
          </td>
         </tr><tr></tr>
         <tr>
          <td nowrap="">
            <xsl:value-of select="$portletEditSASStoredProcessHeight"/>:
          </td>
          <td>&#160;</td>
          <td class="celljustifyleft" nowrap="">
            <input type="text" id="height" name="portletHeight" size="4"><xsl:attribute name="value"><xsl:value-of select="$portletHeight"/></xsl:attribute></input>
          </td>
         </tr>
        <tr>
            <td nowrap=""><xsl:value-of select="$portletEditCollectionShowFormLabel"/>:
            </td>
            <td>&#160;</td>
            <td class="celljustifyleft" nowrap="nowrap">
                <input type="checkbox" name="showForm" id="showForm" onclick="setBooleanHidden('showForm');hasChanged=true;">
                  <xsl:choose>
                  <xsl:when test="$showForm = 'true'">
                      <xsl:attribute name="checked">checked</xsl:attribute>
                      <xsl:attribute name="value">true</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:attribute name="value">false</xsl:attribute>
                  </xsl:otherwise>
                  </xsl:choose>

                </input>
                <input type="hidden" name="selectedshowForm" id="selectedshowForm">
                  <xsl:choose>
                  <xsl:when test="$showForm = 'true'">
                      <xsl:attribute name="value">1</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:attribute name="value">0</xsl:attribute>
                  </xsl:otherwise>
                  </xsl:choose>
               
                </input>
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

<!-- This iframe is here to capture the response from submitting the form -->
      
      <iframe id="formResponse" name="formResponse" style="display:none" width="100%">
      
      </iframe>

</xsl:template>

<xsl:template name="thisPageScripts">

 <script>
    var hasChanged=false;

    function setBooleanHidden(fldName) {
        var checkboxField = document.getElementById(fldName);
        var hiddenField = document.getElementById("selected" + fldName);
        if (checkboxField.checked) {
            hiddenField.value = "1";
        } else {
            hiddenField.value = "0";
        }
    }

  </script>

</xsl:template>

</xsl:stylesheet>

