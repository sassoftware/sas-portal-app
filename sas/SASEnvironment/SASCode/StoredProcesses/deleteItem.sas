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

%setResponse(&deleteItemRC.);

%cleanupPortalDebug;

