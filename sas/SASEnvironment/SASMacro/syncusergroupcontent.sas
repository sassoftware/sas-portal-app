/*
 *  This macro will check to see if any new shared pages have been created that should be added for this
 *  user.  
 *
 *  Since the check to see if any were added is done on every user login, the check needs to be fast, since most
 *  of the time there will be no new pages added.
 *
 *  Parameters:
 *     name = the name of the user to process
 *     rc   = an optional parameter which is the name of a macro variable to contain the macro return code.
 *     useDT = an optional parameter which will override the value stored in the metadata when checking for new pages.  This value 
 *             is passed as a datetime string in local time. (ex. 05OCT2023:13:00:00.0).
 */
%macro syncUserGroupContent(name=,rc=,useDT=);

/*
 *  TODO: Normally, we initialize the macro return code to be -1 in case a macro syntax error is found and then
 *        a non-zero return code will get returned to the caller.  However, this code isn't finished with all
 *        of the error checking and we want this code to be as fast as possible, so for now, set the RC=0;
 */

%let _sucrc=-1;
%let _sucrc=0;


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

filename _sucpxsl "&filesDir./portal/permissionsTree/getSharedPagesLastUpdate.xslt";
filename _sucpxml "&filesDir./portal/root.xml";
filename _sucpreq temp;

proc xsl in=_sucpxml xsl=_sucpxsl out=_sucpreq;
  parameter "userName"="&name"
            ;
run;

filename _sucpxml;
filename _sucpxsl;

%showFormattedXML(_sucpreq,Get Shared Page last update query);

filename _sucprsp temp;

proc metadata in=_sucpreq out=_sucprsp;
run;

%showFormattedXML(_sucprsp,Get Shared Page last update query response);

filename _sucpreq;

/*
 *  Get the value from the property (if it exists)
 *
 *  NOTE: The metadata query was done such that at most, only 1 row should be returned.
 *
 */

 filename _sucpmap "&filesDir./portal/permissionsTree/lastUpdateCheck.map";

 libname _sucprsp xmlv2 xmlmap=_sucpmap xmlfileref=_sucprsp;

data _null_;

  set _sucprsp.LastUpdateProperty;

  /*
   *  NOTE: Have to be careful here with the timezone.  Metadata Values are stored as GMT.
   *        Java timestamps are also GMT.
   */

  /* 
   *   For backward compatibility with existing ID Portal, we store a java timestamp in the metdata for
   *   the last update check value.
   *   However, when we query metadata, we use a SAS datetime value.
   *   Calculate and save both in case they are needed in the future.
   */

  if (symget('useDT') eq '') then do;
	  startJavaDT=input(Value,19.);
	  
	  if (startJavaDT=0) then do;
	     startDT='01jan1970:00:00:00'dt;
	     end;
	  else do;
	
		  /*
		   *  Convert from Java to SAS Datetime
		   *
		   *  The difference between a java time stamp (based on 1/1/1970) and SAS datetime (1/1/1960) is 315619200 seconds
  		   *  The portal uses the java method System.currentTimeMillis to get the timestamp, thus it is a number of
		   *  milliseconds, not seconds, so we need to make sure to multiple/divide by 1000 as appropriate.
		   *  Also note, by default java time stamps are based on UTC where a sas datetime is local time, so make sure to
		   *  calculate appropriately.
		   *  
		   */
	  
	     startDT=(startJavaDT/1000)+315619200;
	     
	     end;
	  end;
  else do;
  
      startDT="&useDT."dt-tzoneoff();
      /* Make sure the java dt is in milliseconds */
      startJavaDT=(startDT-315619200)*1000;
  
      end;
  
  /*  We store the java dt as the actual numeric value as we will need to use that to update the property indicating
   *  when we last checked.
   */
  
  call symput('startJavaDT',trim(left(put(startJavaDT,19.))));
  call symput('startDT',trim(left(put(startDT,datetime23.3))));
  
  now=datetime();
  /*
   *  Make sure we use the UTC value when this is referenced in the future.
   */
  
  endDT=now-tzoneoff();
  
  call symput('endDT',trim(left(put(endDT,datetime23.3))));

  /* Make sure the java dt is in milliseconds */ 
  endJavaDT=(endDT-315619200)*1000;
  /*  Need to make sure it's formatted as a number and not in exponential notation */
 
  call symput('endJavaDT',trim(left(put(endJavaDT,19.))));

  /*
   *  Save the Property Id so we can easily update it later
   */
  
  call symput('lastUpdatePropertyId',Id);
  
run;

