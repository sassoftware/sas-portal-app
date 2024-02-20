<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<!-- Input xml format is the Mod_Request format with both the GetMetadataObjects section
     and the NewMetadata sections filled in.
     For the content of the GetMetadataObjects section, see add.get.psportalpage.xslt
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


<xsl:variable name="portletCollectionItemTypeApplicationLabel" select="$localeXml/string[@key='portletCollectionItemTypeApplicationLabel']/text()"/>
<xsl:variable name="portletCollectionItemTypeLinkLabel" select="$localeXml/string[@key='portletCollectionItemTypeLinkLabel']/text()"/>

<xsl:variable name="portletEditItemRequiredField" select="$localeXml/string[@key='portletEditItemRequiredField']/text()"/>
<xsl:variable name="portletEditItemName" select="$localeXml/string[@key='portletEditItemName']/text()"/>
<xsl:variable name="portletEditItemDescription" select="$localeXml/string[@key='portletEditItemDescription']/text()"/>
<xsl:variable name="portletEditItemKeywords" select="$localeXml/string[@key='portletEditItemKeywords']/text()"/>

<xsl:variable name="portletEditPageRank" select="$localeXml/string[@key='portletEditPageRank']/text()"/>
<xsl:variable name="portletEditPageRankTitle" select="$localeXml/string[@key='portletEditPageRankTitle']/text()"/>
<xsl:variable name="portletEditPageLocation" select="$localeXml/string[@key='portletEditPageLocation']/text()"/>
<xsl:variable name="portletEditPageLocationTitle" select="$localeXml/string[@key='portletEditPageLocationTitle']/text()"/>
<xsl:variable name="portletEditPageShareType" select="$localeXml/string[@key='portletEditPageShareType']/text()"/>
<xsl:variable name="portletEditPageShareTypeNotShared" select="$localeXml/string[@key='portletEditPageShareTypeNotShared']/text()"/>
<xsl:variable name="portletEditPageShareTypeAvailable" select="$localeXml/string[@key='portletEditPageShareTypeAvailable']/text()"/>
<xsl:variable name="portletEditPageShareTypeDefault" select="$localeXml/string[@key='portletEditPageShareTypeDefault']/text()"/>
<xsl:variable name="portletEditPageShareTypePersistent" select="$localeXml/string[@key='portletEditPageShareTypePersistent']/text()"/>

<xsl:variable name="portletEditItemNameRequired" select="$localeXml/string[@key='portletEditItemNameRequired']/text()"/>
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

    <xsl:variable name="userName" select="Mod_Request/NewMetadata/Metaperson"/>

    <xsl:variable name="numberOfWriteableTrees" select="count(Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries//Tree)"/>

    <xsl:variable name="isContentAdministrator">
      <xsl:choose>
         <xsl:when test="not($numberOfWriteableTrees=1)">1</xsl:when>
         <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="parentTreeId" select="Mod_Request/NewMetadata/ParentTreeId"/>

    <xsl:variable name="addLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/createItem')"/>

<!--  NOTE: We set up a hidden formResponse iframe to capture the result so that we can either display the results (if debugging) or simply cause a "go back" to happen after the form is submitted (by using the iframe onload function).  The event handler to handle this is in the CommonFormFunctions template -->

    <form method="post" enctype="application/x-www-form-urlencoded" target="formResponse">
        <xsl:attribute name="action"><xsl:value-of select="$addLink"/></xsl:attribute>

        <input type="hidden" name="type" value="PSPortalPage"/>

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
                    <input type="text" name="name" size="40" value="" id="name"/>
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
                    <input type="text" name="desc" size="40" value="" id="desc"/>
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
                    <input type="text" name="keywords" size="40" value="" id="keywords"/>
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
                    <label for="pageRank"><xsl:value-of select="$portletEditPageRank"/>: </label>
                </td>
                <td>&#160;</td>
                <td nowrap="nowrap" class="textEntry">
                    <input type="text" name="pageRank" size="5" value="100" id="pageRank"/>
                    <img border="0" width="5" alt="">                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                    </img>
