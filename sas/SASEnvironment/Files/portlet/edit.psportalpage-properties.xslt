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

<xsl:variable name="portletEditPageRank" select="$localeXml/string[@key='portletEditPageRank']/text()"/>
<xsl:variable name="portletEditPageRankTitle" select="$localeXml/string[@key='portletEditPageRankTitle']/text()"/>

<xsl:variable name="portletEditPageLocation" select="$localeXml/string[@key='portletEditPageLocation']/text()"/>
<xsl:variable name="portletEditPageLocationTitle" select="$localeXml/string[@key='portletEditPageLocationTitle']/text()"/>
<xsl:variable name="portletEditPageShareType" select="$localeXml/string[@key='portletEditPageShareType']/text()"/>
<xsl:variable name="portletEditPageShareTypeNotShared" select="$localeXml/string[@key='portletEditPageShareTypeNotShared']/text()"/>
<xsl:variable name="portletEditPageShareTypeAvailable" select="$localeXml/string[@key='portletEditPageShareTypeAvailable']/text()"/>
<xsl:variable name="portletEditPageShareTypeDefault" select="$localeXml/string[@key='portletEditPageShareTypeDefault']/text()"/>
<xsl:variable name="portletEditPageShareTypePersistent" select="$localeXml/string[@key='portletEditPageShareTypePersistent']/text()"/>
<xsl:variable name="portletMovePagePortlets" select="$localeXml/string[@key='portletMovePagePortlets']/text()"/>

<xsl:variable name="portletEditItemNameRequired" select="$localeXml/string[@key='portletEditItemNameRequired']/text()"/>

<xsl:variable name="portletHomePrototypeName" select="$localeXml/string[@key='portletHomePrototypeName']/text()"/>

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

<xsl:variable name="pageObject" select="$metadataContext/Multiple_Requests/GetMetadata/Metadata/PSPortalPage"/>
<xsl:variable name="pageName" select="$pageObject/@Name"/>
<xsl:variable name="pagePrototypeName" select="$pageObject/UsingPrototype/Tree/@Name"/>

<xsl:variable name="personObject" select="$metadataContext/Multiple_Requests/GetMetadataObjects/Objects/Person"/>

<!--  The parentTreeId can either be:
      - the user's root permission tree
      - a subtree in the hierarchy under the group's root permission tree.
      When we go to add the portlet, we need to know which root permission tree to add it to, so figure that out now.
-->

<xsl:variable name="parentTreeId" select="$pageObject/Trees/Tree/@Id"/>

<xsl:variable name="currentParentTree" select="$personObject/AccessControlEntries//Tree[@Id=$parentTreeId]"/>
<xsl:variable name="pageCurrentParentTreeId">
  <xsl:choose>
     <xsl:when test="$currentParentTree/@TreeType='Permissions Tree' or $currentParentTree/@TreeType=' Permissions Tree'">
     <xsl:value-of select="$currentParentTree/@Id"/>
     </xsl:when>
     <xsl:otherwise>
     <xsl:value-of select="$personObject/AccessControlEntries/AccessControlEntry/Objects/Tree[SubTrees//Tree[@Id=$parentTreeId]]/@Id"/>
     </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Try to determine if the user's home page or not? -->
<!-- There isn't an obvious way to figure this out, so going with if it is linked to a prototype that has Home as the name -->
<xsl:variable name="isPageHome">
  <xsl:choose>
    <xsl:when test="$pagePrototypeName=$portletHomePrototypeName">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/form.functions.xslt"/>

<!-- Main Entry Point -->

<xsl:template match="/">

    <xsl:call-template name="commonFormFunctions"/>
    <xsl:call-template name="thisPageScripts"/>

    <xsl:variable name="objectId" select="Mod_Request/NewMetadata/Id"/>

    <xsl:variable name="objectDesc" select="$pageObject/@Desc"/>
    <!-- TODO: Keywords not currently supported -->
    <xsl:variable name="objectKeywords"/>
    <xsl:variable name="pageRank" select="$pageObject/Extensions/Extension[@Name='PageRank']/@Value"/>

    <xsl:variable name="userName" select="Mod_Request/NewMetadata/Metaperson"/>

    <xsl:variable name="numberOfWriteableTrees" select="count($personObject/AccessControlEntries//Tree)"/>

    <xsl:variable name="isContentAdministrator">
      <xsl:choose>
         <xsl:when test="not($numberOfWriteableTrees=1)">1</xsl:when>
         <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:variable name="pageCurrentSharingType">
      <xsl:choose>
        <xsl:when test="$pageObject/Extensions/Extension[@Name='SharedPageAvailable']">available</xsl:when>    
        <xsl:when test="$pageObject/Extensions/Extension[@Name='SharedPageSticky']">persistent</xsl:when>    
        <xsl:when test="$pageObject/Extensions/Extension[@Name='SharedPageDefault']">default</xsl:when>   
        <xsl:otherwise>notshared</xsl:otherwise> 
      </xsl:choose>
    </xsl:variable> 
    <xsl:variable name="editLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/updateItem')"/>

