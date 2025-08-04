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
<xsl:variable name="sasFolders" select="$localeXml/string[@key='sasFolders']/text()"/>
<xsl:variable name="myFolder" select="$localeXml/string[@key='myFolder']/text()"/>
<xsl:variable name="locationTitle" select="$localeXml/string[@key='locationTitle']/text()"/>
<xsl:variable name="upOneLevelTitle" select="$localeXml/string[@key='upOneLevelTitle']/text()"/>
<xsl:variable name="sasnavigatorNameTitle" select="$localeXml/string[@key='sasnavigatorNameTitle']/text()"/>
<xsl:variable name="sasnavigatorTypeTitle" select="$localeXml/string[@key='sasnavigatorTypeTitle']/text()"/>
<xsl:variable name="sasnavigatorCreatedTitle" select="$localeXml/string[@key='sasnavigatorCreatedTitle']/text()"/>
<xsl:variable name="sasnavigatorModifiedTitle" select="$localeXml/string[@key='sasnavigatorModifiedTitle']/text()"/>
<xsl:variable name="sasnavigatorFolderType" select="$localeXml/string[@key='sasnavigatorFolderType']/text()"/>
<xsl:variable name="sasnavigatorStoredProcessType" select="$localeXml/string[@key='sasnavigatorStoredProcessType']/text()"/>
<xsl:variable name="sasnavigatorReportType" select="$localeXml/string[@key='sasnavigatorReportType']/text()"/>
<xsl:variable name="sasnavigatorInformationMapRelationalType" select="$localeXml/string[@key='sasnavigatorInformationMapRelationalType']/text()"/>
<xsl:variable name="sasnavigatorInformationMapOlapType" select="$localeXml/string[@key='sasnavigatorInformationMapOlapType']/text()"/>

<!-- Global Variables -->

<xsl:variable name="path" select="/Mod_Request/NewMetadata/Path"/>
<xsl:variable name="objectFilter" select="/Mod_Request/NewMetadata/ObjectFilter"/>
<xsl:variable name="objectFilterEncoded" select="concat('&amp;objectFilter=',encode-for-uri($objectFilter))"/>
<xsl:variable name="navigatorId" select="/Mod_Request/NewMetadata/NavigatorId"/>

<xsl:variable name="showDescription" select="/Mod_Request/NewMetadata/ShowDescription"/>

<xsl:variable name="homeURL" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/spaNavigatorPortlet')"/>

<!--  Main Template -->

<xsl:template match="/">

<head>
<xsl:call-template name="thisPageStyle"/>
<xsl:call-template name="thisPageScripts"/>
</head>
<body class='body'>

 <!--  If the user had passed a blank path or a path='/', then we would have retrieved the root of the SAS Content Tree
      There is not actually a "root" tree, but instead it is a rooted by a SoftwareComponent (named BIP Service) and the set of
      initial trees are associated with it.  Thus, we need to look at what is passed and process it the correct way.
      Note that the "root" of the tree (a SoftwareComponent) can only have sub-trees, where as an actual Tree can have subtrees and members.
 -->

<!--  Get the folder Object from the query to get the subfolders -->

<xsl:variable name="folderType" select="name($metadataContext/Multiple_Requests/GetMetadata[1]/Metadata/*[1])"/>

<xsl:variable name="softwareComponent" select="$metadataContext/Multiple_Requests/GetMetadata[1]/Metadata/SoftwareComponent"/>

<xsl:variable name="folderObject" select="$metadataContext/Multiple_Requests/GetMetadata[1]/Metadata/Tree"/>

<!-- this code works for a passed softwarecomponent because the folderObject won't exist and thus the @Name won't exist -->
<xsl:variable name="folderName">
 <xsl:choose>
   <xsl:when test="$folderObject/@Name"><xsl:value-of select="$folderObject/@Name"/></xsl:when>
   <xsl:otherwise><xsl:value-of select="$sasFolders"/></xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<xsl:variable name="folderNameImage">
 <xsl:choose>
   <xsl:when test="$folderObject/@Name">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Folder.gif</xsl:when>
   <xsl:otherwise>/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/SASFolders.gif</xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<!--  Parse the passed path -->

<xsl:variable name="folderNamesWithBlank" select="tokenize($path,'/')"/>
<xsl:variable name="folderNames" select="$folderNamesWithBlank[normalize-space()]"/>

<!--  Create the Header control area -->

<xsl:variable name="upOneLevelTemp">/<xsl:for-each select="$folderNames[position() &lt; count($folderNames)]"><xsl:if test="."><xsl:value-of select="."/>/</xsl:if></xsl:for-each></xsl:variable>
<xsl:variable name="upOneLevel" select="replace($upOneLevelTemp,'//','/')"/>

