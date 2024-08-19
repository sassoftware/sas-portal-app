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
<xsl:variable name="moveUpButton" select="$localeXml/string[@key='moveUpButton']/text()"/>
<xsl:variable name="moveDownButton" select="$localeXml/string[@key='moveDownButton']/text()"/>
<xsl:variable name="addItemsButton" select="$localeXml/string[@key='addItemsButton']/text()"/>
<xsl:variable name="removeButton" select="$localeXml/string[@key='removeButton']/text()"/>
<xsl:variable name="editButton" select="$localeXml/string[@key='editButton']/text()"/>

<xsl:variable name="portletEditCollectionShowDescriptionLabel" select="$localeXml/string[@key='portletEditCollectionShowDescriptionLabel']/text()"/>
<xsl:variable name="portletEditCollectionShowLocationLabel" select="$localeXml/string[@key='portletEditCollectionShowLocationLabel']/text()"/>
<xsl:variable name="portletEditCollectionSortLabel" select="$localeXml/string[@key='portletEditCollectionSortLabel']/text()"/>
<xsl:variable name="portletEditCollectionSortUsePreferencesLabel" select="$localeXml/string[@key='portletEditCollectionSortUsePreferencesLabel']/text()"/>
<xsl:variable name="portletEditCollectionSortAscendingLabel" select="$localeXml/string[@key='portletEditCollectionSortAscendingLabel']/text()"/>
<xsl:variable name="portletEditCollectionSortDescendingLabel" select="$localeXml/string[@key='portletEditCollectionSortDescendingLabel']/text()"/>
<xsl:variable name="portletEditCollectionItemsLabel" select="$localeXml/string[@key='portletEditCollectionItemsLabel']/text()"/>

<xsl:variable name="portletEditCollectionConfirmMessage" select="$localeXml/string[@key='portletEditCollectionConfirmMessage']/text()"/>
<xsl:variable name="portletEditCollectionTooManySelected" select="$localeXml/string[@key='portletEditCollectionTooManySelected']/text()"/>
<xsl:variable name="portletEditCollectionNoneSelected" select="$localeXml/string[@key='portletEditCollectionNoneSelected']/text()"/>
<xsl:variable name="portletEditCollectionNotEditable" select="$localeXml/string[@key='portletEditCollectionNotEditable']/text()"/>
<xsl:variable name="portletEditCollectionHasChangedMessage" select="$localeXml/string[@key='portletEditCollectionHasChangedMessage']/text()"/>

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
<xsl:variable name="packageSortOrder" select="$portletObject/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='ascending-packageSortOrder']/@DefaultValue"/>

<xsl:call-template name="commonFormFunctions"/>
<xsl:call-template name="thisPageScripts"/>

  <xsl:for-each select="$portletObject/Groups/Group/Members/*">

    <xsl:call-template name="addItemList"/>

  </xsl:for-each>

<div id="mainContentDiv"  style="width: 100%"  class="mainContent">

<!-- Links used in the form -->

<xsl:variable name="addLink">addItem.html</xsl:variable>
<xsl:variable name="removeLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/deleteItem')"/>

