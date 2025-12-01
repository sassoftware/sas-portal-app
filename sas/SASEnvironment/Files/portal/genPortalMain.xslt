<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" encoding="UTF-8"/>

<xsl:param name="locale" select="en_us"/>

<xsl:variable name="localizationDir">SASPortalApp/sas/SASEnvironment/Files/localization</xsl:variable>

<xsl:param name="localizationFile"><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:param>

<xsl:param name="sastheme">default</xsl:param>
<xsl:variable name="sasthemeContextRoot">SASTheme_<xsl:value-of select="$sastheme"/></xsl:variable>

<xsl:param name="appLocEncoded"></xsl:param>
<xsl:param name="featureFlags"></xsl:param>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Strings to be localized -->
<xsl:variable name="pageTabs_skipTabMenuTitle" select="$localeXml/string[@key='pageTabs_skipTabMenuTitle']/text()"/>

<xsl:variable name="portletEditContent" select="$localeXml/string[@key='portletEditContent']/text()"/>
<xsl:variable name="portletEditProperties" select="$localeXml/string[@key='portletEditProperties']/text()"/>
<xsl:variable name="portletRemove" select="$localeXml/string[@key='portletRemove']/text()"/>
<xsl:variable name="portalAdminHeader" select="$localeXml/string[@key='portalAdminHeader']/text()"/>

<!-- include shared files -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portal/genPortalBanner.xslt"/>

<!-- Define the lookup table of writeable trees -->
<xsl:key name="treeKey" match="Tree" use="@Id"/>
<!-- it doesnt say this anywhere in the xsl key doc, but the objects to use for the lookup table
     must be under a shared root object.  Thus, here we can only go to the AccessControlEntries
     level.  Fortunately, the only trees listed under here are the ones we want in our lookup table
  -->
<xsl:variable name="treeLookup" select="/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/AccessControlEntries"/>
<!-- Get the same set of nodes in a a variable --> 
<xsl:variable name="writeableTrees" select="/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/AccessControlEntries/AccessControlEntry/Objects/Tree"/>

<xsl:variable name="userName" select="/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/@Name"/>

<!-- Issue 71 featureflag LINKSTABBLANK: when set links open in new browser window/tab -->
<xsl:variable name="aTarget">
    <xsl:choose>
        <xsl:when test="contains($featureFlags,'LINKSTABBLANK') = 'true'">_target</xsl:when>
        <xsl:otherwise>_self</xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  The main entry point

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->

<xsl:template match="/" name="main">
<!-- pass back the theme to use -->

<xsl:call-template name="thisPageScripts"/>

<div id="sastheme" style="display: none"><xsl:value-of select="$sastheme"/></div>

<xsl:variable name="userRole">
<xsl:choose>
<xsl:when test="not(count($writeableTrees)='1')"><xsl:value-of select="$portalAdminHeader"/></xsl:when>
<xsl:otherwise></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="genBanner">
  <xsl:with-param name="includeTabs">1</xsl:with-param> 
  <xsl:with-param name="userRole"><xsl:value-of select="$userRole"/></xsl:with-param>
  <xsl:with-param name="userName"><xsl:value-of select="$userName"/></xsl:with-param>
</xsl:call-template>

<xsl:call-template name="genTabContent"/>
    
</xsl:template>

<xsl:template name="addTabMap">

  <!-- the portal page object must be the current node when this template is called! -->

  <xsl:variable name="tabId" select="@Id"/>
  <xsl:variable name="tabName" select="@Name"/>

  <!-- Calculate whether this page can be edited based on the permissions on the parent tree -->
  <xsl:variable name="permissionsTree" select="Trees//Tree[@TreeType=' Permissions Tree' or @TreeType='Permissions Tree'][1]"/>
  <xsl:variable name="permissionsTreeId" select="$permissionsTree/@Id"/>
  <xsl:variable name="permissionsTreeKey" select="key('treeKey',$permissionsTreeId,$treeLookup)/@Name"/>

  <xsl:variable name="isWriteable">
    <xsl:choose>
      <xsl:when test="$permissionsTreeKey">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <script>

    var tabId='<xsl:value-of select="$tabId"/>';
    tabs.set(tabId,new Object());
    var tabObject=tabs.get(tabId);
    tabObject.name='<xsl:value-of select="$tabName"/>';

    <xsl:choose>
      <!-- TODO: I don't see another way of finding out whether the page is a Home Page or not,
           but is the name of the page localized?
      -->
      <xsl:when test="$tabName='Home'">
         tabObject.canEdit=true;
         tabObject.canRemove=false;
      </xsl:when>
      <xsl:otherwise>
         <xsl:choose>
            <xsl:when test="$isWriteable=1">
             tabObject.canEdit=true;
             tabObject.canRemove=true;
            </xsl:when>
            <xsl:otherwise> 
             tabObject.canEdit=false;
             <!-- For shared pages, the user can remove from their view any
                  shared pages that don't have the Available or Default setting on the page
             -->
             <xsl:choose>
               <xsl:when test="Extensions/Extension[@Name='SharedPageAvailable'] or Extensions/Extension[@Name='SharedPageDefault']">
                   tabObject.canRemove=true;
               </xsl:when>
               <xsl:otherwise>
                   tabObject.canRemove=false;
               </xsl:otherwise>
             </xsl:choose>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>

  </script>

</xsl:template>

<xsl:template name="thisPageScripts">

