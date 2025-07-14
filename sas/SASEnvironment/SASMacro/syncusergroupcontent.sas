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

/*****************************************************
 * Macro: syncUserGroupContent
 *
 * Main entry point and the macro that is called from outside this file.
 *
 *****************************************************/

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

  
  %getLastSharingInfo(rc=_sucInternalRC,useDT=&useDT.);
  %put NOTE: getLastSharingInfo rc=&_sucInternalRC.;
  
  %put DEBUG: Show timestamps retrieved.;
  %put startDT=&startDT.;
  data _null_;
     length timestamp 8;
     timestamp=&nowSASTimestamp.;
     put "nowDT=&nowDT.";
     
     if symexist('nextFullCheckSASTimestamp') then do;
        timestamp=symget('nextFullCheckSASTimestamp');
        put "nextFullCheckSASTimestamp=" timestamp 14.3;
        put "nextFullCheckSASTimestamp=" timestamp datetime26.3;
        end;
        
  run;
  %put DEBUG: End Show timestamps retrieved.;
  
     
  %if (&_sucInternalRC. = 0) %then %do;
  
	  %if ( &fullUpdateCheckInterval.>-1) %then %do;
%put DEBUG: fullUpdateCheckInterval>1.;
%put DEBUG: nowSASTimestamp=&nowSASTimestamp., nextFullCheckSASTimestamp=&nextFullCheckSASTimestamp.;

		  %if (%sysevalf(&nowSASTimestamp.>&nextFullCheckSASTimestamp.)) %then %do;

%put DEBUG: now>time for full check: nowSASTimestamp=&nowSASTimestamp., nextFullCheckSASTimestamp=&nextFullCheckSASTimestamp.;
		  
		     %let fullUpdateCheckNeeded=1;
		     %end;
		  %else %do;

%put DEBUG: 	fullUpdateCheckNeeded=0;

	         %let fullUpdateCheckNeeded=0;
		  
		     %end;
		     
	      %end;
	  %else %do;
	
	      /* Admin has asked not to do full checks */

%put DEBUG: 	fullUpdateCheckInterval <= -1;
	     
	      %let fullUpdateCheckNeeded=0;
	  
	      %end;

%put fullUpdateCheckNeeded=&fullUpdateCheckNeeded.;
	
	  %if (&fullUpdateCheckNeeded.=1) %then %do;
	   
	      /*
	       *  We can force a full update check simply by clearing the start datetime for the metadata query
	       *  which will return all pages that have ever been created.  Unfortunately, there is no other
	       *  way to find the case where a user was added to an existing group that had existing pages (those
	       *  pages could have been created at any point).
	       *
	       *  TODO:  What is the performance impact of doing no start date and an end date when doing a metadata
	       *         query vs. doing a query with no dates?
	       */
	      
	    %let startDT=;
	    %end;
	
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
		
	/*
	 *  If we got here and no dates have been set, then don't pass them to the stylesheet so they won't be included on
	 *  the query.
	 */
%put Before New Page Query: startdt=&startdt., nowDT=&nowDT.;
		
	proc xsl in=_succxml xsl=_succxsl out=_succreq;
	    %if (("&startdt." ne "") or ("&nowdt." ne "")) %then %do;
	
	        parameter 
	        %if ("&startdt." ne "") %then %do;
	            "startDT"="&startdt."
	            %end;
	        %if ("&nowDT." ne "") %then %do;
	            "endDT"="&nowDT."
	            %end;
	            ;
	        %end;
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
			
	        %let reposname=%sysfunc(dequote(%sysfunc(getoption(METAREPOSITORY))));
		%let treename=&name. Permissions Tree;
		proc xsl in=_sucrrsp xsl=_sucgxsl out=_sucgreq;
			  parameter 
	                  %if ("&startdt." ne "") %then %do;
	                      "startDT"="&startdt."
	                      %end;
	                  %if ("&nowDT." ne "") %then %do;
	                      "endDT"="&nowDT."
	                      %end;
                          /*
                           *  Only retrieve the full history if we are doing a "full check" to try to keep the normal "fast check"
                           *  as fast as possible.
                           */
                          %if (&fullUpdateCheckNeeded.=1) %then %do;

                              "retrieveFullHistory"="1"

                              %end;
		
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
%put Generating add request for new pages;			
		filename _sucareq temp;
		filename _sucaxsl "&filesDir./portal/permissionsTree/createUserSharedPortalPages.xslt";
			
		proc xsl in=_sucgrsp xsl=_sucaxsl out=_sucareq;
		   %if (&fullUpdateCheckNeeded.=1) %then %do;
		       parameter "forceDefaultPageAdd"="0";
		       %end;
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
			
	%updateSharedLastTimestamp(timestampId=&lastUpdatePropertyId.,timestamp=&nowJavaTimestamp.);
	
	/*
	 *  If we are performing a full check, update that timestamp property also.
	 */

    %if (&fullUpdateCheckNeeded.=1) %then %do;
