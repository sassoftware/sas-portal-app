<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Common Setup -->

<!-- Set up the metadataContext variable -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.metadatacontext.xslt"/>
<!-- Set up the environment context variables -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.envcontext.xslt"/>

<!-- Common portlet update processing -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/update.psportlet-properties.xslt"/>

<xsl:template match="/">

<xsl:variable name="configPropertySets" select="$configPropertySet/PropertySets"/>

<!-- Folder Path -->

<xsl:variable name="folderURIPrefix">SBIP://METASERVER</xsl:variable>
<xsl:variable name="folderURISuffix">(Folder)</xsl:variable>

<!--  The Path we store has the prefix SBIP://METASERVER and suffix (Folder) on it.  No need to force the user to enter that, just have them enter the full path -->

<xsl:variable name="oldFolderURIPropertySet" select="$configPropertySets/PropertySet[@Name='selectedFolder']"/>
<xsl:variable name="oldFolderURIProperty" select="$oldFolderURIPropertySet/SetProperties/Property[@Name='PreferenceInstanceProperty']"/>

<xsl:variable name="smartObjectPropertySet" select="$configPropertySets/PropertySet[@Name='SMART_OBJECT_TYPE']"/>
<xsl:variable name="smartObjectPropertySetId" select="$smartObjectPropertySet/@Id"/>
<!--xsl:variable name="smartObjectPropertySetId">A56YJHUZ.AB0001I5</xsl:variable-->

<xsl:variable name="reposId" select="Mod_Request/NewMetadata/Metareposid"/>
<xsl:variable name="imSelected" select="Mod_Request/NewMetadata/IM_SELECTED"/>
<xsl:variable name="imID" select="Mod_Request/NewMetadata/IM_ID"/>
<xsl:variable name="stpSelected" select="Mod_Request/NewMetadata/STP_SELECTED"/>
<xsl:variable name="stpID" select="Mod_Request/NewMetadata/STP_ID"/>
<xsl:variable name="reportSelected" select="Mod_Request/NewMetadata/REPORT_SELECTED"/>
<xsl:variable name="reportID" select="Mod_Request/NewMetadata/REPORT_ID"/>

<xsl:variable name="oldFolderURI" select="$oldFolderURIProperty/@DefaultValue"/>
<xsl:variable name="oldFolderPath" select="substring-before(substring-after($oldFolderURI,$folderURIPrefix),$folderURISuffix)"/>

<xsl:variable name="newFolderPath" select="Mod_Request/NewMetadata/Path"/>

<xsl:variable name="newFolderURI">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/Path"><xsl:value-of select="$folderURIPrefix"/><xsl:value-of select="$newFolderPath"/><xsl:value-of select="$folderURISuffix"/></xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldFolderURI"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Create values that we can use when updating metadata to use as an Id value if needed -->

<xsl:variable name="newFolderURIId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newFolderURI</xsl:variable>

<xsl:variable name="oldFolderURIId">
 <xsl:choose>
   <xsl:when test="$oldFolderURIProperty/@Id">
      <xsl:value-of select="$oldFolderURIProperty/@Id"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$newFolderURIId"/>
   </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--  See if there is anything changed and if so, do it -->

