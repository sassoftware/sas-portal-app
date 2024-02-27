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

<xsl:variable name="portletEditPageNumberOfColumns" select="$localeXml/string[@key='portletEditPageNumberOfColumns']/text()"/>
<xsl:variable name="portletEditPageNumberOfColumns1" select="$localeXml/string[@key='portletEditPageNumberOfColumns1']/text()"/>

<xsl:variable name="portletEditPageNumberOfColumns2"  select="$localeXml/string[@key='portletEditPageNumberOfColumns2']/text()"/>
<xsl:variable name="portletEditPageNumberOfColumns3" select="$localeXml/string[@key='portletEditPageNumberOfColumns3']/text()"/>
<xsl:variable name="portletEditPageColumnWidth"  select="$localeXml/string[@key='portletEditPageColumnWidth']/text()"/>
<xsl:variable name="portletEditPageColumnPercent" select="$localeXml/string[@key='portletEditPageColumnPercent']/text()"/>
<xsl:variable name="portletEditPagePortletLayout" select="$localeXml/string[@key='portletEditPagePortletLayout']/text()"/>
<xsl:variable name="portletEditPageLayout" select="$localeXml/string[@key='portletEditPageLayout']/text()"/>
<xsl:variable name="portletEditPageLayoutColumn" select="$localeXml/string[@key='portletEditPageLayoutColumn']/text()"/>
<xsl:variable name="portletEditPageLayoutGrid"  select="$localeXml/string[@key='portletEditPageLayoutGrid']/text()"/>
<xsl:variable name="portletEditPageAddPortlets"  select="$localeXml/string[@key='portletEditPageAddPortlets']/text()"/>

<xsl:variable name="portletEditPageColumn1Heading" select="$localeXml/string[@key='portletEditPageColumn1Heading']/text()"/>
<xsl:variable name="portletEditPageColumn2Heading" select="$localeXml/string[@key='portletEditPageColumn2Heading']/text()"/>
<xsl:variable name="portletEditPageColumn3Heading" select="$localeXml/string[@key='portletEditPageColumn3Heading']/text()"/>
<xsl:variable name="portletEditPageColumnLayoutMoveUp" select="$localeXml/string[@key='portletEditPageColumnLayoutMoveUp']/text()"/>
<xsl:variable name="portletEditPageColumnLayoutMoveDown"  select="$localeXml/string[@key='portletEditPageColumnLayoutMoveDown']/text()"/>
<xsl:variable name="portletEditPageColumnLayoutMoveLeft"  select="$localeXml/string[@key='portletEditPageColumnLayoutMoveLeft']/text()"/>
<xsl:variable name="portletEditPageColumnLayoutMoveRight" select="$localeXml/string[@key='portletEditPageColumnLayoutMoveRight']/text()"/>
<xsl:variable name="portletEditPageColumnLayoutRemove"  select="$localeXml/string[@key='portletEditPageColumnLayoutRemove']/text()"/>
<xsl:variable name="portletEditPageDeleteRow" select="$localeXml/string[@key='portletEditPageDeleteRow']/text()"/>

<xsl:variable name="portletEditPageHasChangedMessage" select="$localeXml/string[@key='portletEditPageHasChangedMessage']/text()"/>

<xsl:variable name="portletEditPageRemovePortlet"  select="$localeXml/string[@key='portletEditPageRemovePortlet']/text()"/>
<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/form.functions.xslt"/>

<!-- Global Variables -->

<xsl:variable name="pageObject" select="$metadataContext/GetMetadata/Metadata/PSPortalPage"/>

<xsl:variable name="parentTreeId" select="$pageObject/Trees/Tree/@Id"/>

<xsl:variable name="columnLayouts" select="$pageObject/LayoutComponents/*"/>
<xsl:variable name="numberOfColumns" select="count($pageObject/LayoutComponents/*)"/>
<xsl:variable name="pageId" select="$pageObject/@Id"/>
<xsl:variable name="pageType" select="name($pageObject)"/>

<!-- 
      Main Entry Point
-->
<xsl:template match="/">

<xsl:call-template name="commonFormFunctions"/>
<xsl:call-template name="thisPageScripts"/>

<xsl:variable name="saveLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/updateItem')"/>

<xsl:variable name="addPortletLink">addItem.html</xsl:variable>

<!--  Implementation Notes:

      In the original Portal, there were 2 layout options, Column and Grid.
      In the edit page for a portal page, if you selected Column, then at the bottom of the 
      page you were presented n columns (based on the number of columns selected for this page) and you
      placed portlets in the correct column by using the Move Right/Move Left arrows.   When Add Portlets...
      was selected, the Portlet was always added to the first column and you had to move it left if you
      wanted it in a different column.

      if Grid layout was selected, you were presented a "row" view of the page, with the number of columns in
      each row matching the number of columns selected for that page.   To the left of the row layout, there was
      a box of "available" portlets that could be paced in a cell on the grid.  When you selected Add Portlets...
      the portlet was added to the list of available portlets, and the drop down for each cell would be updated to
      reflect that there was a new portlet available to be placed.  To place it in a cell, the user selected it from the
      pull down of that cell.  The user would have to select "Add Row" to add another row to the grid.

      For the first release of this, only the Column Layout mode will be supported.  Thus, references to the available
      list, add row, etc. have either been removed or disabled in this file.

 -->
      <!-- This code to go back is a little funky.  We were initially called via the Edit Page Contents popup, which added an extra item
           to the history list so the popup would be shown and not scroll the page.  thus, we need to go back -2 instead of the standard -1
           to miss the extra popup page
      -->