<script>

   var tabs=new Map();

   function setupSubmenu(submenu) {
      /*
       * This function is called by genPortalBanner generated submenus when
       * a submenu is to be displayed.
       */

       /*
        *  Get currently selected Page
        */
       var tabDiv = document.getElementsByClassName("tabcontent active")[0];

       var pageId=tabDiv.id;

       /*
        *  Lookup the values from the map for the selected page
        */

       var tab=tabs.get(pageId);

       var canEdit=tab.canEdit;
       var canRemove=tab.canRemove;

       var editPageContent=document.getElementById(submenu+"_SubMenu_0");
       var editPageContentLink=document.getElementById(submenu+"_SubMenu_0_anchor");
       var editPageProperties=document.getElementById(submenu+"_SubMenu_1");
       var editPagePropertiesLink=document.getElementById(submenu+"_SubMenu_1_anchor");
       var removePage=document.getElementById(submenu+"_SubMenu_4");
       var removePageLink=document.getElementById(submenu+"_SubMenu_4_anchor");

       var existingEditOnclick=editPageContentLink.getAttribute('onclick');

       if (canEdit) {
          editPageContent.className="PopupMenuItem";
          editPageProperties.className="PopupMenuItem";

          /*
           *  If we don't have an href now, then we moved it on a previous
           *  click.  Put it back.  If there, just continue
           *  NOTE: there shouldn't be a situation where the 2 edit page links 
           *  have different 'edit-able', so just check one.
           */

          if (!existingEditOnclick) {
             editPageContentLink.setAttribute('onclick',editPageContentLink.getAttribute('saveonclick'));
             editPagePropertiesLink.setAttribute('onclick',editPagePropertiesLink.getAttribute('saveonclick'));
             } 

          }
       else {
          editPageContent.className="PopupMenuItemDisabled";
          editPageProperties.className="PopupMenuItemDisabled";
          if (existingEditOnclick) {
             editPageContentLink.removeAttribute('onclick');
             editPagePropertiesLink.removeAttribute('onclick');
             }
          }
       existingRemoveOnclick=removePageLink.getAttribute('onclick');
       if (canRemove) {
          removePage.className="PopupMenuItem";
          if (!existingRemoveOnclick) {
             removePageLink.setAttribute('onclick',removePageLink.getAttribute('saveonclick'));
             }
          }
       else {
          removePage.className="PopupMenuItemDisabled";
          if (existingRemoveOnclick) {
             removePageLink.removeAttribute('onclick');
             }
          }
           
   }


   function editItem(itemType,details) {

   /*
    *  Get currently selected Page
    */

   var tabDiv = document.getElementsByClassName("tabcontent active")[0];

   var pageId=tabDiv.id;

   if (details == 'properties') {
      var pageType=itemType+'-properties';
      }
   else {
      var pageType=itemType;
      }

   var editURL='editItem.html?type='+pageType+'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>id='+pageId;

   /*
    *  Hide menu
    */

   var elementPrefixId="globalMenuBar_0";
   dropDownCleared(elementPrefixId);
   location.href=editURL;
 
   }

   function addItem(itemType) {

   var pageType='PSPortalPage';

   /*
    * TODO: Have to set the related item info so we know where
    * to create the page.
    * OR is it available in permissionsTreeId?
    */

   var permissionsTreeId="";

   var addURL='addItem.html?type='+pageType+'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>permissionsTreeId='+permissionsTreeId;

   /*
    *  Hide menu
    */

   var elementPrefixId="globalMenuBar_0";
   dropDownCleared(elementPrefixId);

   location.href=addURL;

   }

   function removeItem(itemType) {
   var pageType='PSPortalPage';

   /*
    *  Get currently selected Page
    */
   var tabDiv = document.getElementsByClassName("tabcontent active")[0];

   var pageId=tabDiv.id;

   var removeURL='removeItem.html?type='+pageType+'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>id='+pageId;

   /*
    *  Hide menu
    */

   var elementPrefixId="globalMenuBar_0";
   dropDownCleared(elementPrefixId);

   location.href=removeURL;

   }


</script>
</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  This section of the templates is for generating the list of tabs.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->

<xsl:template name="genTabList">

   <!-- Loop over all the tabs on the page and create the tab structure -->
   <table id="pagetabs_Table" class="BannerTabMenuTable" cellspacing="0" cellpadding="0" border="0">
   <tbody>
   <tr>

   <!--  Its possible that the user portal information has not been initialized or they don't have any pages, make sure
         to handle that gracefully.
   -->

   <xsl:variable name="numTabs"><xsl:value-of select="count(Multiple_Requests/GetMetadataObjects/Objects/Group/Members/PSPortalPage[not(Extensions/Extension[@Name='MarkedForDeletion'])])"/></xsl:variable>

   <xsl:choose>

     <xsl:when test="$numTabs=0">
          <!-- Build a dummy tab so that something displays -->
          <xsl:variable name="dummyTabName">ERROR</xsl:variable>

          <xsl:variable name="dummyTabId">0</xsl:variable>
          <xsl:variable name="dummyContentId">content_<xsl:value-of select="$dummyTabId"/></xsl:variable>

          <td id="0_TabCell" class="BannerTabMenuActiveTabCell">

              <table border="0" cellspacing="0" cellpadding="0" id="0" class="buttonContainer default-tab"><xsl:attribute name="onclick">showTab(event, '<xsl:value-of select="$dummyContentId"/>')</xsl:attribute>
                <tbody>
                   <tr>
                                   <xsl:call-template name="buildTab">
                                      <xsl:with-param name="tabId"><xsl:value-of select="$dummyTabId"/></xsl:with-param>
                                      <xsl:with-param name="tabName"><xsl:value-of select="$dummyTabName"/></xsl:with-param>
                                      <xsl:with-param name="tabPosition"><xsl:value-of select="1"/></xsl:with-param>
                                   </xsl:call-template>
                   </tr>
                </tbody>
              </table>
          </td>

     </xsl:when>

     <xsl:otherwise>
   
       <xsl:for-each select="Multiple_Requests/GetMetadataObjects/Objects/Group/Members/PSPortalPage[not(Extensions/Extension[@Name='MarkedForDeletion'])]">
        <xsl:sort select="Extensions/Extension[@Name='PageRank']/@Value" data-type="number"/>
        <xsl:sort select="@MetadataCreated" data-type="number"/>
<!--
        <xsl:variable name="tabNumberId">page_<xsl:value-of select="position() - 1"/></xsl:variable>
-->
        <xsl:variable name="tabNumberId">page_<xsl:value-of select="@Id"/></xsl:variable>

        <td><xsl:attribute name="id"><xsl:value-of select="$tabNumberId"/>_TabCell</xsl:attribute>
            <xsl:choose>
            <xsl:when test="position() = 1">
               <xsl:attribute name="class">BannerTabMenuActiveTabCell</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
               <xsl:attribute name="class">BannerTabMenuTabCell</xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>

            <table border="0" cellspacing="0" cellpadding="0">
                   <xsl:attribute name="id"><xsl:value-of select="$tabNumberId"/></xsl:attribute><xsl:attribute name="onclick">showTab(event, '<xsl:value-of select="@Id"/>')</xsl:attribute>
                   <!-- Mark the first tab to display so that the javascript can find it and display it -->
                   <xsl:choose>

                 <xsl:when test="position() = 1">
                     <xsl:attribute name="class">buttonContainer default-tab</xsl:attribute>
                 </xsl:when>
                 <xsl:otherwise>
                     <xsl:attribute name="class">buttonContainer</xsl:attribute>
                 </xsl:otherwise>
                   </xsl:choose>

            <tbody>
                <tr>
                                   <xsl:call-template name="buildTab">
                                      <xsl:with-param name="tabId"><xsl:value-of select="$tabNumberId"/></xsl:with-param>
                                      <xsl:with-param name="tabName"><xsl:value-of select="@Name"/></xsl:with-param>
                                      <xsl:with-param name="tabPosition"><xsl:value-of select="position()"/></xsl:with-param>
                                   </xsl:call-template>

                </tr>
            </tbody>
            </table>
        </td>

       </xsl:for-each>
  
        </xsl:otherwise>

        </xsl:choose>
 
   </tr>
   
   </tbody>
   </table>