%put DEBUG: after add new pages, fullUpdateCheckNeeded=&fullUpdateCheckNeeded.;	   
		%if ("&lastFullUpdatePropertyId." ne "") %then %do;
%put DEBUG: after add new pages, lastFullUpdatePropertyId=&lastFullUpdatePropertyId.;	   

    		%updateSharedLastTimestamp(timestampId=&lastFullUpdatePropertyId.,timestamp=&nowJavaTimestamp.);
		
	        %end;
	    %end;
	   
    %end;
    %else %do;
    
       %let _sucrc=&_sucInternalRC.;
       
       %end;
       
    %symdel _sucInternalRC / nowarn;

%if ("&rc" ne "") %then %do;
 
    %global &rc.;
    
    %let &rc.=&_sucrc.;
    
    %end;
%mend;

/*
 *  Supporting macros
 */

/*****************************************************
 * Macro: setupSharingPropertyQuery
 *
 * Internal Macro for executing common setup code to query the shared timestamp properties
 *
 *****************************************************/
%macro setupSharingPropertyQuery;

filename _sucpxsl "&filesDir./portal/permissionsTree/getSharedPagesLastUpdate.xslt";
filename _sucpxml "&filesDir./portal/root.xml";
filename _sucpreq temp;

proc xsl in=_sucpxml xsl=_sucpxsl out=_sucpreq;
  parameter "userName"="&name"
            ;
run;

%showFormattedXML(_sucpreq,Get Shared Page last update query);

%mend;

/*****************************************************
 * Macro: cleanupSharingPropertyQuery
 *
 * Internal Macro for executing common cleanup code to query the shared timestamp properties
 *
 *****************************************************/

%macro cleanupSharingPropertyQuery;

    %if (%sysfunc(fileref(_sucpxsl)) < 1) %then %do;
	    filename _sucpxsl;
	    %end;
    %if (%sysfunc(fileref(_sucpxml)) < 1) %then %do;
    	filename _sucpxml; 
	    %end;
	
%mend;

/*****************************************************
 * Macro: setupSharingPropertyData
 *
 * Internal Macro for executing common setup code to query the shared timestamp properties data
 *
 *****************************************************/

%macro setupSharingPropertyData;

	filename _sucpmap "&filesDir./portal/permissionsTree/lastUpdateCheck.map";
	libname _sucprsp xmlv2 xmlmap=_sucpmap xmlfileref=_sucprsp;
 
%mend;

/*****************************************************
 * Macro: cleanupSharingPropertyData
 *
 * Internal Macro for executing common cleanup code to query the shared timestamp properties data
 *
 *****************************************************/

%macro cleanupSharingPropertyData(cleanupResponse=1);

   %if (%sysfunc(libref(_sucprsp))=0) %then %do;
   
      libname _sucprsp;
      %end;
      
   %if (%sysfunc(fileref(_sucpmap)) < 1) %then %do;
      filename _sucpmap;
      %end;
      
   %if (&cleanupResponse.=1) %then %do;
       %if (%sysfunc(fileref(_sucprsp)) < 1) %then %do;
          filename _sucprsp;
          %end;
          
       %end;
   
%mend;

/*****************************************************
 * Macro: getSharingProperties
 *
 * Internal Macro for getting the sharing timestamp properties values
 *
 *****************************************************/

%macro getSharingProperties(rc=);