<table border='0' cellspacing='0'>
    <tr class='tableColumnHeaderRow'>
        <td class="none" nowrap='nowrap'><xsl:value-of select="$locationTitle"/>
              <div class='dropdown'>
                  <button class='dropbtn'><img border='0'><xsl:attribute name="src" select="$folderNameImage"/></img><xsl:value-of select="$folderName"/></button>
                  <div class='dropdown-content' nowrap='nowrap'>
                      <xsl:if test="not($path='/')">

                        <!-- Add a title entry -->

                        <a><xsl:attribute name="href" select="concat($homeURL,$objectFilterEncoded,'&amp;_action=execute&amp;path=/','&amp;navigatorId=',$navigatorId)"/>
                           <img border='0'><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Folder.gif</xsl:attribute></img>&#160;<xsl:value-of select="$sasFolders"/>
                        </a>

                        <!-- Loop over every part of the current path and create an entry for it --> 

                        <xsl:for-each select="$folderNames">

                           <xsl:variable name="currentDepth" select="position()"/>

                           <xsl:variable name="subFolderName" select="."/>

                           <xsl:if test="$subFolderName">

				   <!-- Build the path for this parent folder -->

				   <xsl:variable name="subFolderPathTemp">/<xsl:for-each select="$folderNames[position() &lt;= $currentDepth]"><xsl:if test="."><xsl:value-of select="."/>/</xsl:if></xsl:for-each></xsl:variable>
                                   <!-- depending on what syntax of path is passed in, we could end up with some double slashes in it, make sure
                                        those are removed.
                                   -->
                                   <xsl:variable name="subFolderPath" select="replace($subFolderPathTemp,'//','/')"/>
				   <a><xsl:attribute name="href" select="concat($homeURL,$objectFilterEncoded,'&amp;_action=execute&amp;path=',$subFolderPath,'&amp;navigatorId=',$navigatorId)"/>
                                      <!-- indent for each layer of the path -->
                                      <xsl:for-each select="1 to $currentDepth">&#160;</xsl:for-each>                                      
                                      <img border='0'><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Folder.gif</xsl:attribute></img>&#160;<xsl:value-of select="$subFolderName"/>
                                   </a>

                           </xsl:if>

                        </xsl:for-each>

                      </xsl:if>
                  </div>
              </div>
        </td>
        <td class="none">&#160;&#160;&#160;</td>
        <td nowrap='nowrap' class="none">
           <xsl:choose>
           <xsl:when test="not($path='/') and not($path='')">

                        <a><xsl:attribute name="href" select="concat($homeURL,$objectFilterEncoded,'&amp;_action=execute&amp;path=',$upOneLevel,'&amp;navigatorId=',$navigatorId)"/>
                           <img border='0'><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/up_one_level.gif</xsl:attribute><xsl:attribute name="alt" select="$upOneLevelTitle"/><xsl:attribute name="title" select="$upOneLevelTitle"/></img><span><xsl:attribute name="title" select="$upOneLevelTitle"/>&#160;<xsl:value-of select="$upOneLevelTitle"/></span>
                        </a>
           </xsl:when>
           <xsl:otherwise>
                         <img border='0'><xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/up_one_level_inactive.gif</xsl:attribute><xsl:attribute name="alt" select="$upOneLevelTitle"/><xsl:attribute name="title" select="$upOneLevelTitle"/></img><span><xsl:attribute name="title" select="$upOneLevelTitle"/>&#160;<xsl:value-of select="$upOneLevelTitle"/></span>

           </xsl:otherwise>

           </xsl:choose>

        </td>
    </tr>
</table>

<!--   Create the list of contents -->

<table class="table" width="100%" border="1" cellspacing="0">
    <thead>
        <tr class="tableColumnHeaderRow">
            <th class="l"><span class="portletTableHeader"><xsl:value-of select="$sasnavigatorNameTitle"/></span></th>
            <th class="l"><span class="l"><xsl:value-of select="$sasnavigatorTypeTitle"/></span></th>
            <th class="l"><span><xsl:value-of select="$sasnavigatorModifiedTitle"/></span></th>
        </tr>
    </thead>

    <tbody>

    <!-- Loop over list of child folders -->

       <xsl:choose>

           <xsl:when test="$folderType='SoftwareComponent'">
               <xsl:call-template name="listChildren">
                    <xsl:with-param name="childListParent" select="$softwareComponent/SoftwareTrees"/>
               </xsl:call-template>
           </xsl:when>

           <xsl:when test="$folderType='Tree'">
               <xsl:call-template name="listChildren">
                    <xsl:with-param name="childListParent" select="$folderObject/SubTrees"/>
               </xsl:call-template>
           </xsl:when>
           <xsl:otherwise><xsl:message>ERROR: Invalid tree passed to SAS Navigator</xsl:message></xsl:otherwise>
       </xsl:choose>

    <!-- Loop over list of child members -->

    <xsl:variable name="folderMemberObject" select="$metadataContext/Multiple_Requests/GetMetadata[2]/Metadata/Tree"/>

    <xsl:call-template name="listChildren">
	 <xsl:with-param name="childListParent" select="$folderMemberObject/Members"/>
    </xsl:call-template>
 
    </tbody>
