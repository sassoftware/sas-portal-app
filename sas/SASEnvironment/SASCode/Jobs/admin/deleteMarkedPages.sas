/*
 *  This job will look for any pages that are marked for deletion and 
 *  will physically delete them.
 *  This code must be run as a sas system administrator!
 */

%inc "&sasDir./request_setup.sas";

%getRepoInfo;

/*
 *  Figure out what userid we are using to query the metadata.
 */
%macro calcMetaUser;

  /*
   *  Try to figure out what user to use to access Metadata
   *  Precedence is going to be:
   *  metauser macro variable
   *  metauser sas option
   *  _metauser macro variable
   * 
   */
  %let userFound=0;
  
  %if (%symexist(metauser)=1) %then %do;
	  %if ("&metaUser." ne "") %then %do;
	  %let userFound=1;
	  %end;
  %end;
  
  %if (&userFound. ne 1) %then %do;
      
      %let tryUser=%sysfunc(getoption(METAUSER));
      %if ("&tryUser." ne "") %then %do;
          %global metauser;
          %let metauser=&tryUser.;
          %end;
      %else %do;
      
         %let tryUser=&_metauser.;
         %if ("&tryUser." ne "") %then %do;
             %global metauser;
             %let metauser=&tryUser.;
             %end;
         %end;
         
      %end;
  
  %if (%symexist(metauser)) %then %do;
      %put Will use &metaUser. as the metadata user to lookup metadata for;
      %end;
  %else %do;
      %put ERROR: Unable to derive metadata user information to search for.;
      /*  Make sure the resulting macro variable doesnt exist so any reference
       *  to it is going to cause an error.
       */
      %symdel metauser / nowarn;
      %end;
      
%mend;
%calcMetaUser;

%macro calcMetaPerson;

   /*
    *  Precedence is:
    *   existing metaperson value
    *   _metaperson macro variable (would be set if running as stored process)
    *   value calculated by doing metadata look up on metauser value.
    */
   
   %let personFound=0;
   
   %if (%symExist(metaperson)=0) %then %do;
   
       %if (%symExist(_metaperson)) %then %do;
           %global metaperson;
           %let metaperson=&_metaperson.;
           %end;
       %else %do;
		   %if (%symExist(metauser)=1) %then %do;
		       
		       %getMetaPerson(&metauser.);
		       
		       %end;

	       %end;
       
       %end;
       
   %if (%symExist(metaperson)) %then %do;
       
      %put NOTE: Will use &metaPerson. as the metadata identity;
      %end;
  %else %do;
      %put ERROR: Unable to derive metadata identity information;
      
      /*  Make sure the resulting macro variable doesnt exist so any reference
       *  to it is going to cause an error.
       */
      
      %symdel metaperson / nowarn;
      %end;
%mend;

%calcMetaPerson;

%macro adminDeletePages;

%if (%symexist(metaperson)) %then %do;
    %deleteMarkedPages(&reposid.,&metaperson.);
    %end;
%else %do;
    %put ERROR: No pages processed due to not being to retrieve metadata identity information.;
    %end;

%mend;

%adminDeletePages;

