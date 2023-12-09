<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Get a user permissions tree and the user's profile information which will be used to build the tree content -->

<xsl:param name="treeName"/>
<xsl:param name="identityName"/>
<xsl:param name="reposName"/>

<xsl:template match="/">

    <!-- Expect the input xml to be the response xml from getRepositories method -->

    <xsl:variable name="reposId"><xsl:value-of select="GetRepositories/Repositories/Repository[@Name=$reposName]/@Id"/></xsl:variable>

	<Multiple_Requests>
	<GetMetadataObjects>
					<ReposId><xsl:value-of select="$reposId"/></ReposId>
					<Type>Tree</Type>
					<ns>SAS</ns>
					<!-- 
					     128 = XMLSelect
					-->
					<Flags>128</Flags>
					<Options>
                                   <XMLSelect><xsl:attribute name="search">@Name='<xsl:value-of select="$treeName"/>'</xsl:attribute></XMLSelect>

					</Options>
	</GetMetadataObjects>

                <GetMetadataObjects>
                                        <ReposId><xsl:value-of select="$reposId"/></ReposId>
                                        <Type>Person</Type>
                                        <ns>SAS</ns>
                                        <!--
                                             128 = XMLSelect
                                             256 = GetMetadata
                                               4 = Templates
                                        -->
                                        <Flags>388</Flags>
                                        <Options>
                                        <XMLSelect><xsl:attribute name="search">@Name='<xsl:value-of select="$identityName"/>'</xsl:attribute></XMLSelect>
                                        <Templates>
                                           <Person Id="" Name="">
                                             <!-- Need to retrieve the user's profile information -->
                                             <PropertySets search="PropertySet[@setRole='Profile/global']"/>
                                           </Person>
                                           <PropertySet Id="" Name="" SetRole="">
                                             <PropertySets/>
                                             <SetProperties/>
                                           </PropertySet>
                                           <Property Id="" Name="" PropertyName="" DefaultValue=""/>
                                        </Templates>
                                        </Options>
                 </GetMetadataObjects>


	</Multiple_Requests>

</xsl:template>

</xsl:stylesheet>

