/*
 *  Search for items that match the passed criteria
 */

%let type=sasnavigator;

%inc "&sasDir./request_setup.sas";

%setupPortalDebug(spametadatabrowser);

/*
 *   The only required parameters to this routine are:
 *    path = where to start showing the content tree
 *    objectFilter = the filter to apply to returned members
 */

%navigator(rc=navigatorRC);

%put navigatorRC=&navigatorRC.;

%cleanupPortalDebug;
