
/*
 *  Generate the detailed portlet editor content
 */

filename inxsl "&filesDir./portlet/edit.collection.xslt" encoding="utf-8";

%getRepoInfo;

proc xsl in=outxml xsl=inXSL out=details;
   parameter "appLocEncoded"="&appLocEncoded."
             "localizationFile"="&localizationFile."
             "reposName"="&reposName"
         ;
run;

filename inxsl;

