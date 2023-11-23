<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- input xml is the output of the getUserProfile.xslt generated xml request -->

<xsl:template match="/">

   <xsl:apply-templates select="GetMetadataObjects/Objects/Person"/>

</xsl:template>

<xsl:template match="Property">

<xsl:message>Processing <xsl:value-of select="name(.)"/>, name=<xsl:value-of select="@Name"/></xsl:message>
      <Property>
            <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
            <xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute>
      </Property>

      <xsl:apply-templates select="OwningType/PropertyType"/>

</xsl:template>

<xsl:template match="PropertyType">

<xsl:message>Processing <xsl:value-of select="name(.)"/>, name=<xsl:value-of select="@Name"/></xsl:message>
      <PropertyType>
            <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
            <xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute>
      </PropertyType>

<xsl:message><xsl:value-of select="name(.)"/>: Ending</xsl:message>
</xsl:template>

<xsl:template match="PropertySet">

<xsl:message>Processing <xsl:value-of select="name(.)"/>, name=<xsl:value-of select="@Name"/></xsl:message>

   <xsl:apply-templates select="SetProperties/Property"/>
<xsl:message>PropertySet: after processing properties for this property set</xsl:message>

   <PropertySet>
       <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
       <!-- Name isn't necessary for a delete but adding it so in the logging, it's easier to tell what objects were deleted -->
       <xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute>
   </PropertySet>

<xsl:message><xsl:value-of select="name(.)"/>: Ending</xsl:message>
</xsl:template>

<xsl:template match="Person">

	<xsl:variable name="userId" select="@Id"/>
	<xsl:variable name="userName" select="@Name"/>

<xsl:message>Checking profile information for person, Id=<xsl:value-of select="$userId"/>, Name=<xsl:value-of select="$userName"/></xsl:message>

	<xsl:variable name="profileCount" select="count(//PropertySet[contains(@SetRole,'Profile/')])"/>

	<xsl:message>number of profiles found=<xsl:value-of select="$profileCount"/></xsl:message>

	<!--  Only generate the delete request if the profiles exist -->

        <xsl:choose>

           <xsl:when test="$profileCount &gt; 0">

                <xsl:message>Number of profiles found to delete=<xsl:value-of select="$profileCount"/></xsl:message>

		<DeleteMetadata>

		<Metadata>

                <xsl:for-each select="//PropertySet[contains(@SetRole,'Profile/')]">
                    <xsl:sort select="position()" order="descending"/>

                    <xsl:apply-templates select="."/>

                </xsl:for-each>

		</Metadata>
		<NS>SAS</NS>
		<Flags>268435456</Flags>
		<Options/>

		</DeleteMetadata>

           </xsl:when>
           <xsl:otherwise>

                <!-- Nothing to do, just generate a comment indicating this fact and that the xsl processed properly. -->

                <message>NOTE: User profile does not exist, nothing to delete.</message>
 
           </xsl:otherwise>

        </xsl:choose>

</xsl:template>

<xsl:template match="*">

<xsl:message>Wound up in the default template handler, object type=<xsl:value-of select="name(.)"/>, name=<xsl:value-of select="@Name"/></xsl:message>

</xsl:template>

</xsl:stylesheet>

