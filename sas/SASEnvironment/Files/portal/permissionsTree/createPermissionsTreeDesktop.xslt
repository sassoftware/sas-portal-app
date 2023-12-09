<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- - - - - - - - - - - - - - - -

  Main Entry Point

- - - - - - -->

<xsl:template match="/">

    <!-- input xml is the output of the getPermissionsTreeProfilReferences.xslt generated xml request -->
   
    <!-- Make sure to validate that required fields are present, if not ERROR -->

    <xsl:variable name="parentTreeId" select="Multiple_Requests/GetMetadataObjects/Objects/Tree/@Id"/>
    <xsl:if test="not($parentTreeId)">
       <message>ERROR: Parent tree information not found,parentTreeId=<xsl:value-of select="$parentTreeId"/></message>
    </xsl:if>
    <xsl:variable name="parentTreeName" select="Multiple_Requests/GetMetadataObjects/Objects/Tree/@Name"/>
    <xsl:if test="not($parentTreeName)">
       <message>ERROR: Parent tree information not found,parentTreeId=<xsl:value-of select="$parentTreeId"/></message>
    </xsl:if>

    <xsl:variable name="personName" select="Multiple_Requests/GetMetadataObjects/Objects/Person/@Name"/>

    <xsl:variable name="personId" select="Multiple_Requests/GetMetadataObjects/Objects/Person/@Id"/>

    <AddMetadata>

    <!--   When referencing an existing object, you use the ObjRef= option on the object reference.  No other attributes are required or processed.
           We are including the Name attribute of these referenced objects in the request also so that the metadata request is easier to validate
           and debug, it does not change the processing of a referenced object.
      -->

    <Metadata>
              <xsl:call-template name="createUserContent">
                 <xsl:with-param name="treeId"><xsl:value-of select="$parentTreeId"/></xsl:with-param>
                 <xsl:with-param name="treeName"><xsl:value-of select="$parentTreeName"/></xsl:with-param>
                 
              </xsl:call-template>

    <xsl:comment>SUCCESS: NOTE: Generating AddMetadata request for User Desktop information completed successfully.</xsl:comment>

    </Metadata>
    <ReposId>$METAREPOSITORY</ReposId>
    <NS>SAS</NS>
    <Flags>268435456</Flags>
    <Options/>

    </AddMetadata>

</xsl:template>

<!-- - - - - - - - - - - - - - - -

  Create Content specific to a User tree

- - - - - - -->

<xsl:template name="createUserContent">

<xsl:param name="treeId"/>
<xsl:param name="treeName"/>

<xsl:variable name="profilePortalPagesId" select="Multiple_Requests/GetMetadataObjects/Objects/Person/PropertySets/PropertySet[@SetRole='Profile/global']/PropertySets/PropertySet[@SetRole='Profile/SAS']/PropertySets/PropertySet[@SetRole='Profile/Portal']/SetProperties/Property[@PropertyName='PortalPages']/@Id"/>
<xsl:variable name="profilePortalPagesName" select="Multiple_Requests/GetMetadataObjects/Objects/Person/PropertySets/PropertySet[@SetRole='Profile/global']/PropertySets/PropertySet[@SetRole='Profile/SAS']/PropertySets/PropertySet[@SetRole='Profile/Portal']/SetProperties/Property[@PropertyName='PortalPages']/@Name"/>

<xsl:if test="not($profilePortalPagesId)">
   <message>ERROR: Profile PortalPages property not found, is the user profile initialized?</message>
</xsl:if>

<xsl:variable name="profilePortalHistoryId" select="Multiple_Requests/GetMetadataObjects/Objects/Person/PropertySets/PropertySet[@SetRole='Profile/global']/PropertySets/PropertySet[@SetRole='Profile/SAS']/PropertySets/PropertySet[@SetRole='Profile/Portal']/SetProperties/Property[@PropertyName='PortalHistoryPages']/@Id"/>
<xsl:variable name="profilePortalHistoryName" select="Multiple_Requests/GetMetadataObjects/Objects/Person/PropertySets/PropertySet[@SetRole='Profile/global']/PropertySets/PropertySet[@SetRole='Profile/SAS']/PropertySets/PropertySet[@SetRole='Profile/Portal']/SetProperties/Property[@PropertyName='PortalHistoryPages']/@Name"/>

<xsl:if test="not($profilePortalPagesId)">
   <message>ERROR: Profile PortalHistoryPages property not found, is the user profile initialized?</message>
</xsl:if>
                <Group Name="DESKTOP_PORTALPAGES_GROUP" Desc="Portal Pages">
                      <!--  Associate this group with the user's profile information -->
                      <Properties>
                          <Property>
                              <xsl:attribute name="ObjRef"><xsl:value-of select="$profilePortalPagesId"/></xsl:attribute>
                              <xsl:attribute name="Name"><xsl:value-of select="$profilePortalPagesName"/></xsl:attribute>
                          </Property>
                      </Properties>
                      <Trees>
                         <Tree>
                              <xsl:attribute name="ObjRef"><xsl:value-of select="$treeId"/></xsl:attribute>
                              <xsl:attribute name="Name"><xsl:value-of select="$treeName"/></xsl:attribute>
                         </Tree>
                      </Trees>
                </Group>

                <Group Name="DESKTOP_PAGEHISTORY_GROUP" Desc="Page History">

                      <!--  Associate this group with the user's profile information -->
                       <Properties>
                          <Property>
                              <xsl:attribute name="ObjRef"><xsl:value-of select="$profilePortalHistoryId"/></xsl:attribute>
                              <xsl:attribute name="Name"><xsl:value-of select="$profilePortalHistoryName"/></xsl:attribute>
                          </Property>
                       </Properties>

                      <Trees>
                         <Tree>
                              <xsl:attribute name="ObjRef"><xsl:value-of select="$treeId"/></xsl:attribute>
                              <xsl:attribute name="Name"><xsl:value-of select="$treeName"/></xsl:attribute>
                         </Tree>
                      </Trees>

                </Group>

</xsl:template>

</xsl:stylesheet>

