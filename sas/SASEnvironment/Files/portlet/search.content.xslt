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
<xsl:variable name="portletSearchType" select="$localeXml/string[@key='portletSearchType']/text()"/>
<xsl:variable name="portletSearchTypePage" select="$localeXml/string[@key='portletSearchTypePage']/text()"/>
<xsl:variable name="portletSearchName" select="$localeXml/string[@key='portletSearchName']/text()"/>
<xsl:variable name="portletSearchDesc" select="$localeXml/string[@key='portletSearchDesc']/text()"/>
<xsl:variable name="portletSearchLocation" select="$localeXml/string[@key='portletSearchLocation']/text()"/>
<xsl:variable name="portletSearchCreated" select="$localeXml/string[@key='portletSearchCreated']/text()"/>
<xsl:variable name="portletSearchAscending" select="$localeXml/string[@key='portletSearchAscending']/text()"/>
<xsl:variable name="portletSearchDescending" select="$localeXml/string[@key='portletSearchDescending']/text()"/>
<xsl:variable name="portletSearchCheckbox" select="$localeXml/string[@key='portletSearchCheckbox']/text()"/>
<xsl:variable name="portletSearchNoResults" select="$localeXml/string[@key='portletSearchNoResults']/text()"/>

<xsl:variable name="portletSearchTypeReport" select="$localeXml/string[@key='portletSearchTypeReport']/text()"/>
<xsl:variable name="portletSearchTypeStoredProcess" select="$localeXml/string[@key='portletSearchTypeStoredProcess']/text()"/>
<xsl:variable name="portletSearchTypeUnknown" select="$localeXml/string[@key='portletSearchTypeUnknown']/text()"/>

<xsl:variable name="query" select="Mod_Request/NewMetadata/Query"/>

<xsl:variable name="type" select="Mod_Request/NewMetadata/Type"/>
<xsl:variable name="searchTypes" select="Mod_Request/NewMetadata/SearchTypes"/>

<!-- Main Entry Point -->

