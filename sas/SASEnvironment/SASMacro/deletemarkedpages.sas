%macro deleteMarkedPages(metareposId,metauser);
	
	/*
	 *  Get the list of Pages to remove (ie. marked for Deletion)
	 *  Also need to get the person name associated with the user id being
	 *  used to connect to the metadata server.
	 */
	filename marktmp "&macroDir./deletemarkedpages.xml";
	
	filename markreq temp;
	data _null_;
	  infile marktmp;
	  file markreq;
	  input;
	  length line $255;
	  line=tranwrd(_infile_,'$METAREPOSITORY',"&metareposId.");
	  line=tranwrd(line,'$METAUSER',"&metauser.");
	  put line;
	run;

    filename marktmp;
    
	%showFormattedXML(markreq,Metadata Query to retrieve pages marked for deletion.);
	
	filename markrsp temp;
	
	proc metadata in=markreq out=markrsp;
	run;
	
	%showFormattedXML(markrsp,Metadata Response containing marked pages for deletion.);
	
	/* 
	 *  Read the response
	 */
	filename tmpmap "&macroDir./deletemarkedpages.map";
	
	filename pagemap temp;
	data _null_;
	 infile tmpmap;
	 file pagemap;
	 input;
	 put _infile_;
	run;
	filename tmpmap;
	
	libname markrsp xmlv2 xmlmap=pagemap xmlfileref=markrsp;
	
	%symdel pageids / nowarn;
	
	proc sql noprint;
	  select id into :pageids separated by '|'
	  from markrsp.pages2delete;
	run;
	quit;
	
	%macro loopDeletePages;
	
	 %if (%symexist(pageids)=0) %then %do;
	     %let numPages=0;
	     %end;
	 %else %do;
	     
	     %put pageids=&pageids;
	
	     %let numPages=%sysfunc(countw(&pageids.,|));
	     %end;
	     
	 %put Number of Pages to Delete: &numPages;
	
	 %if (&numPages.>0) %then %do;
	 
		/*
		 *  Build the interfaces needed to call the deleteItem stored process code
		 *  that is common across all iterations of the loop.
		 */
	    %if (%sysfunc(fileref(_webout))>0) %then %do;
	
			filename _webout temp;
			%let weboutAssigned=1;
			%end;
		
	    %let type=PSPortalPage;
	    %let scope=delete;
	    /*
	     *  We have to be careful about not deleting user content, ie. portlets
	     *  that may exist on the page but are the user's own.
	     */
	    %let deletePortletsOnPage=false;
		     
	    %let _metaperson=metaperson;
	    %let _metauser=metauser;
		
		/*
		 * We want the log to return to this jobs log, so make sure that
		 * portal debug is turned off.
		 */
		
	     %symdel portalDebug / nowarn;
	
		 %do i=1 %to &numPages;
		     %let id=%scan(&pageIds,&i,'|');
		     
		     %put Processing Page Id=&id.;
		     
		     %inc "&stpDir./deleteItem.sas" / source2;
		     
		     %end;
	
	     /*
	      *  Clean up built parameters
	      */
	     
	     %symdel _metaperson /nowarn;
	     %symdel deletePortletsOnPage / nowarn;
	     %symdel id / nowarn;
	     %symdel type / nowarn;
	     %symdel scope / nowarn;
	     
	     %if (%symexist(weboutAssigned)) %then %do;	     
			 data _null_;
			  infile _webout;
			  input;
			  put _infile_;
			 run;
			 
			 filename _webout;
			 
			 %symdel weboutAssigned / nowarn;
			 %end;
		 
		 %end;
	  %else %do;
	     %put NOTE: No pages found to be processed.;
	     %end;
	     
	%mend;
	
	%loopDeletePages;
	
%mend;
