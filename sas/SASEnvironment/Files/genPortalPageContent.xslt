<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<!-- the default template if nothing else matches -->

<xsl:template match="*">

<p>hit default template</p>

</xsl:template>

<xsl:template match="Document">

<a><xsl:attribute name="href"><xsl:value-of select="@URI"/></xsl:attribute><xsl:value-of select="@Name"/></a>
  
</xsl:template>

<!-- Template to handle a reference to a Report (typically in bookmarks)-->

<xsl:template match="Transformation[@TransformRole='Report']">

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
	</xsl:call-template>

</xsl:template>

<!-- there are several types of "collection" portlets, ex. collection, bookmarks, etc. 
     Each of these seem to store content in the same way, so have the common processing here
	 -->
<xsl:template name="processCollection">

      <xsl:variable name="numGroups">
	       <xsl:value-of select="count(Groups/Group)"/>
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
	             <xsl:apply-templates  select="."/>
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

    	<xsl:when test="'$displayURI' != ''">
   	        <tr>
	        <td class="portletEntry" valign="top">
			<iframe style="overflow: auto;width: 100%" frameborder="0" >
	        <xsl:attribute name="src"><xsl:value-of select="$displayURI"/></xsl:attribute>
			<xsl:if test="'$iframeHeight' != ''">
                    <xsl:attribute name="height"><xsl:value-of select="$iframeHeight"/></xsl:attribute>
			</xsl:if>

			</iframe>
	        </td>
	        </tr>
			</xsl:when>
		<xsl:otherwise>
		   <xsl:call-template name="emptyPortlet"/>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template name="SASStoredProcessPortlet">

   <!-- Get the Stored Prcess reference and display it as if it was just a call to a url -->

   <xsl:variable name="stpSBIPURI">
      <xsl:value-of select="PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/PropertySets/PropertySet[@Name='selectedFolderItem']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
	</xsl:variable>
   <xsl:choose>
     <xsl:when test="'$stpSBIPURI' != ''">
         <tr>
	        <td class="portletEntry" valign="top">
			
			<xsl:variable name="stpProgram"><xsl:value-of select="encode-for-uri(substring-after($stpSBIPURI,'SBIP://METASERVER'))"/></xsl:variable>
			<!-- NOTE: Can't figure out how to pass an & in the value of an attribute, thus not including the _action parameter for now
			<xsl:variable name="stpURI"><xsl:text>/SASStoredProcess/do?_action=form,properties,execute,nobanner,newwindow&_program=</xsl:text><xsl:value-of select="$stpProgram"/></xsl:variable>
			-->
			
			<xsl:variable name="stpURI"><xsl:text>/SASStoredProcess/do?_program=</xsl:text><xsl:value-of select="$stpProgram"/></xsl:variable>
			<iframe style="overflow: auto;width: 100%" frameborder="0" >
            <xsl:attribute name="src"><xsl:value-of select="$stpURI"/></xsl:attribute>
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

         <tr>
	        <td class="portletEntry" valign="top">
			
			<xsl:variable name="wrsProgram"><xsl:value-of select="encode-for-uri($reportSBIPURI)"/></xsl:variable>
			<xsl:variable name="wrsPath"><xsl:value-of select="substring-after($reportSBIPURI,'SBIP://METASERVER')"/></xsl:variable>

			<xsl:variable name="wrsURI"><xsl:text>/SASWebReportStudio/openRVUrl.do?rsRID=</xsl:text><xsl:value-of select="$wrsProgram"/></xsl:variable>

			<a><xsl:attribute name="href"><xsl:value-of select="$wrsURI"/></xsl:attribute><xsl:value-of select="$wrsPath"/></a>

			<!--
			<iframe style="overflow: auto;width: 100%" frameborder="0" >
            <xsl:attribute name="src"><xsl:value-of select="$wrsURI"/></xsl:attribute>
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

<xsl:template match="PSPortlet">

   <xsl:variable select="@Name" name="portletName"/>

   <!--  It looks like when there isn't a portlet in a given cell in the layout, a place holder portlet
         is put there.  Ignore those.
     -->
   <xsl:choose>     

	   <xsl:when test="@Name = 'PlaceHolder'">
	    <!-- Placeholder porlets seem to be put in place to occupy the space in the layout -->
	    <!-- So that the formatting comes out correctly, need to build the table but hide it-->

		   <table cellpadding="2" cellspacing="0" width="100%" style="border:none">
   			<th align="left" style="border:none;background:transparent;color:transparent">
	   			<xsl:value-of select="$portletName"/>
   			</th>
    		<xsl:call-template name="emptyPortlet"/>
			</table>

		</xsl:when>
		<xsl:otherwise>

		   <!-- Non-placeholder portlets -->

		   <table cellpadding="2" cellspacing="0" width="100%" class="portletTableBorder">
   			<th align="left" class="tableHeader portletTableHeader">
	   			<xsl:value-of select="$portletName"/>
   			</th>

			<xsl:choose>

		  		<xsl:when test="@portletType='Collection'">
    	       	<xsl:call-template name="collectionPortlet"/>
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

   <xsl:apply-templates select="Portlets/PSPortlet"/>
   
</xsl:template>

<!-- Render the page -->

<xsl:template match="PSPortalPage">

	   <div class="tabcontent"><xsl:attribute name="id"><xsl:value-of select="@Id"/></xsl:attribute>
	   
	   <!--  Get what type of layout it has, 1, 2 or 3 columns -->
	   
	   <xsl:variable name="numColumns">
	      <xsl:value-of select="count(LayoutComponents/PSColumnLayoutComponent)"/>
	   </xsl:variable>
	
	   <!-- table cellpadding="2" cellspacing="0" width="100%" class="portletTableBorder" -->
	   <table cellpadding="2" cellspacing="0" width="100%">
	   
	   <xsl:choose>
	      <xsl:when test="$numColumns = 1">
	        <tr valign="top">
	        <td><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[1]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[1]"/>
	        </td>
	        </tr>
	      </xsl:when>
	      <xsl:when test="$numColumns = 2">
	        <tr valign="top">
	        <td align="top"><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[1]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[1]"/></td>
	        <td alight="top"><xsl:attribute name="width"><xsl:value-of select="LayoutComponents/PSColumnLayoutComponent[2]/@ColumnWidth"/>%</xsl:attribute><xsl:apply-templates select="LayoutComponents/PSColumnLayoutComponent[2]"/></td>
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

<xsl:template match="/">
   <!-- Create the tab content area -->
   <xsl:apply-templates select="GetMetadataObjects/Objects/Group/Members/PSPortalPage"/>

</xsl:template>


</xsl:stylesheet>
