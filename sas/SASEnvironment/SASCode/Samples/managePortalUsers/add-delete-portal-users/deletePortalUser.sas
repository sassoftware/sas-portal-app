/*
 *  This program must be run as an admin user who has permissions
 *  to delete portal content areas, ie. Permission Trees, and
 *  can see those that exist.
 */

%inc "&sasDir./request_setup.sas";

/*  Set the user you want to delete */

%let portalUser=Group 4 User 1;

%deletePortalUser(name=&portalUser.,rc=deletePortalUserRC);

%put deletePortalUserRC=&deletePortalUserRC.;


