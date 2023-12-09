<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:param name="treeName"/>

<!-- - - - - - - - - - - - - - - -

  Main Entry Point

- - - - - - -->

<xsl:template match="/">

    <!-- input xml is the output of the getPermissionsTreeReferences.xslt generated xml request -->
   
    <!-- Make sure to validate that required fields are present, if not ERROR -->

    <xsl:variable name="parentTreeId" select="Multiple_Requests/GetMetadataObjects/Objects/Tree/@Id"/>
    <xsl:if test="not($parentTreeId)">
       <message>ERROR: Parent tree information not found,parentTreeId=<xsl:value-of select="$parentTreeId"/></message>
    </xsl:if>
    <xsl:variable name="parentTreeName" select="Multiple_Requests/GetMetadataObjects/Objects/Tree/@Name"/>
    <xsl:if test="not($parentTreeName)">
       <message>ERROR: Parent tree information not found,parentTreeId=<xsl:value-of select="$parentTreeId"/></message>
    </xsl:if>

    <xsl:variable name="identityGroupName" select="Multiple_Requests/GetMetadataObjects/Objects/IdentityGroup/@Name"/>
    <xsl:variable name="identityGroupId" select="Multiple_Requests/GetMetadataObjects/Objects/IdentityGroup/@Id"/>
    <xsl:variable name="identityGroupAdminId" select="Multiple_Requests/GetMetadataObjects/Objects/IdentityGroup/AccessControls/Identities/Identity/@Id"/>
    <xsl:variable name="identityGroupAdminName" select="Multiple_Requests/GetMetadataObjects/Objects/IdentityGroup/AccessControls/Identities/Identity/@Name"/>
    <xsl:variable name="personName" select="Multiple_Requests/GetMetadataObjects/Objects/Person/@Name"/>

    <xsl:variable name="personId" select="Multiple_Requests/GetMetadataObjects/Objects/Person/@Id"/>
    <xsl:variable name="portalACTId" select="Multiple_Requests/GetMetadataObjects/Objects/AccessControlTemplate[@Name='Portal ACT']/@Id"/>
    <xsl:if test="not($portalACTId)">
       <message>ERROR: Portal ACT not found.</message>
    </xsl:if>

     <xsl:variable name="newACEName">
       <xsl:choose>
       <xsl:when test="$identityGroupName != ''">
    <xsl:text>GRANT </xsl:text><xsl:value-of select="$identityGroupName"/><xsl:text> access</xsl:text>
       </xsl:when>
       <xsl:when test="$personName != ''">
    <xsl:text>GRANT </xsl:text><xsl:value-of select="$personName"/><xsl:text> access</xsl:text>
       </xsl:when>
       <xsl:otherwise>
            <message>ERROR:Identity Name not found for creating addMetadata request for Permissions tree</message>
       </xsl:otherwise>

       </xsl:choose>
    </xsl:variable>

    <AddMetadata>

    <!--   When referencing an existing object, you use the ObjRef= option on the object reference.  No other attributes are required or processed.
           We are including the Name attribute of these referenced objects in the request also so that the metadata request is easier to validate
           and debug, it does not change the processing of a referenced object.
      -->

    <Metadata>
    <Tree IsHidden="0" PublicType="" TreeType=" Permissions Tree" UsageVersion="0"> <xsl:attribute name="Name"><xsl:value-of select="$treeName"/></xsl:attribute>
          <ParentTree>
             <Tree>
                <xsl:attribute name="ObjRef"><xsl:value-of select="$parentTreeId"/></xsl:attribute>
                <xsl:attribute name="Name"><xsl:value-of select="$parentTreeName"/></xsl:attribute>
             </Tree>
          </ParentTree>
          <AccessControls>

                   <xsl:call-template name="createACEs">
                      <xsl:with-param name="identityGroupId"><xsl:value-of select="$identityGroupId"/></xsl:with-param>
                      <xsl:with-param name="identityGroupName"><xsl:value-of select="$identityGroupName"/></xsl:with-param>
                      <xsl:with-param name="personId"><xsl:value-of select="$personId"/></xsl:with-param>
                      <xsl:with-param name="personName"><xsl:value-of select="$personName"/></xsl:with-param>
                   </xsl:call-template>

          </AccessControls>
          <UsingPrototype>
                   <xsl:choose>

                   <xsl:when test="$identityGroupId != ''">
                       <IdentityGroup>
                            <xsl:attribute name="ObjRef"><xsl:value-of select="$identityGroupId"/></xsl:attribute>
                            <xsl:attribute name="Name"><xsl:value-of select="$identityGroupName"/></xsl:attribute>
                       </IdentityGroup>
                   </xsl:when>
                   <xsl:when test="$personId != ''">
                       <Person>
                            <xsl:attribute name="ObjRef"><xsl:value-of select="$personId"/></xsl:attribute>
                            <xsl:attribute name="Name"><xsl:value-of select="$personName"/></xsl:attribute>
                       </Person>
                   </xsl:when>
                   <xsl:otherwise>
                        <message>ERROR:Identity not found for creating addMetadata request for Permissions tree</message>
                   </xsl:otherwise>

                   </xsl:choose>

          </UsingPrototype>

          <!-- Now add group or user specific content -->

          <xsl:choose>

          <xsl:when test="$identityGroupId != ''">
              <xsl:call-template name="createGroupContent">
                   <xsl:with-param name="identityGroupName"><xsl:value-of select="$identityGroupName"/></xsl:with-param>
              </xsl:call-template>

          </xsl:when>
          <xsl:when test="$personId != ''">

              <xsl:comment>User Content will be added by the user initialization step</xsl:comment>

          </xsl:when>
          <xsl:otherwise>
               <message>ERROR:Identity not found for creating addMetadata request for Permissions tree</message>
          </xsl:otherwise>

          </xsl:choose>

    </Tree>

    <xsl:comment>SUCCESS: NOTE: Generating AddMetadata request for Permissions Tree completed successfully.</xsl:comment>

    </Metadata>
    <ReposId>$METAREPOSITORY</ReposId>
    <NS>SAS</NS>
    <Flags>268435456</Flags>
    <Options/>

    </AddMetadata>

