<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:param name="identityType"/>
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
					<XMLSelect search="@Name='Portal Application Tree'"/>
					</Options>
	</GetMetadataObjects>

        <GetMetadataObjects>
                                        <ReposId><xsl:value-of select="$reposId"/></ReposId>
                                        <Type>AccessControlTemplate</Type>
                                        <ns>SAS</ns>
                                        <!--
                                             128 = XMLSelect
                                        -->
                                        <Flags>128</Flags>
                                        <Options>
                                        <XMLSelect search="@Name='Portal ACT'"/>
                                        </Options>
        </GetMetadataObjects>

	<GetMetadataObjects>
					<ReposId><xsl:value-of select="$reposId"/></ReposId>
					<Type>Permission</Type>
					<ns>SAS</ns>
					<!--
					     128 = XMLSelect
					-->
					<Flags>128</Flags>
					<Options>
					<XMLSelect search="@Name='ReadMetadata' and @Type='GRANT'"/>
					</Options>
	</GetMetadataObjects>

        <GetMetadataObjects>
                                        <ReposId><xsl:value-of select="$reposId"/></ReposId>
                                        <Type>Permission</Type>
                                        <ns>SAS</ns>
                                        <!--
                                             128 = XMLSelect
                                        -->
                                        <Flags>128</Flags>
                                        <Options>
                                        <XMLSelect search="@Name='WriteMetadata' and @Type='GRANT'"/>
                                        </Options>
        </GetMetadataObjects>

        <xsl:choose>

            <xsl:when test="$identityType='group'">
                <GetMetadataObjects>
                                        <ReposId><xsl:value-of select="$reposId"/></ReposId>
                                        <Type>IdentityGroup</Type>
                                        <ns>SAS</ns>
                                        <!--
                                             128 = XMLSelect
                                             256 = GetMetadata
                                               4 = Templates
                                        -->
                                        <Flags>388</Flags>
                                        <Options>
                                        <XMLSelect><xsl:attribute name="search">@Name='<xsl:value-of select="$identityName"/>'</xsl:attribute></XMLSelect>
                                        <!-- When adding a profile for a group, we need to also specify who is the admin for the group profile 
                                             The doc says this person should also have WriteMetadata permission on the group membership of the group
                                             so retrieving that info also 
                                          -->
                                        <Templates>
                                            <IdentityGroup Id="" Name="">
                                                <AccessControls search="AccessControlEntry[Permissions/Permission[@Name='WriteMetadata' and @Type='GRANT']]"/>
                                            </IdentityGroup>
                                            <AccessControlEntry Id="" Name="">
                                                  <Identities/>
                                                  <Permissions search="Permission[@Name='WriteMetadata']"/>
                                            </AccessControlEntry>
                                            <Person Id="" Name=""/>
                                        </Templates>

                                        </Options>
                 </GetMetadataObjects>


            </xsl:when>

            <xsl:when test="$identityType='user'">

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


            </xsl:when>

         <xsl:otherwise>
                   <message>ERROR: Invalid identityType <xsl:value-of select="$identityType"/> passed</message>
         </xsl:otherwise>

        </xsl:choose>


	</Multiple_Requests>

</xsl:template>

</xsl:stylesheet>

