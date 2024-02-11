<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Input is the Mod_Request xml format -->

<xsl:variable name="publicTreeName">PUBLIC Permissions Tree</xsl:variable>

<xsl:template match="/">

<xsl:variable name="reposId" select="/Mod_Request/NewMetadata/Metareposid"/>

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
                      <Templates>                                                                                                    
                         <Tree Id="" Name="" TreeType="" Desc="">
                           <Members search="Prototype[@MetadataType='PSPortlet']"/> 
                         </Tree>                                                                                                     
                         <Prototype Id="" Name="" Desc="" MetadataType="">
                           <Extensions search="Extension[@Name='URI']"/>
                         </Prototype>
                         <Extension Id="" Name="" Desc="" Value=""/>
                      </Templates>                                                                                                   
                 </Options>                                                                                                          
</GetMetadataObjects>

</xsl:template>

</xsl:stylesheet>

