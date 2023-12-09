options metauser="admin user" metapass="admin pw";

%inc "&sasDir./request_setup.sas";

/*  Set the group you want to delete */

%let portalGroup=Group 4;

%deletePortalGroup(name=&portalGroup.,rc=deletePortalGroupRC);

%put deletePortalGroupRC=&deletePortalGroupRC.;


