/*  Generate the Add Item page */

/*
 *   For each item that is to be added there should be a specific generator (which generates
 *   the page content specific to this type).  If it's not found, then this item type
 *   is not supported to be added.
 *
 *   The parameters being passed to this routine will be dependent on the
 *   type of item being saved.
 *   The only required parameters are:
 *    type = the type of object
 *   Normally, the object that is being created is to be "related" to an existing
 *   object.  In this case, the following parameters need to be set:
 *    relatedId = the id of the related object
 *    relatedType = the type of the related object
 *
 */

%inc "&sasDir./request_setup.sas";

%macro addPortletItem;

  /*
   *  Get the repository information to pass along as part of the metadata context
   *  that might be needed for the add generation.
   */

  %getRepoInfo;

  /*
   *   For each item that is to be added there should be a specific generator (which generates
   *   the page content specific to this type).  If it's not found, then this item type
   *   is not supported to be added.
   */

  %let addItemGenerator=;

  /*
   *   A parameter handler is normally used to map metadata results into the NewMetadata xml 
   *   document.  However, in this case, we are using it to add additional fields into the NewMetadata.xml structure
   *   for the html generators.
   */
  filename newxml temp;

  %if ("%upcase(&type.)"="PSPORTLET") %then %do;
      %let searchType=&portletType.;
      %end;
  %else %do;
      %let searchType=&type.;
      %end;

  %let addItemHandlerFile=&stepsDir./portlet/add.%lowcase(&searchType.).parameters.sas;

  %if (%sysfunc(fileexist(&addItemHandlerFile.)) ne 0)
    %then %do;

    %let addItemHandler=addhndlr;
    filename &addItemHandler. "&addItemHandlerFile.";

    %end;
  %else %do;

    %let addItemHandler=;

    %end;

  /*
   *  Create some xml to pass the current info into the various routines.
   */
 
  %buildModParameters(newxml,&addItemHandler.);

  /*
   *  Generate the Common part of the page
   */

  filename common temp;
  %let common=%sysfunc(pathname(common));

  filename inxsl "&filesDir./portlet/add.html.gen.xslt";

  proc xsl in=newxml xsl=inXSL out=common;
     parameter "appLocEncoded"="&appLocEncoded."
               "sastheme"="&sastheme."
               "localizationFile"="&localizationFile."           
    ;
  run;

  filename inxsl;

  /*
   *  The addItem macro may need to add additional information
   *  to the xml input to the specific, detailed part of the page
   *  so let the macro rebuild it as needed (and thus we don't
   *   need this assigned any longer).
   */

  filename newxml;

  /*
   *  Now generate the detailed part based on the type of item being added
   */

  /*
   *  Start the details section
   */

  %let pagestrt=&filesDir./portlet/add.html.start.snippet;

  filename details temp;
  %let details=%sysfunc(pathname(details));

  %addItem(out=details,rc=addItemRC,handler=&addItemHandler.);

  %put addItemRC=&addItemRC.;

  %if ( "&addItemHandler." ne "" ) %then %do;
      filename &addItemHandler.;
      %end;

  /*
   *  End the details section
   */

  %let pageend=&filesDir./portlet/add.html.end.snippet;

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

%mend;

%setupPortalDebug(addItem);

%addPortletItem;

%cleanupPortalDebug;