<xsl:variable name="editLink">editItem.html</xsl:variable>

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
            <td colspan="2"></td>

                <td colspan="4" class="textEntry" nowrap="nowrap">
                <xsl:value-of select="portletEditCollectionSortLabel"/>
                    <br/>&#160;
                         <input type="radio" name="ascendingPackageSortOrder" value="UsePreferences" onclick="document.getElementById('selectedPackageSortOrder').value='UsePreferences';hasChanged=true;" id="ascendingPackageSortOrderUsePreferences">
                         <xsl:choose> 
                             <xsl:when test="$packageSortOrder = 'UsePreferences'">
                                  <xsl:attribute name="checked">checked</xsl:attribute>
                             </xsl:when>
                             <xsl:when test="not($packageSortOrder)">
                                  <xsl:attribute name="checked">checked</xsl:attribute>
                             </xsl:when>
                         </xsl:choose>
                         </input>
                            <xsl:value-of select="$portletEditCollectionSortUsePreferencesLabel"/>
                    <br/>&#160;
                         <input type="radio" name="ascendingPackageSortOrder" value="Ascending" onclick="document.getElementById('selectedPackageSortOrder').value='Ascending';hasChanged=true;" id="ascendingPackageSortOrderAscending">
                         <xsl:if test="$packageSortOrder = 'Ascending'">
                              <xsl:attribute name="checked">checked</xsl:attribute>
                         </xsl:if>

                         </input>
                            <xsl:value-of select="$portletEditCollectionSortAscendingLabel"/>
                    <br/>&#160;
                         <input type="radio" name="ascendingPackageSortOrder" value="Descending" onclick="document.getElementById('selectedPackageSortOrder').value='Descending';hasChanged=true;" id="ascendingPackageSortOrderDescending">
                         <xsl:if test="$packageSortOrder = 'Descending'">
                              <xsl:attribute name="checked">checked</xsl:attribute>
                         </xsl:if>

                         </input>
                            <xsl:value-of select="$portletEditCollectionSortDescendingLabel"/>
                    <br/><input type="hidden" name="selectedPackageSortOrder" id="selectedPackageSortOrder">
                         <!-- Set the default value to match the radio button we checked upon initial page creation -->

                         <xsl:attribute name="value"><xsl:value-of select="$packageSortOrder"/></xsl:attribute>

                         </input>
                </td>

        <script type="text/javascript">
          var hiddenVal = document.getElementById("selectedPackageSortOrder").value;
          var sortOrderRadio = document.getElementById("ascendingPackageSortOrder" + hiddenVal);
          if (sortOrderRadio != null) {
             sortOrderRadio.checked = true;
          }
        </script>

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
            <td colspan="2"></td>
            <td class="textEntry" valign="top" nowrap="nowrap">
                <div id="itemText" style="">
                      <label for="portletItemSelect">
                          <xsl:value-of select="$portletEditCollectionItemsLabel"/>
                      </label>
                </div>
            </td>
            <td>&#160;</td>

            <td>
            <div id="itemList" style="">
            <table align="left" cellpadding="0" cellspacing="0" border="0">
                <tr>
                    <td rowspan="5" valign="top" class="textEntry">
                        <select name="portletItemSelect" multiple="multiple" size="6" onchange="selectionChanged('portletItemSelect');" id="portletItemSelect" style="width: 70mm">

                          <xsl:for-each select="$portletObject/Groups/Group/Members/*">

                            <xsl:call-template name="addListBox"/>

                          </xsl:for-each>

                        </select>
                    </td>
                    <td></td>
                    <td valign="middle">

                        <a href="#" onclick='moveRowUp("portletItemSelect"); hasChanged=true; return false;'>
                        <img id="upImg" border="0"
                            width="12" height="14"
                            style="display:none"
                             >
                            <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Up.gif</xsl:attribute>
                            <xsl:attribute name="title"><xsl:value-of select="$moveUpButton"/></xsl:attribute>
                            <xsl:attribute name="alt"><xsl:value-of select="$moveUpButton"/></xsl:attribute>
                        </img>
                        </a>
                        <img style="display:block" id="upImgPlaceHolder"
                            width="12" height="14"
                            valign="middle" border="0" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img></td>

                </tr>
                <tr>
                    <td></td>
                    <td valign="middle">
                        <a href="#" onclick='moveRowDown("portletItemSelect"); hasChanged=true; return false;'>
                        <img id="downImg" border="0"
                            width="12" height="14"
                            style="display:none"
                             >
                            <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Down.gif</xsl:attribute>
                            <xsl:attribute name="title"><xsl:value-of select="$moveDownButton"/></xsl:attribute>
                            <xsl:attribute name="alt"><xsl:value-of select="$moveDownButton"/></xsl:attribute>
                        </img>
                        </a>
                        <img style="display:block" id="downImgPlaceHolder"
                            width="12" height="14"
                            valign="middle" border="0" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img></td>

                </tr>
                <tr>
                    <td colspan="2">&#160;</td>
                </tr>

                <tr>
                    <td />
                    <td valign="middle">
                        <a role="button">
 
                        <xsl:attribute name="onclick">if (displayChangedMessage("<xsl:value-of select="$portletEditCollectionHasChangedMessage"/>")) editItem("Collection","portletItemSelect",'<xsl:value-of select="$editLink"/>',noneSelected,tooMany); else return false;</xsl:attribute>

                        <img id="editImg" border="0"
                            width="12" height="14"
                            style="display:none">
                            <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Edit.gif</xsl:attribute>
                            <xsl:attribute name="title"><xsl:value-of select="$editButton"/></xsl:attribute>
                            <xsl:attribute name="alt"><xsl:value-of select="$editButton"/></xsl:attribute>
                        </img>
                        </a>
                        <img style="display:block" id="editImgPlaceHolder"
                            width="12" height="14"
                            valign="middle" border="0" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img></td>
                    </tr>

                <tr>
                    <td />
                    <td valign="middle">
                        <xsl:variable name="collectionGroupId"><xsl:value-of select="$portletObject/Groups/Group[1]/@Id"/></xsl:variable>
                        <a role="button">
                           <xsl:attribute name="onclick">if (displayChangedMessage("<xsl:value-of select="$portletEditCollectionHasChangedMessage"/>")) removeItem("portletItemSelect",'<xsl:value-of select="$collectionGroupId"/>','<xsl:value-of select="$removeLink"/>',noneSelected,tooMany); else return false;</xsl:attribute>
                        <img id="removeImg" border="0" 
                            width="12" height="14"
                            style="display:none">

                            <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Remove.gif</xsl:attribute>
                            <xsl:attribute name="title"><xsl:value-of select="$removeButton"/></xsl:attribute>
                            <xsl:attribute name="alt"><xsl:value-of select="$removeButton"/></xsl:attribute>
                            </img>
                        </a>
                        <img style="display:block" id="removeImgPlaceHolder"
                            width="12" height="14"
                            valign="middle" border="0" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img></td>
                </tr>

                <tr>
                    <td colspan="3">
                        <img border="0" height="6" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img></td>
                </tr>
                <tr>

                    <!--  We want to add an item to the group associated with this portlet, so pass that information
                          along 
                    -->
                    <xsl:variable name="collectionGroupId"><xsl:value-of select="$portletObject/Groups/Group[1]/@Id"/></xsl:variable>
                    <td valign="top" align="right">
                        <input class="button" type="button">
                        <xsl:attribute name="onclick">if (displayChangedMessage("<xsl:value-of select="$portletEditCollectionHasChangedMessage"/>")) addItem("Collection",'<xsl:value-of select="$collectionGroupId"/>','<xsl:value-of select="$parentTreeId"/>',"portletItemSelect",'<xsl:value-of select="$addLink"/>'); else return false;</xsl:attribute>
                         <xsl:attribute name="value"><xsl:value-of select="$addItemsButton"/></xsl:attribute>
                         </input>
                    </td>
                    <td colspan="2" />
                </tr>

            </table>
            </div>
            </td>
            <td width="100%">&#160;</td>
        </tr>
        <tr>
            <td colspan="6"><img border="0" height="30" alt=""><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img></td>
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

