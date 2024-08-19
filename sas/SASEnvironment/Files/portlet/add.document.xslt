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

<xsl:variable name="portletSearchButton" select="$localeXml/string[@key='portletSearchButton']/text()"/>
<xsl:variable name="portletSearchCollapse" select="$localeXml/string[@key='portletSearchCollapse']/text()"/>
<xsl:variable name="portletSearchExpand" select="$localeXml/string[@key='portletSearchExpand']/text()"/>
<xsl:variable name="portletSearchNoResults" select="$localeXml/string[@key='portletSearchNoResults']/text()"/>
<xsl:variable name="portletSearchNoQuery" select="$localeXml/string[@key='portletSearchNoQuery']/text()"/>
<xsl:variable name="portletSearchNoSelection" select="$localeXml/string[@key='portletSearchNoSelection']/text()"/>
<xsl:variable name="portletSearchOnlyOneSelection" select="$localeXml/string[@key='portletSearchOnlyOneSelection']/text()"/>

<xsl:variable name="portletSearchTypeTitle" select="$localeXml/string[@key='portletSearchTypeTitle']/text()"/>
<xsl:variable name="portletSearchTypeReport" select="$localeXml/string[@key='portletSearchTypeReport']/text()"/>
<xsl:variable name="portletSearchTypeStoredProcess" select="$localeXml/string[@key='portletSearchTypeStoredProcess']/text()"/>

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

    <xsl:variable name="searchTableMaxHeight">
      <xsl:choose>
          <xsl:when test="Mod_Request/NewMetadata/SearchTableMaxHeight"><xsl:value-of select="Mod_Request/NewMetadata/SearchTableMaxHeight"/></xsl:when>
          <xsl:otherwise>30em</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

<div id="pages">

  <div class="tabcontent" id="create">

   <form name="createForm" method="post" target="formResponse">
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
</div>


  <div class="tabcontent" id="search">

     <form name="taskSearchForm" id="taskSearchForm" method="post" onsubmit="submitDisableAllForms(); " target="formResponse">
        <xsl:attribute name="action"><xsl:value-of select="$addLink"/></xsl:attribute>

                <!-- This is a bit "quirky".  Even though the object we selected from the search to associate with this portlet is not a Document object, we
                     set the Type=Document so that it follows the same processing path on the server as if we were creating a document.
                 -->

                <input type="hidden" name="Type" value="Document"/>

                <!-- Include parameters that are required when creating a Document
                 -->
                <!-- Indicate that this is a "reference" Document, ie. we are simply creating a reference to another object (info in ReferenceId and ReferenceType) -->

                <input type="hidden" name="contentType" id="createreference" value="Reference"/>
                <input type="hidden" name="URL" value=""/>
                <input type="hidden" name="Name" value=""/>

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

                <input type="hidden" name="searchTypes" id="searchTypes" value=""/>

                <!-- Set the information about the object we are creating a reference Document to point to -->

                <!-- these fields will be set dynamically based on what is selected in the search results -->

                <input type="hidden" name="ReferenceId" id="referenceid" value=""/>
                <input type="hidden" name="ReferenceType" id="referencetype" value=""/>

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
                                    <td><!-- Content Types table -->
                                    <table cellpadding="3" cellspacing="0" class="tableBorder" width="100%">

                                        <tr class="optionsTableHeader">

                                            <th scope="col" class="portalTableSubheadingTrans" nowrap="nowrap">
                                            <input id="topBox" type="checkbox" name="topBox" value="" onclick='checkMe("item",2, "topBox"); return true;' />
                                            <xsl:value-of select="$portletSearchTypeTitle"/></th>
                                        </tr>
                                            <tr>
                                                <td nowrap="nowrap" class="commonLabel">
             
                                                <input type="checkbox" name="typesasreport" value="SASReport" onclick="toggleTopChkBox('item', '2', 'topBox'); return true" id="item1"/> <label
                                                    for="item1"><xsl:value-of select="$portletSearchTypeReport"/></label></td>
                                            </tr>
                                            
                                            <tr>
                                                <td nowrap="nowrap" class="commonLabel">
             
                                                <input type="checkbox" name="typesasstoredprocess" value="SASStoredProcess" onclick="toggleTopChkBox('item', '2', 'topBox'); return true" id="item2"/> <label
                                                    for="item2"><xsl:value-of select="$portletSearchTypeStoredProcess"/></label></td>
                                            </tr>
                                            
                                    </table>
                                    <!-- End Content Types table --></td>
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
<!--
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
-->
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
                                 <xsl:attribute name="style">height: <xsl:value-of select="$searchTableMaxHeight"/>; overflow: auto;</xsl:attribute>
                             
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
                            <input class="button" type="button" onclick='if (submitDisableAllForms()) return cancelForm(); else return false;'>

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

