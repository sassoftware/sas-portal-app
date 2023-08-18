
/*
 *  Generate the detailed portlet editor content
 */

filename inxsl "&filesDir./portlet/editportlet.displayurl.xslt";

proc xsl in=outxml xsl=inXSL out=details;
   parameter "appLocEncoded"="&appLocEncoded.";

run;

filename inxsl;


