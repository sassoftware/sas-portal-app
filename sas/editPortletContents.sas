/*  Generate the Edit Portlet Content page */

%inc "&portalAppDir./sas/setup.sas";

/*
 *  Retrieve the portlet metadata
 */

filename inxml "&filesDir./getPortletContent.xml";

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

filename inxsl "&filesDir./genEditPortletContent.xslt";

proc xsl in=outxml xsl=inXSL out=common;
run;

filename inxsl;

/*
 *  Now generate the detailed part based on the type of portlet being edited
 */

/*
 *  Start the details section
 */

%let pagestrt=&filesDir./editportlet.html.start.snippet;

filename details temp;
%let details=%sysfunc(pathname(details));

%macro portletNotSupported;

   data _null_;
     file details;
     put "<p><b>Portlet type, &portletType., not supported.</b></p>";
     run;

%mend;

%macro genPortletDetails;

%if ( "&portletType"="Collection") %then %do;

    %portletNotSupported;
    
%end;
%else %if ( "&portletType"="Bookmarks") %then %do;

    %portletNotSupported;

%end;
%else %if ( "&portletType"="DisplayURL") %then %do;

    %portletNotSupported;

%end;
%else %if ( "&portletType"="SASStoredProcess") %then %do;

    %portletNotSupported;

%end;
%else %if ( "&portletType"="SASReportPortlet") %then %do;

    %portletNotSupported;

%end;
%else %if ( "&portletType"="Report") %then %do;

    %portletNotSupported;

%end;
%else %do;

    %portletNotSupported;
   
%end;

%mend;

%genPortletDetails;

/*
 *  End the details section
 */

%let pageend=&filesDir./editportlet.html.end.snippet;

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
