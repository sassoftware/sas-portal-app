%macro getLocalizedPreference(key,valueVar);

	%global &valueVar.;
	
	filename l16nmap "&localizationDir./l16ndata.map";
	
	libname l16ndata xmlv2 "&localizationFile." xmlmap=l16nmap;
	
	proc sql noprint;
	  select value into :&valueVar.
	  from l16ndata.preference
	  where key="&key.";
	run;
	
	libname l16ndata;
	filename l16nmap;

%mend;