/*
%put startDT=&startDT.;
%put startJavaDT=&startJavaDT.;

%put endDT=&endDT.;
%put endJavaDT=&endJavaDT.;
%put Id=&lastUpdatePropertyId;
*/

libname _sucprsp;
filename _sucprsp;

/*
 *  Get the list of portal pages that this user can see created between the start and end timestamps
 */

/*
 *   If this code is going to be run at user portal visit, we need the check to be as fast as possible
 *   so we do 2 steps, even though this less efficient when we do have to update the content.
 *
 *        1) See if there are any new pages to add and
 *        2) Add them
 *        I'm going to assume that most times there won't be any pages to add so we want the check
 *        to be as fast as possible, even if it means doing some more work on #2.
 */

filename _succxml "&filesDir./portal/root.xml";
filename _succxsl "&filesDir./portal/permissionsTree/checkUserNewSharedPortalPages.xslt";

filename _succreq temp encoding='utf-8';

/*
 *  NOTE: Metadata server wants convert timestamps that you pass to it as strings to UTC, thus be careful 
 *        about the values passed here.
 */

proc xsl in=_succxml xsl=_succxsl out=_succreq;
  parameter "startDT"="&startdt."
            "endDT"="&endDT."
            ;
run;

%showFormattedXML(_succreq,Check New Portal Pages query);

filename _succxml;
filename _succxsl;

filename _succrsp temp  encoding='utf-8';

proc metadata in=_succreq out=_succrsp;
run;

%showFormattedXML(_succrsp,Check new Portal Pages query response);

filename _succreq;

/*
 *  See if there are any pages to add
 */

filename _succmap "&filesDir./portal/permissionsTree/readNewPageList.map";

libname _succrsp xmlv2 xmlmap=_succmap xmlfileref=_succrsp;

proc sql noprint;
  select count(*) into :numNewPages
  from _succrsp.newpages;
run;
quit;

libname _succrsp;
filename _succmap;

filename _succrsp;

%if (&numNewPages.>0) %then %do;

    %put Found %trim(&numNewPages.) new shared pages to add for this user.;
    
	/*
	 *   Get the metadata needed to build the add/update request.
	 */
	
	filename _sucrreq "&filesDir./portal/getRepositories.xml";
	filename _sucrrsp temp;
	
	proc metadata in=_sucrreq out=_sucrrsp;
	run;
	
	%showFormattedXML(_sucrrsp,Get Repository list);
	
	filename _sucrreq;
	
	filename _sucgxsl "&filesDir./portal/permissionsTree/getUserSharedPortalPagesReferences.xslt";
	
	filename _sucgreq temp encoding='utf-8';
	
	/*
	 *  NOTE: Metadata server wants timestamps in text format, so make sure to pass the correct macro variables.
	 */
	
	%let reposname=%sysfunc(getoption(METAREPOSITORY));
	%let treename=&name. Permissions Tree;
	proc xsl in=_sucrrsp xsl=_sucgxsl out=_sucgreq;
	  parameter "startDT"="&startdt."
	            "endDT"="&endDT."
	            "reposName"="&reposname."
	            "treeName"="&treeName."
	            ;
	run;
	
	%showFormattedXML(_sucgreq,New Portal Pages query);
	
	filename _sucrrsp;
	filename _sucgxsl;
	
	filename _sucgrsp temp  encoding='utf-8';
	
	proc metadata in=_sucgreq out=_sucgrsp;
	run;
	
	%showFormattedXML(_sucgrsp,New Portal Pages query response);
	
	filename _sucgreq;
	
	/*
	 * Generate the add request now to sync the users list of portal pages with the newly found portal pages
	 */
	
	filename _sucareq temp;
	filename _sucaxsl "&filesDir./portal/permissionsTree/createUserSharedPortalPages.xslt";
	
	proc xsl in=_sucgrsp xsl=_sucaxsl out=_sucareq;
	run;
	
	%showFormattedXML(_sucareq,Update Metadata request to sync shared pages);
	
	filename _sucgrsp;
	filename _sucaxsl;
	
	/*
	 *  Now add the shared pages for this user.
	 */
	
	filename _sucarsp temp;

	proc metadata in=_sucareq out=_sucarsp;
	run;

	%showFormattedXML(_sucarsp,Update Metadata response to sync shared pages);
	
	filename _sucareq;
	filename _sucarsp;

    %end;
    
/*
 *  Update the last checked timestamp
 */

%updateSharedLastTimestamp(timestampId=&lastUpdatePropertyId.,timestamp=&endJavaDT.);

%if ("&rc" ne "") %then %do;
 
    %global &rc.;
    
    %let &rc.=&_sucrc.;
    
    %end;
%mend;