</xsl:template>

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    

  This section of the templates is for generating the actual tab content for each of the portal pages.
  
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->

<xsl:template name="genTabContent">

     
     <div id="pages">

       <xsl:variable name="numTabs"><xsl:value-of select="count(Multiple_Requests/GetMetadataObjects/Objects/Group/Members/PSPortalPage[not(Extensions/Extension[@Name='MarkedForDeletion'])])"/></xsl:variable>

       <xsl:choose>
         <xsl:when test="$numTabs=0">
            <xsl:call-template name="buildErrorPage"/>
         </xsl:when>

         <xsl:otherwise>
           <xsl:apply-templates select="Multiple_Requests/GetMetadataObjects/Objects/Group/Members/PSPortalPage[not(Extensions/Extension[@Name='MarkedForDeletion'])]"/>
         </xsl:otherwise>

       </xsl:choose>

     </div>

</xsl:template>

<!-- the default template if nothing else matches -->

<xsl:template match="*">

<p>hit default template, for object <xsl:value-of select="name(.)"/>:<xsl:value-of select="@Id"/></p>

</xsl:template>

<xsl:template name="PortalPageLink">
    <xsl:param name="showDescription"/>
    <xsl:param name="showLocation"/>
    <!-- TODO: Figure out how to link to another portal page, select the tab and show the page content 
         Something like this is needed to be added to the line below...
         <xsl:attribute name="href">#<xsl:value-of select="@Id"/></xsl:attribute>
    -->

    <a><xsl:attribute name="href"></xsl:attribute><xsl:value-of select="@Name"/></a>

    <xsl:choose>
        <xsl:when test="'$showDescription' != '' and $showDescription = 'true'">
            <table><tr><td><xsl:value-of select="@Desc"/></td></tr></table>
        </xsl:when>
        <xsl:when test="'$showLocation' != '' and $showLocation = 'true'">
            <table><tr><td><xsl:value-of select="@URI"/></td></tr></table>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<xsl:template match="Document">
    <xsl:param name="showDescription"/>
    <xsl:param name="showLocation"/>
    
    <a><xsl:attribute name="target"><xsl:value-of select="$aTarget"/></xsl:attribute><xsl:attribute name="href"><xsl:value-of select="@URI"/></xsl:attribute><xsl:value-of select="@Name"/></a><br/>
    
    <xsl:choose>
        <xsl:when test="$showDescription = 'true' and @Desc != ''">
            <span class="treeDescription">- <xsl:value-of select="@Desc"/><br/></span>
        </xsl:when>
    </xsl:choose>
    <xsl:choose>
        <xsl:when test="$showLocation = 'true' and @URI != ''">
            <span class="treeDescription" style="white-space:nowrap">- <xsl:value-of select="@URI"/><br/></span>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<!-- Template to handle a reference to a stored process (typically in bookmarks) -->

<xsl:template match="ClassifierMap[@TransformRole='StoredProcess']">
    <xsl:param name="showDescription"/>
    <xsl:param name="showLocation"/>


   <xsl:variable name="stpLocation">
      <xsl:for-each select="Trees//Tree">
                     <xsl:sort select="position()" order="descending"/>
                     <xsl:text>/</xsl:text><xsl:value-of select="@Name"/>
      </xsl:for-each>
   </xsl:variable>

   <xsl:variable name="stpProgram">
      <xsl:value-of select="$stpLocation"/><xsl:text>/</xsl:text><xsl:value-of select="@Name"/>
   </xsl:variable>
   <xsl:variable name="stpURI"><xsl:text>/SASStoredProcess/do?_action=form,properties,execute&amp;_program=</xsl:text><xsl:value-of select="replace($stpProgram, '&amp;', '%26')"/></xsl:variable>



   <a><xsl:attribute name="target"><xsl:value-of select="$aTarget"/></xsl:attribute><xsl:attribute name="href"><xsl:value-of select="$stpURI"/></xsl:attribute><xsl:value-of select="@Name"/></a><br/>

   <xsl:choose>
        <xsl:when test="$showDescription = 'true' and @Desc != ''">
            <span style="" colspan="13" class="treeDescription">- <xsl:value-of select="@Desc"/></span><br/>
        </xsl:when>
    </xsl:choose>
    <xsl:choose>
        <xsl:when test="$showLocation = 'true' and $stpLocation != ''">
             <span style="white-space: nowrap;" colspan="13" class="treeDescription">- METASERVER<xsl:value-of select="$stpLocation"/></span>
        </xsl:when>
    </xsl:choose>

</xsl:template>

<!-- Template to handle a reference to a Report (typically in bookmarks)-->

<xsl:template match="Transformation[@TransformRole='Report']">
    <xsl:param name="showDescription"/>
    <xsl:param name="showLocation"/>
<!-- Unfortunately, to display a report, you need the entire path to it, thus it is required to navigate the parent tree
     structure.
-->

   <xsl:variable name="reportSBIPURI">
        <xsl:text>SBIP://METASERVER</xsl:text>
        <xsl:for-each select="Trees//Tree">
            <xsl:sort select="position()" order="descending"/>
            <xsl:text>/</xsl:text><xsl:value-of select="@Name"/>
        </xsl:for-each>
        <xsl:text>/</xsl:text><xsl:value-of select="@Name"/>
   </xsl:variable>

    <xsl:call-template name="reportLink">
       <xsl:with-param name="reportSBIPURI" select="$reportSBIPURI"/>
      <xsl:with-param name="showDescription" select="$showDescription"/>
        <xsl:with-param name="showLocation" select="$showLocation"/>
    </xsl:call-template>

