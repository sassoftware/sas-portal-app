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

<xsl:variable name="portletSearchButton" select="$localeXml/string[@key='portletSearchButton']/text()"/>
<xsl:variable name="portletSearchCollapse" select="$localeXml/string[@key='portletSearchCollapse']/text()"/>
<xsl:variable name="portletSearchExpand" select="$localeXml/string[@key='portletSearchExpand']/text()"/>
<xsl:variable name="portletSearchNoResults" select="$localeXml/string[@key='portletSearchNoResults']/text()"/>
<xsl:variable name="portletSearchNoQuery" select="$localeXml/string[@key='portletSearchNoQuery']/text()"/>
<xsl:variable name="portletSearchNoSelection" select="$localeXml/string[@key='portletSearchNoSelection']/text()"/>
<xsl:variable name="portletSearchOnlyOneSelection" select="$localeXml/string[@key='portletSearchOnlyOneSelection']/text()"/>

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

    <xsl:variable name="displayTabCount" select="count(Mod_Request/NewMetadata/Tabs/Tab)"/>

    <xsl:variable name="userName" select="Mod_Request/NewMetadata/Metaperson"/>

    <xsl:variable name="personObject" select="$metadataContext/GetMetadataObjects/Objects/Person"/>
    <xsl:variable name="numberOfWriteableTrees" select="count($personObject/AccessControlEntries//Tree)"/>

    <xsl:variable name="isContentAdministrator">
      <xsl:choose>
         <xsl:when test="not($numberOfWriteableTrees=1)">1</xsl:when>
         <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="parentTreeId" select="Mod_Request/NewMetadata/ParentTreeId"/>

    <xsl:variable name="addLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/createItem')"/>

<!--  NOTE: We set up a hidden formResponse iframe to capture the result so that we can either display the results (if debugging) or simply cause a "go back" to happen after the form is submitted (by using the iframe onload function).  The event handler to handle this is in the CommonFormFunctions template -->

