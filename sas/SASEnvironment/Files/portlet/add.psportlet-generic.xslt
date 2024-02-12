<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<!-- Input xml format is the Mod_Request format 
  -->
<xsl:param name="sastheme">default</xsl:param>
<xsl:variable name="sasthemeContextRoot">SASTheme_<xsl:value-of select="$sastheme"/></xsl:variable>

<xsl:param name="appLocEncoded"/>

<xsl:variable name="localizationDir">SASPortalApp/sas/SASEnvironment/Files/localization</xsl:variable>

<xsl:param name="localizationFile"><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:param>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Strings to be localized -->
<xsl:variable name="saveButton" select="$localeXml/string[@key='saveButton']/text()"/>
<xsl:variable name="cancelButton" select="$localeXml/string[@key='cancelButton']/text()"/>

<xsl:variable name="portletEditItemNameRequired" select="$localeXml/string[@key='portletEditItemNameRequired']/text()"/>
<xsl:variable name="portletEditItemRequiredField" select="$localeXml/string[@key='portletEditItemRequiredField']/text()"/>

<xsl:variable name="portletEditItemName" select="$localeXml/string[@key='portletEditItemName']/text()"/>
<xsl:variable name="portletEditItemDescription" select="$localeXml/string[@key='portletEditItemDescription']/text()"/>
<xsl:variable name="portletEditItemKeywords" select="$localeXml/string[@key='portletEditItemKeywords']/text()"/>

<xsl:variable name="portletEditPortletType" select="$localeXml/string[@key='portletEditPortletType']/text()"/>
<xsl:variable name="portletEditPortletTypeCollection" select="$localeXml/string[@key='portletEditPortletTypeCollection']/text()"/>
<xsl:variable name="portletEditPortletTypeReport" select="$localeXml/string[@key='portletEditPortletTypeReport']/text()"/>
<xsl:variable name="portletEditPortletTypeStoredProcess" select="$localeXml/string[@key='portletEditPortletTypeStoredProcess']/text()"/>
<xsl:variable name="portletEditPortletTypeDisplayURL" select="$localeXml/string[@key='portletEditPortletTypeDisplayURL']/text()"/>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/form.functions.xslt"/>

<!-- Main Entry Point -->

<xsl:template match="/">

    <xsl:call-template name="commonFormFunctions"/>
    <xsl:call-template name="thisPageScripts"/>

    <xsl:variable name="objectType" select="Mod_Request/NewMetadata/Type"/>
    <xsl:variable name="relatedType" select="Mod_Request/NewMetadata/RelatedType"/>
    <xsl:variable name="relatedId" select="Mod_Request/NewMetadata/RelatedId"/>
    <xsl:variable name="parentTreeId" select="Mod_Request/NewMetadata/ParentTreeId"/>

    <xsl:variable name="addLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/createItem')"/>

<!--  NOTE: We set up a hidden formResponse iframe to capture the result so that we can either display the results (if debugging) or simply cause a "go back" to happen after the form is submitted (by using the iframe onload function).  The event handler to handle this is in the CommonFormFunctions template -->

<form method="post" enctype="application/x-www-form-urlencoded" target="formResponse">
<xsl:attribute name="action"><xsl:value-of select="$addLink"/></xsl:attribute>

<input type="hidden" name="type"><xsl:attribute name="value">PSPortlet</xsl:attribute></input>
<input type="hidden" name="relatedId"><xsl:attribute name="value"><xsl:value-of select="$relatedId"/></xsl:attribute></input>
<input type="hidden" name="relatedType"><xsl:attribute name="value"><xsl:value-of select="$relatedType"/></xsl:attribute></input>
<input type="hidden" name="parentTreeId"><xsl:attribute name="value"><xsl:value-of select="$parentTreeId"/></xsl:attribute></input>

