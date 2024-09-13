<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" encoding="UTF-8"/>

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

<xsl:variable name="portletEditCollectionShowDescriptionLabel" select="$localeXml/string[@key='portletEditCollectionShowDescriptionLabel']/text()"/>
<xsl:variable name="portletEditCollectionShowLocationLabel" select="$localeXml/string[@key='portletEditCollectionShowLocationLabel']/text()"/>


<!-- Global Variables -->

<xsl:variable name="portletObject" select="$metadataContext/GetMetadata/Metadata/PSPortlet"/>

<xsl:variable name="parentTreeId" select="$portletObject/Trees/Tree/@Id"/>

<xsl:variable name="saveLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/updateItem')"/>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/form.functions.xslt"/>

<!-- Main Entry Point -->

<xsl:template match="/">

<xsl:variable name="itemType">PSPortlet</xsl:variable>

<xsl:variable name="portletId" select="$portletObject/@Id"/>
<xsl:variable name="portletType" select="$portletObject/@PortletType"/>

<xsl:variable name="showDescription" select="$portletObject/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='show-description']/@DefaultValue"/>
<xsl:variable name="showLocation" select="$portletObject/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='show-location']/@DefaultValue"/>

<xsl:call-template name="commonFormFunctions"/>
<xsl:call-template name="thisPageScripts"/>



<div id="mainContentDiv"  style="width: 100%"  class="mainContent">

<!-- Links used in the form -->



<!-- The form -->

<!--  NOTE: We set up a hidden formResponse iframe to capture the result so that we can either display the results (if debugging) or simply cause a "go back" to happen after the form is submitted (by using the iframe onload function).  The event handler to handle this is in the CommonFormFunctions template -->

