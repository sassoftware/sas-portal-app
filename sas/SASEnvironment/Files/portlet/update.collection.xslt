<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:template match="/">

<xsl:variable name="portletId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/@Id"/>
<xsl:variable name="portletType" select="Mod_Request/GetMetadata/Metadata/PSPortlet/@PortletType"/>

<xsl:variable name="oldShowDescriptionId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='show-description']/@Id"/>
<xsl:variable name="oldShowDescription" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='show-description']/@DefaultValue"/>

<xsl:variable name="newShowDescription">

  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/ShowDescription = 1">true</xsl:when>
     <xsl:when test="Mod_Request/NewMetadata/ShowDescription = 0">false</xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldShowDescription"/></xsl:otherwise>
  </xsl:choose>

</xsl:variable>

<xsl:variable name="oldShowLocationId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='show-location']/@Id"/>
<xsl:variable name="oldShowLocation" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='show-location']/@DefaultValue"/>

<xsl:variable name="newShowLocation">

  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/ShowLocation = 1">true</xsl:when>
     <xsl:when test="Mod_Request/NewMetadata/ShowLocation = 0">false</xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldShowLocation"/></xsl:otherwise>
  </xsl:choose>

</xsl:variable>

<xsl:variable name="oldPackageSortOrderId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='ascending-packageSortOrder']/@Id"/>
<xsl:variable name="oldPackageSortOrder" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']/SetProperties/Property[@Name='ascending-packageSortOrder']/@DefaultValue"/>

<xsl:variable name="newPackageSortOrder">

  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/PackageSortOrder = 'UsePreferences'">UsePreferences</xsl:when>
     <xsl:when test="Mod_Request/NewMetadata/PackageSortOrder = 'Ascending'">Ascending</xsl:when>
     <xsl:when test="Mod_Request/NewMetadata/PackageSortOrder = 'Descending'">Descending</xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldPackageSortOrder"/></xsl:otherwise>
  </xsl:choose>

</xsl:variable>

<xsl:variable name="listChanged"><xsl:value-of select="Mod_Request/NewMetadata/ListChanged"/></xsl:variable>

<!-- See if we have anything to update -->

<xsl:choose>

<xsl:when test="$newShowDescription != $oldShowDescription or $newShowLocation != $oldShowLocation or $newPackageSortOrder != $oldPackageSortOrder or $listChanged = 'true'">

    <UpdateMetadata>

      <Metadata>

        <xsl:if test="$newShowDescription != $oldShowDescription">

            <Property>
               <xsl:attribute name="Id"><xsl:value-of select="$oldShowDescriptionId"/></xsl:attribute>
               <xsl:attribute name="DefaultValue"><xsl:value-of select="$newShowDescription"/></xsl:attribute>
            </Property>
        </xsl:if>

        <xsl:if test="$newShowLocation != $oldShowLocation">

            <Property>
               <xsl:attribute name="Id"><xsl:value-of select="$oldShowLocationId"/></xsl:attribute>
               <xsl:attribute name="DefaultValue"><xsl:value-of select="$newShowLocation"/></xsl:attribute>
            </Property>
        </xsl:if>
        
        <xsl:if test="$newPackageSortOrder != $oldPackageSortOrder">
            <Property>
               <xsl:attribute name="Id"><xsl:value-of select="$oldPackageSortOrderId"/></xsl:attribute>
               <xsl:attribute name="DefaultValue"><xsl:value-of select="$newPackageSortOrder"/></xsl:attribute>
            </Property>
        </xsl:if>

        <xsl:if test="$listChanged = 'true'">
            <!--  The group list has as it's first item a link back to the portlet itself, followed
                  by the list of items.  In this case, we know the list has changed, but we don't
                  know the extent.  Thus, we will just replace the current list with a new list.
             -->
             <xsl:variable name="collectionGroupId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/Groups/Group/@Id"/>
             <Group><xsl:attribute name="Id"><xsl:value-of select="$collectionGroupId"/></xsl:attribute>
                <Members function="replace">
                    <PSPortlet><xsl:attribute name="ObjRef"><xsl:value-of select="$portletId"/></xsl:attribute></PSPortlet>
                    <xsl:for-each select="Mod_Request/NewMetadata/Items/*">
                      <!-- The format of each item in the list is defined as 
                           <linkType>/<repository>/<objectType>/<objectId>
                           all we need here is the <objectType> and </objectId>
                      -->
                      <xsl:variable name="listItemId"><xsl:value-of select="tokenize(., '/')[last()]"/></xsl:variable>
                      <xsl:variable name="listItemType"><xsl:value-of select="tokenize(.,'/')[3]"/></xsl:variable> 
                      <xsl:element name="{$listItemType}"><xsl:attribute name="ObjRef"><xsl:value-of select="$listItemId"/></xsl:attribute></xsl:element>
                    </xsl:for-each>

                </Members>

             </Group>

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

