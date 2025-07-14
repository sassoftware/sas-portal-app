<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- input xml is irrelevant, as long as it is proper xml (it is not used) -->

<!--   The parameters give the property information (name and value) and the propertySet to add it to -->

<xsl:param name="propertyName"/>
<xsl:param name="propertyValue"/>
<xsl:param name="propertySet"/>

<xsl:template match="/">

	<AddMetadata>

	<Metadata>

             <Property SQLType="12">
                 <xsl:attribute name="Name"><xsl:value-of select="$propertyName"/></xsl:attribute>
                 <xsl:attribute name="PropertyName"><xsl:value-of select="$propertyName"/></xsl:attribute>

                 <xsl:attribute name="DefaultValue"><xsl:value-of select="$propertyValue"/></xsl:attribute>
                 <OwningType>
                    <PropertyType Name="StringType" SQLType="12"/>
                 </OwningType>

                 <AssociatedPropertySet>

                    <PropertySet>
                      <xsl:attribute name="ObjRef"><xsl:value-of select="$propertySet"/></xsl:attribute>
                    </PropertySet>

                 </AssociatedPropertySet>

              </Property>

	</Metadata>
	<ReposId>$METAREPOSITORY</ReposId>
	<NS>SAS</NS>
	<Flags>268435456</Flags>
	<Options/>

	</AddMetadata>

</xsl:template>


</xsl:stylesheet>

