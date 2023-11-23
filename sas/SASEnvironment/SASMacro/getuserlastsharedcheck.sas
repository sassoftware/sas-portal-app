/*
 *  This macro will retrieve the last shared check property and value for the passed user.
 *
 *  Parameters:
 *     name = the name of the user to process
 *     timestampId = the macro variable which should contain the id of the timestamp object upon return.
 *     timestamp = the macro variable which should contain the value retrieved as the last timestamp (java millisecond format)
 *     rc   = an optional parameter which is the name of a macro variable to contain the macro return code.
 */

%macro getUserLastSharedCheck(name=,rc=,timestampId=,timestamp=);

/*
 *  TODO: Normally, we initialize the macro return code to be -1 in case a macro syntax error is found and then
 *        a non-zero return code will get returned to the caller.  However, this code isn't finished with all
 *        of the error checking and we want this code to be as fast as possible, so for now, set the RC=0;
 */

%let _gulrc=-1;
%let _gulrc=0;


/*
 *  NOTE: This code must be run as the user who's portal information is being checked!
 *        It relies on metadata server authorization rules such that query results are limited
 *        to just the objects that this user can see.  If this is not true, portal pages might be added
 *        to the user's portal tree that the user does not have permissions (and might be given permissions
 *        as part of this process)
 */

/* 
 *  There is a property stored on the user's portal profile, Portal.LastSharingCheck, that indicates the
 *  last time that we have checked for new shared pages.  The value is stored as a java timestamp, so we have
 *  to convert it back and forth so that we can query metadata with it.
 *  Note that if the value is 0, then the check has never been done for this user and we need to sync
 *  all the shared pages.
 *
 *  NOTE: It doesn't look like that property is protected via permissions, so we need to be careful to get the
 *  correct property with that name.
 */

filename _gulpxsl "&filesDir./portal/permissionsTree/getSharedPagesLastUpdate.xslt";
filename _gulpxml "&filesDir./portal/root.xml";
filename _gulpreq temp;

proc xsl in=_gulpxml xsl=_gulpxsl out=_gulpreq;
  parameter "userName"="&name"
            ;
run;

filename _gulpxml;
filename _gulpxsl;

%showFormattedXML(_gulpreq,Get Shared Page last update query);

filename _gulprsp temp;

proc metadata in=_gulpreq out=_gulprsp;
run;

%showFormattedXML(_gulprsp,Get Shared Page last update query response);

filename _gulpreq;

/*
 *  Get the value from the property (if it exists)
 *
 *  NOTE: The metadata query was done such that at most, only 1 row should be returned.
 *
 */

 filename _gulpmap "&filesDir./portal/permissionsTree/lastUpdateCheck.map";

 libname _gulprsp xmlv2 xmlmap=_gulpmap xmlfileref=_gulprsp;

data _null_;

  set _gulprsp.LastUpdateProperty;

  startJavaDT=input(Value,19.);
  
  call symputx("&timestamp.",trim(left(put(startJavaDT,19.))),'G');
 
  /*
   *  Save the Property Id so we can easily update it later
   */

  call symputx("&timestampId.",Id,'G');
  
run;

%let _gulrc=0;

%put &timestampId=&&&timestampId.;
%put &timestamp.=&&&timestamp.;

libname _gulprsp;
filename _gulprsp;

filename _gulpmap;

%if ("&rc" ne "") %then %do;
 
    %global &rc.;
    
    %let &rc.=&_gulrc.;
    
    %end;
%mend;