/* 
 *  There is a property that the previous ID Portal stored on the user's portal profile, Portal.LastSharingCheck, that indicates the
 *  last time that we have checked for new shared pages.  The value is stored as a java timestamp, so we have
 *  to convert it back and forth so that we can query metadata with it.
 *  Note that if the value is 0, then the check has never been done for this user and we need to sync
 *  all the shared pages.
 *
 *  sas-portal-app has added an additional property, Portal.LastFullSharingCheck, that indicates the last time a "full" sharing check was
 *  performed.  We are going to use the same format, ie. a java timestamp, to be consistent with the existing Portal.LastSharingCheck.
 *
 *
 *  There are 2 different processes that run to check for shared pages:
 *
 *   1) Just check for new pages that have been shared since the last time the user has checked (the Portal.LastSharingCheck timestamp).  
 *      This check is very quick and thus is referred to below as the "fast path".
 *   2) Check all pages that are currently visible to the user and see if they should be added to the user's portal.  This scenario can happen
 *      only when a user is added to a group and that group has existing pages (that existed before the Portal.LastSharingCheck value).  
 *      Since this check is expensive and one wouldn't expect the group changes to happen very often, we are going to refer to this as a "full check"
 *      and not do to do it very often (the duration between checks is specified in the fullUpdateCheckInterval macro variable).  The downside is that when a user is added to a group, there may be a timelag before those new pages show up
 *      in the user's portal.  The upside is that the normal logon process response times are not impacted on every logon.
 *
 *  NOTE: It doesn't look like that property is protected via permissions, so we need to be careful to get the
 *  correct property with that name.
 */



	/*
	 *  If either of the the property Ids are not set, then we need to create the profile information first, 
	 *  then set the values.  We want to do this so subsequent runs through this code for the same
	 *  user is not so expensive.  After we add it, repeat getting the information so the property id values are set for the
	 *  rest of this process.
	 */
	
%let numSharingProperties=0;

%let maxLoops=5;
%let currentLoop=1;
%let _gspRC=0;

%do %while (&numSharingProperties.<2 and &currentLoop.<=&maxLoops.);

%put NOTE: Executing loop iteration: &currentLoop.;

    /*
     * Get the sharing timestamps from the user's profile area
     */
    
	filename _sucprsp temp;
	
	proc metadata in=_sucpreq out=_sucprsp;
	run;
	
	%showFormattedXML(_sucprsp,Get Shared Page last update query response);
	
	/*
	 *  Get the value from the property (if it exists)
	 *
	 *  NOTE: The metadata query was done such that at most, only 2 rows should be returned (1 for the last (fast path) check and 1 for the
     *        last full check.
     */
	
	%setupSharingPropertyData;
	
    proc sql noprint;
    
       select count(*) into :numSharingProperties
       from _sucprsp.LastUpdateProperty;
    run;
    quit;

%put NOTE: Number of Sharing Properties found: &numSharingProperties.;

    /*  If we don't find any sharing properties, then we need to create the user profile */
    
    %if (&numSharingProperties.=0) %then %do;
%put NOTE: Not enough sharing properties, creating user profile now.;
	
	    %createUserProfile(name=&name.);

	    /*  Clean up existing references so we don't get stale data next time through */
	
	    %cleanupSharingPropertyData;
	        
     %end;
     %else %if (&numSharingProperties.=1) %then %do;
     
         /*  Try to determine which property is missing, most likely it is the full sharing property */
 
 		  /*
		   *  Both of the timestamp properties are in the same profile "group", called the portal profile area.
		   *  Since we are here, we know there is at least one of the timestamp properties defined.
		   *  Just in case both don't exist, save the id of this profile group object, so if we need
		   *  to add one of the properties, we have the information we need to do so.
		   *  In the case, where neither exist, then the whole profile area doesn't exist and that is the
		   *  numSharingProperties=0 code path above.
		   */
		  
         proc sql noprint;
           select PortalProfileId into :portalProfileId
           from _sucprsp.LastUpdateProperty(obs=1);
           
           select count(*) into :hasSharingTimestamp
           from _sucprsp.LastUpdateProperty
           where name='Portal.LastSharingCheck';
         run;
         quit;
         
         %if (&hasSharingTimestamp.) %then %do;
         
             /* Since the Full check was added recently, then it's property may not exist yet, so create it now. */
         
             %createFullSharingProperty(name=&name.);
             
             %end;
        %else %do;
             %createSharingProperty(name=&name.);
             %end;

	    /*  Clean up existing references so we don't get stale data next time through */
	
	    %cleanupSharingPropertyData;
	    
        %end;

   %let currentLoop=%eval(&currentLoop.+1);

   %put NOTE: CurrentLoop counter=&currentLoop.;
   
   %end;

   %if (&currentLoop.>&maxLoops.) %then %do;
   
       %put ERROR: User profile sharing properties not updated properly;
       %let _gspRC=100;
       %end;

%if ("&rc" ne "") %then %do;
 
    %global &rc.;
    
    %let &rc.=&_gspRC.;
    
    %end;

%symdel _gspRC / nowarn;
       
%mend;

/*****************************************************
 * Macro: getSharingProperties
 *
 * Internal Macro for getting, processing and publishing the sharing timestamp properties values
 *
 *****************************************************/

