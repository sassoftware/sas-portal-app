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
<xsl:variable name="saveButton" select="$localeXml/string[@key='saveButton']/text()"/>
<xsl:variable name="cancelButton" select="$localeXml/string[@key='cancelButton']/text()"/>

<xsl:variable name="portletEditItemRequiredField" select="$localeXml/string[@key='portletEditItemRequiredField']/text()"/>
<xsl:variable name="portletEditItemName" select="$localeXml/string[@key='portletEditItemName']/text()"/>
<xsl:variable name="portletEditItemDescription" select="$localeXml/string[@key='portletEditItemDescription']/text()"/>
<xsl:variable name="portletEditItemKeywords" select="$localeXml/string[@key='portletEditItemKeywords']/text()"/>

<xsl:variable name="portletEditPageLocation" select="$localeXml/string[@key='portletEditPageLocation']/text()"/>
<xsl:variable name="portletEditPageLocationTitle" select="$localeXml/string[@key='portletEditPageLocationTitle']/text()"/>
<xsl:variable name="portletEditPageShareTypeNotShared" select="$localeXml/string[@key='portletEditPageShareTypeNotShared']/text()"/>

<xsl:variable name="portletEditItemNameRequired" select="$localeXml/string[@key='portletEditItemNameRequired']/text()"/>

<!-- Global Variables -->

<!-- Define the lookup table of writeable trees -->
<xsl:key name="treeKey" match="Tree" use="@Id"/>
<!-- it doesnt say this anywhere in the xsl key doc, but the objects to use for the lookup table
     must be under a shared root object.  Thus, here we can only go to the AccessControlEntries
     level.  Fortunately, the only trees listed under here are the ones we want in our lookup table
  -->
<xsl:variable name="treeLookup" select="$metadataContext/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/AccessControlEntries"/>
<!-- Get the same set of nodes in a a variable -->
<xsl:variable name="writeableTrees" select="$metadataContext/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/AccessControlEntries/AccessControlEntry/Objects/Tree"/>

<xsl:variable name="portletObject" select="$metadataContext/Multiple_Requests/GetMetadata/Metadata/PSPortlet"/>
<xsl:variable name="portletName" select="$portletObject/@Name"/>
<xsl:variable name="portletType" select="$portletObject/@PortletType"/>

<xsl:variable name="personObject" select="$metadataContext/Multiple_Requests/GetMetadataObjects/Objects/Person"/>

<!--  The parentTreeId can either be:
      - the user's root permission tree
      - a group's root permission tree
-->

<xsl:variable name="parentTreeId" select="$portletObject/Trees/Tree/@Id"/>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/form.functions.xslt"/>

<!-- Main Entry Point -->

<xsl:template match="/">

    <xsl:call-template name="commonFormFunctions"/>
    <xsl:call-template name="thisPageScripts"/>

    <xsl:variable name="portletId" select="Mod_Request/NewMetadata/Id"/>

    <xsl:variable name="portletDesc" select="$portletObject/@Desc"/>
    <!-- TODO: Keywords not currently supported -->
    <xsl:variable name="objectKeywords"/>

    <xsl:variable name="userName" select="Mod_Request/NewMetadata/Metaperson"/>

    <xsl:variable name="numberOfWriteableTrees" select="count($personObject/AccessControlEntries//Tree)"/>

    <xsl:variable name="isContentAdministrator">
      <xsl:choose>
         <xsl:when test="not($numberOfWriteableTrees=1)">1</xsl:when>
         <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="editLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/updateItem')"/>

