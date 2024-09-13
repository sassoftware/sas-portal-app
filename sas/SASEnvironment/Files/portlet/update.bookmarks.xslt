<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Common Setup -->

<!-- Set up the metadataContext variable -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.metadatacontext.xslt"/>
<!-- Set up the environment context variables -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.envcontext.xslt"/>

<!-- Global Variables -->

<!-- Common portlet update processing -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/update.psportlet-properties.xslt"/>

<xsl:template match="/">

<!-- Show Description Property -->

<xsl:variable name="newShowDescriptionId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newShowDescription</xsl:variable>
<xsl:variable name="oldShowDescriptionId">
 <xsl:choose>
   <xsl:when test="$configProperties/Property[@Name='show-description']/@Id">
      <xsl:value-of select="$configProperties/Property[@Name='show-description']/@Id"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$newShowDescriptionId"/>
   </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="oldShowDescription" select="$configProperties/Property[@Name='show-description']/@DefaultValue"/>

<xsl:variable name="newShowDescription">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/ShowDescription = 1">true</xsl:when>
     <xsl:when test="Mod_Request/NewMetadata/ShowDescription = 0">false</xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldShowDescription"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Show Location Property -->

<xsl:variable name="newShowLocationId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newShowLocation</xsl:variable>
<xsl:variable name="oldShowLocationId">
 <xsl:choose>
   <xsl:when test="$configProperties/Property[@Name='show-location']/@Id">
      <xsl:value-of select="$configProperties/Property[@Name='show-location']/@Id"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$newShowLocationId"/>
   </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="oldShowLocation" select="$configProperties/Property[@Name='show-location']/@DefaultValue"/>

<xsl:variable name="newShowLocation">

  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/ShowLocation = 1">true</xsl:when>
     <xsl:when test="Mod_Request/NewMetadata/ShowLocation = 0">false</xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldShowLocation"/></xsl:otherwise>
  </xsl:choose>

</xsl:variable>

<xsl:choose>

<xsl:when test="not($newShowDescription=$oldShowDescription) or not($newShowLocation=$oldShowLocation) or $commonPropertiesChanged">

    <Multiple_Requests>

    <UpdateMetadata>

      <Metadata>

        <xsl:call-template name="updateCommonPortletProperties"/>

        <xsl:if test="not($newShowDescription=$oldShowDescription)">

            <Property>
               <xsl:attribute name="Id"><xsl:value-of select="$oldShowDescriptionId"/></xsl:attribute>
               <xsl:attribute name="DefaultValue"><xsl:value-of select="$newShowDescription"/></xsl:attribute>

               <!-- If the old id is not the same as the new id, then we already had the object, so no further
                    metadata is required.  If they are the same, then we need to fill in the rest of the information
                    about this property -->

               <xsl:if test="$oldShowDescriptionId=$newShowDescriptionId">
                   <xsl:attribute name="Name">show-description</xsl:attribute>
                   <xsl:attribute name="SQLType">12</xsl:attribute>

                   <AssociatedPropertySet> 
                      <PropertySet>
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                      </PropertySet>
                   </AssociatedPropertySet>

               </xsl:if>

            </Property>
        </xsl:if>

        <xsl:if test="not($newShowLocation=$oldShowLocation)">

            <Property>
               <xsl:attribute name="Id"><xsl:value-of select="$oldShowLocationId"/></xsl:attribute>
               <xsl:attribute name="DefaultValue"><xsl:value-of select="$newShowLocation"/></xsl:attribute>

               <!-- If the old id is not the same as the new id, then we already had the object, so no further
                    metadata is required.  If they are the same, then we need to fill in the rest of the information
                    about this property -->

               <xsl:if test="$oldShowLocationId=$newShowLocationId">
                   <xsl:attribute name="Name">show-location</xsl:attribute>
                   <xsl:attribute name="SQLType">12</xsl:attribute>

                   <AssociatedPropertySet> 
                      <PropertySet>
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                      </PropertySet>
                   </AssociatedPropertySet>

               </xsl:if>
            </Property>
        </xsl:if>
        
      </Metadata>

      <NS>SAS</NS>
      <Flags>268435456</Flags>
      <Options/>

    </UpdateMetadata>

    <xsl:call-template name="updatePortletKeywords"/>

    </Multiple_Requests>

   </xsl:when>
   <xsl:otherwise>
     <Root/>
     <xsl:comment>NOTE: No update required.</xsl:comment>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>

</xsl:stylesheet>