</xsl:template>

<!-- Template to handle a reference to a InformationMap (typically in bookmarks)-->

<xsl:template match="Transformation[@TransformRole='InformationMap']">
    <xsl:param name="showDescription"/>
    <xsl:param name="showLocation"/>
<!-- Unfortunately, to display a report, you need the entire path to it, thus it is required to navigate the parent tree
     structure.
-->

   <xsl:variable name="reportSBIPURI">
        <xsl:text>SBIP://METASERVER</xsl:text>
        <xsl:for-each select="Trees//Tree">
            <xsl:sort select="position()" order="descending"/>
            <xsl:text>/</xsl:text><xsl:value-of select="@Name"/>
        </xsl:for-each>
        <xsl:text>/</xsl:text><xsl:value-of select="@Name"/>
        <xsl:text>(</xsl:text><xsl:value-of select="@TransformRole"/><xsl:text>)</xsl:text>
   </xsl:variable>

    <xsl:call-template name="reportLink">
       <xsl:with-param name="reportSBIPURI" select="$reportSBIPURI"/>
      <xsl:with-param name="showDescription" select="$showDescription"/>
        <xsl:with-param name="showLocation" select="$showLocation"/>
    </xsl:call-template>

</xsl:template>

<!-- there are several types of "collection" portlets, ex. collection, bookmarks, etc. 
     Each of these seem to store content in the same way, so have the common processing here
     -->
<xsl:template name="processCollection">

      <xsl:variable name="numGroups">
           <xsl:value-of select="count(Groups/Group)"/>
       </xsl:variable>

       <xsl:variable name="showDescription">
           <xsl:value-of select="PropertySets/PropertySet/SetProperties/Property[@Name='show-description']/@DefaultValue"/>
       </xsl:variable>
       <xsl:variable name="showLocation">
           <xsl:value-of select="PropertySets/PropertySet/SetProperties/Property[@Name='show-location']/@DefaultValue"/>
       </xsl:variable>
       
       <!-- The first member in the group seems to be a link back to itself, so skip that entry -->
       <xsl:for-each select="Groups/Group">
       
             <xsl:variable name="numMembers">
             <xsl:value-of select="count(Members/*)"/>
          </xsl:variable>
          
          <xsl:for-each select="Members/*">
                 <xsl:if test="position() > 1">
                 <tr>
                 <td class="portletEntry" valign="top">

                     <!-- The user can make a bookmark to Portal Page.  If we just apply the templates
                          to the current entry, it will try to create a new page div in the output html.
                          In this case, we simply want to make a link to the right tab for this referenced portal page.
                     -->
                     <xsl:choose>
                        <xsl:when test="name(.)='PSPortalPage'">
                            <xsl:call-template name="PortalPageLink">
                                    <xsl:with-param name="showDescription" select="$showDescription"/>
                                    <xsl:with-param name="showLocation" select="$showLocation"/>
                                  </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates  select=".">
                                     <xsl:with-param name="showDescription" select="$showDescription"/>
                                     <xsl:with-param name="showLocation" select="$showLocation"/>
                                 </xsl:apply-templates>
                         </xsl:otherwise>
                     </xsl:choose>
                 </td>
                 </tr>
                 </xsl:if>
             </xsl:for-each>
             
          <!-- If the portlet didn't have any members, add a few blank rows -->
          
          <xsl:if test="$numMembers = 1">
             <xsl:call-template name="emptyPortlet"/>                       
          </xsl:if>
          
       </xsl:for-each>

          <xsl:if test="$numGroups = 0">
                       
              <xsl:call-template name="emptyPortlet"/>

          </xsl:if>    

</xsl:template>

<xsl:template name="SASCollectionPortlet">

        <xsl:variable name="showDescription">
            <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='showDescription']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
        </xsl:variable>
        <xsl:variable name="showLocation">
            <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='showLocation']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
        </xsl:variable>
        
    <!-- SAS Collection portlet, build a list of the links -->
        
          <xsl:variable name="numMembers">
             <xsl:value-of select="count(PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='collectionItems']/SetProperties/Property)"/>
          </xsl:variable>
          
          <xsl:for-each select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='collectionItems']/SetProperties/Property">
                 <tr>
                 <td class="portletEntry" valign="top">
                
                     <!-- The user can make a bookmark to Portal Page.  If we just apply the templates
                          to the current entry, it will try to create a new page div in the output html.
                          In this case, we simply want to make a link to the right tab for this referenced portal page.
                     -->
                     <xsl:choose>
                        <xsl:when test="name(.)='PSPortalPage'">
                            <xsl:call-template name="PortalPageLink">
                                    <xsl:with-param name="showDescription" select="$showDescription"/>
                                    <xsl:with-param name="showLocation" select="$showLocation"/>
                                  </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name='processSASCollectionLink'>
                                     <xsl:with-param name="showDescription" select="$showDescription"/>
                                     <xsl:with-param name="showLocation" select="$showLocation"/>
                                 </xsl:call-template>
                         </xsl:otherwise>
                     </xsl:choose>
                 </td>
                 </tr>
             </xsl:for-each>

          <!-- If the portlet didn't have any members, add a few blank rows -->

          <xsl:if test="$numMembers = 1">
             <xsl:call-template name="emptyPortlet"/>
          </xsl:if>


</xsl:template>