<xsl:template name="addItemList">

    <!-- The list of members of the collection contains a link bank to the collection psportlet itself, ignore that one -->

    <xsl:variable name="itemType" select="name(.)"/>
<xsl:message>addItemList: itemType=<xsl:value-of select="$itemType"/></xsl:message>
    <xsl:if test="$itemType != 'PSPortlet'">

        <xsl:variable name="itemName" select="@Name"/>
        <xsl:variable name="itemId" select="@Id"/>
        <xsl:variable name="itemLinkType">
           <xsl:choose>
             <xsl:when test="@TextRole='Portal Web Application'">WebApplication</xsl:when>
             <xsl:when test="@TextRole='Portal Link'">Link</xsl:when>
             <xsl:when test="@TextRole='Syndication Channel'">ContentChannel</xsl:when>
           </xsl:choose>
        </xsl:variable>
<!-- This was the format of the item key in the existing portal.  However, this has issues being passed as a parameter to 
     a Stored Process since it has special characters in it that are stripped for security reasons

        <xsl:variable name="itemKey"><xsl:value-of select="$itemLinkType"/>%2Bomi%3A%2F%2F<xsl:value-of select="$reposName"/>%2Freposname%3D<xsl:value-of select="$reposName"/>%2F<xsl:value-of select="$itemType"/>%3Bid%3D<xsl:value-of select="$itemId"/></xsl:variable>