<form name="pageForm" 
      method="post" 
      onsubmit="quickSelect('Column', 3, true);" 
      target="formResponse">
      <xsl:attribute name="action"><xsl:value-of select="$saveLink"/></xsl:attribute>

    <input type="hidden" name="id"><xsl:attribute name="value"><xsl:value-of select="$pageId"/></xsl:attribute></input>
    <input type="hidden" name="type"><xsl:attribute name="value"><xsl:value-of select="$pageType"/></xsl:attribute></input>

    <table border="0" cellpadding="0" cellspacing="0" width="100%" class="dataEntryBG">
        <tr>
            <td colspan="8"><img border="0"  height="24" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                 </img>

             </td>
        </tr>
        <tr>
            <td colspan="8" align="center" valign="center" width="100%">
             <div id="portal_message"></div>
            </td>
        </tr>
        <tr>
            <!--  Type of Layout -->
            <td>
            <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
             </td>
            <td class="commonLabel" nowrap="nowrap">
                <xsl:value-of select="$portletEditPageLayout"/>
            </td>
            <td>
             <img border="0"  width="2" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
             </td>
             <xsl:variable name="layoutExtension" select="$pageObject/Extensions/Extension[@Name='LayoutType']"/>

            <xsl:variable name="layoutType">
               <xsl:choose>
               <xsl:when test="$layoutExtension/@Value">

                  <xsl:choose>
                    <!-- TODO: Add support for Grid, for now everything is column based -->
                    <xsl:when test="$layoutExtension/@Value='Grid'">Column</xsl:when>
                    <xsl:when test="$layoutExtension/@Value=''">Column</xsl:when>
                    <xsl:otherwise><xsl:value-of select="$layoutExtension/@Value"/></xsl:otherwise>
                  </xsl:choose>
               </xsl:when>

               <xsl:otherwise>Column</xsl:otherwise>

               </xsl:choose>
            </xsl:variable>

            <td class="textEntry" nowrap="nowrap" colspan="5">
                <input type="radio" name="layoutType" value="Column" onclick="toggleLayout();hasChanged=true;" id="columnLayout">
                    <xsl:if test="$layoutType='Column'">
                      <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:if>
                </input>
                <xsl:value-of select="$portletEditPageLayoutColumn"/> 
             <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
                <!-- disabled because we aren't currently supporting grid layout -->
                <input type="radio" name="layoutType" value="Grid" onclick="toggleLayout();hasChanged=true;" id="gridLayout" disabled="true">
                    <xsl:if test="$layoutType='Grid'">
                      <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:if>
                </input>
                <xsl:value-of select="$portletEditPageLayoutGrid"/> 
            </td>
        </tr>
        <tr>
            <td colspan="8">
             <img border="0" height="6" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
             </td>
        </tr>
        <tr>
            <!-- Number of Columns on the Page -->

            <td>
             <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>

            </td>
            <td class="commonLabel" nowrap="nowrap">
                <xsl:value-of select="$portletEditPageNumberOfColumns"/>
            </td>
            <td>
             <img border="0"  width="2" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>

            <td class="commonLabel" nowrap="nowrap">
                <input type="radio" name="noOfColumns" value="1" onclick="moveListContents('Column2','Column1');moveListContents('Column3','Column1');newToggle(); toggleColumnWidths(); buildNewDataStructure();hasChanged=true;" id="onecolumn">
                <xsl:if test="$numberOfColumns='1'">
                   <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
                </input>
                <label for="onecolumn">
                <xsl:value-of select="$portletEditPageNumberOfColumns1"/>
                </label>
            </td>
            <td>
             <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
             </td>
            <td class="commonLabel" nowrap="nowrap">
                <input type="radio" name="noOfColumns" value="2" onclick="moveListContents('Column3','Column2');newToggle(); toggleColumnWidths(); buildNewDataStructure();hasChanged=true;" id="twocolumns">
                <xsl:if test="$numberOfColumns='2'">
                   <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
                </input>
                <label for="twocolumns">
                <xsl:value-of select="$portletEditPageNumberOfColumns2"/>
                </label>
            </td>
            <td>
             <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>

             </td>
            <td class="commonLabel" nowrap="nowrap" width="100%">
                <input type="radio" name="noOfColumns" value="3" onclick="newToggle(); toggleColumnWidths(); buildNewDataStructure();hasChanged=true;" id="threecolumns">
                <xsl:if test="$numberOfColumns='3'">
                   <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
                </input>
                <label for="threecolumns">
                <xsl:value-of select="$portletEditPageNumberOfColumns3"/>
                </label>
            </td>
        </tr>
        <tr>
            <td colspan="8">
             <img border="0"  height="6" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
             </td>
        </tr>
        <tr>
            <td>
             <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>

             </td>
            <td class="commonLabel" nowrap="nowrap">
                <xsl:value-of select="$portletEditPageColumnWidth"/>
            </td>
            <td>
             <img border="0"  width="2" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>
            <td class="textEntry" nowrap="nowrap">
             <img border="0"  width="2" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
                
                <input type="text" name="column1Width" size="2" id="column1Width">
                  <xsl:call-template name="setInitialColumnPercentages">
                     <xsl:with-param name="layoutObject" select="$columnLayouts[1]"/>
                  </xsl:call-template>
                </input>
                <xsl:value-of select="$portletEditPageColumnPercent"/>
            </td>
            <td>
             <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>
            <td class="textEntry" nowrap="nowrap">
                <span id="unit2" style="display:block;">
                <img border="0"  width="2" alt="" >
                    <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                 </img>
                    <input type="text" name="column2Width" size="2" value="0" id="column2Width">
                     <xsl:call-template name="setInitialColumnPercentages">
                        <xsl:with-param name="layoutObject" select="$columnLayouts[2]"/>
                     </xsl:call-template>
                    </input>
                    <xsl:value-of select="$portletEditPageColumnPercent"/>
                </span>
                <span id="unit2-hidden" style="display:none;">
                     <img border="0"  width="65" height="2" alt="" >
                         <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                      </img>
                </span>
            </td>
            <td>
            <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>
            <td class="textEntry" nowrap="nowrap" width="100%">
                <span id="unit3" style="display:block;">
                    <img border="0"  width="2" alt="" >
                        <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                     </img>
                    <input type="text" name="column3Width" size="2" value="0" id="column3Width">
                     <xsl:call-template name="setInitialColumnPercentages">
                        <xsl:with-param name="layoutObject" select="$columnLayouts[3]"/>
                     </xsl:call-template>
                    </input>
                    <xsl:value-of select="$portletEditPageColumnPercent"/>
                </span>
                <span id="unit3-hidden" style="display:none;">
                         <img border="0"  width="65" height="2" alt="" >
                             <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                          </img>

                </span>
            </td>
        </tr>
        <tr>
            <td colspan="8">
            <img border="0"  width="6" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>
        </tr>
    </table>

    <!--   Column Layout Div (of layout=By Column) -->

    <div id="columnLayoutDiv" style="display:block">
        <table border="0" cellpadding="0" cellspacing="0" width="100%" class="dataEntryBG">
            <tr>
                <td>
                  <img border="0"  width="12" alt="" >
                      <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                   </img>
                </td>
                <td class="commonLabel" nowrap="nowrap" colspan="4">
                    <xsl:value-of select="$portletEditPagePortletLayout"/>
                </td>
                <td width="100%">
                   <img border="0" alt="" >
                    <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                 </img>
                 </td>
            </tr>
            <tr>
                <td>
                 <img border="0"  width="12" alt="" >
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                  </img>
                </td>
                <td colspan="4" valign="top" nowrap="nowrap">
                    <fieldset id="layoutFieldSet" class="portletLayoutFieldSet">
                    <!-- PORTLETS OUTER TABLE -->
                    <table border="0" cellpadding="2" cellspacing="2" width="33%">
                        <tr align="top">

                          <!-- For each of the possible 3 columns, generate the column control -->

                            <xsl:call-template name="columnControls">
                              <xsl:with-param name="columnNumber">1</xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="columnControls">
                              <xsl:with-param name="columnNumber">2</xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="columnControls">
                              <xsl:with-param name="columnNumber">3</xsl:with-param>
                            </xsl:call-template>

                        </tr>
                        <tr align="top">
                            <td valign="top" nowrap="noWrap" width="10%"></td>
                        </tr>

                    </table>
                    <!-- END PORTLETS OUTER TABLE -->
                    </fieldset>
                </td>
                <td width="100%">
                <img border="0"  alt="" >
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                  </img>
                 </td>
            </tr>
            <!-- Add portlet button row -->
            <tr>
                <td colspan="6">
                <img border="0" height="6" alt="" >
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                  </img>
                </td>
            </tr>
            <tr>
                <td>
                <img border="0"  width="12" alt="" >
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                  </img>
                 </td>
                <td>
                <img border="0" alt="" >
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                  </img>
                 </td>
                <td><input class="button" type="button">
                    <xsl:attribute name="value"><xsl:value-of select="$portletEditPageAddPortlets"/></xsl:attribute>
                    <xsl:attribute name="onclick">if (displayChangedMessage("<xsl:value-of select="$portletEditPageHasChangedMessage"/>")) addPortlet('<xsl:value-of select="$parentTreeId"/>','<xsl:value-of select="$addPortletLink"/>'); else return false;</xsl:attribute>
                    </input>
                </td>
                <td colspan="3">&#160;</td>
            </tr>
            <tr>


                <td colspan="6">
           <img border="0"  height="6" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>
            </tr>
            <!-- End Add Button Row -->
        </table>
    </div>

    <!-- Grid Layout Div NOT CURRENTLY SUPPORTED!  -->

    <xsl:call-template name="gridLayoutDiv"/>


    <table  border="0" cellpadding="0" cellspacing="0" width="100%" class="dataEntryBG">
        <tr>
            <td colspan="4">
           <img border="0" height="24" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>
        </tr>
        <tr>
            <td colspan="4" class="wizardMessageFooter" height="1"></td>
        </tr>
        <tr class="buttonBar">
           <td colspan="4">
           <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
           </td>
           <td colspan="4">
           <img border="0"  height="6" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>
        </tr>
        <tr class="buttonBar">
            <td nowrap="nowrap" colspan="3" align="left">
           <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
                <input class="button" type="submit"> 
                    <xsl:attribute name="value"><xsl:value-of select="$okButton"/></xsl:attribute>
                </input>
           <img border="0"  width="1" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
                <input class="button" type="button" 
                    onclick='submitDisableAllForms(); history.go(-2);'>
                    <xsl:attribute name="value"><xsl:value-of select="$cancelButton"/></xsl:attribute>
                </input>
             
