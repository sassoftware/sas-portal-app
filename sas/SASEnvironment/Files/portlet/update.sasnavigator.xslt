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

<!--  It's possible that we don't yet have the SMART_OBJECT_TYPE propertyset, if not note it and we will create it as part of this process -->

<xsl:variable name="smartObjectPropertySetId">
<xsl:choose>
<xsl:when test="exists($smartObjectPropertySet)"><xsl:value-of select="$smartObjectPropertySet/@Id"/></xsl:when>
<xsl:otherwise><xsl:value-of select="substring-after($reposId,'.')"/>.$smartObjectNewId</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:variable name="reposId" select="Mod_Request/NewMetadata/Metareposid"/>

<!-- The default object filter is all objects, so set the checkbox on so that it will be created.  
     NOTE: Do not set the ID field, so the code below knows to create the object first

     NOTE: The original SASPortal had more object filter types than the new SASPortalApp does.  Thus, there may be
           preference objects that exist for the old types.  We want to ignore those or it will cause no objects to show up
           if none of the new types are selected (which is the opposite of what we want to have happen).
 -->

<xsl:variable name="imSelectedParm" select="Mod_Request/NewMetadata/IM_SELECTED"/>
<xsl:variable name="imSelected">
<xsl:choose>
<xsl:when test="string($imSelectedParm) != ''"><xsl:value-of select="$imSelectedParm"/></xsl:when>
<!-- xsl:when test="exists($smartObjectPropertySet)"><xsl:value-of select="Mod_Request/NewMetadata/IM_SELECTED"/></xsl:when -->
<xsl:otherwise>on</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:variable name="imID" select="Mod_Request/NewMetadata/IM_ID"/>

<xsl:variable name="stpSelectedParm" select="Mod_Request/NewMetadata/STP_SELECTED"/>

<xsl:variable name="stpSelected">
<xsl:choose>
<xsl:when test="string($stpSelectedParm) != ''"><xsl:value-of select="$stpSelectedParm"/></xsl:when>
<!-- xsl:when test="exists($smartObjectPropertySet)"><xsl:value-of select="Mod_Request/NewMetadata/STP_SELECTED"/></xsl:when -->
<xsl:otherwise>on</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="stpID" select="Mod_Request/NewMetadata/STP_ID"/>

<xsl:variable name="reportSelectedParm" select="Mod_Request/NewMetadata/REPORT_SELECTED"/>
<xsl:variable name="reportSelected">
<xsl:choose>
<xsl:when test="string($reportSelectedParm) != ''"><xsl:value-of select="$reportSelectedParm"/></xsl:when>
<!-- xsl:when test="exists($smartObjectPropertySet)"><xsl:value-of select="Mod_Request/NewMetadata/REPORT_SELECTED"/></xsl:when -->
<xsl:otherwise>on</xsl:otherwise>
</xsl:choose>
</xsl:variable>

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

    <xsl:if test="contains($smartObjectPropertySetId,'$smartObjectNewId')">


         <!-- If we don't have the smart object property set, add it now -->
         <AddMetadata>
            <Metadata>
                     <PropertySet Name="SMART_OBJECT_TYPE">
                        <xsl:attribute name="Id"><xsl:value-of select="$smartObjectPropertySetId"/></xsl:attribute>
                        <OwningObject>

                           <PropertySet><xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                           </PropertySet>
                        </OwningObject>
                     </PropertySet>
            </Metadata>
            <Reposid><xsl:value-of select="$reposId"/></Reposid>
            <NS>SAS</NS>
            <Flags>268435456</Flags>
            <Options/>
         </AddMetadata>

         </xsl:if>

    <!--  Add new Information Map Property -->

    <xsl:if test="$imSelected != 'off' and string($imID) = ''">
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
      <!-- xsl:if test="$imSelected='off' and string($imID) != '' and ($reportSelected='on' or $stpSelected='on')" -->
      <xsl:if test="$imSelected='off' and string($imID) != ''">
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
      <xsl:if test="$stpSelected !='off' and string($stpID) = ''">
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
      <!-- xsl:if test="$stpSelected='off' and string($stpID) != '' and ($reportSelected='on' or $imSelected='on')" -->
      <xsl:if test="$stpSelected='off' and string($stpID) != ''">
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
      <xsl:if test="$reportSelected != 'off' and string($reportID) = ''">
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

         <!--  Delete Report Property -->
      <!-- xsl:if test="$reportSelected='off' and string($reportID) != '' and ($stpSelected='on' or $imSelected='on')" -->
      <xsl:if test="$reportSelected='off' and string($reportID) != ''">
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

