/*
 *  Search for items that match the passed criteria
 */

%inc "&sasDir./request_setup.sas";

%setupPortalDebug(search);

/*
 *   The only required parameter to this routine is:
 *    query = the terms to search for
 */

%searchQuery(rc=searchQueryRC);

%put searchQueryRC=&searchQueryRC.;

%cleanupPortalDebug;
