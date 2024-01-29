
/*
 *  Generate the detailed portlet editor content
 */

filename inxsl "&filesDir./portlet/edit.displayurl.xslt" encoding="utf-8";

proc xsl in=outxml xsl=inXSL out=details;
   parameter "appLocEncoded"="&appLocEncoded."
             "localizationFile"="&localizationFile."
         ;
run;

filename inxsl;