</td>
            <td width="100%">&#160;</td>
        </tr>
        <tr class="buttonBar">
            <td colspan="4">
              <img border="0"  height="6" alt="" >
                   <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                </img>
            </td>
        </tr>
    </table>

    </form>

<!-- This iframe is here to capture the response from submitting the form -->

<iframe id="formResponse" name="formResponse" style="display:none" width="100%">

</iframe>

</xsl:template>

<xsl:template name="columnControls">

<xsl:param name="columnNumber"/>

  <td valign="top" nowrap="noWrap" width="10%">
      <!-- PORTLETS INNER TABLE -->
      <xsl:variable name="columnPortletBoxId">PortletBox<xsl:value-of select="$columnNumber"/></xsl:variable>
      <xsl:variable name="columnPortletListId">column<xsl:value-of select="$columnNumber"/>Portlets</xsl:variable>
      <xsl:variable name="columnId">Column<xsl:value-of select="$columnNumber"/></xsl:variable>
      <xsl:variable name="nextColumnNumber" select="$columnNumber + 1"/>
      <xsl:variable name="nextColumnId">Column<xsl:value-of select="$nextColumnNumber"/></xsl:variable>
      <xsl:variable name="columnHeading">
           <xsl:choose>
              <xsl:when test="$columnNumber='1'">
                <xsl:value-of select="$portletEditPageColumn1Heading"/>
              </xsl:when>
              <xsl:when test="$columnNumber='2'">
                <xsl:value-of select="$portletEditPageColumn2Heading"/>
              </xsl:when>
              <xsl:when test="$columnNumber='3'">
                <xsl:value-of select="$portletEditPageColumn3Heading"/>
              </xsl:when>
           </xsl:choose>
      </xsl:variable>

      <table border="0" cellpadding="0" cellspacing="0"><xsl:attribute name="id"><xsl:value-of select="$columnPortletBoxId"/></xsl:attribute>
          <tr>
              <td class="commonLabel" align="center">
                  <label><xsl:attribute name="for"><xsl:value-of select="$columnPortletListId"/></xsl:attribute>
                  <xsl:value-of select="$columnHeading"/>
                  </label>
              </td>
              <td colspan="2">&#160;</td>
          </tr>
          <tr>
              <td rowspan="6">
                  <select multiple="false" size="8" style="width: 40mm">
                      <xsl:attribute name="id"><xsl:value-of select="$columnId"/></xsl:attribute>
                      <xsl:attribute name="name"><xsl:value-of select="$columnPortletListId"/></xsl:attribute>

                      <xsl:variable name="layoutObject" select="$pageObject/LayoutComponents/*[position()=$columnNumber]"/>

                      <xsl:for-each select="$layoutObject/Portlets/*">
                          <option>
                              <xsl:attribute name="value"><xsl:value-of select="$reposName"/>:<xsl:value-of select="name(.)"/>:<xsl:value-of select="@Id"/></xsl:attribute> 
                          <xsl:value-of select="@Name"/>

                          </option>
                      </xsl:for-each>
                      
                  </select>
                      
              </td>
              <td rowspan="6">&#160;</td>
              <td><a href="#"><xsl:attribute name="onclick">changeOrder("<xsl:value-of select="$columnId"/>",true); return false;</xsl:attribute>
              <img border="0"  width="12" height="14" >
                  <xsl:attribute name="alt"><xsl:value-of select="$portletEditPageColumnLayoutMoveUp"/></xsl:attribute>
                  <xsl:attribute name="title"><xsl:value-of select="$portletEditPageColumnLayoutMoveUp"/></xsl:attribute>
                  <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Up.gif</xsl:attribute>
               </img></a></td>
              <td>&#160;</td>
          </tr>
          <tr>
              <td><a href="#"><xsl:attribute name="onclick">changeOrder("<xsl:value-of select="$columnId"/>",false); return false;</xsl:attribute>
              <img border="0"  width="12" height="14" >
                  <xsl:attribute name="alt"><xsl:value-of select="$portletEditPageColumnLayoutMoveDown"/></xsl:attribute>
                  <xsl:attribute name="title"><xsl:value-of select="$portletEditPageColumnLayoutMoveDown"/></xsl:attribute>
                  <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Down.gif</xsl:attribute>
               </img></a></td>
              <td>&#160;</td>
          </tr>
          <tr>
              <td style="display:none">
              <xsl:attribute name="id">PortletBox<xsl:value-of select="$nextColumnNumber"/>Right</xsl:attribute>
              <a href="#"><xsl:attribute name="onclick">selSwitch("<xsl:value-of select="$columnId"/>","<xsl:value-of select="$nextColumnId"/>"); return false;</xsl:attribute>
              <img border="0"  width="12" height="14" >
                  <xsl:attribute name="alt"><xsl:value-of select="$portletEditPageColumnLayoutMoveRight"/></xsl:attribute>
                  <xsl:attribute name="title"><xsl:value-of select="$portletEditPageColumnLayoutMoveRight"/></xsl:attribute>
                  <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/MoveRight.gif</xsl:attribute>
               </img></a></td>
              <td>&#160;</td>
          </tr>
          <tr>
              <td style="display:none">
              <xsl:attribute name="id">PortletBox<xsl:value-of select="$nextColumnNumber"/>Left</xsl:attribute>
              <a href="#"><xsl:attribute name="onclick">selSwitch("<xsl:value-of select="$nextColumnId"/>","<xsl:value-of select="$columnId"/>"); return false;</xsl:attribute>
              <img border="0"  width="12" height="14" >
                  <xsl:attribute name="alt"><xsl:value-of select="$portletEditPageColumnLayoutMoveLeft"/></xsl:attribute>
                  <xsl:attribute name="title"><xsl:value-of select="$portletEditPageColumnLayoutMoveLeft"/></xsl:attribute>
                  <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/MoveLeft.gif</xsl:attribute>
               </img></a></td>
              <td>&#160;</td>
          </tr>
          <tr>
              <td><a href="#"><xsl:attribute name="onclick">removePortletFromColumn("<xsl:value-of select="$columnId"/>"); return false;</xsl:attribute>
              <img border="0"  width="12" height="14" >
                  <xsl:attribute name="alt"><xsl:value-of select="$portletEditPageColumnLayoutRemove"/></xsl:attribute>
                  <xsl:attribute name="title"><xsl:value-of select="$portletEditPageColumnLayoutRemove"/></xsl:attribute>
                  <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Remove.gif</xsl:attribute>
               </img></a></td>
              <td>&#160;</td>
          </tr>
      </table>
      <!-- END PORTLETS INNER TABLE -->
      </td>

