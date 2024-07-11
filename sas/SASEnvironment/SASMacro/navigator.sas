%macro navigator(out=_webout,rc=);

%let _naRC=0;

        /*
         *  Unfortunately, we can't do a search on the passed folder and get it's content at the same time due to the 
         *  fear that we might end up navigating the entire SAS Content tree because of the way the metadata templating facility works.
         *  Thus, we will first get the folder that matches the passed path and set it's value into the folderId macro variable,
         *  then will get just the details of the direct members of the passed folder.
         */
        /*  Same parameter handler can be used for both the folder and the sasnavigator */

        %let navigatorParameterHandler=&stepsDir./portlet/render.sasnavigator.parameters.sas;

        filename navhndlr "&navigatorParameterHandler.";

        %let folderGetter=&filesDir./portlet/render.folder.get.xslt;

        %let folderProcessor=&filesDir./portlet/render.folder.xslt;

        %let navigatorGetter=&filesDir./portlet/render.sasnavigator.get.xslt;

        %let navigatorProcessor=&filesDir./portlet/render.sasnavigator.xslt;

        /*
         *  Make sure we have the metadata info available to include in the parameters
         */

        %getRepoInfo;

        /*
         *  Get the folder object 
         */

        filename _flget "&folderGetter.";
        filename _flreq temp;

        filename newxml temp;

        %buildModParameters(newxml,navhndlr);
        %showFormattedXML(newxml,Folder getter input);

        proc xsl in=newxml xsl=_flget out=_flreq;
        run;
        %showFormattedXML(_flreq,Folder getter metadata request);

        filename _flget;
        filename newxml;

        filename _flrsp temp;
        proc metadata in=_flreq out=_flrsp;
        run;
        %showFormattedXML(_flrsp,Folder getter metadata response);

        filename _flreq;
        
        /*  This xsl actually generates SAS code to include */

        %let metadataContext=%sysfunc(pathname(_flrsp));
%put metadataContext=&metadataContext.;

        /*  Rebuild newxml to include metadata */
        filename newxml temp;

        %buildModParameters(newxml,navhndlr);
        %showFormattedXML(newxml,Folder processor input);

        %let metadataContext=;

        filename _flxsl "&folderProcessor.";
        filename _flsas temp;

data _null_;
 infile _flrsp;
 input;
 put _infile_;
run;

%put generating SAS Code to set folder Id;      
        proc xsl in=newxml xsl=_flxsl out=_flsas;
        run;

        %inc _flsas / source2;

        filename _flxsl;
        filename _flrsp;
        filename _flsas;

        /* 
         *  If we found the passed folder, then the folderId macro variable should now contain
         *  the requested folder.
         */

        filename newxml temp;
        %buildModParameters(newxml,navhndlr);
        %showFormattedXML(newxml,Navigator getter input);

        filename _naget "&navigatorGetter.";
        filename _nareq temp;

        proc xsl in=newxml xsl=_naget out=_nareq;
        run;
        %showFormattedXML(_nareq,Navigate getter metadata request);

        filename _naget;
        filename newxml;

        filename _narsp temp;
        proc metadata in=_nareq out=_narsp;
        run;

        %let metadataContext=%sysfunc(pathname(_narsp));
        %showFormattedXML(_narsp,Navigate getter metadata response);

        /*
         * Recreate the newxml format potentially including the link to the metadata context
         */

        filename newxml temp;

        %buildModParameters(newxml,navhndlr);

        %showFormattedXML(newxml,generated New Metadata xml);

        %if (&_naRC. = 0) %then %do;

            filename navxsl "&navigatorProcessor.";

            proc xsl in=newxml xsl=navxsl out=&out.;
            ;
            run;

            filename navxsl;

            %end;
        %else %do;

            %issueMessage(messageKey=metadataGenerationFailed);
            _naRC=100; 

            %end;

       %if (%sysfunc(fileref(_narsp))<1) %then %do;
           filename _narsp;
           %end;

       filename newxml;

       filename navhndlr;

     %if ("&rc." ne "" ) %then %do;
         %global &rc.;
         %let &rc.=&_naRC.;
         %end;

%mend;
