/*  Generate the Edit Item page */

/*
 *   For each item that is to be edited there should be a specific generator (which generates
 *   the page content specific to this type).  If it's not found, then this item type
 *   is not supported to be edited.
 *
 *   The parameters being passed to this routine will be dependent on the
 *   type of item being saved.
 *   The only required parameters are:
 *    id = the id of the object
 *    type = the type of object
 *
 */

%inc "&sasDir./request_setup.sas";

%macro editPortletItem;

  /*
   *  Get the repository information to pass along as part of the metadata context
   *  that might be needed for the edit generation.
   */

  %getRepoInfo;

  /*
   *   For each item that is to be edited there should be a specific generator (which generates
   *   the page content specific to this type).  If it's not found, then this item type
   *   is not supported to be edited.
   */

  %let editItemGenerator=;

  /*
   *  Create some xml to pass the current info into the various routines.
   */

  filename newxml temp;

  %buildModParameters(newxml);

  /*
   *  Generate the Common part of the page
   */

  filename common temp;
  %let common=%sysfunc(pathname(common));

  filename inxsl "&filesDir./portlet/edit.html.gen.xslt";

  proc xsl in=newxml xsl=inXSL out=common;
     parameter "appLocEncoded"="&appLocEncoded."
               "sastheme"="&sastheme."
               "localizationFile"="&localizationFile."           
    ;
  run;

  filename inxsl;

  /*
   *  The editItem macro may need to edit edititional information
   *  to the xml input to the specific, detailed part of the page
   *  so let the macro rebuild it as needed (and thus we don't
   *   need this assigned any longer).
   */

  filename newxml;

  /*
   *  Now generate the detailed part based on the type of item being edited
   */

  /*
   *  Start the details section
   */

  %let pagestrt=&filesDir./portlet/edit.html.start.snippet;

  filename details temp;
  %let details=%sysfunc(pathname(details));

  %editItem(out=details,rc=editItemRC);

  %put editItemRC=&editItemRC.;

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

%mend;

%setupPortalDebug(editItem);

%editPortletItem;

%cleanupPortalDebug;

