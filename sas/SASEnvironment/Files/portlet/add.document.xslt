<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<xsl:param name="sastheme">default</xsl:param>
<xsl:variable name="sasthemeContextRoot">SASTheme_<xsl:value-of select="$sastheme"/></xsl:variable>

<xsl:param name="appLocEncoded"/>

<xsl:variable name="localizationDir">SASPortalApp/sas/SASEnvironment/Files/localization</xsl:variable>

<xsl:param name="localizationFile"><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:param>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Strings to be localized -->
<xsl:variable name="addButton" select="$localeXml/string[@key='addButton']/text()"/>
<xsl:variable name="doneButton" select="$localeXml/string[@key='doneButton']/text()"/>
<xsl:variable name="cancelButton" select="$localeXml/string[@key='cancelButton']/text()"/>
<xsl:variable name="saveButton" select="$localeXml/string[@key='saveButton']/text()"/>


<xsl:variable name="portletCollectionItemTypeApplicationLabel" select="$localeXml/string[@key='portletCollectionItemTypeApplicationLabel']/text()"/>
<xsl:variable name="portletCollectionItemTypeLinkLabel" select="$localeXml/string[@key='portletCollectionItemTypeLinkLabel']/text()"/>

<xsl:variable name="portletEditItemRequiredField" select="$localeXml/string[@key='portletEditItemRequiredField']/text()"/>
<xsl:variable name="portletEditItemName" select="$localeXml/string[@key='portletEditItemName']/text()"/>
<xsl:variable name="portletEditItemDescription" select="$localeXml/string[@key='portletEditItemDescription']/text()"/>
<xsl:variable name="portletEditItemURL" select="$localeXml/string[@key='portletEditItemURL']/text()"/>
<xsl:variable name="portletEditItemKeywords" select="$localeXml/string[@key='portletEditItemKeywords']/text()"/>

<xsl:variable name="portletEditItemNameRequired" select="$localeXml/string[@key='portletEditItemNameRequired']/text()"/>
<xsl:variable name="portletEditItemURLRequired" select="$localeXml/string[@key='portletEditItemURLRequired']/text()"/>
<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/form.functions.xslt"/>

<!-- Main Entry Point -->

<xsl:template match="/">

    <xsl:call-template name="commonFormFunctions"/>
    <xsl:call-template name="thisPageScripts"/>

    <xsl:variable name="objectType" select="Mod_Request/NewMetadata/Type"/>
    <xsl:variable name="relatedType" select="Mod_Request/NewMetadata/RelatedType"/>
    <xsl:variable name="relatedId" select="Mod_Request/NewMetadata/RelatedId"/>
    <xsl:variable name="relatedRelationship" select="Mod_Request/NewMetadata/RelatedRelationship"/>
    <xsl:variable name="parentTreeId" select="Mod_Request/NewMetadata/ParentTreeId"/>

    <xsl:variable name="addLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/createItem')"/>

   <form name="taskSearchForm" method="post" target="formResponse">
        <xsl:attribute name="action"><xsl:value-of select="$addLink"/></xsl:attribute>

        <input type="hidden" name="Type"><xsl:attribute name="value"><xsl:value-of select="$objectType"/></xsl:attribute></input>

        <xsl:if test="$parentTreeId">
            <input type="hidden" name="parentTreeId"><xsl:attribute name="value"><xsl:value-of select="$parentTreeId"/></xsl:attribute></input>
        </xsl:if>
        <xsl:if test="$relatedType">
            <input type="hidden" name="relatedType"><xsl:attribute name="value"><xsl:value-of select="$relatedType"/></xsl:attribute></input>
        </xsl:if>
        <xsl:if test="$relatedId">
            <input type="hidden" name="relatedId"><xsl:attribute name="value"><xsl:value-of select="$relatedId"/></xsl:attribute></input>
        </xsl:if>

        <xsl:if test="$relatedRelationship">
            <input type="hidden" name="relatedRelationship"><xsl:attribute name="value"><xsl:value-of select="$relatedRelationship"/></xsl:attribute></input>
        </xsl:if>

        <table cellpadding="0" cellspacing="0" width="100%" class="dataEntryBG" border="0">
            <tr>
                <td colspan="6">
                    <img border="0" height="12" alt="">
                    <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
            </tr>

            <tr>
                <td><img border="0" width="12" alt="">
                   <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                   </img>
                </td>
                <td align="center" valign="center" colspan="6" width="100%">
                <div id="portal_message"></div>
                </td>
                <td><img border="0" width="12" alt="">
                   <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                   </img>
                </td>
            </tr>
            <tr>
                <td colspan="6">
                    <img border="0" height="12" alt="">
                    <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
            </tr>

            <tr>
                <td>
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                     </img>
                </td>
                <td>
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
                <td class="commonLabel" colspan="3" nowrap="nowrap">
                    <input type="radio" name="contentType" checked="checked" id="createapplication">
                    <xsl:attribute name="value">Application</xsl:attribute>
                    </input>

                    <label for="createapplication"><xsl:value-of select="$portletCollectionItemTypeApplicationLabel"/></label>
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                    <input type="radio" name="contentType" id="createlink">
                    <xsl:attribute name="value">Link</xsl:attribute>
                    </input>

                    <label for="createlink"><xsl:value-of select="$portletCollectionItemTypeLinkLabel"/></label>
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>

                </td>
                <td width="100%">&#160;</td>
            </tr>
            <tr>
                <td colspan="6">
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
            </tr>
            <tr>
                <td>
                     <img border="0" height="12" alt="">
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
                    <label for="name"><xsl:value-of select="$portletEditItemName"/>: </label>
                </td>
                <td>&#160;</td>
                <td class="textEntry" align="left">
                    <input type="text" name="name" maxlength="60" size="40" value="" id="name"/>
                </td>
                <td width="100%">&#160;</td>
            </tr>
            <tr>
                <td colspan="6">
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
            </tr>
            <tr>
                <td>
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
                <td>
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
                <td class="commonLabel" nowrap="nowrap">
                    <label for="desc"><xsl:value-of select="$portletEditItemDescription"/>: </label>
                </td>
                <td>&#160;</td>
                <td class="textEntry">
                    <input type="text" name="desc" maxlength="200" size="40" value="" id="desc"/>
                </td>
                <td width="100%">&#160;</td>
            </tr>
            <tr>
                <td colspan="6">
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
            </tr>
            <tr>
                <td>
                     <img border="0" height="12" alt="">
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
                    <label for="linkurl"><xsl:value-of select="$portletEditItemURL"/>: </label>
                </td>
                <td>&#160;</td>
                <td class="textEntry">
                    <input type="text" name="url" size="40" value="" id="linkurl"/>
                </td>
                <td width="100%">&#160;</td>
            </tr>
            <tr>
                <td colspan="6">
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
            </tr>

            <!-- TODO: Add Keywords support -->
            <!-- xsl:call-template name="includeKeywords"/ -->

            <!-- TODO: Add the ability to add multiple items with one call to this page, for now, add 1 at a time -->
            <!-- xsl:call-template name="addMultiple"/ -->

            <tr>
                <td colspan="6">
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
            </tr>
            <tr>
                <td colspan="6" class="wizardMessageFooter" height="1"></td>
            </tr>

            <tr class="buttonBar">
                <td colspan="6">
                     <img border="0" height="12" alt="">
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
                <input class="button" type="button" onclick='if (submitDisableAllForms()) return cancelForm(); else return false;'>
                    <xsl:attribute name="value"><xsl:value-of select="$cancelButton"/></xsl:attribute>
                </input>
                <!-- TODO: When adding support for multiple, need to remove Add/Cancel and just have Done -->
                <!--
                    <input class="button" type="submit" onclick='if (cancelForm(this, "/SASPortal/editPortlet/start.wiz")) return submitDisableAllForms(); else return false;'>
                        <xsl:attribute name="value"><xsl:value-of select="$doneButton"/></xsl:attribute>
                    </input>
                -->
            </td>
            <td width="100%" />
        </tr>

            <tr class="buttonBar">
                <td colspan="6">
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
            </tr>
        </table>
    </form>

