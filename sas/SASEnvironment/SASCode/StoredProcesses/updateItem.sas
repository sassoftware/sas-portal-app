/*  Save the changes made to an Item page */

%inc "&sasDir./request_setup.sas";

/*
 *   The parameters being passed to this routine will be dependent on the
 *   type of item being saved.
 *   The only required parameters are:
 *    id = the object id
 *    type = the type of object
 */

%setupPortalDebug(updateItem);

%updateItem(rc=updateItemRC);

%put updateItemRC=&updateItemRC.;

%setResponse(&updateItemRC.);

%cleanupPortalDebug;