-->

        <xsl:variable name="itemKey"><xsl:value-of select="$itemLinkType"/>/<xsl:value-of select="$reposName"/>/<xsl:value-of select="$itemType"/>/<xsl:value-of select="$itemId"/></xsl:variable>
        
        <script language="javascript" type="">
             itemDataList[itemCount] = new Object();
             itemDataList[itemCount].name = "<xsl:value-of select="$itemName"/>";
             itemDataList[itemCount].entityKey = "<xsl:value-of select="$itemKey"/>";

        <xsl:choose>
           <xsl:when test="lower-case($itemType)='document'">
             itemDataList[itemCount].canEdit = true;
           </xsl:when>
           <xsl:otherwise>
             itemDataList[itemCount].canEdit = false;
           </xsl:otherwise>
       </xsl:choose>
             itemCount++;

          </script>

        </xsl:if>


</xsl:template>

<xsl:template name="addListBox">

    <!-- The list of members of the collection contains a link bank to the collection psportlet itself, ignore that one -->

    <xsl:variable name="itemType" select="name(.)"/>

    <xsl:if test="$itemType != 'PSPortlet'">

        <xsl:variable name="itemName" select="@Name"/>
        <xsl:variable name="itemId" select="@Id"/>
        <xsl:variable name="itemLinkType">
           <xsl:choose>
             <xsl:when test="@TextRole='Portal Web Application'">WebApplication</xsl:when>
             <xsl:when test="@TextRole='Portal Link'">Link</xsl:when>
             <xsl:when test="@TextRole='Syndication Channel'">ContentChannel</xsl:when>
           </xsl:choose>
        </xsl:variable>
<!-- This was the format of the item key in the existing portal.  However, this has issues being passed as a parameter to
     a Stored Process since it has special characters in it that are stripped for security reasons

        <xsl:variable name="itemKey"><xsl:value-of select="$itemLinkType"/>%2Bomi%3A%2F%2F<xsl:value-of select="$reposName"/>%2Freposname%3D<xsl:value-of select="$reposName"/>%2F<xsl:value-of select="$itemType"/>%3Bid%3D<xsl:value-of select="$itemId"/></xsl:variable>
-->

        <xsl:variable name="itemKey"><xsl:value-of select="$itemLinkType"/>/<xsl:value-of select="$reposName"/>/<xsl:value-of select="$itemType"/>/<xsl:value-of select="$itemId"/></xsl:variable>

       <option><xsl:attribute name="value"><xsl:value-of select="$itemKey"/></xsl:attribute>
       <xsl:value-of select="$itemName"/>
       </option>

       </xsl:if>
</xsl:template>

<xsl:template name="thisPageScripts">

