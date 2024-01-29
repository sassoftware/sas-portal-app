
/*
 *  Generate the detailed document editor content for an item in a collection
 */

filename inxsl "&filesDir./portlet/edit.document.xslt" encoding="utf-8";

proc xsl in=outxml xsl=inXSL out=details;
   parameter "appLocEncoded"="&appLocEncoded."
             "localizationFile"="&localizationFile."
         ;
run;

filename inxsl;