<!--  NOTE: We set up a hidden formResponse iframe to capture the result so that we can either display the results (if debugging) or simply cause a "go back" to happen after the form is submitted (by using the iframe onload function).  The event handler to handle this is in the CommonFormFunctions template -->

    <form method="post" enctype="application/x-www-form-urlencoded" target="formResponse">
        <xsl:attribute name="action"><xsl:value-of select="$editLink"/></xsl:attribute>

        <input type="hidden" name="type" value="PSPortlet"/>
        <input type="hidden" name="id"><xsl:attribute name="value"><xsl:value-of select="$portletId"/></xsl:attribute></input>
        <input type="hidden" name="portlettype"><xsl:attribute name="value"><xsl:value-of select="$portletType"/></xsl:attribute></input>

        <table cellpadding="0" cellspacing="0" width="100%" class="dataEntryBG">
            <tr>
                <td colspan="6">
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
                    <img border="0" height="24" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>

                </td>
            </tr>

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
                    <label for="name"><xsl:value-of select="$portletEditItemName"/>: </label>
                </td>
                <td>&#160;</td>
                <td class="textEntry" align="left">
                    <input type="text" name="name" size="40" id="name">
                      <xsl:attribute name="value"><xsl:value-of select="$portletName"/></xsl:attribute>
                    </input>
                </td>
                <td width="100%">&#160;</td>
            </tr>
            <tr>
                <td colspan="6">
                    <img border="0" height="6" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>

                </td>
            </tr>
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
                    <label for="desc"><xsl:value-of select="$portletEditItemDescription"/>: </label>
                </td>
                <td>&#160;</td>
                <td class="textEntry">
                    <input type="text" name="desc" size="40" id="desc">
                      <xsl:attribute name="value"><xsl:value-of select="$portletDesc"/></xsl:attribute>
                    </input>
                </td>
                <td width="100%">&#160;</td>
            </tr>
            <tr>
                <td colspan="6">
                    <img border="0" height="6" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>

                </td>
            </tr>
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
                    <label for="keywords"><xsl:value-of select="$portletEditItemKeywords"/>: </label>
                </td>
                <td>&#160;</td>
                <td class="textEntry">
                    <input type="text" name="keywords" size="40" id="keywords" disabled="disabled">
                      <xsl:attribute name="value"><xsl:value-of select="$objectKeywords"/></xsl:attribute>
                    </input>
                </td>
                <td width="100%">&#160;</td>
            </tr>
            <tr>
                <td colspan="6">
                    <img border="0" height="6" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>

                </td>
            </tr>
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

                <xsl:choose>
                  <xsl:when test="$isContentAdministrator=1">
                        <td class="commonLabel" nowrap="nowrap">
                            <label for="parentTreeId"><xsl:value-of select="$portletEditPageLocation"/></label>
                        </td>
                        <td>&#160;</td>
                        <td class="textEntry">
                            <select name="parentTreeId" id="parentTreeId">
                                <xsl:for-each select="$personObject/AccessControlEntries//Tree[@TreeType='Permissions Tree' or @TreeType=' Permissions Tree']">
                                   <xsl:variable name="optionTreeName" select="@Name"/>
                                   <xsl:variable name="optionTreeId" select="@Id"/>
                                   <xsl:variable name="optionTreeNameDisplay">
                                      <xsl:choose>
                                         <xsl:when test="starts-with($optionTreeName,$userName)"><xsl:value-of select="$portletEditPageShareTypeNotShared"/></xsl:when>
                                         <xsl:otherwise><xsl:value-of select="$optionTreeName"/></xsl:otherwise>
                                      </xsl:choose>
                                   </xsl:variable>
                                <option><xsl:attribute name="value" select="$optionTreeId"/>
                                   <xsl:if test="$optionTreeId=$parentTreeId">
                                     <xsl:attribute name="selected">true</xsl:attribute>
                                   </xsl:if>
                                <xsl:value-of select="$optionTreeNameDisplay"/>
                                </option>
                                </xsl:for-each>
                            </select>
                        </td>
                  </xsl:when>
                  <xsl:otherwise>
                      <td class="commonLabel" nowrap="nowrap">&#160;</td>
                      <td>&#160;</td>
                      <td class="textEntry">
                         <input type="hidden" name="parentTreeId"><xsl:attribute name="value"><xsl:value-of select="$parentTreeId"/></xsl:attribute>
                         </input>
                      </td>
                  </xsl:otherwise>
                </xsl:choose>
                <td width="100%">&#160;</td>
            </tr>
            <tr>
                <td colspan="6">
                    <img border="0" height="6" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>

                </td>
            </tr>
 
            <tr>
                <td colspan="6">
                    <img border="0" height="6" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>

                </td>
            </tr>
            <tr>
                <td colspan="6">
                    <img border="0" height="6" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>

                </td>
            </tr>
            <!-- buttons -->
            <tr>
                <td colspan="6">
                    <img border="0" height="24" alt="">
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>

                </td>
            </tr>
            <tr>
                <td colspan="6" class="wizardMessageFooter" height="1"></td>
            </tr>
            <tr class="buttonBar">
                <td colspan="6">
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
                <input class="button" type="button" onclick='if (submitDisableAllForms()) history.go(backDepth); else return false;'>
                    <xsl:attribute name="value"><xsl:value-of select="$cancelButton"/></xsl:attribute>
                </input>
            </td>
            <td width="100%" />
        </tr>

        </table>
    </form>

      <!-- This iframe is here to capture the response from submitting the form -->
      
      <iframe id="formResponse" name="formResponse" style="display:none" width="100%">
      
      </iframe>


</xsl:template>

<xsl:template name="thisPageScripts">

<script>

   backDepth=-1;

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
                <td>&#160;</td>
                <td>
                    <input class="button" type="submit" value='Add' onclick='if (formvalidate(new Array("label"), new Array(jsMessage))) return submitDisableAllForms(); else return false;'/>
                </td>
                <td colspan="3" width="100%">&#160;</td>
            </tr>

</xsl:template>

</xsl:stylesheet>

