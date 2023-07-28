<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<xsl:template match="Document">

<a><xsl:attribute name="href"><xsl:value-of select="@URI"/></xsl:attribute><xsl:value-of select="@Name"/></a>
  
</xsl:template>

<xsl:template name="collectionPortlet">
<!-- Collection portlet, build a list of the links -->
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

<xsl:template name="displayURLPortlet">
<!-- Display URL portlet, display the referenced URL -->

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
	    <!-- So that the formatting comes out correctly, need to build the table but hide it-->

		   <table cellpadding="2" cellspacing="0" width="100%" style="border:none">
   			<th align="left" style="border:none;background:transparent;color:transparent">
	   			<xsl:value-of select="$portletName"/>
   			</th>
    		<xsl:call-template name="emptyPortlet"/>
			</table>

		</xsl:when>
		<xsl:otherwise>
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