<!--  NOTE: We set up a hidden formResponse iframe to capture the result so that we can either display the results (if debugging) or simply cause a "go back" to happen after the form is submitted (by using the iframe onload function).  The event handler to handle this is in the CommonFormFunctions template -->

    <form method="post" enctype="application/x-www-form-urlencoded" target="formResponse">
        <xsl:attribute name="action"><xsl:value-of select="$editLink"/></xsl:attribute>

        <input type="hidden" name="type" value="PSPortalPage"/>
        <input type="hidden" name="id"><xsl:attribute name="value"><xsl:value-of select="$objectId"/></xsl:attribute></input>

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
                      <xsl:attribute name="value"><xsl:value-of select="$pageName"/></xsl:attribute>
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
                      <xsl:attribute name="value"><xsl:value-of select="$objectDesc"/></xsl:attribute>
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
                <td class="commonLabel" nowrap="nowrap">
                    <label for="pageRank"><xsl:value-of select="$portletEditPageRank"/>: </label>
                </td>
                <td>&#160;</td>
                <td nowrap="nowrap" class="textEntry">
                    <input type="text" name="pageRank" size="5" id="pageRank">
                      <xsl:variable name="pageRankValue">
                      <xsl:choose>
                         <xsl:when test="$pageRank"><xsl:value-of select="$pageRank"/></xsl:when>
                         <xsl:otherwise>100</xsl:otherwise>
                      </xsl:choose>
                      </xsl:variable>
                      <xsl:attribute name="value"><xsl:value-of select="$pageRankValue"/></xsl:attribute>
                    </input>
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
<!--
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

                <td class="commonLabel" nowrap="nowrap">&#160;</td>
                <td>&#160;</td>
                <td>&#160;</td>

                <td width="100%">&#160;</td>
            </tr>
