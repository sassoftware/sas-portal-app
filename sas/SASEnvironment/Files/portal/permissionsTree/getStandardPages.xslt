<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:param name="reposName"/>
<xsl:param name="treeName"/>
<xsl:param name="publicTreeName">PUBLIC Permissions Tree</xsl:param>

<xsl:template match="/">

<xsl:variable name="reposId"><xsl:value-of select="GetRepositories/Repositories/Repository[@Name=$reposName]/@Id"/></xsl:variable>

<Multiple_Requests>

<GetMetadataObjects>                                                            
	       <ReposId><xsl:value-of select="$reposId"/></ReposId>              
	       <Type>Tree</Type>                               
	       <ns>SAS</ns>                                    
	       <!-- 256 = GetMetadata
		    128 = XMLSelect
		      4 =  Template
	       -->
	       <Flags>388</Flags>                              
	       <Options>                                       
                      <XMLSelect>
                            <xsl:attribute name='search'>@Name='<xsl:value-of select="$publicTreeName"/>'</xsl:attribute>
                      </XMLSelect>
                      <!-- XMLSelect search="@Name='DESKTOP_PROFILE'"/ -->
                      <Templates>                                                                                                    
                         <Tree Id="" Name="" TreeType="" Desc="">
                           <Members/> 
                           <SubTrees/>
                         </Tree>                                                                                                     
                         <Prototype Id="" Name="" Desc="" MetadataType="">                                                                                                         <Extensions/>
                         </Prototype>
                         <Extension Id="" Name="" Desc="" Value=""/>
                         <Group Id="" Name="" Desc="">
                             <Members/>
                         </Group>
                      </Templates>                                                                                                   
                 </Options>                                                                                                          
</GetMetadataObjects>

<GetMetadataObjects>                                                            
               <ReposId><xsl:value-of select="$reposId"/></ReposId>
               <Type>Tree</Type>
               <ns>SAS</ns>
               <!-- 256 = GetMetadata
                    128 = XMLSelect
		      4 =  Template
               -->
               <Flags>388</Flags>
               <Options>
                      <XMLSelect>
                            <xsl:attribute name='search'>@Name='<xsl:value-of select="$treeName"/>'</xsl:attribute>
                      </XMLSelect>
                      <Templates>
                         <Tree Id="" Name="" Desc="" TreeType="">
                            <Members/>
                         </Tree>
                         <Group Id="" Name=""/>
                      </Templates>
                 </Options>
 </GetMetadataObjects>

</Multiple_Requests>

</xsl:template>

</xsl:stylesheet>

