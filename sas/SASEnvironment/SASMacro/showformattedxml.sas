%macro showFormattedXML(xmlToFormat,header,out=,force=,quiet=no);

%if ((%symexist(SHOWXML)) or ("&force." ne "")) %then %do;

	%if ( "&xmlToFormat."="") %then %do;
	
	    %let xmlToFormat=outxml;
	    
	    %end;

    /*
     *  If the input file doesn't exist, issue a message and stop processing.
     */
    
    %if (%sysfunc(fexist(&xmlToFormat.))) %then %do;
	    
		filename _fmtXSL temp;
		filename _fmtdXML temp;
		
		data _null_;
		
		    file _fmtXSL;
			put '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">';
			put '<xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>';
			put '<xsl:template match="*">';
			put '<xsl:copy>';
			put '<xsl:copy-of select="@*"/>';
			put '<xsl:apply-templates/>';
			put '</xsl:copy>';
			put '</xsl:template>';
			put '<xsl:template match="comment()|processing-instruction()">';
                        put '&#160;';
			put '<xsl:copy/>';
                        put '&#160;';
			put '</xsl:template>';
			put '</xsl:stylesheet>';
		run;
		
		proc xsl in=&xmlToFormat. xsl=_fmtXSL out=_fmtdXML ;
		run;
	
		%if ("&header." ne "") %then %do;
		    %put --------------------------------------------------;
		    %put showFormattedXML: &header.;
		    %put --------------------------------------------------;
	        %end;	    
                %if ("&quiet." eq "no" or "&quiet." eq "" and "&quiet." eq "n") %then %do;

                    data _null_;
                     infile _fmtdXML;
                     input;
                     put _infile_;
                     run;
                 %end;
		
		filename _fmtXSL;
		
		%if ("&out" ne "") %then %do;
		
		    data _null_;
		      infile _fmtdXML;
		      file &out.;
		      input;
		      put _infile_;
		      run;
		   %end;
		   
		filename _fmtdXML;
		
		%end;
   %else %do;
   
		%if ("&header." ne "") %then %do;
		    %put --------------------------------------------------;
		    %put &header.;
		    %put --------------------------------------------------;
	        %end;	    

        %put NOTE: SHOWFORMATTEDXML: Input file, &xmlToFormat., does not exist.;
        
        %end;   

%end;

%mend;