</xsl:template>

<xsl:template name="thisPageScripts">

<script>

    var hasChanged=false;

    // Declare the javascript variables for the grid layout table
    var rowLabels = new Array();
    var selectedEntityKeys = new Array();
    var availablePortlets = new Array();
    var noOfRows = 0;
    var availablePortletsCounter = 0;

    var backDepth=-2;

    var deleteButtonHtml = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>a href="#" title="' + deleteAltText + '"<xsl:text disable-output-escaping="yes">&gt;</xsl:text>' + imageHtml + '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>/a<xsl:text disable-output-escaping="yes">&gt;</xsl:text>';
    var deleteAltText = "<xsl:value-of select="$portletEditPageDeleteRow"/>";
    var imageHtml = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>img border="0" src="/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Remove.gif" width="12" height="14" alt="' + deleteAltText + '" title="'+ deleteAltText + '"/<xsl:text disable-output-escaping="yes">&gt;</xsl:text>';

    var emptyImageHtml = '<xsl:text disable-output-escaping="yes">&lt;</xsl:text>img border="0" src="/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif" width="12" height="14" alt=""/<xsl:text disable-output-escaping="yes">&gt;</xsl:text>';

    var confirmMessage = "<xsl:value-of select="$portletEditPageRemovePortlet"/>";

