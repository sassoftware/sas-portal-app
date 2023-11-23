/*
 *  This macro will initialize the users profile information for the passed user
 *  Parameters:
 *    name = the person name of the user to add
 */

%macro getUserProfile(name=,rc=,out=);

%let _gup=-1;

%if ("&name"="") %then %do;
    %put ERROR: User name must be passed to create the profile.;
    
    %end;
%else %do;

	/*
	 *  See if it already exists?
	 */
	
	filename _gupnull "&filesDir./portal/root.xml";
	
	filename _gupgxsl "&filesDir./portal/profile/getUserProfile.xslt";
	
	filename _gupgreq temp;
	
	proc xsl in=_gupnull xsl=_gupgxsl out=_gupgreq;
	   parameter "userName"="&name.";
	run;
	
	filename _gupnull;
	filename _gupgxsl;

    %checkXSLResult(xml=_gupgreq,rc=getxslrc,msg=Generated get request for user profile info);
		
	%if ( &getxslrc.=0) %then %do;
	
	    filename _gupgrsp temp;
	    
		proc metadata in=_gupgreq out=_gupgrsp;
		run;
		
		%showFormattedXML(_gupgrsp,User Profile information results,out=&out.);

	    filename _gupgrsp;
	
	    %let _gup=0;
	    
		%end;
     %else %do;
        
         %let _gup=&getxslrc.;
         %end;
		
     filename _gupgreq;
    	
    %end;

%if ("&rc." ne "") %then %do;

    %global &rc.;
    
    %let &rc.=&_gup.;
    
    %end;
    
%mend;
