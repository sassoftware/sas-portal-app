/*
 *  Search for items that match the passed criteria
 */

%inc "&sasDir./request_setup.sas";

%setupPortalDebug(spalinksearch);

/*
 *   The only required parameters to this routine are:
 *    objectPath = full metadata path to object to show
 */

%openlink(rc=linksearchRC);

%put linksearchRC=&linksearchRC.;

%cleanupPortalDebug;

