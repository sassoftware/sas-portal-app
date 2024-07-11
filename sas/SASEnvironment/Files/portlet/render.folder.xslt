<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="text"/>

<!-- Common Setup -->

<!-- Set up the metadataContext variable -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.metadatacontext.xslt"/>
<!-- Set up the environment context variables -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.envcontext.xslt"/>

<xsl:variable name="path" select="/Mod_Request/NewMetadata/Path"/>
<xsl:variable name="objectFilter" select="/Mod_Request/NewMetadata/ObjectFilter"/>
<xsl:variable name="objectFilterEncoded" select="concat('&amp;objectFilter=',encode-for-uri($objectFilter))"/>

<xsl:template match="/">

<!--  If the user had passed a blank path or a path='/', then we would have retrieved the root of the SAS Content Tree
      There is not actually a "root" tree, but instead it is a rooted by a SoftwareComponent (named BIP Service) and the set of
      initial trees are associated with it.
      Thus, here we have to return  the type and the id so we know what we are dealing with.
 -->

<xsl:variable name="mainObject" select="$metadataContext/GetMetadataObjects/Objects/*[1]"/>

<xsl:variable name="mainObjectType" select="name($mainObject)"/>
<xsl:variable name="mainObjectId" select="$mainObject/@Id"/>

<xsl:text>%let folderId=</xsl:text><xsl:value-of select="$mainObjectType"/>/<xsl:value-of select="$mainObjectId"/><xsl:text>;</xsl:text>

</xsl:template>

</xsl:stylesheet>