<iframe id="formResponse" name="formResponse" style="display:block" width="100%">

</iframe>

</xsl:template>

<xsl:template name="thisPageScripts">

<xsl:variable name="searchLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/search')"/>

<script>

   var hasChanged = false;

   rememberCurrentTab=false;

   backDepth=-1;

   var searchErrorMsg = "<xsl:value-of select="$portletSearchNoQuery"/>";

   var searchLink="<xsl:value-of select="$searchLink"/>";
 
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
          *
          *  Because the search results could have different types of objects in it, the id of the search item is in the form
          *  Type/Id
          */
         
         document.getElementById('referenceid').value=selectedCheckboxId.substring(selectedCheckboxId.indexOf('/')+1);
         document.getElementById('referencetype').value=selectedCheckboxId.substring(0,selectedCheckboxId.indexOf('/'));

         return true;

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
            if (element.checked) {

               if (values == "") 
                  values=values + element.value;
               else
                  values=values + "," + element.value;

               }
            i++;
        }
        var element2 = document.getElementById("searchTypes");
        element2.value=values;
    }

    function submitSearch(jsMessage) {

            /*
             *  Since we may be inside a larger form, make sure we
             *  don't propagate the event that got us here.
             */
            event.preventDefault();

            element=document.getElementById("searchresults");

            getContentTypeChkBoxes();

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

               var query = encodeURIComponent(document.getElementById('query').value);

               var searchURL=searchLink;
               searchURL=searchURL.concat('<xsl:text disable-output-escaping="yes">&amp;</xsl:text>','query=',query);

               <!-- Passing a type of "Content" implies that we will search "all" content, with the ability to limit the 
                    types of content being searched by passing the "searchTypes" parameter with a comma separated list of types to search
               -->
               searchURL=searchURL.concat('<xsl:text disable-output-escaping="yes">&amp;</xsl:text>','type=Content');
               searchURL=searchURL.concat('<xsl:text disable-output-escaping="yes">&amp;</xsl:text>','searchTypes=',document.getElementById("searchTypes").value);

               xhttp.open("GET", searchURL, true);
               xhttp.send();

               /* Done processing the file request, exit and let the onreadystatechange function do it's thing */
               return;

            }
            else {
                    return false;
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

    function toggleTopChkBox(itemname,total, topBoxId) {
       var elem;
       elem = document.getElementById(topBoxId);
       checkTopBox = true;

       if (elem != null  <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> total > 0) {
           for (var i = 1; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text>= total; i++) {
               chkBox = document.getElementById(itemname + i);
               if (chkBox != null <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> !chkBox.checked) {
                   checkTopBox = false;
                   break;
               }
           }

           if (checkTopBox)
              elem.checked = true;
           else
              elem.checked = false;
       }

    }

    function checkMe(name, total, topBoxId)
    {
       var elem;
       elem = document.getElementById(topBoxId);
       if (elem != null  <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> total > 0) {
           var isChecked = elem.checked;

           if (isChecked) {
               for (var i = 1; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text>= total; i++) {
                 var  chkBox = document.getElementById(name + i);
                 if (chkBox != null)
                   chkBox.checked = true;
               }
            } else {
               for (var i = 1; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text>= total; i++) {
                 var  chkBox = document.getElementById(name + i);
                 if (chkBox != null)
                   chkBox.checked = false;
               }
            }
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

