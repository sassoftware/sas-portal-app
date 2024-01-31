/*  Generate the Edit Item page */

%inc "&sasDir./request_setup.sas";

%macro editPortletItem;

/*
 *   For each item that is to be edited, there should be a getter (that gets the existing metadata)
 *   and a generator (which generates the item specific page content).  If either of those are not found, then
 *   this item type is not supported to be edited.
 */

%let editItemGenerator=;

%if ("%upcase(&type.)"="PSPORTLET") %then %do;
   %if (%symexist(portlettype)) %then %do;
      %let searchType=&portletType.;
      %end;
   %else %do;   
      %let searchType=&type.;
      %end;
   %end;
%else %do;
   %let searchType=&type.;
   %end;

%let editItemGetter=&filesDir./portlet/edit.%lowcase(&searchType.).get.xml;

%if (%sysfunc(fileexist(&editItemGetter.))=0) %then %do;

    %let editItemGenerator=&stepsDir./portlet/edit.unsupported.sas;

    /*  Pass a dummy xml file */

    filename outxml temp;

    /*
     *  Include the standard parameters 
     */
    data _null_;
      file outxml;
      put '<Mod_Request>';
      put '<NewMetadata>';
      put "<Type>&type.</Type>";
      put "<Id>&id.</Id>";
      %if (%symexist(portlettype)) %then %do;
          put "<PortletType>&portletType</PortletType>";
          %end;
      put '</NewMetadata>';
      put '</Mod_Request>';
    run;

    %end;
%else %do;

    filename inxml "&editItemGetter.";

    filename request temp;

    data _null_;

      infile inxml ;
      file request;
      input;

      length line $400;
      /*
       *  Replace the passed id in the metadata request
       */
      line=transtrn(_infile_,'${TYPEID}',"&Id.");
      put line;
    run;

    filename outxml temp;

    proc metadata in=request out=outxml;
    run;

    filename inxml;
    filename request;

%end;

/*
 *  Generate the Common part of the page
 */

filename common temp;
%let common=%sysfunc(pathname(common));

filename inxsl "&filesDir./portlet/edit.html.gen.xslt";

proc xsl in=outxml xsl=inXSL out=common;
   parameter "appLocEncoded"="&appLocEncoded."
             "sastheme"="&sastheme."
             "localizationFile"="&localizationFile."           
  ;
run;

filename inxsl;

/*
 *  Now generate the detailed part based on the type of item being edited
 */

/*
 *  Start the details section
 */

%let pagestrt=&filesDir./portlet/edit.html.start.snippet;

filename details temp;
%let details=%sysfunc(pathname(details));

%macro genItemDetails;

/*
 *  See if we have a stylesheet for this type of porlet
 */

%if ("&editItemGenerator." = "") %then %do;

    %if ("%upcase(&type.)"="PSPORTLET") %then %do;
       %if (%symexist(portlettype)) %then %do;
          %let searchType=&portletType.;
          %end;
       %else %do;
          %let searchType=&type.;
          %end;
       %end;
    %else %do;
       %let searchType=&type.;
       %end;

    %let editItemGenerator=&stepsDir./portlet/edit.%lowcase(&searchType.).sas;

    %if (%sysfunc(fileexist(&editItemGenerator.))=0) %then %do;

        %let editItemGenerator=&stepsDir./portlet/edit.unsupported.sas;
        %end;

    %end;

%inc "&editItemGenerator.";
   
%mend;

%genItemDetails;

/*
 *  End the details section
 */

%let pageend=&filesDir./portlet/edit.html.end.snippet;

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

%mend;

%setupPortalDebug(editItem);

%put Type=&Type.;
%put Id=&Id.;

%if (%symexist(portlettype)) %then %do;
    %put portletType=&portletType.;
    %end;

%editPortletItem;


%cleanupPortalDebug;

