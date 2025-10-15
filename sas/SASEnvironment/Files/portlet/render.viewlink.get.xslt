<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- input xml format is the Mod_Request xml format with context information
     about the request is in the NewMetadata section
-->

<xsl:template match="/">

  <!-- Sample values of parameters
    path=/Shared Data/folder1/folder2
  -->

 <!--  If the user had passed a blank path or a path='/', then we would have retrieved the root of the SAS Content Tree
      There is not actually a "root" tree, but instead it is a rooted by a SoftwareComponent (named BIP Service) and the set of
      initial trees are associated with it.
      Thus, here we need to look at the information passed and decide which query to do.
 -->

 <xsl:variable name="objectPath" select="/Mod_Request/NewMetadata/Path"/>
 <xsl:variable name="reposId" select="/Mod_Request/NewMetadata/Metareposid"/>

  <xsl:message>objectPath=<xsl:value-of select="$objectPath"/></xsl:message>
 
 <!--  Get the part of the tree from under the Portal Application Tree -->
 
 <xsl:variable name="objectTreePath" select="substring-after($objectPath,'Portal Application Tree/')"/>
 
 
 <xsl:variable name="objectType" select="substring-before(substring-after($objectTreePath,'('),')')"/>

 <xsl:variable name="metadataType">Document</xsl:variable>
 
 <xsl:variable name="metadataTextRole">
  <xsl:choose>
    <xsl:when test="$objectType='Link'">Portal Link</xsl:when>
    <xsl:when test="$objectType='WebApplication'">Portal Web Application</xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
 </xsl:variable>
 
 <xsl:variable name="folderNames" select="tokenize($objectTreePath,'/')"/>

 <!-- The name of the object has (<type>) on the end, ex. (Link), remove that from the name to search with -->

 <xsl:variable name="searchCriteria">
 <xsl:for-each select="$folderNames">
   <xsl:sort select="position()" order="descending"/>
    <xsl:choose>
    <xsl:when test="position() = 1">*[@Name='<xsl:choose><xsl:when test="substring-before(.,'(')"><xsl:value-of select="substring-before(.,'(')"/></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose>' <xsl:if test="$metadataTextRole != ''">and @TextRole='<xsl:value-of select="$metadataTextRole"/>'</xsl:if>]</xsl:when>
    <xsl:when test="position() = 2"><xsl:if test=".">[Trees/Tree[@Name='<xsl:value-of select="."/>']<xsl:if test="position() = last()">/ParentTree/Tree[@Name='Portal Application Tree']]</xsl:if></xsl:if></xsl:when>
    <xsl:when test="position() = last()"><xsl:if test=".">/ParentTree/Tree[@Name='<xsl:value-of select="."/>']</xsl:if>]</xsl:when>
    <xsl:otherwise>/ParentTree/Tree[@Name='<xsl:value-of select="."/>']</xsl:otherwise>
  </xsl:choose>
 </xsl:for-each>
 </xsl:variable>
 
 <xsl:message>result=<xsl:value-of select="$searchCriteria"/></xsl:message>
 
 		   	<GetMetadataObjects>
   				<ReposId><xsl:value-of select="$reposId"/></ReposId>
   				<Type><xsl:value-of select="$metadataType"/></Type>
   				<ns>SAS</ns>
                <!-- 256 = GetMetadata
                     128 = XMLSelect
                     4 =  Template
                -->
   				<Flags>388</Flags>
   				<Options>
   				  <XMLSelect><xsl:attribute name="search"><xsl:value-of select="$searchCriteria"/></xsl:attribute></XMLSelect>
   				  <Templates>
   				    <xsl:element name="{$metadataType}">
   				      <xsl:attribute name="Id"/>
   				      <xsl:attribute name="Name"/>
   				      <xsl:attribute name="URI"/>
   				      <xsl:attribute name="TextRole"/>
   				    </xsl:element>
   				  </Templates>
   				</Options>
			</GetMetadataObjects>

</xsl:template>

</xsl:stylesheet>

