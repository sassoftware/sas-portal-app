/*  Generate the Edit Portlet Content page */

%inc "&portalAppDir./sas/setup.sas";

/*
 *  Retrieve the portlet metadata
 */

filename inxml "&filesDir./portlet/getPortletContent.xml";

filename request temp;

data _null_;

  infile inxml ;
  file request;
  input;

  length line $400;
  /*
   *  Replace the passed id in the metadata request
   */
  line=transtrn(_infile_,'${TYPEID}',"&id.");
  put line;
run;

filename outxml temp;

proc metadata in=request out=outxml;
run;
/*
data _null_;
 infile request;
 input;
 put _infile_;
 run;
 data _null_;
 infile outxml;
 input;
 put _infile_;
 run;
 */

filename inxml;
filename request;


/*
 *  Generate the Common part of the page
 */

filename common temp;
%let common=%sysfunc(pathname(common));

filename inxsl "&filesDir./portlet/genEditPortletContent.xslt";

proc xsl in=outxml xsl=inXSL out=common;
   parameter "appLocEncoded"="&appLocEncoded."
             "sastheme"="&sastheme."

             "portletEditContentTitle"="&portletEditContentTitle."
             ;
run;

filename inxsl;

/*
 *  Now generate the detailed part based on the type of portlet being edited
 */

/*
 *  Start the details section
 */

%let pagestrt=&filesDir./portlet/editportlet.html.start.snippet;

filename details temp;
%let details=%sysfunc(pathname(details));

%macro portletNotSupported;

   data _null_;
     file details;
     put "<p><b>&portletEditNotSupported.</b></p>";
     run;

%mend;

%macro genPortletDetails;

/*
 *  See if we have a stylesheet for this type of porlet
 */
%let editPortletProcessor=&filesDir./portlet/editportlet.%lowcase(&portletType.).sas;

%if (%sysfunc(fileexist(&editPortletProcessor.))) %then %do;

    %inc "&editPortletProcessor.";
   
    %end;
    
%else %do;

    %portletNotSupported;
   
%end;

%mend;

%genPortletDetails;

/*
 *  End the details section
 */

%let pageend=&filesDir./portlet/editportlet.html.end.snippet;

/*
 *  Put the files together and do any necessary text substitution
 */

filename snippets ("&common.","&pagestrt.","&details.","&pageend.") encoding="utf-8";

data _null_;
 infile snippets;
 file _webout;
 input;
 put _infile_;

 run;

filename snippets;

filename details;

filename common;

filename outxml;