<!-- This iframe is here to capture the response from submitting the form -->

<iframe id="formResponse" name="formResponse" style="display:none">

</iframe>

</xsl:template>

<xsl:template name="thisPageScripts">

<script>

console.log('add page entry');

   var hasChanged = false;
  
   /*
    *  Cancel this form
    */
   function cancelForm() {
     // console.log('cancelForm');
 
     // console.log('cancelForm: referrer='+document.referrer);
     // console.log('cancelForm: backDepth='+backDepth);

     // alert('wait to go back');

     history.go(backDepth);

     return true;

     } 
   /* 
    *  Validate fields in form
    */

   function validateForm() {
      /*
       *  If any changes were made,
       *  At a minimum, the Name and URL field must be non-blank
       */

      var nameValue = document.getElementById('name').value;
      if (nameValue.length==0) {
         alert('<xsl:value-of select="$portletEditItemNameRequired"/>');
         return false;
         }

      var urlValue = document.getElementById('linkurl').value;
      if (urlValue.length==0) {
         alert('<xsl:value-of select="$portletEditItemURLRequired"/>');
         return false;
         }

      return true;

   }

</script>

</xsl:template>

<xsl:template name="includeKeywords">

            <tr>
                <td>
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
                <td>
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
                <td class="commonLabel" nowrap="nowrap">
                    <label for="keywords"><xsl:value-of select="$portletEditItemKeywords"/>: </label>
                </td>
                <td>&#160;</td>
                <td class="textEntry">
                    <input type="text" name="keywords" size="40" value="" id="keywords"/>
                </td>
                <td width="100%">&#160;</td>
            </tr>

</xsl:template>

<xsl:template name="addMultiple">

            <tr>
                <td colspan="6">
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
            </tr>
            <tr>
                <td colspan="4">
                     <img border="0" height="12" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
                </td>
                <td valign="top" align="left">
                    <input class="button" type="submit" value='Add' onclick='if (formvalidate(new Array("label", "linkurl"), new Array(jsMessage, jsURLMessage)) &amp;&amp; cancelForm(this, "/SASPortal/editPortlet/addNewItem.wiz")) return submitDisableAllForms(); else return false;'/>
                </td>
                <td width="100%">&#160;</td>
            </tr>

</xsl:template>

</xsl:stylesheet>