<div id="pages">

  <div class="tabcontent" id="create">

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
                                <xsl:for-each select="$personObject/AccessControlEntries//Tree">
                                   <xsl:sort select="@Name"/>
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
                         <input type="hidden" name="parentTreeId"><xsl:attribute name="value"><xsl:value-of select="$personObject/AccessControlEntries/AccessControlEntry/Objects/Tree/@Id"/></xsl:attribute>
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
                <input class="button" type="button" onclick='if (submitDisableAllForms()) history.go(backDepth); else return false;'>
                    <xsl:attribute name="value"><xsl:value-of select="$cancelButton"/></xsl:attribute>
                </input>
            </td>
            <td width="100%" />
        </tr>

        </table>
    </form>

  </div>

  <div class="tabcontent" id="search">

     <form name="taskSearchForm" id="taskSearchForm" method="post" onsubmit="submitDisableAllForms(); " target="formResponse">
        <xsl:attribute name="action"><xsl:value-of select="$addLink"/></xsl:attribute>

                <input type="hidden" name="type" id="type" value="PSPortalPage"/>

                <input type="hidden" name="parentTreeId" id='searchparenttreeid'>
                     <xsl:attribute name="value"><xsl:value-of select="$personObject/AccessControlEntries/AccessControlEntry/Objects/Tree/@Id"/></xsl:attribute>
                </input>

                <!-- the id will be set dynamically based on what is selected in the search results -->
                <input type="hidden" name="id" id="searchpageid" value=""/>

                <!-- Container table -->
                <table id="resultsdiv" border="0" cellspacing="0" cellpadding="0" width="100%" valign="top" height="100%">
                    <tr>
                        <td class="dataEntryBG" id="searchOptions" valign="top">
                            <!-- Sidebar table -->
                            <table id="sidebar" border="0" cellspacing="6" cellpadding="3" valign="top" style="">
                                <tr>
                                    <td>
                                        <!-- Keywords table -->
                                        <table cellpadding="3" cellspacing="0" width="100%">
                                            <tr>
                                                <td class="commonLabel">
                                                    <label for="query"><xsl:value-of select="$portletEditItemKeywords"/>: </label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="textEntry" onkeypress="if(event.keyCode==13) return submitSearch(searchErrorMsg); ">
                                                    <input type="text" name="query" size="30" value=""  id="query"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="right">
                                                    <input class="button" type="button" onclick='return submitSearch(searchErrorMsg);'>
                                                       <xsl:attribute name="value"><xsl:value-of select="$portletSearchButton"/></xsl:attribute>
                                                    </input>
                                                </td>
                                            </tr>
                                        </table>
                                        <!-- End Keywords table -->
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <!-- Search Options table -->
                                        <!--  Paging support not supported from original portal 
                                        <table cellpadding="3" cellspacing="0" class="tableBorder" width="100%">
                                            <tr class="searchResultsTableHeader">
                                                <td colspan="2" class="portalTableSubheadingTrans" nowrap="nowrap">Search Results</td>
                                            </tr>
                                            <tr>
                                                <td align="left" nowrap="nowrap" class="commonLabel">
                                                    <label for="resultsperpage">Results per page: </label>
                                                </td>
                                                <td align="left" nowrap="nowrap" width="100%">
                                                    <select name="noOfRows" size="1" onchange="submitChangeRows();return true;" id="resultsperpage">
                                                        <option value="20" selected="selected">20</option>
                                                        <option value="30">30</option>
                                                        <option value="40">40</option>
                                                        <option value="50">50</option>
                                                    </select>
                                                </td>
                                            </tr>
                                        </table>
                                        -->
                                        <!-- End Search Options table -->
                                    </td>
                                </tr>
                                <!-- Put some space in the search options to have the page line up better with Create tab upon initial entry -->
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                            </table>
                        </td>
                        <!-- End Sidebar table -->
                        <td class="searchResultsTableColumn">
                            <div id="expandSidebar">
                                <img border="0" valign="top" width="11" height="16" onclick='toggleSearchOptionsDiv(); ' >
                                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/CollapseLeftArrows.gif</xsl:attribute>
                                     <xsl:attribute name="alt"><xsl:value-of select="$portletSearchCollapse"/></xsl:attribute>
                                     <xsl:attribute name="title"><xsl:value-of select="$portletSearchCollapse"/></xsl:attribute>
				</img>

                            </div>
                            <div id="collapseSidebar" style="display: none">
                                <img border="0" valign="top" width="11" height="16" onclick='toggleSearchOptionsDiv(); ' >
                                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/CollapseRightArrows.gif</xsl:attribute>
                                     <xsl:attribute name="alt"><xsl:value-of select="$portletSearchExpand"/></xsl:attribute>
                                     <xsl:attribute name="title"><xsl:value-of select="$portletSearchExpand"/></xsl:attribute>
				</img>
                                
                            </div>
                        </td>
                        <td>
                            <img border="0" height="12" alt="">
                                 <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
		            </img>
                            
                        </td>
                        <td width="100%" valign="top">
                            <table border="0" cellspacing="0" cellpadding="0" width="100%">
                                <tr>
                                    <td>
                                       <img border="0" height="12" alt="">
				            <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
				       </img>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                       <img border="0" alt="">
				            <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
				       </img>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                       <img border="0" height="6" alt="">
				            <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
				       </img>
                                    </td>
                                </tr>
                            </table>
                            <div id="searchresults" name="searchresults">
                               <xsl:comment> Search Results table </xsl:comment>
                               <table border="0" width="100%" cellspacing="0" cellpadding="1">
                                <!--  Initial display - no search results found -->
                                <tr align="center">
                                    <td class="textEntry" colspan="12" align="center"><xsl:value-of select="$portletSearchNoResults"/></td>
                                </tr>
                                </table>
                               <xsl:comment> End Search Results table </xsl:comment>
                            </div>
 
                            <table border="0" width="100%" cellspacing="0" cellpadding="1">
                                <tr align="center">
                                    <td colspan="12" align="center">
                                       <img border="0" height="6" alt="">
				            <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
				       </img>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>&#160;</td>
                    </tr>
                   
                    <tr>
                        <td colspan="5" class="wizardMessageFooter" height="1"></td>
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
                            <input class="button" type="submit" onclick='if (validateSearchForm()) return submitDisableAllForms(); else return false;'>
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

  </div>
</div>
      <!-- This iframe is here to capture the response from submitting the form -->
      
      <iframe id="formResponse" name="formResponse" style="display:none" width="100%">
      
      </iframe>


</xsl:template>

<xsl:template name="thisPageScripts">

<xsl:variable name="searchLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/search')"/>