</script>

    <script>
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

    </script>

    <script>

    /*
     *  This function is called when the page is displayed.
     */

    function doOnLoad() {

       newToggle();
       moveControls();
       toggleLayout();
       // buildAvailablePortletsDropdown();
       // buildGridLayoutTable();
       setColumnWidthsDisplayStyle();

    }

    function moveControls()
    {
    // This function existed in the original IDP, but most were commented out.
    // leaving it here in case it's purpose shows up in the future.

    //    moveContent();
    //    moveOptionsMenu();
    //    moveHelpMenu();
    //    moveSearchResultsActionsLinks();

    /*    if (window.event != null) {
           if (window.event.type != "resize") {
                document.onclick = hideMenus;
           }
        }
        else {
             document.onclick = hideMenus;
        }
    */
    }
    //
    // Select or unselect all values in all the select lists
    //
    function moveListContents(fboxName, tboxName)
    {
          var selBoxMoveFrom = document.getElementById(fboxName);
          var selBoxMoveTo = document.getElementById(tboxName);
          var i = 0;
          while (selBoxMoveFrom.options.length != 0) {
                var thisItem = selBoxMoveFrom.options[i];
                selBoxMoveTo.options[selBoxMoveTo.length] = new Option( thisItem.text, thisItem.value );
                selBoxMoveFrom.options[i] = null;
          }
          pageChanged(true);
    }

    // call this function when a from field changed when Editing a Page, or when Saving or Cancelling
    function pageChanged(isChanged)
    {
       parent.isPageChanged = isChanged;
    }

   function toggleLayout()
    {
       var columnLayoutDivElem = document.getElementById("columnLayoutDiv");
       var gridLayoutDivElem = document.getElementById("gridLayoutDiv");

       var colLayoutElem = document.getElementById("columnLayout");
       var gridLayoutElem = document.getElementById("gridLayout");
       if (gridLayoutElem != null <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> gridLayoutElem.checked) {
             columnLayoutDivElem.style.display="none";
             gridLayoutDivElem.style.display="block";
       } else  {
             columnLayoutDivElem.style.display="block";
             gridLayoutDivElem.style.display="none";
       }

    }

    function newToggle() {
       var elem;
       var noOfColumns = getNoOfColumns();

       for(x = 1; x <xsl:text disable-output-escaping="yes">&lt;</xsl:text> 4; x++) {
          var boxId = "PortletBox" + x;
          var leftId = "PortletBox" + x + "Left";
          var rightId = "PortletBox" + x + "Right";
          if(x <xsl:text disable-output-escaping="yes">&lt;</xsl:text>= noOfColumns) {
             elem = document.getElementById(boxId);
             elem.style.display="block";
             elem = document.getElementById(leftId);
             if(elem != null)
                elem.style.display="block";
             elem = document.getElementById(rightId);
             if(elem != null)
                elem.style.display="block";
          } else {
             elem = document.getElementById(boxId);
             elem.style.display="none";
             elem = document.getElementById(leftId);
             if(elem != null)
                elem.style.display="none";
             elem = document.getElementById(rightId);
             if(elem != null)
                elem.style.display="none";
          }
       }

    }
    function getNoOfColumns() {
       var noOfColumns = 1;
       var columnTwoElem = document.getElementById("twocolumns");
       var columnThreeElem = document.getElementById("threecolumns");

       if (columnTwoElem != null <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> columnTwoElem.checked)
         noOfColumns = 2;
       else if (columnThreeElem != null <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> columnThreeElem.checked)
         noOfColumns = 3;
       return noOfColumns;
    }

    function toggleColumnWidths() {

       var noOfColumns = getNoOfColumns();
       var columnOneWidthElem = document.getElementById("column1Width");
       var columnTwoWidthElem = document.getElementById("column2Width");
       var columnThreeWidthElem = document.getElementById("column3Width");


       if (noOfColumns == 1) {
          columnOneWidthElem.value="100";
          columnTwoWidthElem.value="";
          columnThreeWidthElem.value="";
       } else if (noOfColumns == 2) {
          columnOneWidthElem.value="50";
          columnTwoWidthElem.value="50";
          columnThreeWidthElem.value="";
       } else if (noOfColumns == 3) {
          columnOneWidthElem.value="33";
          columnTwoWidthElem.value="33";
          columnThreeWidthElem.value="33";
       }

       setColumnWidthsDisplayStyle();
    }

    function setColumnWidthsDisplayStyle() {

       var noOfColumns = getNoOfColumns();
       var unit2Elem = document.getElementById("unit2");
       var unit3Elem = document.getElementById("unit3");
       var unit2HiddenElem = document.getElementById("unit2-hidden");
       var unit3HiddenElem = document.getElementById("unit3-hidden");


       if (noOfColumns == 1) {
          unit2Elem.style.display="none";
          unit3Elem.style.display="none";
          unit2HiddenElem.style.display="block";
          unit3HiddenElem.style.display="block";
       } else if (noOfColumns == 2) {
          unit2Elem.style.display="block";
          unit3Elem.style.display="none";
          unit2HiddenElem.style.display="none";
          unit3HiddenElem.style.display="block";
       } else if (noOfColumns == 3) {
          unit2Elem.style.display="block";
          unit3Elem.style.display="block";
          unit2HiddenElem.style.display="none";
          unit3HiddenElem.style.display="none";
       }
    }

    function buildNewDataStructure() {
       selectedEntityKeysTemp = new Array();
       var srcValue;
       for (var i=0; i<xsl:text disable-output-escaping="yes">&lt;</xsl:text>noOfRows; i++) {
          selectedEntityKeysTemp[i] = new Array();
          selectedEntityKeysTemp[i][0] = new Object();
          selectedEntityKeysTemp[i][1] = new Object();
          selectedEntityKeysTemp[i][2] = new Object();

          for (var col=0; col<xsl:text disable-output-escaping="yes">&lt;</xsl:text>3; col++) {
             srcValue = getSelectedValue(i, col);
             selectedEntityKeysTemp[i][col].entityKey = srcValue;
          }
       }
       selectedEntityKeys = selectedEntityKeysTemp;
       buildGridLayoutTable();
    }

    function buildGridLayoutTable() {
        // Clear the table
        var tableObj = document.getElementById("gridLayoutTable");
           clearTable(tableObj);

          if (noOfRows == 0) {
                 buildRow(tableObj, noOfRows);
                 noOfRows++;
           } else {
              for (var rowCount=0; rowCount <xsl:text disable-output-escaping="yes">&lt;</xsl:text> noOfRows; rowCount++) {
                 buildRow(tableObj, rowCount);
           }
        }
    }

    function buildRow(tableObj, rowNumber) {

       var tr;

       // Build empty row
       tr = tableObj.insertRow(tableObj.rows.length);

       // Add the columns to the row
       buildColumns(tr, rowNumber);

    }

    function buildColumns(rowObj, rowNumber) {

        var tr, td;
        var tr2, td2;
        var noOfColumns = getNoOfColumns();

        // Row label
        td = rowObj.insertCell(rowObj.cells.length);
        td.noWrap = true;
        td.className = "commonLabel";
        td.vAlign = "middle";
        if (rowLabels.length <xsl:text disable-output-escaping="yes">&gt;</xsl:text> rowNumber)
           td.innerHTML = rowLabels[rowNumber];
        else
           td.innerHTML = rowNumber + 1 + ":";

        // Fieldset containing table for up to 3 columns
        td = rowObj.insertCell(rowObj.cells.length);
        td.noWrap = true;
        var objFieldset   = document.createElement('fieldset');
        objFieldset.className = "portletLayoutInnerFieldSet";
        td.appendChild(objFieldset);

        // Remove image
        td = rowObj.insertCell(rowObj.cells.length);
        td.noWrap = true;
        td.vAlign = "middle";
        td.id = rowNumber;
        if (isInternetExplorer())
           td.attachEvent("onclick", deleteRow);
        else
           td.addEventListener("click", deleteRow, false);

        if (rowNumber == 0) {
           td.innerHTML = emptyImageHtml;
        } else {
           td.innerHTML = deleteButtonHtml;
           td.style.cursor = "hand";
        }

        var newTableObj = document.createElement('table');
        objFieldset.appendChild(newTableObj);

        // Build dropdowns for portlet selections
        tr2 = newTableObj.insertRow(newTableObj.rows.length);

        for (var j=0; j<xsl:text disable-output-escaping="yes">&lt;</xsl:text>noOfColumns; j++) {
           buildPortletDropDown(tr2, rowNumber, j);
        }
    }



    function buildPortletDropDown(rowObj, rowNumber, colNumber) {

        var td, selectObj;

        td = rowObj.insertCell(rowObj.cells.length);

        var selectObj = document.createElement('select');
        selectObj.style.width = "40mm";
        selectObj.id = "select_row" + rowNumber + "_col" + colNumber;
        for (var i = 0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> availablePortlets.length; i++) {
           selectObj.options[i] = new Option( availablePortlets[i].label, availablePortlets[i].entityKey );
           if (isPortletSelected(availablePortlets[i].entityKey, rowNumber, colNumber))
              selectObj.options[i].selected = true;
        }
        td.appendChild(selectObj);

    }
    function clearTable (tableObj) {
          while (tableObj.rows.length <xsl:text disable-output-escaping="yes">&gt;</xsl:text> 0) {
              tableObj.deleteRow(0);
          }
    }
    function isInternetExplorer() {
       var appVer = navigator.appVersion.toLowerCase();
       return (appVer.indexOf('msie') <xsl:text disable-output-escaping="yes">&gt;</xsl:text> -1);

    }

    function deleteRow(evt) {
       var rowNumber;

       if (isInternetExplorer()) {
          var td = evt.srcElement;
          // If the source element was the delete image, get the td instead.
          if (td.id == "") {
             td = td.parentElement;
          }
          rowNumber = parseInt(td.id);
       } else {
          var elem = evt.target;
          // If the source element was the delete image, get the td instead.
          if (elem.id == "") {
             elem = elem.parentNode;
          }
          rowNumber = parseInt(elem.id);
       }

       selectedEntityKeysTemp = new Array();
       var counter = 0;
       var srcValue;

       for (var i=0; i<xsl:text disable-output-escaping="yes">&lt;</xsl:text>noOfRows; i++) {
          if (i != rowNumber) {
             selectedEntityKeysTemp[counter] = new Array();
             selectedEntityKeysTemp[counter][0] = new Object();
             selectedEntityKeysTemp[counter][1] = new Object();
             selectedEntityKeysTemp[counter][2] = new Object();

             for (var col=0; col<xsl:text disable-output-escaping="yes">&lt;</xsl:text>3; col++) {
                srcValue = getSelectedValue(i, col);
                selectedEntityKeysTemp[counter][col].entityKey = srcValue;
             }
             counter++;
          }
       }
       selectedEntityKeys = selectedEntityKeysTemp;
       noOfRows--;
       buildGridLayoutTable();
    }
    function getSelectedValue(rowNumber, colNumber) {
       var id, srcIndex, srcValue, selectObj;

       id = "select_row" + rowNumber + "_col" + colNumber;
       selectObj = document.getElementById(id);
       if (selectObj != null) {

          srcIndex = selectObj.selectedIndex;
          if (srcIndex <xsl:text disable-output-escaping="yes">&gt;</xsl:text>-1) {
              srcValue = selectObj.options[srcIndex].value;
              }
          else {
              srcValue="";
              }
       } else {
          srcValue = "";
       }
       return srcValue;

    }

    // Function to move a selected value from one SELECT LIST to another
    function selSwitch(fboxName,tboxName)
    {
       var i= 0;
       var fbox = document.getElementById(fboxName);
       var tbox = document.getElementById(tboxName);
       srcIndex = fbox.selectedIndex;
       if (srcIndex <xsl:text disable-output-escaping="yes">&gt;</xsl:text>= 0)
       {
           with (fbox)
           {
                 for (i = 0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> length; i++)
                 {
                       with (options[i])
                       {
                          if (options[i].selected)
                          {
                                tbox.options[tbox.length] = new Option( text, value );
                                options[i] = null;
                                i--;
                          }
                       }
                 } // end for loop
           }
           pageChanged(true);
       }
       else
          pageChanged(false);

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

    function removePortletFromColumn(columnId) {
       var columnElem = document.getElementById(columnId);
       if (columnElem != null) {
          var selectedSrcIndex = columnElem.selectedIndex;
          if (selectedSrcIndex <xsl:text disable-output-escaping="yes">&gt;</xsl:text>= 0) {
          	var selectedSrcValue = columnElem.options[selectedSrcIndex].value;
          	if (deleteOption(columnId, confirmMessage)) {
                   var allPortletsElem = document.getElementById("allPortlets");
                   if (allPortletsElem != null) {
                      for (var j=0; j<xsl:text disable-output-escaping="yes">&lt;</xsl:text>allPortletsElem.options.length; j++) {
                         var srcValue = allPortletsElem.options[j].value;
                   	 if (srcValue == selectedSrcValue) {
                      	    allPortletsElem.options[j] = null;
                      	    break;
                   	    }
                         }
                      }
                   removePortlet(selectedSrcValue);
          	   }
              }
           }
    }


    //
    // Sets the correct URL for adding a portlet.
    //
    function addPortlet(parentTreeId, addUrl) {

      addItemParms="portletType=";
      /*
       *  Pass generic portlet type to allow for the user to select which type of portlet they want to define.
       */

      var relatedObjectType="<xsl:value-of select="name($columnLayouts[1])"/>";
      var relatedObjectId="<xsl:value-of select="$columnLayouts[1]/@Id"/>";
      var portletType="psportlet-generic";
      addItemParms=addItemParms.concat(portletType,'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>type=PSPortlet','<xsl:text disable-output-escaping="yes">&amp;</xsl:text>parentTreeId=',parentTreeId,'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>relatedType=',relatedObjectType,'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>relatedId=',relatedObjectId);


      if (addUrl.includes('?')) {
         addUrl=addUrl.concat('<xsl:text disable-output-escaping="yes">&amp;</xsl:text>',addItemParms);
         }

      else {
         addUrl=addUrl.concat('?',addItemParms);
         }

      submitDisableAllForms();
      location.href=addUrl;

       }
    function removePortlet(selectedSrcValue) {
       var noOfColumns = getNoOfColumns();
       availablePortletsTemp = new Array();
       var count =0;
       for (var i=0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> availablePortlets.length; i++) {
         if (availablePortlets[i].entityKey != selectedSrcValue) {
            availablePortletsTemp[count] = new Array();
            availablePortletsTemp[count].label = availablePortlets[i].label;
            availablePortletsTemp[count].entityKey = availablePortlets[i].entityKey;
            count++;
         }
       }
       availablePortlets = availablePortletsTemp;
       selectedEntityKeysTemp = new Array();
       var counter = 0;
       var srcValue;

       for (var i=0; i<xsl:text disable-output-escaping="yes">&lt;</xsl:text>noOfRows; i++) {
          selectedEntityKeysTemp[i] = new Array();
          selectedEntityKeysTemp[i][0] = new Object();
          selectedEntityKeysTemp[i][1] = new Object();
          selectedEntityKeysTemp[i][2] = new Object();

          for (var col=0; col<xsl:text disable-output-escaping="yes">&lt;</xsl:text>3; col++) {
             srcValue = getSelectedValue(i, col);
             if (srcValue == selectedSrcValue)
                srcValue = "";
             selectedEntityKeysTemp[i][col].entityKey = srcValue;
          }
       }
       selectedEntityKeys = selectedEntityKeysTemp;
       buildGridLayoutTable();

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

    function isPortletSelected(entityKeyToCheck, rowNumber, colNumber) {
       var isSelected = false;

       if (selectedEntityKeys.length <xsl:text disable-output-escaping="yes">&gt;</xsl:text> rowNumber) {
          var portletEntityKey = selectedEntityKeys[rowNumber][colNumber].entityKey;
          if (portletEntityKey == entityKeyToCheck)
             isSelected = true;
       }

       return isSelected;
    }

    function buildHiddenFieldsForSubmit() {
       var form = document.forms[0];
       var gridSelected = false;

       var allPortletsElem = document.getElementById("allPortlets");
       if (allPortletsElem != null) {
          for (var j=0; j<xsl:text disable-output-escaping="yes">&lt;</xsl:text>allPortletsElem.options.length; j++) {
             var srcLabel = allPortletsElem.options[j].text;
             var srcValue = allPortletsElem.options[j].value;
             var hiddenFld = document.createElement("input");
             hiddenFld.type = "hidden";
             hiddenFld.name = "availablePortletsLabels";
             hiddenFld.value = srcLabel;
             form.appendChild(hiddenFld);
             var hiddenFld = document.createElement("input");
             hiddenFld.type = "hidden";
             hiddenFld.name = "availablePortletsValues";
             hiddenFld.value = srcValue;
             form.appendChild(hiddenFld);
          }
       }

       for (var col=0; col<xsl:text disable-output-escaping="yes">&lt;</xsl:text>3; col++) {
          var colCount = 1;
          for (var i=0; i<xsl:text disable-output-escaping="yes">&lt;</xsl:text>noOfRows; i++) {
             var srcValue = getSelectedValue(i, col);
             var hiddenFld = document.createElement("input");
             hiddenFld.type = "hidden";
             hiddenFld.name = "gridLayoutPortletsColumn" + (col + 1);
             hiddenFld.value = srcValue;
             form.appendChild(hiddenFld);
          }
       }
       for (var col=1; col<xsl:text disable-output-escaping="yes">&lt;</xsl:text>=3; col++) {
          var colId = "Column" + col;
          var columnElem = document.getElementById(colId);
          if (columnElem != null ) {
             for (var i=0; i<xsl:text disable-output-escaping="yes">&lt;</xsl:text>columnElem.options.length; i++) {
                var srcValue = columnElem.options[i].value;
                var hiddenFld = document.createElement("input");
                hiddenFld.type = "hidden";
                hiddenFld.name = "columnLayoutPortletsColumn" + col;
                hiddenFld.value = srcValue;
                form.appendChild(hiddenFld);
             }
          }
       }
    }
    function buildAvailablePortletsDropdown() {
       var allPortletsElem = document.getElementById("allPortlets");
          var counter = 0;
          for (var i = 0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> availablePortlets.length; i++) {
             if (availablePortlets[i].entityKey.length != 0) {
                allPortletsElem.options[counter] = new Option( availablePortlets[i].label, availablePortlets[i].entityKey );
                counter++;
             }
          }
    }

    //
    // Select or unselect all values in all the select lists
    //
    function quickSelect(name, total, selectAll)
    {
        if (selectAll)
        {
            for (var i = 1; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text>= total; i++)
            {
                selBox = document.getElementById(name + i);
                selectAllOptions(selBox);
            }
        } else {
            for (var i = 1; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text>= total; i++)
            {
                selBox = document.getElementById(name + i);
                unSelectAllOptions(selBox);
            }
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

</script>

<script>

  /*  
   * In normal javascript, this function would be tied to the onload event of the workarea
   * div.  However, since we are generating the page, just do it as the last item
   * of defining the scripts for this page.
   */
  doOnLoad();

</script>

</xsl:template>

<xsl:template name="setInitialColumnPercentages">
  <xsl:param name="layoutObject"/>

                  <xsl:attribute name="onclick">hasChanged=true;</xsl:attribute>

                  <xsl:choose>
                    <xsl:when test="not($layoutObject/@ColumnWidth='0') and not($layoutObject/@ColumnWidth='')">
                      <xsl:attribute name="value"><xsl:value-of select="$layoutObject/@ColumnWidth"/></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:choose>
                        <xsl:when test="$numberOfColumns='1'">
                           <xsl:attribute name="value">100</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$numberOfColumns='2'">
                           <xsl:attribute name="value">50</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$numberOfColumns='3'">
                           <xsl:attribute name="value">33</xsl:attribute>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:otherwise>
                  </xsl:choose>

</xsl:template>

<xsl:template name="gridLayoutDiv">

    <div id="gridLayoutDiv" style="display:none">
        <table border="0" cellpadding="0" cellspacing="0" width="100%" class="dataEntryBG">
            <tr>
                <td>
           <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>
                <td class="commonLabel" nowrap="nowrap" colspan="4">
                    Portlet layout:
                </td>
                <td>
           <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>
                <td class="commonLabel" nowrap="nowrap" width="100%">
                    Portlets:
                </td>
            </tr>
            <tr>
                <td>
           <img border="0"  width="12" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>
                <td class="commonLabel" colspan="4" valign="top" nowrap="nowrap">
                    <fieldset class="portletLayoutFieldSet">
                    <!-- PORTLETS OUTER TABLE -->
                    <table border="0" cellpadding="2" cellspacing="0" width="33%">
                        <tr align="top">

                            <td valign="top" nowrap="nowrap" width="10%">
                                <!-- PORTLETS INNER TABLE1 -->
                                <table border="0" cellpadding="2" cellspacing="0" id="gridLayoutTable">
                                    <!-- BUILD IN JavaScript -->
                                </table>
                            </td>
                        </tr>
                        <tr align="top">
                            <td valign="top" nowrap="nowrap" width="10%"></td>
                        </tr>
                    </table>
                    <!-- END PORTLETS TABLE -->
                    </fieldset>
                    <!-- ADD ROW BUTTON TABLE -->
                    <table border="0" cellpadding="0" cellspacing="0" align="right">
                        <tr align="top">
                            <td>
			    <img border="0" height="2" alt="" >
				 <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
			      </img>
			     </td>
                        </tr>
                        <tr align="top">
                            <td><input class="button" type="button" value="Add Row..."
                                onclick="addNewRow(); return false;">
                                </input>
			    </td>
                          
                        </tr>
                    </table>

                </td>
                <td>
		 <img border="0"  width="12" alt="" >
		      <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
		   </img>
		</td>
                <td nowrap="nowrap" valign="top">
                    <table border="0" cellpadding="0" cellspacing="0" valign="top">
                        <tr valign="top">
                            <td valign="top">
                                <select id="allPortlets" name="allPortlets" style="width: 40mm" size="10" />
                            </td>
                            <td>
			    <img border="0"  width="4" alt="" >
				<xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
			     </img>
			    </td>
                            <td valign="bottom"><a href="#" onclick='removePortletFromGrid(); return false;'>
                                <img style="vertical-align:text-bottom;" border="0" width="12" height="14"
                                    alt='Remove'
                                    title='Remove'>
				    <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Remove.gif</xsl:attribute>
			        </img>
              
				</a></td>
                        </tr>
                    </table>
                    <table border="0" cellpadding="2" cellspacing="0" valign="top">
                        <tr valign="top">
                            <td valign="top">
                                <input class="button" type="submit" value="Add Portlets..."
                                onclick='buildHiddenFieldsForSubmit(); if (cancelForm(this, "/SASPortal/editPage/displayAddPortlet.wiz")) return submitDisableAllForms(); else return false;'/></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="7">
           <img border="0" height="2" alt="" >
                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
             </img>
            </td>
            </tr>
        </table>
    </div>

</xsl:template>

</xsl:stylesheet>

