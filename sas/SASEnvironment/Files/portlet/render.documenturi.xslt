<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<!-- Common Setup -->

<!-- Set up the metadataContext variable -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.metadatacontext.xslt"/>
<!-- Set up the environment context variables -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.envcontext.xslt"/>

<xsl:template match="/">

    <xsl:variable name="documentUri" select="GetMetadataObjects/Objects/Document/@URI"/>

    <HTML>
        <HEAD>
            <TITLE>Redirect</TITLE>
            <META HTTP-EQUIV="Refresh" NAME="NULL">
                <xsl:attribute name="URL">
                    <xsl:text>0; URL=</xsl:text><xsl:value-of select="$documentUri"/>
                </xsl:attribute>
            </META>
        </HEAD>
    <BODY>
    <H1>Redirect the request to another stored process.</H1>
    </BODY>
    </HTML>

</xsl:template>

</xsl:stylesheet>