<form method="post" id="mainForm"
      onsubmit="selectAllItems('portletItemSelect');" 
      target="formResponse">
      <xsl:attribute name="action"><xsl:value-of select="$saveLink"/></xsl:attribute>

    <xsl:if test="$parentTreeId">
       <input type="hidden" name="parentTreeId"><xsl:attribute name="value"><xsl:value-of select="$parentTreeId"/></xsl:attribute></input>
    </xsl:if>

    <input type="hidden" name="portletId"><xsl:attribute name="value">Portlet+omi://<xsl:value-of select="$reposName"/>/PSPortlet;id=<xsl:value-of select="$portletId"/></xsl:attribute></input>
    <input type="hidden" name="id"><xsl:attribute name="value"><xsl:value-of select="$portletId"/></xsl:attribute></input>
    <input type="hidden" name="type"><xsl:attribute name="value"><xsl:value-of select="$itemType"/></xsl:attribute></input>
    <input type="hidden" name="portletType"><xsl:attribute name="value"><xsl:value-of select="$portletType"/></xsl:attribute></input>
    <input type="hidden" name="listChanged" value="false"/>

    <table border="0" cellpadding="0" cellspacing="0" width="100%" class="dataEntryBG">
        <tr>
            <td colspan="6"><br/></td>
        </tr>
         <tr>
             <td align="center" valign="center" colspan="6" width="100%">
             <div id="portal_message"></div>
             </td>
         </tr>
        <tr>
            <td colspan="2">&#160;</td>
            <td colspan="4" class="commonLabel" nowrap="nowrap">
                <input type="checkbox" name="showDescription" onclick="setBooleanHidden('showDescription');hasChanged=true;" id="showDescription">
                  <xsl:choose>
                  <xsl:when test="$showDescription = 'true'">
                      <xsl:attribute name="checked">checked</xsl:attribute>
                      <xsl:attribute name="value">on</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="not($showDescription)">
                      <!-- When a new Collection Portlet is created, it doesn't yet have properties, but 
                           the old ID Portal set these values to true by default, so do the same thing
                           so when it is saved, the properties get created.
                      -->
                      <xsl:attribute name="checked">checked</xsl:attribute>
                      <xsl:attribute name="value">on</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:attribute name="value">off</xsl:attribute>
                  </xsl:otherwise>
                  </xsl:choose>

                </input>
                <label for="showDescription">
                    <xsl:value-of select="$portletEditCollectionShowDescriptionLabel"/>
                </label>
                <input type="hidden" name="selectedShowDescription" id="selectedshowDescription">
				 <xsl:choose>
				   <xsl:when test="$showDescription = 'true'">
					<xsl:attribute name="value">1</xsl:attribute>
                   </xsl:when>
				   <xsl:when test="not($showDescription)">
					<xsl:attribute name="value">1</xsl:attribute>
                   </xsl:when>
				   <xsl:otherwise>
					<xsl:attribute name="value">0</xsl:attribute>
				   </xsl:otherwise>
                 </xsl:choose>
				</input>
            </td>
        </tr>

        <tr>
            <td colspan="2"></td>
            <td colspan="4" class="commonLabel" nowrap="nowrap">
                <input type="checkbox" name="showLocation" onclick="setBooleanHidden('showLocation');hasChanged=true;" id="showLocation">
                  <xsl:choose>
                  <xsl:when test="$showLocation = 'true'">
                      <xsl:attribute name="checked">checked</xsl:attribute>
                      <xsl:attribute name="value">on</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="not($showLocation)">
                      <!-- When a new Collection Portlet is created, it doesn't yet have properties, but 
                           the old ID Portal set these values to true by default, so do the same thing
                           so when it is saved, the properties get created.
                      -->
                      <xsl:attribute name="checked">checked</xsl:attribute>
                      <xsl:attribute name="value">on</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:attribute name="value">off</xsl:attribute>
                  </xsl:otherwise>
                  </xsl:choose>

                </input>

                <label for="showLocation">
                    <xsl:value-of select="$portletEditCollectionShowLocationLabel"/>
                </label>
                <input type="hidden" name="selectedShowLocation" id="selectedshowLocation">
				 <xsl:choose>
				   <xsl:when test="$showLocation = 'true'">
					<xsl:attribute name="value">1</xsl:attribute>
                   </xsl:when>
				   <xsl:when test="not($showLocation)">
					<xsl:attribute name="value">1</xsl:attribute>
                   </xsl:when>
				   <xsl:otherwise>
					<xsl:attribute name="value">0</xsl:attribute>
				   </xsl:otherwise>
                 </xsl:choose>
				</input>
            </td>
        </tr>

        <tr>
            <td colspan="2"></td>
            <td colspan="4" class="commonLabel" nowrap="nowrap">&#160;
            </td>
        </tr>
        <tr>
            <td colspan="6"></td>
        </tr>

        <tr>
            <td colspan="6" class="wizardMessageFooter" height="1"></td>
        </tr>
        <tr class="buttonBar">
            <td colspan="6"><img border="0" height="6" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img></td>
        </tr>
        <tr class="buttonBar">
            <td nowrap="nowrap" align="left" colspan="5">
                &#160;&#160;
                <input class="button" type="submit" onclick='return submitDisableAllForms();'> 
                    <xsl:attribute name="value"><xsl:value-of select="$okButton"/></xsl:attribute>
                </input>
                &#160;
                <input class="button" type="button" onclick='submitDisableAllForms(); history.go(-1);'>
                    <xsl:attribute name="value"><xsl:value-of select="$cancelButton"/></xsl:attribute>
                </input>
 
            </td>
            <td width="100%" />
        </tr>
        <tr class="buttonBar">
            <td colspan="6"><img border="0" height="6" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img></td>
        </tr>

    </table>

</form>

<!-- This iframe is here to capture the response from submitting the form -->

<iframe id="formResponse" name="formResponse" style="display:none" width="100%">

</iframe>

<!-- This iframe is here to capture the response from removing an item -->

<iframe id="removeResponse" name="removeResponse" style="display:none">

</iframe>

</div>

</xsl:template>


<xsl:template name="thisPageScripts">

<script>


    var hasChanged = false;

    /*
     *  This event listener is to catch when the page is returned
     *  to via some sort of "back" navigation.
     *  When an item is added to or edited in the form list, the called
     *  stored process will return to this page via "back".  At this
     *  point, we need the page to refresh to see the changes that
     *  were made.
     */
    window.addEventListener("pageshow", function (event) {

        var historyTraversal = event.persisted,
          perf = window.performance,
          perfEntries =
            perf <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> perf.getEntriesByType <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> perf.getEntriesByType("navigation"),
          perfEntryType = perfEntries <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> perfEntries[0] <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> perfEntries[0].type,
          navigationType = perf <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> perf.navigation <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> perf.navigation.type;

        if (
          historyTraversal ||
          perfEntryType === "back_forward" ||
          navigationType === 2
        ) {

          // Handle page restore.

          window.location.reload();
        }
    });


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

