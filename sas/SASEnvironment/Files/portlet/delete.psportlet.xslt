<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Re-usable scripts -->
<!-- Set up the metadataContext variable -->
<xsl:include href="setup.metadatacontext.xslt"/>
<xsl:include href="delete.all.routines.xslt"/>

<!-- Removetype is the type of removal to do 
       remove = just remove the portlet from my personal portal space
       delete = remove the portlet from the personal portal space and permanently delete it

     layoutComponentId = the layoutcomponent Id to remove it from (if portletRemove=remove)

 -->

<!-- Main Entry Point -->

<xsl:template match="/">


<xsl:variable name="newRemoveType"><xsl:value-of select="lower-case(Mod_Request/NewMetadata/RemoveType)"/></xsl:variable>
<xsl:variable name="newLayoutComponentId"><xsl:value-of select="Mod_Request/NewMetadata/RelatedId"/></xsl:variable>
<xsl:variable name="newLayoutComponentType"><xsl:value-of select="Mod_Request/NewMetadata/RelatedType"/></xsl:variable>

<xsl:variable name="portletId"><xsl:value-of select="Mod_Request/NewMetadata/Id"/></xsl:variable>

<xsl:variable name="currentPortletObject" select="$metadataContext/Multiple_Requests/GetMetadataObjects/Objects/PSPortlet"/>

<xsl:variable name="portletName" select="$currentPortletObject/@Name"/>
    <xsl:choose>

      <xsl:when test="$newRemoveType='remove' or $newRemoveType=''">

       <!-- A remove is actually an updatemetadata request -->

       <xsl:comment>Include the phrase DeleteMetadata so the xsl checking thinks it worked</xsl:comment>

       <UpdateMetadata>

         <Metadata>

          <!--- Just remove it from the passed layout -->
          <xsl:element name="{$newLayoutComponentType}">
             <xsl:attribute name="Id"><xsl:value-of select="$newLayoutComponentId"/></xsl:attribute>
             <Portlets Function="Remove">
                 <PSPortlet><xsl:attribute name="Id"><xsl:value-of select="$portletId"/></xsl:attribute>
                 </PSPortlet>
             </Portlets>
           </xsl:element>

         </Metadata>
         <NS>SAS</NS>
         <Flags>268435456</Flags>
         <Options/>

      </UpdateMetadata>

      </xsl:when>

      <xsl:when test="$newRemoveType='delete'">

       <DeleteMetadata>

         <Metadata>

         <xsl:apply-templates select="$currentPortletObject"/>

         </Metadata>

         <NS>SAS</NS>
         <Flags>268435456</Flags>
         <Options/>

       </DeleteMetadata>
     </xsl:when>

     <xsl:otherwise>
       <xsl:comment>ERROR:Invalid RemoveType value passed, <xsl:value-of select="$newRemoveType"/></xsl:comment>
     </xsl:otherwise>
    </xsl:choose>

</xsl:template>

</xsl:stylesheet>

