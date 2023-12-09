options metauser="admin user" metapass="admin pw";

%inc "&sasDir./request_setup.sas";

/*  Set the group you want to create */

%let portalGroup=Group 4;

%createPortalGroup(name=&portalGroup.,rc=createPortalGroupRC);

%put createPortalGroupRC=&createPortalGroupRC.;


