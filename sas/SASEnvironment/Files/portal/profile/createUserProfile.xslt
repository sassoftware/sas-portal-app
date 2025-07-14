<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- input xml is the output of the getUserProfile.xslt generated xml request -->

<xsl:template match="/">

   <xsl:apply-templates select="GetMetadataObjects/Objects/Person"/>

</xsl:template>

<xsl:template name="buildProfile">

   <xsl:param name="profileType"/>
   <xsl:param name="parentPropertySetId"/>
   <xsl:param name="userId"/>

   <xsl:choose>

     <xsl:when test="$profileType='global'">

        <!-- Create the metadata content for this profile -->

        <PropertySet Id="$globalPropertySet" Name="global" SetRole="Profile/global">
           <OwningObject>
              <Person><xsl:attribute name="ObjRef"><xsl:value-of select="$userId"/></xsl:attribute></Person>
           </OwningObject>
           
        </PropertySet>

        <!-- Now build the rest of the profile hierarchy after this one -->

        <xsl:call-template name="buildProfile">

            <xsl:with-param name="profileType">SAS</xsl:with-param>
            <!-- NOTE: The $ value here is not referring to an xsl variable.  It is the syntax that the AddMetadata supports
                   to reference another object in the same AddMetadata request -->
            <xsl:with-param name="parentPropertySetId">$globalPropertySet</xsl:with-param>

        </xsl:call-template>

     </xsl:when>

     <xsl:when test="$profileType='SAS'">

        <!-- Create the metadata content for this profile -->

        <PropertySet Id="$sasPropertySet" Name="SAS" SetRole="Profile/SAS">
           <OwningObject>
              <PropertySet><xsl:attribute name="ObjRef"><xsl:value-of select="$parentPropertySetId"/></xsl:attribute></PropertySet>
           </OwningObject>

        </PropertySet>

        <!-- Now build the rest of the profile hierarchy after this one -->

        <xsl:call-template name="buildProfile">

            <xsl:with-param name="profileType">portal</xsl:with-param>

            <!-- NOTE: The $ value here is not referring to an xsl variable.  It is the syntax that the AddMetadata supports
                   to reference another object in the same AddMetadata request -->

            <xsl:with-param name="parentPropertySetId">$sasPropertySet</xsl:with-param>

        </xsl:call-template>

     </xsl:when>

     <xsl:when test="$profileType='portal'">

        <!-- Create the metadata content for this profile -->

        <PropertySet Id="$portalPropertySet" Name="Portal" SetRole="Profile/Portal">
           <OwningObject>
              <PropertySet><xsl:attribute name="ObjRef"><xsl:value-of select="$parentPropertySetId"/></xsl:attribute></PropertySet>
           </OwningObject>
           <SetProperties>

              <Property Id="$portalPagesProperty" Name="PortalPages" PropertyName="PortalPages" DefaultValue="Object_Value" SQLType="12">
                 <OwningType>
                    <PropertyType Name="StringType" SQLType="12"/>
                 </OwningType>
              </Property>
              <Property Id="$portalHistoryPagesProperty" Name="PortalHistoryPages" PropertyName="PortalHistoryPages" DefaultValue="Object_Value" SQLType="12">
                 <OwningType>
                    <PropertyType Name="StringType" SQLType="12"/>
                 </OwningType>
              </Property>
              <Property Id="$portalRegistryLastUpdatedProperty" Name="Portal.RegistryLastUpdated" PropertyName="Portal.RegistryLastUpdated" DefaultValue="0" SQLType="12">
                 <OwningType>
                    <PropertyType Name="StringType" SQLType="12"/>
                 </OwningType>
              </Property>
              <Property Id="$PortalLastSharingCheckProperty" Name="Portal.LastSharingCheck" PropertyName="Portal.LastSharingCheck" DefaultValue="0" SQLType="12">
                 <OwningType>
                    <PropertyType Name="StringType" SQLType="12"/>
                 </OwningType>
              </Property>
              <Property Id="$PortalLastFullSharingCheckProperty" Name="Portal.LastFullSharingCheck" PropertyName="Portal.LastFullSharingCheck" DefaultValue="0" SQLType="12">
                 <OwningType>
                    <PropertyType Name="StringType" SQLType="12"/>
                 </OwningType>
              </Property>

           </SetProperties>

        </PropertySet>

     </xsl:when>

     <xsl:otherwise>

       <message>buildProfile: ERROR: Invalid profileType passed, <xsl:value-of select="$profileType"/></message>

     </xsl:otherwise>

   </xsl:choose>

