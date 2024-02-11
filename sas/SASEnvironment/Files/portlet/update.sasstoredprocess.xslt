<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- TODO:
       - remove displayurl processing (since this was copied from it)
       - on first edit, add PriorWindowState Extension to PortletRenderState PropertySet, ExtensionType=3, Value=3
-->

<xsl:template match="/">

<xsl:variable name="reposId" select="/Mod_Request/NewMetadata/Metareposid"/>

<xsl:variable name="portletId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/@Id"/>
<xsl:variable name="portletType" select="Mod_Request/GetMetadata/Metadata/PSPortlet/@PortletType"/>

<!--  For the following properties, when the portlet is first created, these properties are not
      created by default.  Thus, it's possible that when we get here, we actually have to create them.
      If we determine that to be the case, then create the id in the format that UpdateMetadata expects
      so that it will create a new object.
-->
<xsl:variable name="configPropertySet" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']"/>
<xsl:variable name="configPropertySetId" select="$configPropertySet/@Id"/>

<xsl:variable name="configProperties" select="$configPropertySet/SetProperties"/>

<!-- Portlet Height -->

<xsl:variable name="newPortletHeightId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletHeight</xsl:variable>

<xsl:variable name="oldPortletHeightId">
 <xsl:choose>
   <xsl:when test="$configProperties/Property[@Name='sas_DisplayURI_Height']/@Id">
      <xsl:value-of select="$configProperties/Property[@Name='sas_DisplayURI_Height']/@Id"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$newPortletHeightId"/>
   </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="oldPortletHeight" select="$configProperties/Property[@Name='sas_DisplayURI_Height']/@DefaultValue"/>
<xsl:variable name="newPortletHeight">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/PortletHeight"><xsl:value-of select="Mod_Request/NewMetadata/PortletHeight"/></xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldPortletHeight"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Portlet URI -->

<xsl:variable name="newPortletURIId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletURI</xsl:variable>

<xsl:variable name="oldPortletURIId">
 <xsl:choose>
   <xsl:when test="$configProperties/Property[@Name='sas_DisplayURI_DisplayURI']/@Id">
      <xsl:value-of select="$configProperties/Property[@Name='sas_DisplayURI_DisplayURI']/@Id"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$newPortletURIId"/>
   </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="oldPortletURI" select="$configProperties/Property[@Name='sas_DisplayURI_DisplayURI']/@DefaultValue"/>
<xsl:variable name="newPortletURI">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/PortletURI"><xsl:value-of select="Mod_Request/NewMetadata/PortletURI"/></xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldPortletURI"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="oldPortletURI" select="$configProperties/Property[@Name='sas_DisplayURI_DisplayURI']/@DefaultValue"/>

<xsl:choose>

  <xsl:when test="not($oldPortletHeight = $newPortletHeight) or not($oldPortletURI = $newPortletURI)">

    <UpdateMetadata>

      <Metadata>

        <xsl:if test="not($oldPortletHeight=$newPortletHeight)">

           <Property><xsl:attribute name="Id"><xsl:value-of select="$oldPortletHeightId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$newPortletHeight"/></xsl:attribute>

               <!-- If the old id is not the same as the new id, then we already had the object, so no further
                    metadata is required.  If they are the same, then we need to fill in the rest of the information
                    about this property -->

               <xsl:if test="$oldPortletHeightId=$newPortletHeightId">

                   <xsl:attribute name="Name">sas_DisplayURI_Height</xsl:attribute>
                   <xsl:attribute name="SQLType">12</xsl:attribute>

                   <AssociatedPropertySet>
                      <PropertySet>
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                      </PropertySet>
                   </AssociatedPropertySet>

               </xsl:if>
        </Property>
        </xsl:if>

        <xsl:if test="not($oldPortletURI=$newPortletURI)">
           <Property><xsl:attribute name="Id"><xsl:value-of select="$oldPortletURIId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$newPortletURI"/></xsl:attribute>

               <!-- If the old id is not the same as the new id, then we already had the object, so no further
                    metadata is required.  If they are the same, then we need to fill in the rest of the information
                    about this property -->

               <xsl:if test="$oldPortletURIId=$newPortletURIId">
                   <xsl:attribute name="Name">sas_DisplayURI_DisplayURI</xsl:attribute>
                   <xsl:attribute name="SQLType">12</xsl:attribute>

                   <AssociatedPropertySet>
                      <PropertySet>
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                      </PropertySet>
                   </AssociatedPropertySet>

               </xsl:if>
           </Property>
        </xsl:if>

      <!-- If this is the first time we are editing this object, there are a few other properties that the old IDP 
           defined that may not exist.  Check for them now, and add them if they don't exist 
      -->

      <xsl:if test="not($configProperties/Property[@Name='sas_DisplayURI_IsIframe'])">
        <xsl:variable name="newIFrameId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newIFrame</xsl:variable>
        <Property>
                <xsl:attribute name="Id"><xsl:value-of select="$newIFrameId"/></xsl:attribute>
                <xsl:attribute name="DefaultValue">true</xsl:attribute>

                <xsl:attribute name="Name">sas_DisplayURI_IsIframe</xsl:attribute>
                <xsl:attribute name="SQLType">12</xsl:attribute>

                <AssociatedPropertySet>
                   <PropertySet>
                      <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                   </PropertySet>
                </AssociatedPropertySet>

        </Property>
      </xsl:if>
      <xsl:if test="not($configProperties/Property[@Name='sas_DisplayURI_IsBipEnabled'])">
        <xsl:variable name="newBIPId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newBIP</xsl:variable>
        <Property>
                <xsl:attribute name="Id"><xsl:value-of select="$newBIPId"/></xsl:attribute>
                <xsl:attribute name="DefaultValue">false</xsl:attribute>

                <xsl:attribute name="Name">sas_DisplayURI_IsBipEnabled</xsl:attribute>
                <xsl:attribute name="SQLType">12</xsl:attribute>

                <AssociatedPropertySet>
                   <PropertySet>
                      <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                   </PropertySet>
                </AssociatedPropertySet>

        </Property>

      </xsl:if>

      </Metadata>

      <NS>SAS</NS>
      <Flags>268435456</Flags>
      <Options/>

    </UpdateMetadata>

  </xsl:when>

  <xsl:otherwise>
     <Root/>
     <xsl:comment>NOTE: No update required.</xsl:comment>
  </xsl:otherwise>

 </xsl:choose>

</xsl:template>

</xsl:stylesheet>

