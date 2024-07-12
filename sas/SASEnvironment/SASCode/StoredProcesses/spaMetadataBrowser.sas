/*
 *  Search for items that match the passed criteria
 */

%let type=sasnavigator;

%inc "&sasDir./request_setup.sas";

/*
 *  It is expected that a single user might have multiple instances of the SAS Navigator in their Portal.
 *  Thus, just using the name of this stored process as the identifier of the session won't be unique and
 *  will cause every one other than one to fail with a lock failure on the log (if portaldebug is turned on).
 *  Thus, we have to create a more unique identifier to use.
 */
%setupPortalDebug(spametadatabrowser,unique=y);

/*
 *   The only required parameters to this routine are:
 *    path = where to start showing the content tree
 *    objectFilter = the filter to apply to returned members
 */

%navigator(rc=navigatorRC);

%put navigatorRC=&navigatorRC.;

%cleanupPortalDebug;