<xsl:template name="processSASCollectionLink">

    <xsl:param name="showDescription"/>
    <xsl:param name="showLocation"/>
    <xsl:message>showLocation=<xsl:value-of select="$showLocation"/></xsl:message>
    <xsl:variable name="SBIPURL" select="@DefaultValue"/>
    <xsl:variable name="linkFullName" select="tokenize($SBIPURL, '/')[last()]"/>
    <xsl:variable name="lastParen" select="max(for $i in 1 to string-length($linkFullName)
                                                return if (substring($linkFullName, $i, 1) = '(') then $i else ())" />
    <xsl:variable name="linkName" select="substring($linkFullName,1, $lastParen - 1)" />
    <xsl:variable name="linkFullPath" select="substring($SBIPURL, 1 , string-length($SBIPURL) - string-length($linkFullName ) -1 )" />
    
    <xsl:choose>
        <xsl:when test="contains($SBIPURL, '(Report)') = 'true'">
            <xsl:variable name="SASCollectionURI"><xsl:text>/SASWebReportStudio/openRVUrl.do?rsRID=</xsl:text><xsl:value-of select="$SBIPURL"/></xsl:variable>
            <a><xsl:attribute name="target"><xsl:value-of select="$aTarget"/></xsl:attribute><xsl:attribute name="href"><xsl:value-of select="$SASCollectionURI"/></xsl:attribute><xsl:value-of select="$linkName"/></a>
        </xsl:when>
        <xsl:when test="contains($SBIPURL, '(StoredProcess)') = 'true'">
            <xsl:variable name="SASCollectionURI">/SASStoredProcess/do?_action=execute<xsl:text>&amp;</xsl:text>_program=<xsl:value-of select="$SBIPURL"/></xsl:variable>
            <a><xsl:attribute name="target"><xsl:value-of select="$aTarget"/></xsl:attribute><xsl:attribute name="href"><xsl:value-of select="$SASCollectionURI"/></xsl:attribute><xsl:value-of select="$linkName"/></a>
        </xsl:when>
        <xsl:when test="contains($SBIPURL, '(InformationMap)') = 'true'">
            <xsl:variable name="SASCollectionURI"><xsl:text>/SASWebReportStudio/openRVUrl.do?rsRID=</xsl:text><xsl:value-of select="$SBIPURL"/></xsl:variable>
            <a><xsl:attribute name="target"><xsl:value-of select="$aTarget"/></xsl:attribute><xsl:attribute name="href"><xsl:value-of select="$SASCollectionURI"/></xsl:attribute><xsl:value-of select="$linkName"/></a>
        </xsl:when>
        <xsl:when test="contains($SBIPURL, '(Link)') = 'true'">
            <xsl:variable name="SASCollectionURI">/SASStoredProcess/do?_action=execute<xsl:text>&amp;</xsl:text>_program=<xsl:value-of select="$appLocEncoded"/>services/viewLink<xsl:text>&amp;</xsl:text>path=<xsl:value-of select="$SBIPURL"/></xsl:variable>
            <a><xsl:attribute name="target"><xsl:value-of select="$aTarget"/></xsl:attribute><xsl:attribute name="href"><xsl:value-of select="$SASCollectionURI"/></xsl:attribute><xsl:value-of select="$linkName"/></a>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="SASCollectionURI"></xsl:variable>
            <xsl:call-template name="emptyPortlet"/>
        </xsl:otherwise>
    </xsl:choose>
    
    <!-- @Desc does not work here -->
    <xsl:if test="'$showDescription' != '' and $showDescription = 'true' and @Desc != ''">
        <table><tr><td><span style="" colspan="13" class="treeDescription">- <xsl:value-of select="@Desc"/></span></td></tr></table>
    </xsl:if>
    <xsl:if test="'$showLocation' != '' and $showLocation = 'true'">
        <table><tr><td><span style="white-space: nowrap;" colspan="13" class="treeDescription">- <xsl:value-of select="$linkFullPath"/></span></td></tr></table>
    </xsl:if>

</xsl:template>


<xsl:template name="collectionPortlet">

    <!-- Collection portlet, build a list of the links -->

    <!-- not yet convinced there won't be some differences in how the different collections are processed so keep this redirection template here-->

    <xsl:call-template name="processCollection"/>

</xsl:template>

<xsl:template name="bookmarksPortlet">

    <!-- Bookmark portlet, build a list of the links -->

    <!-- not yet convinced there won't be some differences in how the different collections are processed so keep this redirection template here-->

    <xsl:call-template name="processCollection"/>

</xsl:template>

<!-- Display URL portlet, display the referenced URL -->
<xsl:template name="displayURLPortlet">

   <!-- Get the property that has the URI in it -->
   <xsl:variable name="displayURI">

      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_DisplayURL']/@DefaultValue"/>

   </xsl:variable>

   <xsl:variable name="iframeHeight">

      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='sas_DisplayURL_Height']/@DefaultValue"/>

   </xsl:variable>


    <!-- If a URI is defined, show it, otherwise just render an empty portlet -->
    <xsl:choose >

        <xsl:when test="$displayURI != ''">
               <tr>
            <td class="portletEntry" valign="top" colspan="2">
            <iframe style="overflow: auto;width: 100%" frameborder="0" >
            <xsl:attribute name="data-src"><xsl:value-of select="$displayURI"/></xsl:attribute>
                        <xsl:choose>
            <xsl:when test="'$iframeHeight' != '' and $iframeHeight != 0">
                    <xsl:attribute name="height"><xsl:value-of select="$iframeHeight"/></xsl:attribute>
            </xsl:when> 
                        <xsl:otherwise>
                            <xsl:attribute name="onload">resizeIframe(this)</xsl:attribute>
                        </xsl:otherwise>
                        </xsl:choose>
            </iframe>
            </td>
            </tr>
            </xsl:when>
        <xsl:otherwise>
           <xsl:call-template name="emptyPortlet"/>
        </xsl:otherwise>
    </xsl:choose>

</xsl:template>


<xsl:template name="SASNavigator">
  <xsl:param name = "spaObjectsParam"  select="''"/>

   <!-- Get the SASNavigator and display and call stp -->

        <xsl:variable name="navigatorId" select="@Id"/>

    <xsl:variable name="spaNavPath">
        <xsl:choose>
            <xsl:when test="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='selectedFolder']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue">
                <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='selectedFolder']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>SBIP://METASERVER/(Folder)</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="stpPortletHeight" select="250"/>
    <xsl:variable name="spaPath"><xsl:value-of select="substring-after(substring-before($spaNavPath,'(Folder)'),'SBIP://METASERVER')"/></xsl:variable>
    
    <xsl:variable name="spaObjects">
        <xsl:choose>
            <xsl:when test="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='SMART_OBJECT_TYPE']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue">
                <xsl:for-each select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='SMART_OBJECT_TYPE']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
              <xsl:when test="$spaObjectsParam != ''">
                  <xsl:value-of select="$spaObjectsParam"/>
              </xsl:when>
            <xsl:otherwise>
                <xsl:text>StoredProcess,Report,InformationMap</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    
        <xsl:variable name="stpURI">/SASStoredProcess/do?_action=execute<xsl:text>&amp;</xsl:text>_program=<xsl:value-of select="$appLocEncoded"/>services/spaNavigatorPortlet<xsl:text>&amp;</xsl:text>path=<xsl:value-of select="$spaPath"/><xsl:text>&amp;</xsl:text>objectFilter=<xsl:value-of select="$spaObjects"/><xsl:text>&amp;</xsl:text>navigatorId=<xsl:value-of select="$navigatorId"/></xsl:variable>
    
        <tr>
            <td class="portletEntry" valign="top" colspan="2">
                <iframe style="overflow: auto;width: 100%" frameborder="0" >
                    <xsl:attribute name="data-src"><xsl:value-of select="$stpURI"/></xsl:attribute>
                    
                    <xsl:choose>
                    <xsl:when test="$stpPortletHeight != '' and $stpPortletHeight != 0">
                        <xsl:attribute name="height"><xsl:value-of select="$stpPortletHeight"/></xsl:attribute>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:attribute name="onload">resizeIframe(this)</xsl:attribute>
                    </xsl:otherwise>
                    </xsl:choose>
                </iframe>
            </td>
        </tr>