%macro getLastSharingInfo(rc=,useDT=);

  %setupSharingPropertyQuery;
  
  %getSharingProperties(rc=_glsiRC);
  
  %put getSharingProperties rc=&_glsiRC;
  
  %cleanupSharingPropertyQuery;

  %if (&_glsiRC.=0) %then %do;
	  
	  /*
	   *   Timestamp formats
	   *
	   *   For backward compatibility with existing ID Portal, we store a java timestamp in the metdata for
	   *   the last update check value.
	   *   However, when we query metadata, we use a SAS datetime value.
	   *   Calculate and save both in case they are needed in the future.
	   *
	   *  NOTE: Have to be careful here with the timezone.  Metadata Values are stored as GMT.
	   *        Java timestamps are also GMT.
	   *
	   *  Converting from Java to SAS Datetime
	   *
	   *  The difference between a java time stamp (based on 1/1/1970) and SAS datetime (1/1/1960) is 315619200 seconds
	   *  The portal uses the java method System.currentTimeMillis to get the timestamp, thus it is a number of
	   *  milliseconds, not seconds, so we need to make sure to multiple/divide by 1000 as appropriate.
	   *  Also note, by default java time stamps are based on UTC where a sas datetime is local time, so make sure to
	   *  calculate appropriately.
	   *  
	   */
	
	/*
	 *		    See if the user has specified a fullUpdateCheckInterval.
	 *		    This value is either:
	 *		       <0  = never do a full update check (user must manually check for group updates)
	 *		        0  = always do a full update check
	 *		        n  = the number of minutes between full update checks (default is 12 hours=720 minutes)
	 */
	%if (%symexist(fullUpdateCheckDefaultInterval)=0) %then %do;
	    %let fullUpdateCheckDefaultInterval=720;

            %end;
 
	%if (%symexist(fullUpdateCheckInterval)=0) %then %do;
	
	    %global fullUpdateCheckInterval;
	    
	    %let fullUpdateCheckInterval=&fullUpdateCheckDefaultInterval.;
	    
	    %end;

	%else %if ("&fullUpdateCheckInterval."="") %then %do;
	
	    %let fullUpdateCheckInterval=&fullUpdateCheckDefaultInterval.;
	    
	    %end;
	
	/*
	 *  Output values selected from timestamp queries 
	 */
	
	%global fullUpdateCheckNeeded;
	%let fullUpdateCheckNeeded=0;
	%global lastFullUpdatePropertyId;
	%let lastFullUpdatePropertyId=;
	
	%global lastUpdatePropertyId;
	%let lastUpdatePropertyId=;
	
	%global portalProfileId;
	%let portalProfileId=;
	
	%global startDT;
	%let startDT=0;
	
	%global nowSASTimestamp nowDT nowJavaTimestamp;
	%global nextFullCheckSASTimestamp;

	/*
	 *  Pull the timestamp information out of the stored timestamps and format them into the needed values and formats.
	 */
	data _null_;
	
	  set _sucprsp.LastUpdateProperty;
	
	  if (_n_=1) then do;
	  
	      now=datetime();
	      
		  /*
		   *  Make sure we use the UTC value when this is referenced in the future.
		   */
		
		  nowSASTimestamp=now-tzoneoff();
		  retain nowSASTimestamp;
		  
		  call symputx('nowSASTimestamp',put(nowSASTimestamp,14.3),'G');
		  
		  call symputx('nowDT',put(nowSASTimestamp,datetime26.3),'G');
		
		  /* Make sure the java dt is in milliseconds */
		  nowJavaTimestamp=(nowSASTimestamp-315619200)*1000;
		  
		  /*  Need to make sure it's formatted as a number and not in exponential notation */
			
		  call symputx('nowJavaTimestamp',put(nowJavaTimestamp,19.),'G');
		  	      
	      end;
	      
	  if (name='Portal.LastSharingCheck') then do;
	
	      /*
	       *  Sometimes its helpful to use a different datetime for comparison to see if we should check for updates.
	       *  Allow the useDT macro variable to be set to a SAS datetime formatted string to use instead of the currently stored time.
	       *  Note that useDT is passed in local time!
	       */
	      
		  if (symget('useDT') eq '') then do;
	  
	         startJavaTimestamp=input(Value,19.);
	         
	         end;
		  else do;
	
	         /*  Use the passed value as the start timestamp */
	
	         startDT="&useDT."dt-tzoneoff();
	         /* Make sure the java dt is in milliseconds */
	         startJavaDT=(startDT-315619200)*1000;
	  
		     end;
		     
		  if (startJavaTimestamp=0) then do;
		     startSASTimestamp='01jan1970:00:00:00'dt;
		     end;
		  else do;
			
		     startSASTimestamp=(startJavaTimestamp/1000)+315619200;
			     
		     end;
		  
		  /*  We store the java dt as the actual numeric value as we will need to use that to update the property indicating
		   *  when we last checked.
		   */
		  
		  call symputx('startJavaTimestamp',put(startJavaTimestamp,19.),'G');
		  call symputx('startDT',put(startSASTimestamp,datetime26.3),'G');
				  
		  /*
		   *  Save the Property Id so we can easily update it later
		   */
		  
		  call symputx('lastUpdatePropertyId',Id,'G');
	  
	      end;
	      
	  /* If the admin has specified to not ever do full updates, don't calculate the timestamp (ie. leave it as it's default value (blank)) */
	
	  %if (&fullUpdateCheckInterval.>-1) %then %do;
	
		  else if (name='Portal.LastFullSharingCheck') then do;
		
		      /*
		       *  Sometimes its helpful to use a different datetime for comparison to see if we should check for updates.
		       *  Allow the useDT macro variable to be set to a SAS datetime formatted string to use instead of the currently stored time.
		       *  Note that useDT is passed in local time!
		       */
		      
			  if (symget('useDT') eq '') then do;
	
				  /*  Value stored as a java datetime value */
				 
				  lastFullCheckJavaTimestamp=input(Value,19.);
				  end;
			  else do;
	              /*  Use the passed value as the start timestamp */
	
		         tempFullSASTimestamp="&useDT."dt-tzoneoff();
		         /* Make sure the java dt is in milliseconds */
		         lastFullCheckJavaTimestamp=(tempFullSASTimestamp-315619200)*1000;
	  
	     	     end;	
			  if (lastFullCheckJavaTimestamp=0) then do;
			     lastFullCheckJavaTimestamp='01jan1970:00:00:00'dt;
			     end;
				     		     
			  /*  Convert to a SAS datetime value */
			 
			  lastFullSASTimestamp=(lastFullCheckJavaTimestamp/1000)+315619200;
