/*
 *  This macro will initialize the users profile information for the passed user
 *  Parameters:
 *    name = the person name of the user to add
 */

%macro createUserProfile(name=,rc=);

%let _mrc=-1;

%if ("&name"="") %then %do;
    %put ERROR: User name must be passed to create the profile.;
    
    %end;
%else %do;

	/*
	 *  See if it already exists?
	 */
	
	filename _cupnull "&filesDir./portal/root.xml";
	
	filename _cupgxsl "&filesDir./portal/profile/getUserProfile.xslt";
	
	filename _cuppget temp;
	
	proc xsl in=_cupnull xsl=_cupgxsl out=_cuppget;
	   parameter "userName"="&name.";
	run;
	
	filename _cupnull;
	filename _cupgxsl;

    %checkXSLResult(xml=_cuppget,rc=getxslrc,msg=Generated get request for user profile info);
		
	%if ( &getxslrc.=0) %then %do;
	
		filename _cuppinf temp;
		
		proc metadata in=_cuppget out=_cuppinf;
		run;
		
		%showFormattedXML(_cuppinf,User Profile information results);
	
	    /*
	     *  Generate the necessary add request.
	     *  If the information just retrieved shows that it already exists, the add request returned will
	     *  be empty.
	     */
	
	    filename _cuppxsl "&filesDir./portal/profile/createUserProfile.xslt";
	    
	    filename _cupareq temp;
	    
	    proc xsl in=_cuppinf xsl=_cuppxsl out=_cupareq;
	    run;
	    
	    filename _cuppxsl;
	    filename _cuppinf;
	
	    %checkXSLResult(xml=_cupareq,rc=addxslrc,msg=Generate add request for user profile information);
			
		%if ( &addxslrc.=0) %then %do;
	
	        /*
	         *  If the XSL process completed successfully, check the output file if it has
	         *  a AddMetadata generated.
	         */
	    
		    %let addCreated=0;
		
		    /*
		     *  See if the output file has an AddMetadata request in it
		     */
		
		    data _null_;
		       infile _cupareq;
		       input;
		       if (find(_infile_,'AddMetadata')>0) then do;
		          call symput('addCreated','1');
		          stop;
		          end;
		    run;
		    
		    %if (&addCreated.) %then %do;
		
		            %put NOTE: Add request for user profile information generated.;
		
		            /*  Execute the add request */
		               
		            filename _cuparsp temp;
		            
		            proc metadata in=_cupareq out=_cuparsp;
		            run;
		
		            %showFormattedXML(_cuparsp,Add request for user profile information results);
		            
		            filename _cuparsp;
		            
		            %let _mrc=0;
		            
		        %end;
		    %else %do;
		    
		        %put NOTE: Profile information for user &name. already exists.;
		        %let _mrc=0;
		        
		        %end;
		        
		    %end;
        
        %else %do;
        
            %let _mrc=&addxslrc.;
            %end;
            
         filename _cupareq;

		%end;
     %else %do;
        
         %let _mrc=&getxslrc.;
         %end;
		
        filename _cuppget;
    	
    %end;

%if ("&rc." ne "") %then %do;

    %global &rc.;
    
    %let &rc.=&_mrc.;
    
    %end;
    
%mend;
