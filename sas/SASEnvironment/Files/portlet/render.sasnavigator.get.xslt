<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- input xml format is the Mod_Request xml format with context information
     about the request is in the NewMetadata section
-->

<xsl:template match="/">

  <!-- Sample values of parameters
    path=/Shared Data/folder1/folder2
    objectFilter=StoredProcess,Report,InformationMap
  -->

 <!--  If the user had passed a blank path or a path='/', then we would have retrieved the root of the SAS Content Tree
      There is not actually a "root" tree, but instead it is a rooted by a SoftwareComponent (named BIP Service) and the set of
      initial trees are associated with it.
      Thus, here we need to look at the information passed and decide which query to do.
 -->

 <xsl:variable name="path" select="/Mod_Request/NewMetadata/Path"/>
 <xsl:variable name="objectFilter" select="/Mod_Request/NewMetadata/ObjectFilter"/>
 <xsl:variable name="reposId" select="/Mod_Request/NewMetadata/Metareposid"/>
 <xsl:variable name="passedFolderId" select="/Mod_Request/NewMetadata/FolderId"/>

<Multiple_Requests>

<xsl:variable name="folderType" select="substring-before($passedFolderId,'/')"/>
<xsl:variable name="folderId" select="substring-after($passedFolderId,'/')"/>

<xsl:choose>

 <xsl:when test="$folderType='SoftwareComponent'">
  <!-- we were passed the "root" of the SAS Content tree to process -->
     <GetMetadata>
     <Metadata>
     <SoftwareComponent Name="">
       <xsl:attribute name="Id"><xsl:value-of select="$folderId"/></xsl:attribute>
       <SoftwareTrees search="Tree[@TreeType='BIP Folder']"/>
     </SoftwareComponent>
     </Metadata>
     <NS>SAS</NS>
     <!-- 4 =  Template
     -->
     <Flags>4</Flags>
     <Options>
        <Templates>
           <Tree Id="" Name="" Desc="" MetadataCreated=""/>
        </Templates>
     </Options>
     </GetMetadata>

 </xsl:when>

 <xsl:otherwise>
 <!-- we were passed a tree object to process -->
 <GetMetadata>
 <Metadata>
 <Tree Name="" Desc="" MetadataCreated="">
   <xsl:attribute name="Id"><xsl:value-of select="$folderId"/></xsl:attribute>
   <SubTrees/>
 </Tree>
 </Metadata>
 <NS>SAS</NS>
 <!-- 4 =  Template
 -->
 <Flags>4</Flags>
 <Options>
    <Templates>
       <Tree Id="" Name="" Desc="" MetadataCreated=""/>
    </Templates>
 </Options>
 </GetMetadata>

 <GetMetadata>
 <Metadata>
 <Tree TreeType="" Name="" Desc="" MetadataCreated="">
   <xsl:attribute name="Id"><xsl:value-of select="$folderId"/></xsl:attribute>
   <Members search="*[@TransformRole ne '']"/>
 </Tree>
 </Metadata>
 <NS>SAS</NS>
     <!-- 16 =  Include Subtypes (to pick up Root template below)
           4 =  Template
     -->
 <Flags>20</Flags>
 <Options>
     <Templates>
        <Transformation Id="" Name="" Desc="" TransformRole="" PublicType="" MetadataCreated="" MetadataUpdated=""/>
        <ClassifierMap Id="" Name="" Desc="" TransformRole="" PublicType="" MetadataCreated="" MetadataUpdated=""/>
        <Root Id="" Name="" Desc="" MetadataCreated="" MetadataUpdated=""/>
     </Templates>
 </Options>
 </GetMetadata>

 </xsl:otherwise>

 </xsl:choose>

</Multiple_Requests>

</xsl:template>

</xsl:stylesheet>