</xsl:template>



<xsl:template name="SASStoredProcessPortlet">

   <!-- Get the Stored Prcess reference and display it as if it was just a call to a url -->

   <xsl:variable name="stpSBIPURI">
      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='selectedFolderItem']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
    </xsl:variable>
   <xsl:variable name="stpPortletHeight">
      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='portletHeight']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
    </xsl:variable>

   <xsl:choose>
     <xsl:when test="$stpSBIPURI != ''">
         <tr>
            <td class="portletEntry" valign="top" colspan="2">
            
            <xsl:variable name="stpProgram"><xsl:value-of select="encode-for-uri(substring-after($stpSBIPURI,'SBIP://METASERVER'))"/></xsl:variable>

                        <!-- Should we display the form or execute the stp?
                             The old portal allowed you to set values for the prompts when the stp was selected
                             to show in this portlet.  When the portal was displayed, the stp was just executed.
                             Since we aren't currently giving the user the ability to edit prompts when the stp
                             is created, we need to give them the ability to fill in the form if one exists.
                             Thus we created a showForm extension so the user could indicate to do so.
                             Check for it now and see what the want to do.
                        -->
                        <xsl:variable name="showSTPForm">
                          <xsl:choose>
                             <xsl:when test="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='show-form']/@DefaultValue">
                                <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='show-form']/@DefaultValue"/></xsl:when>
                              
                             <xsl:otherwise>false</xsl:otherwise>
                          </xsl:choose>

                        </xsl:variable>
                        <xsl:variable name="stpAction">
                           <xsl:choose>
                             <xsl:when test="$showSTPForm='true'">form,properties,execute</xsl:when>
                             <xsl:otherwise>execute</xsl:otherwise>
                           </xsl:choose>
                        </xsl:variable>
            <xsl:variable name="stpURI">/SASStoredProcess/do?_action=nobanner,<xsl:value-of select="$stpAction"/><xsl:text>&amp;</xsl:text>_program=<xsl:value-of select="$stpProgram"/></xsl:variable>
            <iframe style="overflow: auto;width: 100%" frameborder="0" >
            <xsl:attribute name="data-src"><xsl:value-of select="$stpURI"/></xsl:attribute>

            <xsl:choose>
            <xsl:when test="$stpPortletHeight != '' and $stpPortletHeight != 0">
                <xsl:attribute name="height"><xsl:value-of select="$stpPortletHeight"/></xsl:attribute>
            </xsl:when>

            <xsl:otherwise>
                          <xsl:attribute name="onload">resizeIframe(this)</xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>

            </iframe>

            </td>
            </tr>

     </xsl:when>
     <xsl:otherwise>
           <xsl:call-template name="emptyPortlet"/>
     </xsl:otherwise>


     </xsl:choose>

</xsl:template>

<xsl:template name="reportLink">
   <xsl:param name = "reportSBIPURI" />
   <xsl:param name="showDescription"/>
    <xsl:param name="showLocation"/>

         <tr>
            <td class="portletEntry" valign="top" colspan="2">
            
            <xsl:variable name="wrsProgram"><xsl:value-of select="encode-for-uri($reportSBIPURI)"/></xsl:variable>
            <xsl:variable name="wrsPath"><xsl:value-of select="substring-after($reportSBIPURI,'SBIP://METASERVER')"/></xsl:variable>

            <xsl:variable name="wrsURI"><xsl:text>/SASWebReportStudio/openRVUrl.do?rsRID=</xsl:text><xsl:value-of select="$wrsProgram"/></xsl:variable>

            <a><xsl:attribute name="target"><xsl:value-of select="$aTarget"/></xsl:attribute><xsl:attribute name="href"><xsl:value-of select="$wrsURI"/></xsl:attribute><xsl:value-of select="@Name"/></a><br/>

         <xsl:variable name="wrsLocation">
            <xsl:for-each select="Trees//Tree">
                           <xsl:sort select="position()" order="descending"/>
                           <xsl:text>/</xsl:text><xsl:value-of select="@Name"/>
            </xsl:for-each>
         </xsl:variable>    

         <xsl:choose>
              <xsl:when test="$showDescription = 'true' and @Desc != ''">
                  <span style="" colspan="13" class="treeDescription">- <xsl:value-of select="@Desc"/><br/></span>
              </xsl:when>
          </xsl:choose>
          <xsl:choose>
              <xsl:when test="$showLocation = 'true' and $wrsLocation != ''">
                  <span style="white-space: nowrap;" colspan="13" class="treeDescription">- METASERVER<xsl:value-of select="$wrsLocation"/></span>
              </xsl:when>
          </xsl:choose>


            <!--
            <iframe style="overflow: auto;width: 100%" frameborder="0" >
            <xsl:attribute name="data-src"><xsl:value-of select="$wrsURI"/></xsl:attribute>
            </iframe>
            -->
            
            </td>
            </tr>


</xsl:template>

<xsl:template name="processReportPortlet">
  <xsl:param name = "reportSBIPURI" />

    <xsl:choose>
     <xsl:when test="'$reportSBIPURI' != ''">

        <xsl:call-template name="reportLink">
            <xsl:with-param name="reportSBIPURI" select="$reportSBIPURI"/>
        </xsl:call-template>


     </xsl:when>
     <xsl:otherwise>
           <xsl:call-template name="emptyPortlet"/>
     </xsl:otherwise>

   </xsl:choose>
</xsl:template>