<xsl:value-of select="$portletEditPageRankTitle"/>
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
			    <select name="parentTreeId" onchange="toggleScopeDiv();" id="parentTreeId">
                                <xsl:for-each select="/Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries//Tree">
                                   <xsl:variable name="optionTreeName" select="@Name"/>
                                   <xsl:variable name="optionTreeId" select="@Id"/>
                                   <xsl:variable name="optionTreeNameDisplay">
                                      <xsl:choose>
                                         <xsl:when test="starts-with($optionTreeName,$userName)"><xsl:value-of select="$portletEditPageShareTypeNotShared"/></xsl:when>
                                         <xsl:otherwise><xsl:value-of select="$optionTreeName"/></xsl:otherwise>
                                      </xsl:choose>
                                   </xsl:variable>
                                <option><xsl:attribute name="value" select="$optionTreeId"/><xsl:value-of select="$optionTreeNameDisplay"/></option>
                                </xsl:for-each>
			    </select>
			</td>
                  </xsl:when>
                  <xsl:otherwise>
                      <td class="commonLabel" nowrap="nowrap">&#160;</td>
                      <td>&#160;</td>
                      <td class="textEntry">
                         <input type="hidden" name="parentTreeId"><xsl:attribute name="value"><xsl:value-of select="/Mod_Request/GetMetadataObjects/Objects/Person/AccessControlEntries/AccessControlEntry/Objects/Tree/@Id"/></xsl:attribute>
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
                    <div id="scopeLabelDiv" style="visibility: hidden">
                        <label for="scope"><xsl:value-of select="$portletEditPageShareType"/>: </label>
                    </div>
                </td>
                <td>&#160;</td>
                <td class="textEntry">
                    <div id="scopeDiv" style="visibility: hidden">
                        <!-- The old IDP set the default scope to be default, so do the same here -->
                        <select name="scope" id="scope">
                            <option value="0"><xsl:value-of select="$portletEditPageShareTypeAvailable"/></option>
                            <option value="1" selected="true"><xsl:value-of select="$portletEditPageShareTypeDefault"/></option>
                            <option value="2"><xsl:value-of select="$portletEditPageShareTypePersistent"/></option>
                        </select>
                    </div>
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
                <input class="button" type="button" onclick='if (submitDisableAllForms()) history.go(-2); else return false;'>
                    <xsl:attribute name="value"><xsl:value-of select="$cancelButton"/></xsl:attribute>
                </input>
            </td>
            <td width="100%" />
        </tr>

        </table>
    </form>

      <!-- This iframe is here to capture the response from submitting the form -->
      
      <iframe id="formResponse" name="formResponse" style="display:none">
      
      </iframe>


</xsl:template>

<xsl:template name="thisPageScripts">

<script>

   var hasChanged = false;

   backDepth=-2;

   toggleScopeDiv();

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

   function toggleScopeDiv() {

       /*
        *  Toggle the scope field visibility based on the sharing location.
        */

       /*
        *  If it's the not the "not shared" entry, then see what type of page
        *  are we creating.
        */
       var parentTreeSelect=document.getElementById('parentTreeId');
       var selectedText=parentTreeSelect.options[parentTreeSelect.selectedIndex].text;
       /*
        *  If not shared, hide the option to select which sharing option
        */
       var scopeLabelDiv=document.getElementById('scopeLabelDiv');
       var scopeDiv=document.getElementById('scopeDiv');

       if (selectedText==='<xsl:value-of select="$portletEditPageShareTypeNotShared"/>') {

          scopeLabelDiv.style.visibility="hidden";
          scopeDiv.style.visibility="hidden";

          }
       else {

          scopeLabelDiv.style.visibility="";
          scopeDiv.style.visibility="";

          }
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