</xsl:template>

<xsl:template name="buildProfiles">

  <xsl:param name="userId"/>

  <!-- Figure out how many of the profiles we need to create -->

  <xsl:variable name="globalProfileId" select="PropertySets/PropertySet[@SetRole,'Profile/global']/@Id"/>

  <xsl:choose>

    <xsl:when test="not($globalProfileId)">

      <xsl:call-template name="buildProfile">

         <xsl:with-param name="profileType">global</xsl:with-param>
         <xsl:with-param name="userId"><xsl:value-of select="$userId"/></xsl:with-param>

      </xsl:call-template>


    </xsl:when>
    <xsl:otherwise>

      <!-- Global Profile exists, see if we need to create the SAS profile -->
 
      <xsl:variable name="sasProfileId" select="PropertySets/PropertySet[@SetRole,'Profile/global']/PropertySets/PropertySet[@SetRole,'Profile/SAS']/@Id"/>

      <xsl:choose>

	    <xsl:when test="not($sasProfileId)">

	      <xsl:call-template name="buildProfile">

		 <xsl:with-param name="profileType">SAS</xsl:with-param>
                 <xsl:with-param name="userId"><xsl:value-of select="$userId"/></xsl:with-param>
                 <xsl:with-param name="parentPropertySetId"><xsl:value-of select="$globalProfileId"/></xsl:with-param>

	      </xsl:call-template>


	    </xsl:when>
	    <xsl:otherwise>

                    <!-- SAS Profile exists, see if we need to create the portal profile -->

	            <xsl:variable name="portalProfileId" select="PropertySets/PropertySet[@SetRole,'Profile/global']/PropertySets/PropertySet[@SetRole,'Profile/SAS']/PropertySets/PropertySet[@SetRole,'Profile/portal']/@Id"/>


		    <xsl:if test="not($portalProfileId)">

			      <xsl:call-template name="buildProfile">

				 <xsl:with-param name="profileType">portal</xsl:with-param>
                                 <xsl:with-param name="userId"><xsl:value-of select="$userId"/></xsl:with-param>
                                 <xsl:with-param name="parentPropertySetId"><xsl:value-of select="$sasProfileId"/></xsl:with-param>

			      </xsl:call-template>

                    </xsl:if>


	    </xsl:otherwise>

	  </xsl:choose>


    </xsl:otherwise>

  </xsl:choose>

</xsl:template>

<xsl:template match="Person">

	<xsl:variable name="userId" select="@Id"/>
	<xsl:variable name="userName" select="@Name"/>

	<xsl:variable name="profileCount" select="count(//PropertySets/PropertySet[contains(@SetRole,'Profile/')])"/>

	<xsl:variable name="userGlobalProfileId" select="GetMetadataObjects/Objects/Person/PropertySets/PropertySet/@Id"/>

	<!--  Only generate the add request if the profile doesn't exist (ie. wasn't found in the response) -->

	<!--  The user should have at least 3 profiles (global, SAS, portal) if the user has been properly initialized. -->

        <xsl:choose>

	<xsl:when test="$profileCount &lt; 3">

		<AddMetadata>

		<Metadata>

		<xsl:call-template name="buildProfiles">

                   <xsl:with-param name="userId"><xsl:value-of select="$userId"/></xsl:with-param>

                </xsl:call-template>

		</Metadata>
		<ReposId>$METAREPOSITORY</ReposId>
		<NS>SAS</NS>
		<Flags>268435456</Flags>
		<Options/>

		</AddMetadata>

         	</xsl:when>
         <xsl:otherwise>
                <!-- The XSL processor won't allow an xml file to be generated that only has a comment or a 
                     processing instruction in it :-( 
                     Thus, we have to generate a fictitous element so that the parser doesn't complain
                -->
                <message>NOTE: User profile information already exists.</message>

         </xsl:otherwise>

         </xsl:choose>

</xsl:template>

</xsl:stylesheet>

