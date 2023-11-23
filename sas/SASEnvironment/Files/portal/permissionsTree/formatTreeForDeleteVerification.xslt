<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes"/>

<!-- The intent of this template is take an input set of objects, and generate a GetMetadata on each referenced object to verify 
     if they still exist or not -->

<!-- Note: Executing this request may result in objects being returned.  This can happen if a shared object is referenced. Thus, 
     after executing this metadata request, the response will need to be investigated to make sure that only the ones returned 
     are those that are expected. -->

<xsl:template match="/">

<Multiple_Requests>

  <xsl:apply-templates select="/GetMetadataObjects/Objects/*"/>

</Multiple_Requests>
   
</xsl:template>

<xsl:template match="@Id">
  <xsl:param name="objectType"/>

<xsl:variable name="reposid">A0000001.<xsl:value-of select="substring-before(.,'.')"/></xsl:variable>

<GetMetadataObjects>
   <Reposid><xsl:value-of select="$reposid"/></Reposid>
   <Type><xsl:value-of select="$objectType"/></Type>
   <Objects/>
   <ns>SAS</ns>
   <Flags>128</Flags>
   <Options>
     <XMLSelect><xsl:attribute name="search">@Id='<xsl:value-of select="."/>'</xsl:attribute></XMLSelect>
    </Options>
</GetMetadataObjects>
  
</xsl:template>

<xsl:template match="@ObjRef">
  <xsl:param name="objectType"/>

  <xsl:comment>Found ObjRef: <xsl:value-of select="."/>, Type=<xsl:value-of select="$objectType"/></xsl:comment>

</xsl:template>

<xsl:template match="@*">
  <xsl:param name="objectType"/>
  <xsl:param name="shouldExist"/>
    <!-- xsl:comment>In match @*, type=<xsl:value-of select="name(.)"/></xsl:comment -->
  <!-- skip other attributes -->
</xsl:template>

<xsl:template match="*">
    <!-- xsl:comment>In match *, type=<xsl:value-of select="name(.)"/></xsl:comment -->

    <xsl:apply-templates select="@*">
       <xsl:with-param name="objectType"><xsl:value-of select="name(.)"/></xsl:with-param>

    </xsl:apply-templates>

    <xsl:apply-templates/>

</xsl:template>

<xsl:template match="comment()|processing-instruction()">
    <!-- xsl:comment>In match comment, type=<xsl:value-of select="name(.)"/></xsl:comment -->
 <!-- skip -->
</xsl:template>

</xsl:stylesheet>
