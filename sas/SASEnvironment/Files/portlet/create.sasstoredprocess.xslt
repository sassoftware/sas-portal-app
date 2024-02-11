<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!-- All initial portlet adds are very similar, so use a common routine and setting
     variables that indicate what processing should be done.
 -->

<xsl:variable name="includeCollectionGroup">0</xsl:variable>
<xsl:variable name="portletType">SASStoredProcess</xsl:variable>
<xsl:variable name="prototypeURI">/sas/portlets/remote/SASStoredProcess/display</xsl:variable>
<xsl:variable name="includePortletRenderState">1</xsl:variable>

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/create.psportlet.xslt"/>

</xsl:stylesheet>

