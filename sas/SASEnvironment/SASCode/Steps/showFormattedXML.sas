filename fmtXSL temp;
filename fmtdXML temp;

data _null_;

  file fmtXSL;
  infile cards4;
  input;
  put _infile_;
cards4;
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
<xsl:template match="*">
<xsl:copy>
<xsl:copy-of select="@*"/>
<xsl:apply-templates/>
</xsl:copy>
</xsl:template>
<xsl:template match="comment()|processing-instruction()">
<xsl:copy/>
</xsl:template>
</xsl:stylesheet>
;;;;
run;
proc xsl in=outxml xsl=fmtXSL out=fmtdXML ;
run;

data _null_;
 infile fmtdXML;
 input;
 put _infile_;
 run;
