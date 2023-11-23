<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:param name="treeName"/>
<xsl:param name="includeMembers">0</xsl:param>
<xsl:param name="includeMemberDetails">0</xsl:param>

<xsl:template match="/">

<GetMetadataObjects>
                                <ReposId>$METAREPOSITORY</ReposId>
                                <Type>Tree</Type>
                                <ns>SAS</ns>
                                <!-- 256 = GetMetadata
                                     128 = XMLSelect
                                      16 = Include Subtypes (for Templates to use Root for un-templated objects)
                                       4 =  Template
                                -->
                               <xsl:choose>
                                <xsl:when test="$includeMembers ne '0'">
                                     <Flags>404</Flags>
                                </xsl:when>
                                <xsl:otherwise>
                                     <Flags>388</Flags>
                                </xsl:otherwise>

                                </xsl:choose>
                                <Options>
                                   <XMLSelect><xsl:attribute name="search">@Name='<xsl:value-of select="$treeName"/>'</xsl:attribute></XMLSelect>
                                   <Templates>
                                      <Tree Id="" Name="">
                                          <AccessControls/>
                                          <xsl:if test="$includeMembers ne '0'">
                                             <Members/>
                                             <SubTrees/>

                                             <xsl:if test="$includeMemberDetails ne '0'">
                                              <UsingPrototype/>
                                             </xsl:if>

                                          </xsl:if>

                                      </Tree>
                                      <AccessControlEntry Id="" Name="">
                                         <Identities/>
                                         <Permissions/>
                                      </AccessControlEntry>

                                      <xsl:if test="$includeMembers ne '0'">

                                           <xsl:if test="$includeMemberDetails ne '0'">

                                             <PSPortalPage Id="" Name="" Desc="">
                                               <Extensions/>
                                               <LayoutComponents/>
                                               <PropertySets/>
                                               <Properties/>
                                             </PSPortalPage>
                                            
                                             <PSPortlet Id="" Name="" Desc="" PortletType="">
                                               <PropertySets/>
                                               <Properties/>
                                               <UsingPrototype/>
                                             </PSPortlet>
 
                                             <Group Id="" Name="" Desc="">
                                                <Members/>
                                                <Properties/>
                                                <PropertySets/>
                                             </Group>

                                             <PropertySet Id="" Name="" Desc="" SetRole="">
                                               <SetProperties/>
                                             </PropertySet>

                                             <Property Id="" Name="" Desc="" DefaultValue="" PropertyName="">
                                               <AssociatedPropertySet/>
                                             </Property>

                                             <Extension Id="" Name="" Desc="" Value=""/>

                                             <PSColumnLayoutComponent Id="" Name="">
                                               <Portlets/>
                                             </PSColumnLayoutComponent>
                                              
                                           </xsl:if>

                                           <Root Id="" Name="" Desc=""/>
                                      </xsl:if>

                                   </Templates>
                              </Options>
</GetMetadataObjects>

</xsl:template>

</xsl:stylesheet>

