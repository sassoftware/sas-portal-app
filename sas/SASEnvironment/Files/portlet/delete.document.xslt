<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Removetype is the type of removal to do 
       remove = just remove the document from the related object
       delete = remove the document from the personal portal space and permanently delete it

     relatedType = the Type of the related object to remove it from (if removeType=remove)
     relatedId = the id of the related object to remove it from (if removeType=remove)

 -->

<!-- Main Entry Point -->

<xsl:template match="/">


<xsl:variable name="newRemoveType"><xsl:value-of select="lower-case(Mod_Request/NewMetadata/RemoveType)"/></xsl:variable>
<xsl:variable name="newRelatedId"><xsl:value-of select="Mod_Request/NewMetadata/RelatedId"/></xsl:variable>
<xsl:variable name="newRelatedType"><xsl:value-of select="Mod_Request/NewMetadata/RelatedType"/></xsl:variable>

<xsl:variable name="objectId"><xsl:value-of select="Mod_Request/NewMetadata/Id"/></xsl:variable>
<xsl:variable name="objectType"><xsl:value-of select="Mod_Request/NewMetadata/Type"/></xsl:variable>

    <xsl:choose>

      <xsl:when test="$newRemoveType='remove' or $newRemoveType=''">

       <!-- A remove is actually an updatemetadata request -->

       <xsl:comment>Include the phrase DeleteMetadata so the xsl checking thinks it worked</xsl:comment>

       <UpdateMetadata>

         <Metadata>

          <xsl:element name="{$newRelatedType}">
             <xsl:attribute name="Id"><xsl:value-of select="$newRelatedId"/></xsl:attribute>
             <Members Function="Remove">
                 <xsl:element name="{$objectType}">
                  <xsl:attribute name="Id"><xsl:value-of select="$objectId"/></xsl:attribute>
                 </xsl:element>
             </Members>
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

           <xsl:element name="{$objectType}">
             <xsl:attribute name="Id"><xsl:value-of select="$objectId"/></xsl:attribute>
           </xsl:element>

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