</xsl:template>

<!-- - - - - - - - - - - - - - - -

  Create Access Control Entries for this Tree 

- - - - - - -->

<xsl:template name="createACEs">

   <xsl:param name="identityGroupId"/>
   <xsl:param name="identityGroupName"/>
   <xsl:param name="personId"/>
   <xsl:param name="personName"/>
 
   <xsl:variable name="readPermissionId" select="Multiple_Requests/GetMetadataObjects/Objects/Permission[@Name='ReadMetadata']/@Id"/>
   <xsl:variable name="readPermissionName" select="Multiple_Requests/GetMetadataObjects/Objects/Permission[@Name='ReadMetadata']/@Name"/>
   <xsl:variable name="writePermissionId" select="Multiple_Requests/GetMetadataObjects/Objects/Permission[@Name='WriteMetadata']/@Id"/>
   <xsl:variable name="writePermissionName" select="Multiple_Requests/GetMetadataObjects/Objects/Permission[@Name='WriteMetadata']/@Name"/>
   <xsl:variable name="identityGroupAdminId" select="Multiple_Requests/GetMetadataObjects/Objects/IdentityGroup/AccessControls/AccessControlEntry/Identities/Person/@Id"/>
   <xsl:variable name="identityGroupAdminName" select="Multiple_Requests/GetMetadataObjects/Objects/IdentityGroup/AccessControls/AccessControlEntry/Identities/Person/@Name"/>
   <xsl:variable name="portalACTId" select="Multiple_Requests/GetMetadataObjects/Objects/AccessControlTemplate/@Id"/>
   <xsl:variable name="portalACTName" select="Multiple_Requests/GetMetadataObjects/Objects/AccessControlTemplate/@Name"/>

    <xsl:variable name="newACEName">
      <xsl:choose>
      <xsl:when test="$identityGroupName != ''">
   <xsl:text>GRANT </xsl:text><xsl:value-of select="$identityGroupName"/><xsl:text> access</xsl:text>
      </xsl:when>
      <xsl:when test="$personName != ''">
   <xsl:text>GRANT </xsl:text><xsl:value-of select="$personName"/><xsl:text> access</xsl:text>
      </xsl:when>
      <xsl:otherwise>
           <xsl:message>ERROR:Identity Name not found for creating addMetadata request for Permissions tree</xsl:message>
      </xsl:otherwise>

      </xsl:choose>
   </xsl:variable>

          <!-- Including Name attribute on ObjRef references so the generated metadata request is easier to read -->

          <AccessControlTemplate>
                <xsl:attribute name="ObjRef"><xsl:value-of select="$portalACTId"/></xsl:attribute>
                <xsl:attribute name="Name"><xsl:value-of select="$portalACTName"/></xsl:attribute>
          </AccessControlTemplate>

          <!-- Generate the correct Access Control Entries based on whether this is a group or user permissions tree -->

          <xsl:choose>

          <xsl:when test="$identityGroupId != ''">

                  <AccessControlEntry Id="" Desc="" IsHidden="0" PublicType="" UsageVersion="0"> <xsl:attribute name="Name"><xsl:value-of select="$newACEName"/></xsl:attribute>
                        <Identities>

                               <IdentityGroup>
                                  <xsl:attribute name="ObjRef"><xsl:value-of select="$identityGroupId"/></xsl:attribute>
                                  <xsl:attribute name="Name"><xsl:value-of select="$identityGroupName"/></xsl:attribute>
                               </IdentityGroup>
                        </Identities>
                        <Permissions>
                           <Permission>
                                  <xsl:attribute name="ObjRef"><xsl:value-of select="$readPermissionId"/></xsl:attribute>
                                  <xsl:attribute name="Name"><xsl:value-of select="$readPermissionName"/></xsl:attribute>
                           </Permission>
                        </Permissions>
                  </AccessControlEntry>

                  <!-- Create the Group Admin ACE -->

                  <xsl:variable name="newAdminACEName">GRANT <xsl:value-of select="$identityGroupAdminName"/> Write</xsl:variable>

                  <AccessControlEntry Id="" Desc="" IsHidden="0" PublicType="" UsageVersion="0"> <xsl:attribute name="Name"><xsl:value-of select="$newAdminACEName"/></xsl:attribute>
                        <Identities>

                               <Person>
                                     <xsl:attribute name="ObjRef"><xsl:value-of select="$identityGroupAdminId"/></xsl:attribute>
                                     <xsl:attribute name="Name"><xsl:value-of select="$identityGroupAdminName"/></xsl:attribute>
                               </Person>
                        </Identities>
                        <Permissions>
                           <Permission>
                               <xsl:attribute name="ObjRef"><xsl:value-of select="$readPermissionId"/></xsl:attribute>
                               <xsl:attribute name="Name"><xsl:value-of select="$readPermissionName"/></xsl:attribute>
                            </Permission>
                           <Permission>
                               <xsl:attribute name="ObjRef"><xsl:value-of select="$writePermissionId"/></xsl:attribute>
                               <xsl:attribute name="Name"><xsl:value-of select="$writePermissionName"/></xsl:attribute>
                           </Permission>
                        </Permissions>
                  </AccessControlEntry>

           </xsl:when>
           <xsl:when test="$personId != ''">

                  <AccessControlEntry Id="" Desc="" IsHidden="0" PublicType="" UsageVersion="0"> <xsl:attribute name="Name"><xsl:value-of select="$newACEName"/></xsl:attribute>
                        <Identities>

                               <Person>
                                     <xsl:attribute name="ObjRef"><xsl:value-of select="$personId"/></xsl:attribute>
                                     <xsl:attribute name="Name"><xsl:value-of select="$personName"/></xsl:attribute>
                               </Person>
                        </Identities>
                        <Permissions>
                           <Permission>
                               <xsl:attribute name="ObjRef"><xsl:value-of select="$readPermissionId"/></xsl:attribute>
                               <xsl:attribute name="Name"><xsl:value-of select="$readPermissionName"/></xsl:attribute>
                            </Permission>
                           <Permission>
                               <xsl:attribute name="ObjRef"><xsl:value-of select="$writePermissionId"/></xsl:attribute>
                               <xsl:attribute name="Name"><xsl:value-of select="$writePermissionName"/></xsl:attribute>
                           </Permission>
                        </Permissions>
                  </AccessControlEntry>
           </xsl:when>

           <xsl:otherwise>
                  <message>ERROR:Identity not found for creating addMetadata request for Permissions tree</message>
           </xsl:otherwise>

          </xsl:choose>

