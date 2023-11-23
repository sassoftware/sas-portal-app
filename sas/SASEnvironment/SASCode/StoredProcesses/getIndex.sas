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

%checkPortalUser(name=&user.,exists=userPortalContentExists,rc=checkUserPortalContentRC);

%if (&checkUserPortalContentRC.=0) %then %do;

    %if (&userPortalContentExists.=0) %then %do;
    
        /*  The user portal content does not exist, should we initialize or not?
         */
        
        %if (%symexist(INITNEWUSER)) %then %do;
        
            %initPortalUser(name=&user.,rc=initPortalUserRC);
            
            %let checkUserPortalContentRC=&initPortalUserRC.;
            
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

   %end;

%mend;

/* ------------------------------------------------------------------------------------------
 *   Main
 * -----------------------------------------------------------------------------------------*/

%inc "&sasDir./request_setup.sas";
%genPortalMain(user=&_metaperson.);

