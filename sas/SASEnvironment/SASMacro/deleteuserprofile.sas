/*
 *  This macro will initialize the users profile information for the passed user
 *  Parameters:
 *    name = the person name of the user to add
 */

%macro deleteUserProfile(name=,rc=);

%let _dupRC=-1;

%if ("&name"="") %then %do;
    %put ERROR: User name must be passed to create the profile.;
    %end;
%else %do;

	/*
	 *  See if it already exists?
	 */
	
	filename _DUPXML "&filesDir./portal/root.xml";
	
	filename _duppxsl "&filesDir./portal/profile/getUserProfile.xslt";
	
	filename _dupgreq temp;
	
	proc xsl in=_DUPXML xsl=_duppxsl out=_dupgreq;
	   parameter "userName"="&name.";
	run;
	
	filename _DUPXML;
	filename _duppxsl;

    %checkXSLResult(xml=_dupgreq,rc=getxslrc,msg=Generate get request for user profile info);
		
	%if ( &getxslrc.=0) %then %do;
	
		filename _dupgrsp temp;
		
		proc metadata in=_dupgreq out=_dupgrsp;
		run;
		
		%showFormattedXML(_dupgrsp,User Profile information results);
		
	    /*
	     *  Generate the necessary delete request.
	     *  If the information just retrieved shows that it doesn't exist, the delete request returned will
	     *  be empty.
	     */
	
	    filename _dupdxsl "&filesDir./portal/profile/deleteUserProfile.xslt";
	    
	    filename _dupdreq temp;
	    
	    proc xsl in=_dupgrsp xsl=_dupdxsl out=_dupdreq;
	    run;
	    
	    filename _dupdxsl;
	    filename _dupgrsp;
	
	    %checkXSLResult(xml=_dupdreq,rc=delxslrc,msg=Generated Delete request for user profile information);
			
		%if ( &delxslrc.=0) %then %do;
	
	        /*
	         *  If the XSL process completed successfully, check the output file if it has
	         *  a DeleteMetadata generated.
	         */
	        
		    %let deleteCreated=0;
	
		    /*
		     *  See if the output file has an DeleteMetadata request in it
		     */
		
		    data __dupnull_;
		       infile _dupdreq;
		       input;
		       if (find(_infile_,'DeleteMetadata')>0) then do;
		          call symput('deleteCreated','1');
		          stop;
		          end;
		    run;
		    
		    %if (&DeleteCreated.) %then %do;
		
		            %put NOTE: Delete request foruser profile information generated.;
		            
		            %showFormattedXML(_dupdreq,Generated Delete request for user profile information);
		
		            /*  Execute the delete request */
		               
		            filename _dupdrsp temp;
		            
		            proc metadata in=_dupdreq out=_dupdrsp;
		            run;
		
		            %showFormattedXML(_dupdrsp,Delete request for user profile information results);
		            
		            filename _dupdrsp;
		            
		            %let _dupRC=0;
		            
		        %end;
		    %else %do;
		    
		        %put Profile information for user &name. does not exist.;
		        %let _dupRC=0;
		        
		        %end;
	        %end;
	    %else %do;
	    
	        %let _dupRC=&delxslRC.;
	        
	        %end;
	    
        filename _dupdreq;

		%end;
    %else %do;
    
        %let _dupRC=&getxslRC.;
    
        %end;
	
    filename _dupgreq;
    	
%end;

%if ("&rc." ne "") %then %do;

    %global &rc.;
    
    %let &rc.=&_dupRC.;
    
    %end;     
%mend;
