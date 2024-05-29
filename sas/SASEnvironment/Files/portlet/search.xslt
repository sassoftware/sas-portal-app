<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<!-- Common Setup -->

<!-- Set up the metadataContext variable -->
<xsl:include href="setup.metadatacontext.xslt"/>
<!-- Set up the environment context variables -->
<xsl:include href="setup.envcontext.xslt"/>

<!-- load the appropriate localizations -->

<!-- This localization handling is not the normal processing!
     Since this file is included in other files, the base uri of this file changes.
     Thus, the passed in localization file location doesn't work.

     We will build a new directory, relative to the directory of this file, and get the
     correct resources file from the passed in location to build a specialized
     locale file location for this script
-->

<xsl:variable name="localizationDirOverride">../localization</xsl:variable>

<xsl:variable name="localizationFile">
 <xsl:choose>
   <xsl:when test="/Mod_Request/NewMetadata/LocalizationFile"><xsl:value-of select="/Mod_Request/NewMetadata/LocalizationFile"/></xsl:when>
   <xsl:otherwise><xsl:value-of select="$localizationDirOverride"/>/resources_en.xml</xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<xsl:variable name="useLocalizationFile"><xsl:value-of select="$localizationDirOverride"/>/<xsl:value-of select="tokenize($localizationFile,'/')[last()]"/></xsl:variable>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($useLocalizationFile)/*"/>

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

<xsl:variable name="query" select="Mod_Request/NewMetadata/Query"/>

<xsl:variable name="type" select="Mod_Request/NewMetadata/Type"/>

<!-- Main Entry Point -->

<xsl:template match="/">

   <xsl:call-template name="searchScripts"/>

   <!-- This stylesheet generates the html response based on the passed metadata -->

    <xsl:variable name="resultCount" select="count($metadataContext/Multiple_Requests//Objects/PSPortalPage[not(Extensions/Extension[@Name='MarkedForDeletion'])])"/>

    <xsl:comment> Search Results table </xsl:comment>
  
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
                             <!--  
                             <a href="#" onclick='submitSort(this, "Label", "/SASPortal/addPage/sortTaskSearch.wiz");return true;'>
                              -->
                              <xsl:value-of select="$portletSearchName"/>
                              <!-- 
                              </a>
                              -->
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
                             <!--  
                             <a href="#" onclick='submitSort(this, "Desc", "/SASPortal/addPage/sortTaskSearch.wiz");return true;'>
                             -->
                             <xsl:value-of select="$portletSearchDesc"/>
                             <!--  
                             </a>
                             -->
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
                             <!--  
                             <a href="#" onclick='submitSort(this, "Location", "/SASPortal/addPage/sortTaskSearch.wiz");return true;'>
                             -->
                             <xsl:value-of select="$portletSearchLocation"/>
                             <!--  
                             </a>
                             -->
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
                             <!--  
                             <a href="#" onclick='submitSort(this, "CreationDate", "/SASPortal/addPage/sortTaskSearch.wiz");return true;'>
                             -->
                             <xsl:value-of select="$portletSearchCreated"/>
                             <!--  
                             </a>
                             -->
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

                <xsl:for-each select="$metadataContext/Multiple_Requests//Objects/PSPortalPage[not(Extensions/Extension[@Name='MarkedForDeletion']) and Trees/Tree]">
                    <xsl:sort select="@Name"/> 
                    <xsl:variable name="resultPosition" select="position()"/>

                    <xsl:variable name="resultPageId"><xsl:value-of select="@Id"/></xsl:variable>

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
                             <xsl:attribute name="id"><xsl:value-of select="$resultPageId"/></xsl:attribute>
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
                                      <xsl:attribute name="alt"><xsl:value-of select="$portletSearchTypePage"/></xsl:attribute>
                                      <xsl:attribute name="title"><xsl:value-of select="$portletSearchTypePage"/></xsl:attribute>
                                         <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Page.gif</xsl:attribute>
                                 </img>
                              </td>
                         <!-- Name -->
                         <td class="textTableCell" nowrap="nowrap">
                             <!-- TODO:  Add support for selecting name and showing page -->
                             <!--
                             <a href='/SASPortal/addPage/viewPage.wiz?com.sas.portal.ItemId=PortalPage%2Bomi%3A%2F%2FFoundation%2Freposname%3DFoundation%2FPSPortalPage%3Bid%3DA5WARVLJ.BP00002Q' target='_self'>
                             -->
                             <xsl:value-of select="@Name"/>
                             <!--
                             </a>
                             -->
                          </td>
                          <!-- Desc -->
                          <td class="textTableCell"> 
                          <xsl:value-of select="@Desc"/>
                          </td>
                        <!-- Location -->
                        <td class="textTableCell">

                          <xsl:variable name="parentTree" select="Trees/Tree"/>
                          <xsl:variable name="parentTreeId" select="$parentTree/@Id"/>
                          <xsl:variable name="parentTreeName" select="$parentTree/@Name"/>

                          <!--  For a page that exists in a group tree, it may be under one of the subtrees for sticky (Persistent) or default (Default) pages -->
                          
                          <xsl:variable name="parentPermissionsTree" select="$metadataContext/Multiple_Requests/GetMetadataObjects[1]/Objects/Tree[SubTrees//Tree[@Id=$parentTreeId]]"/>

                          <xsl:variable name="parentPermissionsTreeName">

                              <xsl:choose>

                                   <!-- This really shouldn't happen that we have a page with no parent tree, but handle here just in case -->

                                   <xsl:when test="not($parentTreeName)"/>
                                  
                                   <xsl:when test="$parentTree/@TreeType='Permissions Tree' or $parentTree/@TreeType=' Permissions Tree'">
                                     <xsl:value-of select="substring-before($parentTree/@Name,' Permissions Tree')"/>  
                                   </xsl:when>
                                   <xsl:otherwise>
                                       <xsl:choose>

                                         <xsl:when test="$parentTreeName='Sticky'">
                                             <xsl:value-of select="substring-before($parentPermissionsTree/@Name,' Permissions Tree')"/> [Persistent]
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <xsl:value-of select="substring-before($parentPermissionsTree/@Name,' Permissions Tree')"/> [<xsl:value-of select="$parentTreeName"/>]
                                         </xsl:otherwise>
                                       </xsl:choose>
                                   </xsl:otherwise>

                              </xsl:choose>

                          </xsl:variable>
                          <xsl:value-of select="$parentPermissionsTreeName"/>  
                        </td>
                        <!-- Created Date -->
                        <td class="textTableCell" nowrap="nowrap">
                          <xsl:value-of select="@MetadataCreated"/> 
                        </td>
                     </tr>

                 </xsl:for-each>

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

