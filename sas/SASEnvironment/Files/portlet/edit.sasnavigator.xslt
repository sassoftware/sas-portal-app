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
<xsl:variable name="portletEditNavigatorFolder" select="$localeXml/string[@key='portletEditNavigatorFolder']/text()"/>
<xsl:variable name="portletEditNavigatorFolderRequired" select="$localeXml/string[@key='portletEditNavigatorFolderRequired']/text()"/>
<xsl:variable name="sasnavigatorPathCheckbox" select="$localeXml/string[@key='sasnavigatorPathCheckbox']/text()"/>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/form.functions.xslt"/>

<!-- Global Variables -->

<xsl:variable name="portletObject" select="$metadataContext/GetMetadata/Metadata/PSPortlet"/>
<xsl:variable name="portletId" select="$portletObject/@Id"/>
<xsl:variable name="portletType" select="$portletObject/@PortletType"/>
<xsl:variable name="parentTreeId" select="$portletObject/Trees/Tree/@Id"/>


<xsl:template match="/">

<xsl:call-template name="commonFormFunctions"/>
<xsl:call-template name="thisPageScripts"/>

<!-- Properties -->

<xsl:variable name="configPropertySet" select="$portletObject/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']"/>
<xsl:variable name="configPropertySetId" select="$configPropertySet/@Id"/>

<xsl:variable name="configProperties" select="$configPropertySet/SetProperties"/>
<xsl:variable name="configPropertySets" select="$configPropertySet/PropertySets"/>

<!--  The Folder path we store has the prefix SBIP://METASERVER on it.  No need to force the user to enter that, just have them enter the full path -->

<xsl:variable name="portletURIFolder" select="$configPropertySets/PropertySet[@Name='selectedFolder']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
<xsl:variable name="portletPathFolderTemp" select="substring-before(substring-after($portletURIFolder,'SBIP://METASERVER'),'(Folder)')"/>
<xsl:variable name="portletPathFolder">
   <xsl:choose>
      <xsl:when test="$portletPathFolderTemp=''">/</xsl:when>
      <xsl:otherwise><xsl:value-of select="$portletPathFolderTemp"/></xsl:otherwise>
   </xsl:choose>
</xsl:variable>

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
            <xsl:value-of select="$portletEditNavigatorFolder"/>
          </td>
          
          <td class="celljustifyleft" nowrap="">
            <input type="text" id="path" name="path" size="60"><xsl:attribute name="value"><xsl:value-of select="$portletPathFolder"/></xsl:attribute></input>
          </td>
         </tr>
         <tr>
            <td>&#160;</td>
            <td>
              <input type="checkbox" id="checkboxPath" name="checkboxPath"></input>
              <label for="checkboxPath"><xsl:value-of select="$sasnavigatorPathCheckbox"/></label>
              <label for="checkboxPath" id="labelPath"></label>
            
        </td>
        <td>&#160;</td>
        </tr>
         <tr>
          <td nowrap="">
          </td>
         </tr>
        <tr></tr>

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
                    <input class="button" type="submit" name="submit" onclick=' return onsubmitPath(); '><xsl:attribute name="value"><xsl:value-of select="$saveButton"/></xsl:attribute></input>
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

  document.getElementById('labelPath').textContent = sessionStorage.getItem("pathValue.<xsl:value-of select="$portletId"/>");

    function onsubmitPath() {
        var checkbox = document.getElementById('checkboxPath');
        if (checkbox.checked) {
          document.getElementById("path").value = sessionStorage.getItem("pathValue.<xsl:value-of select="$portletId"/>");
          }

        if (validateForm()) {
        
           return submitDisableAllForms(); 
           } 

        else  return false;
    };

    function setBooleanHidden(fldName) {
        var checkboxField = document.getElementById(fldName);
        var hiddenField = document.getElementById("selected" + fldName);
        if (checkboxField.checked) {
            hiddenField.value = "1";
        } else {
            hiddenField.value = "0";
        }
    }

   /*
    *  Validate fields in form
    */

   function validateForm() {
      /*
       *  If any changes were made,
       *  At a minimum, the Folder field must be non-blank
       */

      var pathValue = document.getElementById('path').value;
      if (pathValue.length==0) {
         alert('<xsl:value-of select="$portletEditNavigatorFolderRequired"/>');
         return false;
         }

      return true;

    }
  </script>

</xsl:template>

</xsl:stylesheet>