<xsl:choose>

  <xsl:when test="not($oldFolderURI = $newFolderURI) or $commonPropertiesChanged">
    <Multiple_Requests>

    <!--  Add new Information Map Property -->
    <xsl:if test="$imSelected='on' and string($imID) = ''">
         <AddMetadata>
            <Metadata>
               <Property Name="PreferenceInstanceProperty" SQLType="12" DefaultValue="InformationMap">
                  <AssociatedPropertySet>
                     <PropertySet Name="SMART_OBJECT_TYPE">
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$smartObjectPropertySetId"/></xsl:attribute>
                     </PropertySet>
                  </AssociatedPropertySet>
               </Property>
            </Metadata>
            <Reposid><xsl:value-of select="$reposId"/></Reposid>
            <NS>SAS</NS>
            <Flags>268435456</Flags>
            <Options/>
         </AddMetadata>
    </xsl:if>

      <!--  Delete Information Map Property -->
      <xsl:if test="$imSelected='off' and string($imID) != '' and ($reportSelected='on' or $stpSelected='on')">
         <DeleteMetadata>
            <Metadata>
               <Property Name="PreferenceInstanceProperty">
                  <xsl:attribute name="Id"><xsl:value-of select="$imID"/></xsl:attribute>
               </Property>
            </Metadata>
            <Reposid><xsl:value-of select="$reposId"/></Reposid>
            <NS>SAS</NS>
            <Flags>268435456</Flags>
            <Options/>
         </DeleteMetadata>
      </xsl:if>

      <!--  Add new Stored Process Property -->
      <xsl:if test="$stpSelected='on' and string($stpID) = ''">
            <AddMetadata>
               <Metadata>
                  <Property Name="PreferenceInstanceProperty" SQLType="12" DefaultValue="StoredProcess">
                     <AssociatedPropertySet>
                        <PropertySet Name="SMART_OBJECT_TYPE">
                           <xsl:attribute name="ObjRef"><xsl:value-of select="$smartObjectPropertySetId"/></xsl:attribute>
                        </PropertySet>
                     </AssociatedPropertySet>
                  </Property>
               </Metadata>
               <Reposid><xsl:value-of select="$reposId"/></Reposid>
               <NS>SAS</NS>
               <Flags>268435456</Flags>
               <Options/>
            </AddMetadata>
      </xsl:if>

      <!--  Delete Stored Process Property -->
      <xsl:if test="$stpSelected='off' and string($stpID) != '' and ($reportSelected='on' or $imSelected='on')">
         <DeleteMetadata>
            <Metadata>
               <Property Name="PreferenceInstanceProperty">
                  <xsl:attribute name="Id"><xsl:value-of select="$stpID"/></xsl:attribute>
               </Property>
            </Metadata>
            <Reposid><xsl:value-of select="$reposId"/></Reposid>
            <NS>SAS</NS>
            <Flags>268435456</Flags>
            <Options/>
         </DeleteMetadata>
      </xsl:if>

      <!--  Add new Report Property -->
      <xsl:if test="$reportSelected='on' and string($reportID) = ''">
            <AddMetadata>
               <Metadata>
                  <Property Name="PreferenceInstanceProperty" SQLType="12" DefaultValue="Report">
                     <AssociatedPropertySet>
                        <PropertySet Name="SMART_OBJECT_TYPE">
                           <xsl:attribute name="ObjRef"><xsl:value-of select="$smartObjectPropertySetId"/></xsl:attribute>
                        </PropertySet>
                     </AssociatedPropertySet>
                  </Property>
               </Metadata>
               <Reposid><xsl:value-of select="$reposId"/></Reposid>
               <NS>SAS</NS>
               <Flags>268435456</Flags>
               <Options/>
            </AddMetadata>
      </xsl:if>

         <!--  Delete Stored Process Property -->
      <xsl:if test="$reportSelected='off' and string($reportID) != '' and ($stpSelected='on' or $imSelected='on')">
         <DeleteMetadata>
            <Metadata>
               <Property Name="PreferenceInstanceProperty">
                  <xsl:attribute name="Id"><xsl:value-of select="$reportID"/></xsl:attribute>
               </Property>
            </Metadata>
            <Reposid><xsl:value-of select="$reposId"/></Reposid>
            <NS>SAS</NS>
            <Flags>268435456</Flags>
            <Options/>
         </DeleteMetadata>
      </xsl:if>

    <UpdateMetadata>

      <Metadata>

        <xsl:call-template name="updateCommonPortletProperties"/>

        <!--  Folder Path  -->

        <xsl:if test="not($oldFolderURI=$newFolderURI)">

             <!-- Get the information we will need to create the property set hierarchy if it doesn't exist yet -->

             <!--  We have to start at the propertyset level and see what needs to be created -->
             <xsl:variable name="newFolderURIPropertySetId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newFolderPropertySet</xsl:variable>
             <xsl:variable name="folderURIPropertySetId">
                <xsl:choose>
                   <xsl:when test="$oldFolderURIPropertySet/@Id">
                      <xsl:value-of select="$oldFolderURIPropertySet/@Id"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="$newFolderURIPropertySetId"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:variable>

            <xsl:if test="$folderURIPropertySetId=$newFolderURIPropertySetId">
                   <!-- The property set doesn't exist, so create it now -->

                   <PropertySet Name="selectedFolder">
                      <xsl:attribute name="Id"><xsl:value-of select="$folderURIPropertySetId"/></xsl:attribute>
                      <xsl:variable name="folderURIPropertySetExtensionId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newFolderURIPropertySetExtension</xsl:variable>
                      <Extensions>
                        <Extension Name="ReadOnly" ExtensionType="String" Value="false">
                           <xsl:attribute name="Id"><xsl:value-of select="$folderURIPropertySetExtensionId"/></xsl:attribute>
                        </Extension>
                      </Extensions>

                      <OwningObject>
                         <PropertySet>
                           <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                         </PropertySet>
                      </OwningObject>
                   </PropertySet>

            </xsl:if>

           <Property><xsl:attribute name="Id"><xsl:value-of select="$oldFolderURIId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$newFolderURI"/></xsl:attribute>

               <!-- If the old id is not the same as the new id, then we already had the object, so no further
                    metadata is required.  If they are the same, then we need to fill in the rest of the information
                    about this property -->
               <xsl:if test="$oldFolderURIId=$newFolderURIId">

                   <xsl:attribute name="Name">PreferenceInstanceProperty</xsl:attribute>
                   <xsl:attribute name="SQLType">12</xsl:attribute>

                   <AssociatedPropertySet>
                      <PropertySet>
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$folderURIPropertySetId"/></xsl:attribute>
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

