/*
 *  This program must be run as an admin user who has permissions
 *  to create group portal content areas, ie. Permission Trees, and
 *  can see those that exist.
 */

%inc "&sasDir./request_setup.sas";

/*  Set the group you want to create */

%let portalGroup=Group 4;

%createPortalGroup(name=&portalGroup.,rc=createPortalGroupRC);

%put createPortalGroupRC=&createPortalGroupRC.;