</table>

</body>
<script >

    var pathValue = "<xsl:value-of select='$path' />";
    sessionStorage.setItem("pathValue.<xsl:value-of select="$navigatorId"/>", pathValue);

</script>
</xsl:template>

<xsl:template name="listChildren">

 <xsl:param name="childListParent"/>

    <xsl:for-each select="$childListParent/*">
        <xsl:sort select="upper-case(@Name)" order="ascending" />

        <xsl:variable name="childFolderName" select="@Name"/>

        <xsl:variable name="childType">
           <xsl:choose>
              <xsl:when test="name(.)='Tree'">folder</xsl:when>
              <xsl:when test="name(.)='ClassifierMap' and @TransformRole='StoredProcess'">storedprocess</xsl:when>
              <xsl:when test="name(.)='Transformation' and @TransformRole='Report'">report</xsl:when>
              <xsl:when test="name(.)='Transformation' and @TransformRole='InformationMap' and @PublicType='InformationMap.OLAP'">imap_olap</xsl:when>
              <xsl:when test="name(.)='Transformation' and @TransformRole='InformationMap' and @PublicType='InformationMap.Relational'">imap_relational</xsl:when>
              <xsl:otherwise>unsupported</xsl:otherwise>
           </xsl:choose>
        </xsl:variable>

        <!-- We will use the following variable to indicate whether we should include this in the output or not.  A missing value indicates
             we should not include it.  It could be missing because it is a type of object we don't support, or it could be because the passed
             objectFilter doesn't include it
        -->
        <xsl:variable name="childTypeString">
            <xsl:choose>
              <xsl:when test="$childType='folder'"><xsl:value-of select="$sasnavigatorFolderType"/></xsl:when>
              <xsl:when test="$childType='storedprocess'"><xsl:if test="contains(lower-case($objectFilter),'storedprocess')"><xsl:value-of select="$sasnavigatorStoredProcessType"/></xsl:if></xsl:when>
              <xsl:when test="$childType='report'"><xsl:if test="contains(lower-case($objectFilter),'report')"><xsl:value-of select="$sasnavigatorReportType"/></xsl:if></xsl:when>
              <xsl:when test="$childType='imap_relational'"><xsl:if test="contains(lower-case($objectFilter),'informationmap')"><xsl:value-of select="$sasnavigatorInformationMapRelationalType"/></xsl:if></xsl:when>
              <xsl:when test="$childType='imap_olap'"><xsl:if test="contains(lower-case($objectFilter),'informationmap')"><xsl:value-of select="$sasnavigatorInformationMapOlapType"/></xsl:if></xsl:when>
              <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="childImage">
            <xsl:choose>
              <xsl:when test="$childType='folder'">Folder.gif</xsl:when>
              <xsl:when test="$childType='storedprocess'">StoredProcess.gif</xsl:when>
              <xsl:when test="$childType='report'">Report.gif</xsl:when>
              <xsl:when test="$childType='imap_relational'">InformationMapRelational.gif</xsl:when>
              <xsl:when test="$childType='imap_olap'">InformationMapOLAP.gif</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="childPathTemp" select="concat($path,'/',$childFolderName)"/>
        <xsl:variable name="childPathSlash" select="replace($childPathTemp,'//','/')"/>
        <xsl:variable name="childPath" select="replace($childPathSlash,'\+','%2B')"/>
        <xsl:variable name="myfolderPath" select="concat($homeURL,$objectFilterEncoded,'&amp;_action=execute&amp;path=/User Folders/',$envMetaperson,'/My Folder','&amp;navigatorId=',$navigatorId)"/>

        <xsl:variable name="childLink">
            <xsl:choose>
              <xsl:when test="$childType='folder'"><xsl:value-of select="concat($homeURL,$objectFilterEncoded,'&amp;_action=execute&amp;path=',$childPath,'&amp;navigatorId=',$navigatorId)"/></xsl:when>
              <xsl:when test="$childType='storedprocess'"><xsl:value-of select="concat('/SASStoredProcess/do?_action=form,properties,execute,newwindow&amp;_program=',$childPath)"/></xsl:when>
              <xsl:when test="$childType='report'"><xsl:value-of select="concat('/SASWebReportStudio/openRVUrl.do?rsRID=SBIP://METASERVER',$childPath,'(Report)')"/></xsl:when>
              <xsl:when test="$childType='imap_relational' or $childType='imap_olap'"><xsl:value-of select="concat('/SASWebReportStudio/openRVUrl.do?rsRID=SBIP://METASERVER',$childPath,'(InformationMap)')"/></xsl:when>
              <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="not($childTypeString='')">

            <xsl:if test="$path='/' and position()=1">
                <tr>
                    <td><span><img style="vertical-align:baseline;" border="0">
                              <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/MyFolder.gif</xsl:attribute></img>
                        <xsl:choose>
                            <xsl:when test="$childLink">
                                <a><xsl:attribute name="href" select="$myfolderPath"/>
                                <xsl:if test="not($childType='folder')">
                                   <xsl:attribute name="target">_blank</xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="$myFolder"/>
                                </a>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:if test="$showDescription">
                        <br/><small><xsl:value-of select="@Desc"/></small>
                        </xsl:if>
                        </span>
                    </td>
                    <td><span><xsl:value-of select="$childTypeString"/></span></td>
                    <td><span><xsl:value-of select="@MetadataCreated"/></span></td>
                </tr>
            </xsl:if>
            <tr>
                <td><span><img style="vertical-align:baseline;" border="0">
                          <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/<xsl:value-of select="$childImage"/></xsl:attribute></img>
                    <xsl:choose>
                        <xsl:when test="$childLink">
                            <a><xsl:attribute name="href" select="$childLink"/>
                            <xsl:if test="not($childType='folder')">
                               <xsl:attribute name="target">_blank</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$childFolderName"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$childFolderName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="$showDescription">
                    <br/><small><xsl:value-of select="@Desc"/></small>
                    </xsl:if>
                    </span>
                </td>

                <td><span><xsl:value-of select="$childTypeString"/></span></td>
                <xsl:choose>
                        <xsl:when test="@MetadataUpdated">
                            <td><span><xsl:value-of select="@MetadataUpdated"/></span></td>
                        </xsl:when>
                        <xsl:otherwise>
                            <td><span><xsl:value-of select="@MetadataCreated"/></span></td>
                        </xsl:otherwise>
                </xsl:choose>
                
            </tr>

        </xsl:if>

     </xsl:for-each>