<xsl:template name="ReportLocalPortlet">

   <!-- Get the Report reference.  At least for now, just make it a link that can be launched.  Ultimately, it would be nice if we could 
        show the report in place, but can't find a way to do that yet.
    -->

   <xsl:variable name="wrsSBIPURI">
      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='SELECTED_REPORT']/@DefaultValue"/>
    </xsl:variable>
    
    <xsl:call-template name="processReportPortlet">
       <xsl:with-param name="reportSBIPURI" select="$wrsSBIPURI"/>
    </xsl:call-template>
 
</xsl:template>

<xsl:template name="SASReportPortlet">

   <!-- Get the Report reference.  At least for now, just make it a link that can be launched.  Ultimately, it would be nice if we could 
        show the report in place, but can't find a way to do that yet.
    -->

   <xsl:variable name="wrsSBIPURI">
      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='selectedFolderItem']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
    </xsl:variable>

     <xsl:call-template name="processReportPortlet">
       <xsl:with-param name="reportSBIPURI" select="$wrsSBIPURI"/>
    </xsl:call-template>
   
</xsl:template>

<xsl:template name="emptyPortlet">

                 <tr>
                 <td class="portletEntry" valign="top">
                 <br/>
                 </td>
                 </tr>
          
                 <tr>
                 <td class="portletEntry" valign="top">
                 <br/>
                 </td>
                 </tr>


</xsl:template>

<xsl:template name="buildPlaceholderPortlet">

  <xsl:param name="portletName"/>
  <!-- Placeholder porlets seem to be put in place to occupy the space in the layout -->
  <!-- So that the formatting comes out correctly, need to build the table but hide it-->
  <table cellpadding="2" cellspacing="0" width="100%" style="border:none">
         <th align="left" style="border:none;background:transparent;color:transparent"><xsl:value-of select="$portletName"/></th>
         <xsl:call-template name="emptyPortlet"/>
  </table>
</xsl:template>

<xsl:template match="PSPortlet">
  <xsl:param name="layoutComponentId"/>
  <xsl:param name="layoutComponentType"/>

   <xsl:variable select="@Name" name="portletName"/>

   <!--  It looks like when there isn't a portlet in a given cell in the layout, a place holder portlet
         is put there.  Ignore those.
     -->
   <xsl:choose>     

       <xsl:when test="@Name = 'PlaceHolder'">
            <xsl:call-template name="buildPlaceholderPortlet">

               <xsl:with-param name="portletName"><xsl:value-of select="$portletName"/></xsl:with-param>
            </xsl:call-template>

        </xsl:when>
        <xsl:otherwise>

           <!-- Non-placeholder portlets -->
           <xsl:variable name="portletType" select="@portletType"/>

                   <!-- Have to determine if this portlet can be modified.  We have to do a similar
                        activity that we did for the portal page, query whether the portlet is in 
                        a writeable tree. 
                   -->

                   <xsl:variable name="portletPermissionsTree" select="Trees/Tree"/>
                   <xsl:variable name="portletPermissionsTreeId" select="$portletPermissionsTree/@Id"/>

                   <xsl:variable name="portletPermissionsTreeKey" select="key('treeKey',$portletPermissionsTreeId,$treeLookup)/@Name"/>

                   <xsl:variable name="portletIsWriteable">
                      <xsl:choose>
                         <xsl:when test="$portletPermissionsTreeKey">1</xsl:when>
                         <xsl:otherwise>0</xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                   <!-- We only support editing of certain types of portlets -->
                   <xsl:variable name="portletIsEditable">
                      <xsl:choose>
              <xsl:when test="@portletType='Collection'">1</xsl:when>
             <xsl:when test="@portletType='DisplayURL'">1</xsl:when>
              <xsl:when test="@portletType='SASStoredProcess'">1</xsl:when>
              <xsl:when test="@portletType='SASReportPortlet'">1</xsl:when>
             <xsl:when test="@portletType='Report'">1</xsl:when>
              <xsl:when test="@portletType='Bookmarks'">1</xsl:when>
              <xsl:when test="@portletType='SASNavigator'">1</xsl:when>
                         <xsl:otherwise>0</xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>

           <xsl:variable name="portletId" select="@Id"/>

           <table cellpadding="2" cellspacing="0" width="100%" class="portletTableBorder">
           <tr class="portletTableHeader">
               <th align="left" class="tableHeader portletTableHeaderLeft" style="border-right:none">
              <xsl:value-of select="$portletName"/>
               </th>
            <th align="right" class="portletTableHeaderRight">
            <table cellpadding="0" cellspacing="0" border="0">
                        <tbody>
                            <tr>
                               <td nowrap="" valign="middle"><i><font size="1"> </font></i></td>
                               <td>&#160;</td>
                               <td>&#160;</td>
                                <xsl:choose>
                                    <xsl:when test="$portletIsWriteable='1'">

                                        <xsl:if test="$portletIsEditable='1'">
                                            <td nowrap="" valign="middle">
                                                <img alt="" width="1" height="15" valign="middle" border="0"><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/PortletPipe.gif</xsl:attribute></img>
                                            </td>
                                            <td>&#160;</td>
                                            <td nowrap="" valign="middle">
                                                <xsl:variable name="editPortletContentLink" select="concat('editItem.html?Id=',$portletId,'&amp;portletType=',$portletType,'&amp;Type=PSPortlet','&amp;v=5')"/>

                                                <a target="_self"><xsl:attribute name="href"><xsl:value-of select="$editPortletContentLink"/></xsl:attribute>
                                                <img valign="middle" border="0"><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/PortletNote.gif</xsl:attribute><xsl:attribute name="alt"><xsl:value-of select="$portletEditContent"/></xsl:attribute><xsl:attribute name="title"><xsl:value-of select="$portletEditContent"/></xsl:attribute></img>
                                                </a>
                                            </td>
                                            <td>&#160;</td>
                                            <td nowrap="" valign="middle">
                                                <img alt="" width="1" height="15" valign="middle" border="0"><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/PortletPipe.gif</xsl:attribute></img>
                                            </td>
                                            <td>&#160;</td>
                                            <td nowrap="" valign="middle">
                                                <xsl:variable name="editPortletPropertiesLink" select="concat('editItem.html?Id=',$portletId,'&amp;portletType=psportlet-properties&amp;Type=PSPortlet','&amp;v=5')"/>

                                                <a target="_self"><xsl:attribute name="href"><xsl:value-of select="$editPortletPropertiesLink"/></xsl:attribute>
                                                <img valign="middle" border="0"><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/PortletProp.gif</xsl:attribute><xsl:attribute name="alt"><xsl:value-of select="$portletEditProperties"/></xsl:attribute><xsl:attribute name="title"><xsl:value-of select="$portletEditProperties"/></xsl:attribute></img>
                                                </a>
                                            </td>
                                            <td>&#160;</td>
                                        </xsl:if>

                                        <td nowrap="" valign="middle">
                                            <img alt="" width="1" height="15" valign="middle" border="0"><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/PortletPipe.gif</xsl:attribute></img>
                                        </td>
                                        <td>&#160;</td>
                                    <td nowrap="" valign="middle">
                                        <xsl:variable name="removeLink" select="concat('removeItem.html?Id=',$portletId,'&amp;portletType=',$portletType,'&amp;Type=PSPortlet','&amp;RelatedId=',$layoutComponentId,'&amp;RelatedType=',$layoutComponentType,'&amp;v=5')"/>
                                      <a target="_self">
                                        <xsl:attribute name="href"><xsl:value-of select="$removeLink"/></xsl:attribute>
                                            <img valign="middle" border="0"><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/PortletClose.gif</xsl:attribute><xsl:attribute name="alt"><xsl:value-of select="$portletRemove"/></xsl:attribute><xsl:attribute name="title"><xsl:value-of select="$portletRemove"/></xsl:attribute></img>
                                      </a>
                                    </td>
                                    <td>&#160;</td>
                                   </xsl:when>
                                   <xsl:otherwise>
                                     <td colspan="13" nowrap="" valign="middle">&#160;</td>
                                   </xsl:otherwise>
                                </xsl:choose>

            </tr>
                        </tbody>
        </table>
            </th>
            </tr>
            <xsl:choose>

              <xsl:when test="@portletType='Collection'">
                            <xsl:call-template name="collectionPortlet"/>
                  </xsl:when>
              <xsl:when test="@portletType='CollectionPortlet'">
                            <xsl:call-template name="SASCollectionPortlet"/>
                  </xsl:when>
                  <xsl:when test="@portletType='DisplayURL'">
                       <xsl:call-template name="displayURLPortlet"/>
                </xsl:when>
              <xsl:when test="@portletType='SASStoredProcess'">
                       <xsl:call-template name="SASStoredProcessPortlet"/>
                </xsl:when>
              <xsl:when test="@portletType='SASReportPortlet'">
                       <xsl:call-template name="SASReportPortlet"/>
                </xsl:when>
              <xsl:when test="@portletType='Report'">
                       <xsl:call-template name="ReportLocalPortlet"/>
                </xsl:when>
              <xsl:when test="@portletType='Bookmarks'">
                       <xsl:call-template name="bookmarksPortlet"/>
                </xsl:when>
              <xsl:when test="@portletType='SASNavigator'">
                       <xsl:call-template name="SASNavigator"/>
                </xsl:when>
              <xsl:when test="@portletType='InformationMapNavigator'">
                        <xsl:call-template name="SASNavigator">
                          <xsl:with-param name="spaObjectsParam">InformationMap</xsl:with-param>
                        </xsl:call-template>         
              </xsl:when>
              <xsl:when test="@portletType='StoredProcessNavigator'">
                        <xsl:call-template name="SASNavigator">
                          <xsl:with-param name="spaObjectsParam">StoredProcess</xsl:with-param>
                        </xsl:call-template>
              </xsl:when>
              <xsl:when test="@portletType='TreeNavigator'">
                        <xsl:call-template name="SASNavigator"/>
              </xsl:when>
              <xsl:when test="@portletType='ReportNavigator'">
                        <xsl:call-template name="SASNavigator">
                          <xsl:with-param name="spaObjectsParam">Report</xsl:with-param>
                        </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <!-- currently unsupported portlet type, render an empty portlet -->
                    <xsl:call-template name="emptyPortlet"/>
              </xsl:otherwise>
            </xsl:choose>

               </table>
       </xsl:otherwise>

    </xsl:choose>

