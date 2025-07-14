<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:param name="userName"/>

<xsl:template match="/">

<GetMetadataObjects>                                                            
                       <ReposId>$METAREPOSITORY</ReposId>              
                       <Type>Person</Type>                               
                       <ns>SAS</ns>                                    
                       <!-- 256 = GetMetadata
                            128 = XMLSelect
                              4 =  Template
                       -->
                       <Flags>388</Flags>                              
                       <Options>                                       
                      <XMLSelect><xsl:attribute name="search"><xsl:text>@Name='</xsl:text><xsl:value-of select="$userName"/><xsl:text>'</xsl:text></xsl:attribute></XMLSelect>                                                  
                      <Templates>                                                                                                    
                         <Person Id="" Name="">                                                                                        
                           <PropertySets search="PropertySet[@Name='global']"/>

                         </Person>                                                                                                     
                         <PropertySet Id="" Name="" Desc="" SetRole="">
                            <PropertySets/>
                            <SetProperties search="*[@Name='Portal.LastSharingCheck' or @Name='Portal.LastFullSharingCheck']"/>
                         </PropertySet>                                                        
                         <Property Id="" Name="" PropertyName="" DefaultValue="">
                         </Property>  
                      </Templates>                                                                                                   
                 </Options>                                                                                                          
 </GetMetadataObjects>

</xsl:template>

</xsl:stylesheet>

