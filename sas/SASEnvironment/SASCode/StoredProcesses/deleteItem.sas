/*  Save the changes made to an Item Remove page */

%inc "&sasDir./request_setup.sas";

/*
 *   The parameters being passed to this routine will be dependent on the
 *   type of item being deleted.
 *   The only required parameters are:
 *    type = the type of object
 *    id   = the id of the object to delete
 */

%setupPortalDebug(deleteItem);

%deleteItem(rc=deleteItemRC);

%put deleteItemRC=&deleteItemRC.;

/*
 *  Send back to the browser to go back
 */
%if (&deleteItemRC.=0) %then %do;

    data _null_;
      file _webout;
      put "<script>history.go(-2);</script>";
    run;
%end;

%cleanupPortalDebug;