-->
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
                  <xsl:when test="$isContentAdministrator=1 and not($isPageHome='1')">
                        <td class="commonLabel" nowrap="nowrap">
                            <label for="parentTreeId"><xsl:value-of select="$portletEditPageLocation"/></label>
                        </td>
                        <td>&#160;</td>
                        <td class="textEntry">
                            <select name="parentTreeId" onchange="toggleScopeDiv();" id="parentTreeId">
                                <xsl:for-each select="$personObject/AccessControlEntries//Tree[@TreeType='Permissions Tree' or @TreeType=' Permissions Tree']">
                                   <xsl:sort select="@Name"/>
                                   <xsl:variable name="optionTreeName" select="@Name"/>
                                   <xsl:variable name="optionTreeId" select="@Id"/>
                                   <xsl:variable name="optionTreeNameDisplay">
                                      <xsl:choose>
                                         <xsl:when test="starts-with($optionTreeName,$userName)"><xsl:value-of select="$portletEditPageShareTypeNotShared"/></xsl:when>
                                         <xsl:otherwise><xsl:value-of select="$optionTreeName"/></xsl:otherwise>
                                      </xsl:choose>
                                   </xsl:variable>
                                <option><xsl:attribute name="value" select="$optionTreeId"/>
                                   <xsl:if test="$optionTreeId=$pageCurrentParentTreeId">
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
                         <input type="hidden" name="parentTreeId"><xsl:attribute name="value"><xsl:value-of select="$pageCurrentParentTreeId"/></xsl:attribute>
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
                        <select name="scope" id="scope">
                            <option value="0">
                            <xsl:if test="$pageCurrentSharingType='available'">
                                <xsl:attribute name="selected">true</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$portletEditPageShareTypeAvailable"/>
                            </option>
                            <option value="1">
                            <xsl:if test="$pageCurrentSharingType='default'">
                                <xsl:attribute name="selected">true</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$portletEditPageShareTypeDefault"/>

                            </option>       
                            <option value="2">
                            <xsl:if test="$pageCurrentSharingType='persistent'">
                                <xsl:attribute name="selected">true</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$portletEditPageShareTypePersistent"/>
                            </option>
                        </select>
                    </div>
                </td>
                <td width="100%">&#160;</td>
            </tr>

        <tr>
            <td><img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                </img>

            </td>
            <td><img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                </img>

            </td>
            <td><img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                </img>

            </td>
            <td valign="center" colspan="2" width="100%">
            <div id="containedElementsDiv" style="visibility: hidden; display: none">

            <table cellpadding="0" cellspacing="0" border="0" width="100%">
                <tr>
                    <td colspan="2"><img border="0" height="12" alt="" >
                         <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img>

                    </td>
                </tr>
                <tr>
                    <td><img border="0" width="12" alt="" >
                           <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img>

                    </td>
                    <td class="commonLabel">
                        <input type="checkbox" name="movePortletsOnPage" value="true" id="moveContainedElements" checked="checked"/>
                        <label for="moveContainedElements"><xsl:value-of select="$portletMovePagePortlets"/> </label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2"><img border="0" height="6" alt="" >
                         <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img>
                     </td>
                </tr>

                <tr>
                    <td><img border="0" width="12" alt="" >
                        <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img>
                    </td>
                    <td>
                    <div id="listOfElementsDiv" class="listOfItemsDiv">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                        <xsl:for-each select="$metadataContext/Multiple_Requests/GetMetadata/Metadata/PSPortalPage/LayoutComponents/PSColumnLayoutComponent/Portlets/PSPortlet">

                             <!-- Only want to include in the list the portlets that are in the same tree as the current page.
                             -->

                             <xsl:variable name="portletPermissionsTree" select="Trees/Tree"/>
                             <xsl:variable name="portletPermissionsTreeId" select="$portletPermissionsTree/@Id"/>
                             <xsl:if test="$pageCurrentParentTreeId=$portletPermissionsTreeId">

                             <tr>

                                 <td valign="center" nowrap="nowrap">

                                 <table border="0" cellpadding="0" cellspacing="0"
                                     width="100%">
                                     <tr>
                                         <td><img border="0" width="2" alt="" >
                                              <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img>

                                         </td>
                                         <td><img border="0" width="10" alt="" >
                                              <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img>

                                         </td>


                                         <td class="commonLabel" valign="center" nowrap="nowrap">
                                                <img border="0" width="16" height="16" alt='Portlet' >
                                                        <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Portlet.gif</xsl:attribute>
                                                </img>

                                         </td>
                                         <td>&#160;</td>
                                         <td class="commonLabel" nowrap="nowrap"><xsl:value-of select="@Name"/>
                                         </td>
                                         <td width="100%">&#160;</td>
                                     </tr>
                                 </table>

                                 </td>
                             </tr>
                             </xsl:if>

                          </xsl:for-each>

                    </table>

                    </div>
                    </td>
                </tr>
            </table>

            </div>
            </td>
            <td><img border="0" width="12" alt="" >
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

   backDepth=-2;

   var hasChanged = false;

   toggleScopeDiv('init');

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

   function toggleScopeDiv(parm) {

       /*
        *  Toggle the scope field visibility based on the sharing location.
        *
        *  NOTE: We only want to show the list of portlets to also move if
        *  the sharing location changes, not on initial entry.
        *
        *  NOTE: We never want to show the sharing location information about
        *  the user's home page. So check for that.
        *
        */
       if ('<xsl:value-of select="$isPageHome"/>'==='0') {

           var parentTreeSelect=document.getElementById('parentTreeId');
           var selectedValue=parentTreeSelect.options[parentTreeSelect.selectedIndex].value;
           var selectedText=parentTreeSelect.options[parentTreeSelect.selectedIndex].text;
           var scopeLabelDiv=document.getElementById('scopeLabelDiv');
           var scopeDiv=document.getElementById('scopeDiv');

           /*  
            *  If we are initializing the scope div information, only show
            *  sharing type if the current sharing information isn't 'not shared'
            */

           if (parm==='init') {
               /*
                *  If not shared, hide the option to select which sharing option
                */
               if (selectedText==='<xsl:value-of select="$portletEditPageShareTypeNotShared"/>') {

                  scopeLabelDiv.style.visibility="hidden";
                  scopeDiv.style.visibility="hidden";

                  }
               else {

                  scopeLabelDiv.style.visibility="";
                  scopeDiv.style.visibility="";

                  }


              }
           else {
               /*
                *  We only want to show this section if the sharing location has
                *  been changed AND we are not changing back to the one that was 
                *  originally set when entering the edit page AND we are not switching
                *  to not shared.
                */
/*
               if (selectedValue==='<xsl:value-of select="$pageCurrentParentTreeId"/>' || selectedText==='<xsl:value-of select="$portletEditPageShareTypeNotShared"/>') {
*/

               if (selectedValue==='<xsl:value-of select="$pageCurrentParentTreeId"/>') {
                  scopeLabelDiv.style.visibility="hidden";
                  scopeDiv.style.visibility="hidden";
                  setMoveContainedElementsDiv('hidden');

                  }
               else {

               /*
                *  Showing the sharing scope field doesn't make sense if we are switching it to be not shared 
                */

               if (selectedText==='<xsl:value-of select="$portletEditPageShareTypeNotShared"/>') {
                  scopeLabelDiv.style.visibility="hidden";
                  scopeDiv.style.visibility="hidden";
                  }
               else {
                  scopeLabelDiv.style.visibility="";
                  scopeDiv.style.visibility="";
                  }
               setMoveContainedElementsDiv('visible');

                  }
               }
           }

     }

  function setMoveContainedElementsDiv(visibility) {

    var elementDiv = document.getElementById('containedElementsDiv');

    if (visibility=="hidden") {

       elementDiv.style.visibility="hidden";
       elementDiv.style.display="none";
       }
    else {
       elementDiv.style.visibility="visible";
       elementDiv.style.display="block";
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

