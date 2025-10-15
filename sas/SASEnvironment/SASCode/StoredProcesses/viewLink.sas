/*
 *  Display the viewer associated with the passed metadata path
 */

%let type=viewLink;

%inc "&sasDir./request_setup.sas";

%setupPortalDebug(viewLink);

/*
 *   The only required parameters to this routine are:
 *    path = the path to the object to display
 */

%viewLink(rc=viewLinkRC);

%put viewLinkRC=&viewLinkRC.;

%cleanupPortalDebug;
