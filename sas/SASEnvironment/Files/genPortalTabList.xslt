<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<xsl:template match="/">
   <!-- Loop over all the tabs on the page and create the tab structure -->
   <table id="pagetabs_Table" class="BannerTabMenuTable" cellspacing="0" cellpadding="0" border="0">
   <tbody>
   <tr>

   <xsl:for-each select="GetMetadataObjects/Objects/Group/Members/PSPortalPage">

           <td  class="BannerTabMenuTabCell">
                <button class="tab-button BannerTabButtonCenter">
                      <xsl:attribute name="onclick">showTab(event, '<xsl:value-of select="@Id"/>')</xsl:attribute>
                      <xsl:if test="position() = 1">
				           <xsl:attribute name="id">default-tab</xsl:attribute>
      				  </xsl:if>
                <span><xsl:value-of select="@Name"/></span></button>
           </td>

   </xsl:for-each>
   
   </tr>
   
   </tbody>
   </table>
 
</xsl:template>
</xsl:stylesheet>
