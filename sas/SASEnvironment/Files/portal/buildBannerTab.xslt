<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" encoding="UTF-8"/>
<!-- The following variables must be set by the including file -->

<!-- localeXml = the file containing the appropriate localizations -->
<!-- sastheme  = the name of the sas theme to use -->
<!-- sasthemeContextRoot = the the web server context root of the SAS theme application -->

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  This section of the templates is for generating a tab

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->
<xsl:template name="buildTab">
  <xsl:param name="tabId"/>
  <xsl:param name="tabName"/>
  <xsl:param name="tabPosition"/>

   <!--  This is a complicated way of doing tabs, but it is done this way so that existing SAS Themes will still properly render -->

   <!--  The left part of the tab -->

   <td valign="top" align="left">
       <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_l</xsl:attribute>
       <xsl:choose>

         <xsl:when test="$tabPosition = 1">
             <xsl:attribute name="class">BannerTabButtonLeftActive</xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
             <xsl:attribute name="class">BannerTabButtonLeft</xsl:attribute>
         </xsl:otherwise>
       </xsl:choose>

         <img border="0">
              <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_l_img</xsl:attribute>

               <xsl:choose>

                 <xsl:when test="tabPosition = 1">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonLeftActive.gif</xsl:attribute>
                 </xsl:when>
                 <xsl:otherwise>
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonLeft.gif</xsl:attribute>
                 </xsl:otherwise>

               </xsl:choose>

         </img>
   </td>

   <!-- The center part of the tab -->

   <td nowrap="nowrap" align="center">

       <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_c</xsl:attribute>

       <xsl:choose>
       <xsl:when test="tabPosition = 1">
             <xsl:attribute name="class">BannerTabButtonCenterActive</xsl:attribute>
             <xsl:attribute name="style">background-image: url(&quot;/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonCenterActive.gif&quot;);</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
             <xsl:attribute name="class">BannerTabButtonCenter</xsl:attribute>
             <xsl:attribute name="style">background-image: url(&quot;/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonCenter.gif&quot;);</xsl:attribute>
       </xsl:otherwise>
       </xsl:choose>

      <button  type="button" style="background-color: transparent;border-style: none;">
            <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_button</xsl:attribute>
             <xsl:attribute name="title"><xsl:value-of select="$tabName"/></xsl:attribute>

             <span>
                 <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_label</xsl:attribute>
                 <xsl:value-of select="$tabName"/>
             </span>
     </button>
   </td>

   <!-- the right part of the tab -->

   <td valign="top" align="right">
       <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_r</xsl:attribute>
       <xsl:choose>

         <xsl:when test="tabPosition = 1">
             <xsl:attribute name="class">BannerTabButtonRightActive</xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
             <xsl:attribute name="class">BannerTabButtonRight</xsl:attribute>
         </xsl:otherwise>
       </xsl:choose>
      <img alt="" border="0">
              <xsl:attribute name="id"><xsl:value-of select="$tabId"/>_r_img</xsl:attribute>
               <xsl:choose>
                 <xsl:when test="tabPosition = 1">
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonRightActive.gif</xsl:attribute>
                 </xsl:when>
                 <xsl:otherwise>
                     <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/BannerTabButtonRight.gif</xsl:attribute>
                 </xsl:otherwise>
               </xsl:choose>

         </img>

   </td>

</xsl:template>

</xsl:stylesheet>