<xsl:template match="/">

   <xsl:call-template name="searchScripts"/>

   <!-- This stylesheet generates the html response based on the passed metadata -->
    <!--  This history is that originally, the search functionality was only provided for pages (see search.psportalpage.xslt).  Then this more
          more generic search was added, with the hope that it would subsume the page specific implementation.  However, there are subtle enough differences
          in the object selection and the location calculations, that I decided to leave them as separate implementations and just deal with the code
          duplication instead of risking complicated, buggy logic.

         Leaving this variable setting here in case this is attempted again in the future.
 
         <xsl:variable name="resultObjects" select="$metadataContext/Multiple_Requests//Objects/*[not(name(.)='Keyword') and (not(name(.)='Tree')) or ((name(.)='PSPortalPage') and (not(Extensions/Extension[@Name='MarkedForDeletion'])))]"/>

    -->

    <!-- We only want objects that are not trees and not keywords -->

    <xsl:variable name="resultObjects" select="$metadataContext/Multiple_Requests//Objects/*[not(name(.)='Keyword') and (not(name(.)='Tree'))]"/>

    <xsl:variable name="resultCount" select="count($resultObjects)"/>

    <xsl:choose>

      <xsl:when test="$resultCount=0">
          <table border="0" width="100%" cellspacing="0" cellpadding="1">
               <tr align="center">
                 <td class="textEntry" colspan="12" align="center"><xsl:value-of select="$portletSearchNoResults"/></td>
                </tr>
          </table>

      </xsl:when>

      <xsl:otherwise>

         <table border="0" width="100%" class="mainTable" cellspacing="0" cellpadding="3" id="searchResultsTable" name="searchResultsTable">
             <!-- Table Header -->

             <tr class="searchResultsTableHeader">
                    <!-- Checkbox for selecting row -->
                    
                    <th scope="col" class="centeredTableHeader">
                    <!--  Select All not supported from original portal
                    <input id="resultsTopBox" disabled="disabled" type="checkbox" name="resultsTopBox" value="" title='Select all items to add' 
                         onclick="checkMe('chkBoxName', '1', 'resultsTopBox');chkDisableButtonStatus('1','addbutton1','resultsTopBox');chkDisableButtonStatus('1','addbutton2','resultsTopBox');return true;" />
                    -->
                    &#160;
                    </th>

                    <!-- Item was added indicator -->

                     <!--  Added indicator not needed since not allow ing multiple selections  
                     <th scope="col" class="centeredTableHeader">
                     <img border="0" width="16" height="16" alt='Item was added' title='Item was added'>
                                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/CheckmarkGreen.gif</xsl:attribute>
                     </img>
                     </th>
                     -->

                     <!-- Object type -->
                     <th scope="col" class="centeredTableHeader"  nowrap="nowrap">
                     <xsl:value-of select="$portletSearchType"/>
                     </th>                            

                     <!-- Name Column Header -->
                     <th scope="col" class="tableHeader" nowrap="nowrap">
                     <table border="0">
                         <tr class="tableHeader">
                             <td class="commonLabel"  nowrap="nowrap">
                             <!-- TODO:  Add support for sorting -->
                              <xsl:value-of select="$portletSearchName"/>
                             </td>
                             <!-- TODO:  Add support for sorting -->
                             <!--   For now, indicate to the user that the results are sorted by ascending Name -->
                             <td>
                                 <img style="vertical-align:text-bottom;" border="0" width="16" height="16">

                                     <xsl:attribute name="alt"><xsl:value-of select="$portletSearchAscending"/></xsl:attribute>
                                     <xsl:attribute name="title"><xsl:value-of select="$portletSearchAscending"/></xsl:attribute>
                                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/UpArrowBlue.gif</xsl:attribute>
                                 </img>
                             </td>
                         </tr>
                     </table>
                     </th>
                     <!-- Description Column Header -->
                     <th scope="col" class="tableHeader"  nowrap="nowrap">
                     <table border="0">
                         <tr class="searchResultsTableHeader">
                             <td class="commonLabel">
                             <!-- TODO:  Add support for sorting -->
                             <xsl:value-of select="$portletSearchDesc"/>
                             </td>
                             <td></td>
                         </tr>
                     </table>
                     </th>
                     <!-- Location Column Header -->
                     
                     <th scope="col" class="tableHeader" nowrap="nowrap">

                     <table border="0">
                         <tr class="searchResultsTableHeader">
                             <td class="commonLabel"  nowrap="nowrap">
                             <!-- TODO:  Add support for sorting -->
                             <xsl:value-of select="$portletSearchLocation"/>
                             </td>
                             <td></td>
                         </tr>
                     </table>

                     </th>
                     <!-- Created Date Column Header -->
                     <th scope="col" class="tableHeader" nowrap="nowrap">
                     <table border="0">
                         <tr class="tableHeader">
                             <td class="commonLabel"  nowrap="nowrap">
                             <!-- TODO:  Add support for sorting -->
                             <xsl:value-of select="$portletSearchCreated"/>
                             </td>
                             <td>
                             </td>
                         </tr>
                     </table>
                     </th>
                     </tr>
                
                <!-- data rows -->

                <!--  When a page is deleted by a content administrator, it's marked for deletion and not physically deleted.  We don't want to include
                      those pages in a seach results shown to the user (although they may be in the metadata response we are looking at -->

                <!--  Also, in my test system, there were some pages that weren't in trees, that shouldn't happen and don't allow them to select those -->

                <!--  Since we did 2 different queries, there is a possibility of duplicates in the resulting set of objects.  Here we group the objects by id, then only select
                      the first one with a given id to process.
                -->

                <xsl:for-each-group group-by="@Id" select="$resultObjects">

                    <!-- typically a sort is case sensitive, it makes more sense to do a case insensitive sort here -->
                    <xsl:sort select="lower-case(@Name)"/> 
                    <xsl:for-each select="current-group()[1]">

                        <xsl:variable name="resultPosition" select="position()"/>

                        <!-- Because we could have different types of objects in the search results, we have to keep the type and the Id values -->

                        <xsl:variable name="resultId"><xsl:value-of select="name(.)"/>/<xsl:value-of select="@Id"/></xsl:variable>

                        <tr>
                            <xsl:variable name="rowMod" select="$resultPosition mod 2"/>
                            <xsl:variable name="rowType">

                               <xsl:choose>
                                  <xsl:when test="$rowMod='0'">2</xsl:when>
                                  <xsl:otherwise><xsl:value-of select="$rowMod"/></xsl:otherwise>
                               </xsl:choose>
                            </xsl:variable>
                            <xsl:attribute name="class">dataRow<xsl:value-of select="$rowType"/>_tableRow</xsl:attribute>
                        
                             <!-- Selected Check box -->
                             <td scope="row" class="imageTableCell">
                             <xsl:variable name="checkboxTitle"><xsl:value-of select="$portletSearchCheckbox"/></xsl:variable>

                             <input type="checkbox" value="true" onclick="selectCheckbox(this);" >
                                 <xsl:attribute name="name">checkbox_<xsl:value-of select="$resultPosition"/></xsl:attribute>
                                 <xsl:attribute name="id"><xsl:value-of select="$resultId"/></xsl:attribute>
                                 <xsl:attribute name="title"><xsl:value-of select="$checkboxTitle"/></xsl:attribute>
                             </input>

                             </td>
                             <!-- Added indicator -->
                             <!-- Not needed until adding multiple selection support
                             <td class="imageTableCell"> 
                             &#160;
                             </td>
                             -->
                             <!-- Type indicator -->
                                 <td class="imageTableCell">
                                     <img border="0" width="16" height="16">

                                        <xsl:choose>
                                            <xsl:when test="@TransformRole='StoredProcess'">
                                                <xsl:attribute name="alt"><xsl:value-of select="$portletSearchTypeStoredProcess"/></xsl:attribute>
                                                <xsl:attribute name="title"><xsl:value-of select="$portletSearchTypeStoredProcess"/></xsl:attribute>
                                                   <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/StoredProcess.gif</xsl:attribute>
                                            </xsl:when>
 
                                            <xsl:when test="@TransformRole='Report'">
                                                <xsl:attribute name="alt"><xsl:value-of select="$portletSearchTypeReport"/></xsl:attribute>
                                                <xsl:attribute name="title"><xsl:value-of select="$portletSearchTypeReport"/></xsl:attribute>
                                                   <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Report.gif</xsl:attribute>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="alt"><xsl:value-of select="$portletSearchTypeUnknown"/></xsl:attribute>
                                                <xsl:attribute name="title"><xsl:value-of select="$portletSearchTypeUnknown"/></xsl:attribute>
                                                   <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/DefaultDocument.gif</xsl:attribute>

                                            </xsl:otherwise>
 
                                        </xsl:choose>

                                     </img>
                                  </td>
                             <!-- Name -->
                             <td class="textTableCell" nowrap="nowrap">
                                 <!-- TODO:  Add support for selecting name and showing object -->
                                 <xsl:value-of select="@Name"/>
                              </td>
                              <!-- Desc -->
                              <td class="textTableCell"> 
                              <xsl:value-of select="@Desc"/>
                              </td>
                            <!-- Location -->
                            <td class="textTableCell">

                              <xsl:variable name="locationPath">

                                  <xsl:for-each select="Trees//Tree">
                                          <xsl:sort select="position()" order="descending"/>
                                          <xsl:text>/</xsl:text><xsl:value-of select="@Name"/>
                                  </xsl:for-each>

                              </xsl:variable>

                              <xsl:value-of select="$locationPath"/>

                            </td>
                            <!-- Created Date -->
                            <td class="textTableCell" nowrap="nowrap">
                              <xsl:value-of select="@MetadataCreated"/> 
                            </td>
                         </tr>
                    </xsl:for-each>

                </xsl:for-each-group>

         </table>

    </xsl:otherwise>

    </xsl:choose>

    <xsl:comment> End Search Results table </xsl:comment>

</xsl:template>

<xsl:template name="searchScripts">

<script>

function selectCheckbox(checkbox) {

   if (checkbox.checked == true) {
   /* 
    *  Deselect all others besides the one just selected.
    */

      searchResultsTable=document.getElementById('searchResultsTable');

      searchResultsTable.querySelectorAll('input').forEach(function(node) {
   
      if (node.type=="checkbox") {

         if (node != checkbox) {

            node.checked=false;

            }
         
         }   

      });
    }
}

</script>

</xsl:template>

</xsl:stylesheet>

