/*  Generate the Remove Item page */

/*
 *   For each item that is to be removed there should be a specific generator (which generates
 *   the page content specific to this type).  If it's not found, then this item type
 *   is not supported to be removed.
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

%macro removePortletItem;

  /*
   *   For each item that is to be removed there should be a specific generator (which generates
   *   the page content specific to this type).  If it's not found, then this item type
   *   is not supported to be removed.
   */

  %let removeItemGenerator=;

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

  filename inxsl "&filesDir./portlet/remove.html.gen.xslt";

  proc xsl in=newxml xsl=inXSL out=common;
     parameter "appLocEncoded"="&appLocEncoded."
               "sastheme"="&sastheme."
               "localizationFile"="&localizationFile."           
    ;
  run;

  filename inxsl;

  filename newxml;

  /*
   *  Now generate the detailed part based on the type of item being removed
   */

  /*
   *  Start the details section
   */

  %let pagestrt=&filesDir./portlet/remove.html.start.snippet;

  filename details temp;
  %let details=%sysfunc(pathname(details));

  /*
   *  We aren't going to reuse the input newxml and just
   *  let it get regenerated because the request may have a
   *  "getter" and we would need to merge anyway.
   */

  %removeItem(out=details,rc=removeItemRC);

  %put removeItemRC=&removeItemRC.;

  /*
   *  End the details section
   */

  %let pageend=&filesDir./portlet/remove.html.end.snippet;

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

%setupPortalDebug(removeItem);

%removePortletItem;

%cleanupPortalDebug;

