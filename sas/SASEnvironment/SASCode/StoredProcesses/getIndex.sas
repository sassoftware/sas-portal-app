/*  Generate the main page */

%macro genPortalMain(user=);

/*
 *  See if the user portal area has been initialized and if not, what should we do?
 *
 *  Try to make this check as fast as possible.  
 */

%if ("&user."="") %then %do;
    %let user=&_metaperson.;
    %end;

/*
 *  CheckPortalUser will verify that content exists in the user's permission tree.
 *  If it returns 0 (ie. content doesn't exist), it is up to the initPortalUser to determine
 *  whether the permission tree doesn't exist (which will return an error) or if the content doesn't
 *  exist (which it will create).
 *
 *  We do the check this way to make it most efficient in the "normal" case, ie. the content does exist.
 */

%checkPortalUser(name=&user.,exists=userPortalContentExists,rc=checkUserPortalContentRC);

%if (&checkUserPortalContentRC.=0) %then %do;

    %if (&userPortalContentExists.=0) %then %do;

        /*
         *  See if the situation is that the user's permission tree doesn't exist, or
         *  if it's the content.
         *  The user's permission tree not existing is a special case because it requires
         *  admin permissions to do so, so treat that special.
         *  If the permission tree exists, but there is no content, then initialize
         *  the portal user content.
         */
        
     	%let portalPermissionsTree=&user. Permissions Tree;
	    
	    %objectExists(type=Tree,name=&portalPermissionsTree.,existsvar=_cptTreeExists);

     	%if (&_cptTreeExists. = 1) %then %do;
	
	        /*  The user portal content does not exist, should we initialize or not?
	         *  NOTE: This feature flag, INITNEWUSER, will eventually go away and the default will be "1", ie. initialize new users.
	         */
	        
	        %if (%symexist(INITNEWUSER)) %then %do;
	        
	            %initPortalUser(name=&user.,rc=initPortalUserRC);
	            
	            %let checkUserPortalContentRC=&initPortalUserRC.;
	            
	            /* Note: -1001 signifies that the user's permission tree doesn't exist, shouldn't happen since we just checked it 
	             */
	            
	            %end;
	        %else %do;
	
	            /*
	             *  Content doesn't exist and we haven't specified to initialize new users
	             */
	            
	            %let checkUserPortalContentRC=-1002;
	        
	            %end;
            %end;
        %else %do;
        
            /*
             *  Indicate that the permission tree doesn't exist.
             */
            
            %let checkUserPortalContentRC=-1001;
        
            %end;
            
        %end;
    %else %do;

	    /*
	     *  See if we need to sync the user's group shared information.
	     *  Note: if this was a new user that was just initialized, then
	     *        this was done as part of the new user initialization.
	     */

        %if (%symexist(SYNCUSER)) %then %do;
        
           %syncUserGroupContent(name=&user.,rc=syncUserGroupContentRC);
            
            %let checkUserPortalContentRC=&syncUserGroupContentRC.;
            
            %end;
        %end;
        
    %end;

%if (&checkUserPortalContentRC.=0) %then %do;

	/*
	 *  Now retrieve the (possibly updated) portal metadata
	 *
	 */

	filename inxml "&filesDir./portal/getPortalContent.xml";
	   
	filename outxml temp;
	
	proc metadata in=inxml out=outxml;
	run;
	
	filename inxml;

    %showFormattedXML(outxml,getPortalContent response);
    
	/*
	 *  Generate the main page
	 */
	
	filename inxsl "&filesDir./portal/genPortalMain.xslt" encoding='utf-8';
	
	proc xsl in=outxml xsl=inXSL out=_webout;
	   parameter "appLocEncoded"="&appLocEncoded."
	             "sastheme"="&sastheme."
                 "localizationFile"="&localizationFile."
	       ;
	
	run;

   filename inxsl;
   filename outxml;
   
   %end;
%else %do;

   /*  An error has occurred, format a response page to the user indicating the issue.
    */
   
   filename outxml "&filesDir/portal/root.xml";
   filename inxsl "&filesDir./portal/genPortalError.xslt";
   
   proc xsl in=outxml xsl=inxsl out=_webout;
                 
	   parameter "appLocEncoded"="&appLocEncoded."
	             "sastheme"="&sastheme."
                     "localizationFile"="&localizationFile."
                     "errorCode"="&checkUserPortalContentRC."
	       ;
   run;
   
   filename inxsl;
   filename outxml;
   
   %end;
%mend;

/* ------------------------------------------------------------------------------------------
 *   Main
 * -----------------------------------------------------------------------------------------*/

%inc "&sasDir./request_setup.sas";

%genPortalMain(user=&_metaperson.);