put "lastFullSASTimestamp=" lastFullSASTimestamp datetime26.3;	
			  updateCheckIntervalSeconds=&fullUpdateCheckInterval.*60;
			  nextFullCheckSASTimestamp=lastFullSASTimestamp+updateCheckIntervalSeconds;
put "nextFullCheckSASTimestamp=" nextFullCheckSASTimestamp 14.3;	
put "nextFullCheckSASTimestamp=" nextFullCheckSASTimestamp datetime26.3;	
	
	     	  /*  We store the sas dt as the actual numeric value so we can easily compare it later
		       */
		  
		      *call symputx('nextFullCheckSASTimestamp',put(nextFullCheckSASTimestamp,14.3),'G');
		      call symputx('nextFullCheckSASTimestamp',nextFullCheckSASTimestamp,'G');
	
			  /*
			   *  Save the Property Id so we can easily update it later
			   */
			  
			  call symputx('lastFullUpdatePropertyId',Id,'G');
		
		      end;
	
	      %end;
	      
	  run;

    %end;

%put nowSASTimestamp=&nowSASTimestamp.;

%put nowSASTimestamp=%sysfunc(putn(&nowSASTimestamp.,14.3));
%put nowSASTimestamp=%sysfunc(putn(&nowSASTimestamp.,17.6));

%cleanupSharingPropertyData;

%if ("&rc" ne "") %then %do;
 
    %global &rc.;
    
    %let &rc.=&_glsiRC.;
    
    %end;
    
%symdel _glsiRC / nowarn;

%mend;

/*****************************************************
 * Macro: createFullSharingProperty
 *
 * Internal Macro for creating the sharing timestamp property that saves the information about full sharing check
 *
 *****************************************************/

%macro createFullSharingProperty(name=);

%put NOTE: in createFullSharingProperty routine., portal profile id=&portalProfileId.;

   %createProfileProperty(groupId=&portalProfileId.,name=Portal.LastFullSharingCheck,value=0);
   
%mend;

/*****************************************************
 * Macro: createSharingProperty
 *
 * Internal Macro for creating the sharing timestamp property that saves the information about "fast path" sharing check
 *
 *****************************************************/

%macro createSharingProperty(name=);

%put NOTE: in createSharingProperty routine., portal profile id=&portalProfileId.;

   %createProfileProperty(groupId=&portalProfileId.,name=Portal.LastSharingCheck,value=0);

%mend;