<script>
    var confirmMessage = "<xsl:value-of select="$portletEditCollectionConfirmMessage"/>";
    var tooMany = "<xsl:value-of select="$portletEditCollectionTooManySelected"/>";
    var noneSelected = "<xsl:value-of select="$portletEditCollectionNoneSelected"/>";
    var notEdit = "<xsl:value-of select="$portletEditCollectionNotEditable"/>";

    var hasChanged = false;

    var itemDataList = new Array();
    var itemCount = 0;

    /*
     *  Some of the pages that are linked off to from this page, muck with the
     *  history, so we need to make sure we get the correct depth to go back
     */

    var backDepth=-1;

    function addReloadHandler(iframe) {

         iframe.addEventListener( "load", function(e) {

         /*
          * Since we removed an item from the list, refresh the screen.
          */
         location.reload();

        } );

       }

    /*
     *  The call to remove an item will target a div called removeResponse.
     *  When it is populated, refresh the page to pick up the change.
     */

    var removeResponse = document.getElementsByName('removeResponse')[0];
    if (removeResponse) {

        addReloadHandler(removeResponse);

        }

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

    function selectFirstRow(selectBoxName) {
        var selectBox = document.getElementById(selectBoxName);
        if (selectBox.length <xsl:text disable-output-escaping="yes">&gt;</xsl:text> 0) {
            selectBox.selectedIndex = 0;
        }
        selectionChanged(selectBoxName);
    }

    function selectionChanged(selectBoxName) {
        var selectBox = document.getElementById(selectBoxName);
        var selectedRow = selectBox.selectedIndex;

        var upEnabled = false;
        var downEnabled = false;
        var editEnabled = false;
        var removeEnabled = false;

        if (selectedRow <xsl:text disable-output-escaping="yes">&gt;</xsl:text>= 0) {
            // Determine basic rules for action icons
            if (selectedRow != 0) {
                upEnabled = true;
            }
            if (selectedRow != (itemDataList.length-1)) {
                downEnabled = true;
            }


            editEnabled = itemDataList[selectedRow].canEdit;

            removeEnabled = true;
        }

        // Show/hide the action icons
        toggleVisible("upImg", upEnabled);
        toggleVisible("downImg", downEnabled);
        toggleVisible("editImg", editEnabled);
        toggleVisible("removeImg", removeEnabled);

    }

    function toggleVisible(ctrlName, isVisible) {

        var ctrl = document.getElementById(ctrlName);
        var placeHolder = document.getElementById(ctrlName+"PlaceHolder");
        if (isVisible) {
            ctrl.style.display = "block";
            placeHolder.style.display = "none";
        } else {
            ctrl.style.display = "none";
            placeHolder.style.display = "block";
        }
    }
    function moveRowUp(selectBoxName) {
        var selectBox = document.getElementById(selectBoxName);
        var selectedRow = selectBox.selectedIndex;

        if (selectedRow <xsl:text disable-output-escaping="yes">&gt;</xsl:text> 0) {
            swapListRow(itemDataList, selectedRow-1, selectedRow);
            changeOrder(selectBoxName, true);
            selectionChanged(selectBoxName);
        }
    }

    function moveRowDown(selectBoxName) {
        var selectBox = document.getElementById(selectBoxName);
        var selectedRow = selectBox.selectedIndex;

        if (selectedRow <xsl:text disable-output-escaping="yes">&lt;</xsl:text> (itemDataList.length - 1)) {
            swapListRow(itemDataList, selectedRow+1, selectedRow);
            changeOrder(selectBoxName, false);
            selectionChanged(selectBoxName);
        }
    }

    function removeRow(selectBoxName, confirmMessage) {
        var selectBox = document.getElementById(selectBoxName);
        var selectedRow = selectBox.selectedIndex;

        deleteOption(selectBoxName, confirmMessage);
        if (parent.isPageChanged) {
            itemDataList.splice(selectedRow, 1);

            // If there is any more data
            if (itemDataList.length <xsl:text disable-output-escaping="yes">&gt;</xsl:text> 0) {
                // If the selection is beyond the end of the list
                if (selectedRow <xsl:text disable-output-escaping="yes">&gt;</xsl:text>= itemDataList.length) {
                    selectedRow = itemDataList.length - 1;
                }

                // Select the new row
                selectBox.selectedIndex = selectedRow;
            }

            selectionChanged(selectBoxName);
        }
    }

    function swapListRow(listData, index1, index2) {
        var temp = listData[index1];
        listData[index1] = listData[index2];
        listData[index2] = temp;
    }

    function setBooleanHidden(fldName) {
        var checkboxField = document.getElementById(fldName);
        var hiddenField = document.getElementById("selected" + fldName);
        if (checkboxField.checked) {
            hiddenField.value = "1";
        } else {
            hiddenField.value = "0";
        }
    }

    //
    // Sets the correct URL for adding an item.
    //
    function addItem(portletType, groupId, parentTreeId, selectBoxName, addUrl)
    {

      var selectBox = document.getElementById(selectBoxName);
      addItemParms="portletType=";
      addItemParms=addItemParms.concat(portletType,'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>type=Document','<xsl:text disable-output-escaping="yes">&amp;</xsl:text>relatedId=',groupId,'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>relatedType=Group','<xsl:text disable-output-escaping="yes">&amp;</xsl:text>parentTreeId=',parentTreeId);
 

      if (addUrl.includes('?')) {
         addUrl=addUrl.concat('<xsl:text disable-output-escaping="yes">&amp;</xsl:text>',addItemParms);
         }

      else {
         addUrl=addUrl.concat('?',addItemParms);
         }

      submitDisableAllForms();
      location.href=addUrl;
    }

    //
    // Sets the correct URL for editing an item.
    //
    function editItem(portletType, selectBoxName, editUrl, nothingselected, toomanyselected)
    {

      var selectBox = document.getElementById(selectBoxName);
      var i= 0;
      if (selectBox.options.length <xsl:text disable-output-escaping="yes">&gt;</xsl:text> 0)
      {
          for (var j = 0; j <xsl:text disable-output-escaping="yes">&lt;</xsl:text> selectBox.options.length; j++)
          {
              if (selectBox.options[j].selected)
             i++;
           }
       }

       if (i <xsl:text disable-output-escaping="yes">&gt;</xsl:text> 1)
       {
           alert(""+toomanyselected);
       }
       else
       {
           srcIndex = selectBox.selectedIndex;
           if (srcIndex <xsl:text disable-output-escaping="yes">&gt;</xsl:text>= 0)
           {
            
              var selectedValue=selectBox.options[srcIndex].value; 
              //
              //  The syntax of the item Value is:
              //  link type/repository name/item type/item id
              //
              //  In this case, we just need the item type and item id, so get those now.
              //
             const keyArray = selectedValue.split("/");
             let itemType = keyArray[2];
             let itemId = keyArray[3];
             editItemParms="portletType=";
             editItemParms=editItemParms.concat(portletType,'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>type=',itemType,'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>id=',itemId);

             if (editUrl.includes('?')) {
                  editUrl=editUrl.concat('<xsl:text disable-output-escaping="yes">&amp;</xsl:text>',editItemParms);
                  }

              else {
                  editUrl=editUrl.concat('?',editItemParms);
           }
 
              submitDisableAllForms();
              location.href=editUrl;

           }
           else
               alert(""+nothingselected);
        }
    }

    //
    // Sets the correct URL for removing an item.
    //
    function removeItem(selectBoxName, groupId, removeUrl, nothingselected, toomanyselected)
    {
      var selectBox = document.getElementById(selectBoxName);
      var i= 0;
      if (selectBox.options.length <xsl:text disable-output-escaping="yes">&gt;</xsl:text> 0)
      {
          for (var j = 0; j <xsl:text disable-output-escaping="yes">&lt;</xsl:text> selectBox.options.length; j++)
          {
              if (selectBox.options[j].selected)
             i++;
           }
       }

       if (i <xsl:text disable-output-escaping="yes">&gt;</xsl:text> 1)
       {
           alert(""+toomanyselected);
       }
       else
       {
           srcIndex = selectBox.selectedIndex;
           if (srcIndex <xsl:text disable-output-escaping="yes">&gt;</xsl:text>= 0)
           {
            
              var selectedValue=selectBox.options[srcIndex].value; 
              var retValue=confirm(confirmMessage);

              if (retValue) {
                  pageChanged(false);

                  //
                  //  The syntax of the item Value is:
                  //  link type/repository name/item type/item id
                  //
                  //  In this case, we just need the item type and item id, so get those now.
                  //
                 const keyArray = selectedValue.split("/");
                 let itemType = keyArray[2];
                 let itemId = keyArray[3];
                 removeItemParms="Type=";
                 removeItemParms=removeItemParms.concat(itemType,'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>id=',itemId,'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>relatedId=',groupId,'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>relatedType=Group','<xsl:text disable-output-escaping="yes">&amp;</xsl:text>parentTreeId=','<xsl:value-of select="$parentTreeId"/>');

                 if (removeUrl.includes('?')) {
                      removeUrl=removeUrl.concat('<xsl:text disable-output-escaping="yes">&amp;</xsl:text>',removeItemParms);
                      }

                  else {
                      removeUrl=removeUrl.concat('?',removeItemParms);
                      }
     
                  submitDisableAllForms();
                  // backDepth=-2;

                  removeResponse.contentWindow.location.replace(removeUrl);
              
                  }
             else {
                return retValue;
                } 
           }
           else
               alert(""+nothingselected);
        }
    }
    //
    // Select or values in a select list
    //
    function selectAllOptions(selBox)
    {
        if (selBox != null <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> selBox.options.length <xsl:text disable-output-escaping="yes">&gt;</xsl:text> 0)
        {
            for (var j = 0; j <xsl:text disable-output-escaping="yes">&lt;</xsl:text> selBox.options.length; j++)
            {
                selBox.options[j].selected = true;
            }
        }
    }

    function selectAllItems(name)
    {
         selBox = document.getElementById(name);
         selectAllOptions(selBox);
    }

    //
    // UnSelect all values in a select list
    //
    function unSelectAllOptions(selBox)
    {
        if (selBox != null <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> selBox.options.length <xsl:text disable-output-escaping="yes">&gt;</xsl:text> 0)
        {
            for (var j = 0; j <xsl:text disable-output-escaping="yes">&lt;</xsl:text> selBox.options.length; j++)
            {
                selBox.options[j].selected = false;
            }
        }
    }
    //
    // Rearrange the items in a SELECT LIST by moving it up or down
    //
    function changeOrder(selectBoxName, moveUp)
    {
      var selectBox = document.getElementById(selectBoxName);
      var srcText = srcValue = destText = destValue = "";
      var srcIndex = destIndex = 0;
      srcIndex = selectBox.selectedIndex;

       if (srcIndex <xsl:text disable-output-escaping="yes">&gt;</xsl:text>= 0)
       {
           pageChanged(true);

           switch (moveUp)
          {
               case false:
                  increment = 1
                  if (srcIndex +1 == selectBox.length)
                     return;
                  destIndex = srcIndex + increment;
                  break;
             case true:
                increment = -1
                if (srcIndex <xsl:text disable-output-escaping="yes">&lt;</xsl:text> 1) return;
                    destIndex = srcIndex + increment;
                break;
           }

          with (selectBox)
          {
            srcText  = options[srcIndex].text;
            srcValue = options[srcIndex].value;

            destText  = options[destIndex].text;
            destValue = options[destIndex].value;

            options[destIndex].text = srcText;
            options[destIndex].value = srcValue;

            options[srcIndex].text = destText;
            options[srcIndex].value = destValue;

            selectedIndex = destIndex;
           }
       }
       else
           pageChanged(false);


    }

    // call this function when a from field changed when Editing a Page, or when Saving or Cancelling
    function pageChanged(isChanged)
    {
        parent.isPageChanged = isChanged;
     
        /*
         *  Set the value in the input form to pass back to the server.
         *  This routine is called many times, sometimes with false after it had been called with true.
         *  For what we want to pass to the server, once the list is modified in any way, it shouldn't
         *  go back to false.
         */
        var listChangedInput = document.querySelector("input[name='listChanged']");

        if (isChanged) {
           listChangedInput.value=isChanged;
           }

    }

    //
    // Delete an item from a SELECT LIST.
    //
    function deleteOption(selectBoxName, removeConfirmMsg)
    {
      var retval = confirm(removeConfirmMsg);
      if (!retval) {
         pageChanged (false);
      } else {
         var selectBox = document.getElementById(selectBoxName);
         if (selectBox != null <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> selectBox.options.length <xsl:text disable-output-escaping="yes">&gt;</xsl:text> 0) {
             for (var i = 0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> selectBox.length; i++) {
                 if (selectBox.options[i].selected) {
                     selectBox.options[i]=null;
                     pageChanged(true);
                     i--;
                 }
             }
         }
      }
      return retval;
    }

</script>


</xsl:template>

</xsl:stylesheet>