</xsl:template>

<!--  Render the Column of the page -->

<xsl:template match="PSColumnLayoutComponent">

   <xsl:variable name="layoutComponentId" select="@Id"/>
   <xsl:variable name="layoutComponentType" select="name(.)"/>
   <xsl:apply-templates select="Portlets/PSPortlet">
     <xsl:with-param name="layoutComponentId" select="$layoutComponentId"/>
     <xsl:with-param name="layoutComponentType" select="$layoutComponentType"/>
   </xsl:apply-templates>
   
</xsl:template>

<!-- Render the page -->

<xsl:template match="PSPortalPage">

       <div class="tabcontent"><xsl:attribute name="id"><xsl:value-of select="@Id"/></xsl:attribute>
     
           <!-- Add it to our metadata about the tabs -->
 
           <xsl:call-template name="addTabMap"/>
 
       <!--  Get what type of layout it has, 1, 2 or 3 columns -->
       
       <xsl:variable name="numColumns">
          <xsl:value-of select="count(LayoutComponents/PSColumnLayoutComponent)"/>
       </xsl:variable>
    
       <!-- table cellpadding="2" cellspacing="0" width="100%" class="portletTableBorder" -->
       <table cellpadding="2" cellspacing="0" width="100%">
       
       <xsl:choose>
          <xsl:when test="$numColumns = 1">
            <tr valign="top">
              <td><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[1]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[1]"/></td>
            </tr>
          </xsl:when>
          <xsl:when test="$numColumns = 2">
            <tr valign="top">
              <td><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[1]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[1]"/></td>
              <td><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[2]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[2]"/></td>
            </tr>
          </xsl:when>
          <xsl:when test="$numColumns = 3">
            <tr valign="top">
              <td><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[1]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[1]"/></td>
              <td><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[2]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[2]"/></td>
              <td><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[3]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[3]"/></td>
            </tr>
          </xsl:when>
          <xsl:otherwise>
            <p>unknown columns</p>
          </xsl:otherwise>
    
       </xsl:choose>
       
       </table>
       
       </div>
</xsl:template>

<!-- Build an ERROR Page -->

<xsl:template name="buildErrorPage">

           <div class="tabcontent" id="content_0">
           <!-- table cellpadding="2" cellspacing="0" width="100%" class="portletTableBorder" -->
           <table cellpadding="2" cellspacing="0" width="100%">

                <tr valign="top">
                <td width="100%">

                   <b>No Portal content exists for this user.</b>

                </td>
                </tr>

           </table>

           </div>
</xsl:template>

</xsl:stylesheet>
