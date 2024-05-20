<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:variable name="portletObject" select="$metadataContext/GetMetadata/Metadata/PSPortlet"/>

<xsl:variable name="portletId" select="$portletObject/@Id"/>
<xsl:variable name="portletType" select="$portletObject/@PortletType"/>

<!--  For the following properties, when a collection is first created, these properties are not
      created by default.  Thus, it's possible that when we get here, we actually have to create them.
      If we determine that to be the case, then create the id in the format that UpdateMetadata expects
      so that it will create a new object.
-->
<xsl:variable name="configPropertySet" select="$portletObject/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']"/>
<xsl:variable name="configPropertySetId" select="$configPropertySet/@Id"/>

<xsl:variable name="configProperties" select="$configPropertySet/SetProperties"/>

<!-- Name -->

<xsl:variable name="oldName" select="$portletObject/@Name"/>
<xsl:variable name="newName">
  <xsl:choose>
   <xsl:when test="/Mod_Request/NewMetadata/Name"><xsl:value-of select="/Mod_Request/NewMetadata/Name"/></xsl:when>
   <xsl:otherwise><xsl:value-of select="$oldName"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Description -->

<xsl:variable name="oldDesc" select="$portletObject/@Desc"/>
<xsl:variable name="newDesc">
  <xsl:choose>
   <xsl:when test="/Mod_Request/NewMetadata/Desc"><xsl:value-of select="/Mod_Request/NewMetadata/Desc"/></xsl:when>
   <xsl:otherwise><xsl:value-of select="$oldDesc"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Keywords -->

<xsl:variable name="oldKeywords">
  <xsl:for-each select="$portletObject/Keywords/Keyword">
    <xsl:value-of select="@Name"/><xsl:text> </xsl:text>
  </xsl:for-each>
</xsl:variable>
<xsl:variable name="newKeywords">
 <xsl:choose>
    <xsl:when test="/Mod_Request/NewMetadata/Keywords"><xsl:value-of select="/Mod_Request/NewMetadata/Keywords"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$oldKeywords"/></xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<!-- Parent Tree -->

<xsl:variable name="oldParentTreeId" select="$portletObject/Trees/Tree/@Id"/>
<xsl:variable name="newParentTreeId">
  <xsl:choose>
   <xsl:when test="/Mod_Request/NewMetadata/ParentTreeId"><xsl:value-of select="/Mod_Request/NewMetadata/ParentTreeId"/></xsl:when>
   <xsl:otherwise><xsl:value-of select="$oldParentTreeId"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="commonPropertiesChanged">
  <xsl:choose>
    <xsl:when test="not($newName=$oldName) or not($newDesc=$oldDesc) or not($newParentTreeId=$oldParentTreeId) or not($newKeywords=$oldKeywords)">1</xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:variable>

<xsl:include href="manage.keywords.xslt"/>

<!-- template to handle updating common portlet properties -->

<xsl:template name="updateCommonPortletProperties">

    <xsl:if test="$commonPropertiesChanged">

       <PSPortlet>
         <xsl:attribute name="Id"><xsl:value-of select="$portletId"/></xsl:attribute>

           <xsl:if test="not($newName=$oldName)">

             <xsl:attribute name="Name"><xsl:value-of select="$newName"/></xsl:attribute>

           </xsl:if>

           <xsl:if test="not($newDesc=$oldDesc)">

             <xsl:attribute name="Desc"><xsl:value-of select="$newDesc"/></xsl:attribute>

           </xsl:if>

           <xsl:if test="not($newParentTreeId=$oldParentTreeId)">

             <Trees Function="replace">
               <Tree>
                 <xsl:attribute name="ObjRef"><xsl:value-of select="$newParentTreeId"/></xsl:attribute>
               </Tree>
             </Trees>
           </xsl:if>

       </PSPortlet>
    </xsl:if>
</xsl:template>

<xsl:template name="updatePortletKeywords">

   <!-- We have to do this as a separate call because we may end up generating Delete Metadata calls to delete
        existing Keywords, and thus we can't process it inline 
    -->

           <!-- Update list of Keywords? -->

           <xsl:if test="not($newKeywords=$oldKeywords)">

                <xsl:call-template name="ManageKeywords">
                    <xsl:with-param name="oldKeywords" select="$oldKeywords"/>
                    <xsl:with-param name="newKeywords" select="$newKeywords"/>
                    <xsl:with-param name="owningObject" select="$portletObject"/>
                </xsl:call-template>

           </xsl:if>

</xsl:template>


</xsl:stylesheet>

