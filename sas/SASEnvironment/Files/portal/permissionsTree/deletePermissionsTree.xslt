<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:template name="deleteThisObject">

   <xsl:variable name="objectType" select="name(.)"/>

   <xsl:element name="{$objectType}">

             <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
             <xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute>

   </xsl:element>

</xsl:template>

<xsl:template match="Tree">

        <xsl:call-template name="deleteThisObject"/>

	<xsl:apply-templates select="AccessControls/*"/>

	<xsl:apply-templates select="Members/*"/>

</xsl:template>

<xsl:template match="AccessControlEntry">

        <xsl:call-template name="deleteThisObject"/>

</xsl:template>

<xsl:template match="Keyword">
    <xsl:call-template name="deleteThisObject"/>
</xsl:template>

<xsl:template match="Extension">
    <xsl:call-template name="deleteThisObject"/>
</xsl:template>

<xsl:template match="Property">
    <xsl:call-template name="deleteThisObject"/>
</xsl:template>

<xsl:template match="PropertySet">
    <xsl:call-template name="deleteThisObject"/>
    <xsl:apply-templates select="SetProperties/*"/>
    <xsl:apply-templates select="Extensions/*"/>

</xsl:template>

<xsl:template match="PSPortlet">
    <!-- When deleting the portlet other related objects (like extensions and propertyset/properties should automatically
         be deleted also.
         NOTE: After trying this, it looks like the propertyset was deleted, but not the properties in the propertyset,
               so explicitly deleting them here.
      -->
    <xsl:apply-templates select="PropertySets/*"/>
    <xsl:apply-templates select="Extensions/*"/>
    <xsl:apply-templates select="Keywords/*"/>

    <xsl:call-template name="deleteThisObject"/>

</xsl:template>

<xsl:template match="Group">

    <!-- We should delete the group, but don't iterate over it's members as they could be linked into multiple groups
         and could contain a link to an object that is shared (like a shared portal page).
      -->

    <xsl:call-template name="deleteThisObject"/>
    
</xsl:template>

<xsl:template match="PSPortalPage">

    <xsl:call-template name="deleteThisObject"/>

</xsl:template>

<xsl:template match="/">

	<DeleteMetadata>

	<Metadata>

	   <xsl:apply-templates select="GetMetadataObjects/Objects/Tree"/>

	</Metadata>
	<ReposId>$METAREPOSITORY</ReposId>
	<NS>SAS</NS>
	<Flags>268435456</Flags>
	<Options/>

	</DeleteMetadata>

</xsl:template>

</xsl:stylesheet>

