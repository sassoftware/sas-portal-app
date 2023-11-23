/*
 *  The timestampFormat has the following possible values:
 *    javamillis = the format of the value that will be stored (most efficient)
 *    sasdt = a sas datetime value (numeric)
 *    sasdtFormat = a sas datetime value in string format, ie. ddmmmyyyy:hh:mm:ss.xxx, in local time
 *    sasdtFormatUTC = a sas datetime value in string format, ie. ddmmmyyyy:hh:mm:ss.xxx, in UTC
 *
 *  The dryrun parameter allows you to see what values would be set, but doesn't set them.
 */

%macro updateUserSharedLastTimestamp(user=,timestamp=,timestampFormat=javamillis,rc=,dryrun=0);

%let _uuslrc=-1;

%if ("&user." = "") %then %do;
      %put ERROR: user to update timestamp for must be passed;
      
    %end;
    
%else %do;

    /*
     * Get the id of the timestamp to update.
     */

   %getUserLastSharedCheck(name=&user.,timestampId=_uuslId,timestamp=_uuslOldTimestamp);

   /*
    *  Convert the passed timestamp to the correct format
    */
   
   %let passedFormatString=%trim(%left(%lowcase(&timestampFormat.)));
   
   %if ("&passedFormatString"="sasdtformat" or "&passedFormatString"="sasdtformatutc") %then %do;
   
       data _null_;
       
         %if ("&passedFormatString"="sasdtformat") %then %do;
              useTimestamp=("&timestamp."dt+tzoneoff()-315619200)*1000; 
              %end;
         %else %do;
              useTimestamp=("&timestamp."dt-315619200)*1000; 
              %end;
         call symputx("_uuslTimestamp",trim(left(put(useTimestamp,19.))),'L');
         
         run;
         
       %end;

  %else %if ("&passedFormatString."="sasdt" or "&passedFormatString."="sasdtutc") %then %do;

         data _null_;
  
         %if ("&passedFormatString."="sasdt") %then %do;
         
            useTimestamp=(&timestamp.+tzoneoff()-315619200)*1000;
            %end;
         %else %do;
            useTimestamp=(&timestamp.-315619200)*1000;
            %end;

            call symputx("_uuslTimestamp",trim(left(put(useTimestamp,19.))),'L');
            
            run;
            
       %end;
  %else %do;
       
      %let _uuslTimestamp=&timestamp.;
      
      %end;
   
   /*
    *  The passed timestamp value must be in a java milliseconds format!
    */
   %if (&dryrun. = 0) %then %do;
   
       %updateSharedLastTimestamp(timestampId=&_uuslId.,timestamp=&_uuslTimestamp.);
       
       %end;
   
   %else %do;
	   %put timestampId=&_uuslId.;
	   %put timestamp=&_uuslTimestamp.;
	
	   data _null_;
	     sasdt=(&_uuslTimestamp./1000)+315619200;
	     call symputx("_uuslTimestampDT",trim(left(put(sasdt,datetime26.3))),'L');     
	     run;
	   
	   %put timestampDT=&_uuslTimestampDT.;
	   
	   %end;
	   
   %let _uuslRC=0;
   
%end;


%if ("&rc" ne "") %then %do;
 
    %global &rc.;
    
    %let &rc.=&_uuslRC.;
    
    %end;
    
%mend;
