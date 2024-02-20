%macro getMetaPerson(_gmpuser);

%put Retrieving Person information for user=&_gmpuser.;

   %let personFound=0;
   
   %if (%symExist(metaperson)=0) %then %do;
   
       %if (%symExist(_metaperson)) %then %do;
           %global metaperson;
           %let metaperson=&_metaperson.;
           %end;
       %else %do;
		   %if (%symExist(metauser)=1) %then %do;
		           
		       %end;
		   %else %do;
		   
		       %end;
	       %end;
       
       %end;
       
   %if (%symExist(metaperson)) %then %do;
       
      %put Will use &metaPerson. as the metadata identity;
      %end;
%if (%index(&_gmpuser.,@)>0) %then %do;
    /*
     * Looks like an internal account and internal accounts
     * must match the name of the Person to which it is associated,
     * so just return the substring before the @.
     */
    %global metaperson;
    %let metaperson=%scan(&_gmpuser.,1,'@');
    %end;
%else %do;
	filename _gmpxml "&macroDir./getmetaperson.xml";
	
	filename _gmpreq temp;
	data _null_;
	  infile _gmpxml;
	  file _gmpreq;
	  input;
	  length line $255;
	
	  line=tranwrd(_infile_,'$METAUSER',"&_gmpuser.");
	  put line;
	run;
	
	%showFormattedXML(_gmpreq);
	
	filename _gmpxml;
	
	filename _gmprsp temp;
	
	proc metadata in=_gmpreq out=_gmprsp;
	run;
	
	%showFormattedXML(_gmprsp);

    filename _gmpreq;

    filename _gmpmap "&macroDir./getmetaperson.map";
    
    libname _gmprsp xmlv2 xmlmap=_gmpmap xmlfileref=_gmprsp;
    
    proc sql noprint;
      select name into :tryperson
      from _gmprsp.person;
    run;
    
    %if (%symexist(tryperson)) %then %do;
        %global metaperson;
        %let metaperson=&tryPerson.;
        %end;
    %else %do;
        %put ERROR: Could not retrieve person information for user &_gmpuser.;
        %symdel metaperson / nowarn;
        
        %end;
    
    libname _gmprsp;
    filename _gmpmap;
    filename _gmprsp;
    
    %end;
    
%mend;