<script>

   var hasChanged = false;

   rememberCurrentTab=false;

   backDepth=-2;

   toggleScopeDiv();

   var searchErrorMsg = "<xsl:value-of select="$portletSearchNoQuery"/>";

   var searchLink="<xsl:value-of select="$searchLink"/>";

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
   /* 
    *  Validate fields in search form
    */

   function validateSearchForm() {

      var noResultSelected = "<xsl:value-of select="$portletSearchNoSelection"/>";
      var tooManyResultsSelected = "<xsl:value-of select="$portletSearchOnlyOneSelection"/>";

      searchResultsTable=document.getElementById('searchResultsTable');
      /*
       *  Make sure a search result is selected.
       */

      if (searchResultsTable==null) {

            /*  If the "No Search Results" table is shown, it doesn't have the id on the table
             *  so nothing can be selected.
             */

            alert(""+noResultSelected);
            return false;
          }

      /*
       *  Get all of the checkboxes and see how many are selected, min=1, max=1
       */

      const items = searchResultsTable.querySelectorAll('input');

      var selectedCount=0;
      var selectedCheckboxId='';

      for (let i = 0; i  &lt; items.length; i++) {
          var item=items[i];

          if (item.type='checkbox') {
             if (item.checked) {
                selectedCount=selectedCount+1;
                selectedCheckboxId=item.id;

                }
             }
          }
     
      if (selectedCount==0) {
         alert(""+noResultSelected);
         return false;
         }
      else if (selectedCount>1) {
         alert(""+tooManyResultsSelected);
         return false;

         }

      else {

         /*
          *  Set the selected id for the input form
          */

         document.getElementById('searchpageid').value=selectedCheckboxId;

         return true;

        } 
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

       if (parentTreeSelect) {

       if (parentTreeSelect instanceof HTMLInputElement) {
              scopeLabelDiv.style.visibility="hidden";
              scopeDiv.style.visibility="hidden";
          }
       else {
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
        }
     }

    function toggleSearchOptionsDiv() {
        var searchOptions = document.getElementById("searchOptions");
        // var optionsDisplayStyle = document.getElementById("optionsDisplayStyle");
        var collapseImageDiv = document.getElementById("collapseSidebar");
        var expandImageDiv = document.getElementById("expandSidebar");
        var visibility = searchOptions.style.display;
        if (visibility == '') {
            searchOptions.style.display = 'none';
            // optionsDisplayStyle.value = 'none';
            collapseImageDiv.style.display = '';
            expandImageDiv.style.display = 'none';
        } else {
            searchOptions.style.display = '';
            // optionsDisplayStyle.value = '';
            collapseImageDiv.style.display = 'none';
            expandImageDiv.style.display = '';
        }
    }

    // Function to check for empty query fields and alert the user to enter a value
    function validate(fieldName,text)
    {
        var object = document.getElementById(fieldName);

        if (object == null || object.value.trim().length > 0)
            return true;
        else
        {
            alert(""+text);
            if (navigator.appName.indexOf('Netscape') > -1)
            {
                object.focus();
            }
            return false;
        }
    }

    function getContentTypeChkBoxes() {
        values = "";
        var i=1;
        while (true) {
            id = "item" + i;
            var element = document.getElementById(id);
            if (element == null)
               break;
            if (i==1)
               values = values + element.checked;
            else
               values = values + "," + element.checked;
            i++;
        }
        var element2 = document.getElementById("selectedItemString");
        element2.value=values;
    }

    function submitSearch(jsMessage) {

            /*
             *  Since we may be inside a larger form, make sure we
             *  don't propagate the event that got us here.
             */
            event.preventDefault();

            element=document.getElementById("searchresults");

            // getContentTypeChkBoxes();  
            if (validate("query", jsMessage)) {
               submitDisableAllForms(); 

               /* Make an HTTP request to get search results */
               xhttp = new XMLHttpRequest();

               /*
                *  Start On State Change function definition
                */

               xhttp.onreadystatechange = function() {

                 if (this.readyState == 4) {
                   if (this.status == 200) {
                      element.innerHTML = this.responseText;

                      /*
                       *  Execute any scripts that may be in the generated text
                       *  Scripts in dynamically generted content aren't parsed and executed
                       *  Thus here we need to explicitly find all of the script elements and
                       *  add them as children (which will cause the execution).
                       *  NOTE: experimented with several ways of doing this, this is the only
                       *  way I found that would both execute them AND make the contents of the
                       *  scripts available to other scripts.
                       */
                      element.querySelectorAll('script').forEach(function(node) {
                         script = document.createElement('script');
                         script.innerHTML=node.innerText;
                         element.appendChild(script);

                         });

                      }
                   if (this.status == 404) {
                      element.innerHTML = "Page not found.";
                      }
                   }
                 }
               /*
                * End  On State Change function definition
                */

               var query = document.getElementById('query').value;


               var searchURL=searchLink;
               searchURL=searchURL.concat('<xsl:text disable-output-escaping="yes">&amp;</xsl:text>','query=',query);
               searchURL=searchURL.concat('<xsl:text disable-output-escaping="yes">&amp;</xsl:text>','type=PSPortalPage');
               xhttp.open("GET", searchURL, true);
               xhttp.send();

               /* Done processing the file request, exit and let the onreadystatechange function do it's thing */
               return;

            }
            else {
                    return false;
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

