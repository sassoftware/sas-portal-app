/*
 *  This sample shows how one can write a file to a directory
 *  that requests the admin to create the user's Portal Content Area (ie. permissions tree).
 *
 *  The intent is that the files in this directory will then be post processed
 *  either through a batch job that runs on a normal schedule, or to use system
 *  capabilities to trigger a sas job to run when the file is created.
 *
 *  Note that in this case, the _cptTreeExists macro variable should not be changed
 *  from the value at call this program (ie. 0), but this code can change the
 *  message being returned to the user interface, by setting the _cptErrorMessage
 *  macro variable.
 *
 */
  
%macro myCreatePortalUserFile(id=,user=);

filename userfile "&requestDirectory./&id..txt" encoding="utf-8";

data _null_;
  file userfile;
  length line $256;
  line=trim(left("&user."));
  put line;
run;

filename userfile;

%let _cptTreeErrorMessage=Your request has been registered, please try again later.;

%mend;

%let requestDirectory=Data/user-registry-requests;

/*  Set the user you want to create */

%let portalUser=&_metaPerson.;
%let portalUserId=&_metaUser.;

%myCreatePortalUserFile(id=&portalUserId.,user=&portalUser.);