<!-- table for data entry -->
	<table cellpadding="0" cellspacing="0" width="100%" class="dataEntryBG" border="0">
	    <tr>
		<td colspan="5">
		    <img border="0" height="24" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
	    </tr>

            <tr>
                <td><img border="0" width="12" alt="">
                   <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                   </img>
                </td>
                <td align="center" valign="center" colspan="3" width="100%">
                <div id="portal_message"></div>
                </td>
                <td><img border="0" width="12" alt="">
                   <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                   </img>
                </td>
            </tr>

            <tr>
                <td colspan="5">
                    <img border="0" height="24" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
            </tr>

	    <!-- type -->
	    <tr>
		<td>
		    <img border="0" width="12" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
		<td>
		    <img border="0" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
		<td class="commonLabel" nowrap="noWrap">
		    <label for="portlettype"><xsl:value-of select="$portletEditPortletType"/></label>
		    &#160;
		</td>
		<td class="textEntry">
		    <select name="portlettype" id="portlettype">
			<option value="collection"><xsl:value-of select="$portletEditPortletTypeCollection"/></option>
			<option value="report"><xsl:value-of select="$portletEditPortletTypeReport"/></option>
			<option value="sasstoredprocess"><xsl:value-of select="$portletEditPortletTypeStoredProcess"/></option>
			<option value="displayurl"><xsl:value-of select="$portletEditPortletTypeDisplayURL"/></option>
		    </select>
		</td>
		<td width="100%">&#160;</td>
	    </tr>
	    <tr>
		<td colspan="5">
		    <img border="0" height="6" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
	    </tr>
	    <!-- name -->
	    <tr>
		<td>
		    <img border="0" width="12" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
		<td>
		    <img border="0" width="12" height="12">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/InputRequired.gif</xsl:attribute>
                     <xsl:attribute name="alt"><xsl:value-of select="$portletEditItemRequiredField"/></xsl:attribute>
                     <xsl:attribute name="title"><xsl:value-of select="$portletEditItemRequiredField"/></xsl:attribute>
                    </img>
		</td>
		<td class="commonLabel" nowrap="nowrap">
		    <label for="name"><xsl:value-of select="$portletEditItemName"/></label>
		    &#160;
		</td>
		<td class="textEntry" align="left">
		    <input type="text" name="name" size="40" value="" id="name"/>
		</td>
		<td width="100%">&#160;</td>
	    </tr>
	    <tr>
		<td colspan="5">
		    <img border="0" height="6" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
	    </tr>
	    <!-- description -->
	    <tr>
		<td>
		    <img border="0" width="12" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
		<td>
		    <img border="0" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
		<td class="commonLabel" nowrap="nowrap">
		    <label for="desc"><xsl:value-of select="$portletEditItemDescription"/></label>
		    &#160;
		</td>
		<td class="textEntry">
		    <input type="text" name="desc" size="40" value="" id="desc"/>
		</td>
		<td width="100%">&#160;</td>
	    </tr>
	    <tr>
		<td colspan="5">
		    <img border="0" height="6" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
	    </tr>
	    <!-- keywords -->
	    <tr>
		<td>
		    <img border="0" width="12" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
		<td>
		    <img border="0" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>

<!-- TODO: Add support for Keywords 

		<td class="commonLabel" nowrap="nowrap">
		    <label for="keywords"><xsl:value-of select="$portletEditItemKeywords"/></label>
		    &#160;
		</td>
		<td class="textEntry">
		    <input type="text" name="keywords" size="40" value="" id="keywords"/>
		</td>
-->
<!-- TODO: When adding support for Keywords, remove these 2 spacers -->

		<td>
		    <img border="0" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
		<td>
		    <img border="0" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>

		<td width="100%">&#160;</td>
	    </tr>
	    <tr>
		<td colspan="5">
		    <img border="0" height="6" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
	    </tr>
	    <tr>
		<td colspan="5">
		    <img border="0" height="6" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
	    </tr>
	    <!-- add button -->
	    <tr>
		<td>
		    <img border="0" width="12" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
		<td>
		    <img border="0" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
		<td>
		    <img border="0" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
		<td width="100%">&#160;</td>
	    </tr>
	    <!-- buttons -->
	    <tr>
		<td colspan="5">
		    <img border="0" height="24" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
	    </tr>
	    <tr>
		<td colspan="5" class="wizardMessageFooter" height="1"></td>
	    </tr>
	    <tr class="buttonBar">
		<td colspan="5">
		    <img border="0" height="6" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
	    </tr>
	    <tr class="buttonBar">

            <td nowrap="nowrap" align="left" colspan="5">
                <img border="0" height="12" alt="">
                  <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                </img>
                <input class="button" type="submit" onclick='if (validateForm()) return submitDisableAllForms(); else return false;'>
                    <xsl:attribute name="value"><xsl:value-of select="$saveButton"/></xsl:attribute>
                </input>
                &#160;

                <input class="button" type="button" onclick='if (submitDisableAllForms()) history.go(-1); else return false;'>
                    <xsl:attribute name="value"><xsl:value-of select="$cancelButton"/></xsl:attribute>
                </input>
            </td>
	    </tr>
	    <tr class="buttonBar">
		<td colspan="5">
		    <img border="0" height="6" alt="">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
		</td>
	    </tr>
	    <!-- end buttons -->
	</table>
    </form>

      <!-- This iframe is here to capture the response from submitting the form -->
      
      <iframe id="formResponse" name="formResponse" style="display:none">
      
      </iframe>

</xsl:template>

<xsl:template name="thisPageScripts">

<script>

   var hasChanged = false;

   /* 
    *  Validate fields in form
    */

   function validateForm() {
      /*
       *  If any changes were made,
       *  At a minimum, the Name must be non-blank
       */

      var nameValue = document.getElementById('name').value;
      if (nameValue.length==0) {
         alert('<xsl:value-of select="$portletEditItemNameRequired"/>');
         return false;
         }

      return true;

   }

</script>

</xsl:template>

</xsl:stylesheet>