</xsl:template>

<xsl:template name="thisPageStyle">

<style>
{
  background-color: #FAFBFE;
  color: #000000;
  font-family: Arial, 'Albany AMT', Helvetica, Helv;
  font-size: x-small;
  font-style: normal;
  font-weight: normal;
  margin-left: 8px;
  margin-right: 8px;
}
A {
    color: #275e94;
    text-decoration: none;
}
.table
{
  border-bottom-width: 0px;
  border-collapse: collapse;
  border-color: #C1C1C1;
  border-left-width: 1px;
  border-right-width: 0px;
  border-spacing: 0px;
  border-style: solid;
  border-top-width: 1px;
}

.l {text-align: left }
.c {text-align: center }
.r {text-align: right }
.d {text-align: right }
.j {text-align: justify }
.t {vertical-align: top }
.m {vertical-align: middle }
.b {vertical-align: bottom }
TD, TH {
    vertical-align: top
    border-bottom: #cecfd2 1px solid;
    border-left: none;
    border-right: #cecfd2 1px solid;
    border-top: none;
    color: #000000;
    font-size: small;
    font-family: 'trebuchet ms', arial, 'arial unicode ms', sans-serif;
}
td.none {border: 0}
.dropbtn {
  background-color: white;
  padding: 2px 4px;
}

.dropdown {
  position: relative;
  display: inline-block;
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: #ffffff;
  padding: 2px 4px;
  min-width: 200px;
  box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
  z-index: 5;
}

.dropdown-content a {
  color: black;
  background-color: #ffffff;
  padding: 4px 4px;
  display: block;
  min-width: 300px;
  text-decoration: none;
}

.dropdown-content a:hover {background-color: #f1f1f1;}

.dropdown:hover .dropdown-content {display: block;}

.dropdown:hover .dropbtn {background-color: #999999;}
</style>

</xsl:template>

<xsl:template name="thisPageScripts">

</xsl:template>

</xsl:stylesheet>