</xsl:template>

<!-- - - - - - - - - - - - - - - -

  Create Content specific to a Group tree

- - - - - - -->

<xsl:template name="createGroupContent">
  <xsl:param name="identityGroupName"/>

  <PropertySets>
      <PropertySet Name="ModifiedByProductPropertySet" SetRole="ModifiedByProductPropertySet"/>
  </PropertySets>

  <SubTrees>

     <Tree Name="RolesTree">
           <xsl:attribute name="Desc">RolesTree <xsl:value-of select="$identityGroupName"/></xsl:attribute>

        <SubTrees>

           <Tree Name="DefaultRole">
                 <xsl:attribute name="Desc">DefaultRole <xsl:value-of select="$identityGroupName"/></xsl:attribute>

              <SubTrees>

                 <Tree Name="DESKTOP_PROFILE" Desc="DESKTOP_PROFILE DefaultRole">

                    <SubTrees>
                       <Tree Id="$StickyTree" Name="Sticky" Desc="Sticky DefaultRole"/>
                       <Tree Id="$DefaultTree" Name="Default" Desc="Default DefaultRole"/>
                         

                    </SubTrees>

                 </Tree>

              </SubTrees>

           </Tree>

        </SubTrees>

     </Tree>

  </SubTrees>

</xsl:template>

</xsl:stylesheet>

