<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:variable name="contextFile" select="Mod_Request/NewMetadata/MetadataContext"/>

<!-- The contextFile argument could be a SAS temporary file path, which could have a # in the name.
     Unfortunately, that is invalid in a file uri without being escaped.  Thus, we need to escape
     the last part of the filename (but not the rest since we want the slashes.
-->

<xsl:variable name="contextTokens" select="tokenize($contextFile,'/')"/>
<xsl:variable name="contextTokensCount" select="count($contextTokens)"/>
<xsl:variable name="contextFileName" select="$contextTokens[$contextTokensCount]"/>
<xsl:variable name="contextFilePath">
     <xsl:for-each select="$contextTokens">
       <xsl:choose><xsl:when test="$contextTokensCount &gt; 1">
              <xsl:choose><xsl:when test="position()=1"><xsl:value-of select="."/></xsl:when>
                         <xsl:when test="position() &lt; $contextTokensCount">/<xsl:value-of select="."/></xsl:when>
              </xsl:choose>
              </xsl:when><xsl:otherwise/></xsl:choose>
           </xsl:for-each>
</xsl:variable>

<xsl:variable name="contextFileURI" select="concat('file://',$contextFilePath,'/',encode-for-uri($contextFileName))"/>
<xsl:variable name="metadataContext" select="document($contextFileURI)"/>

</xsl:stylesheet>

