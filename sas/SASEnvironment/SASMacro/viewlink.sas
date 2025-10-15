%macro viewLink(out=_webout,rc=);

%let _vlRC=0;

        %let viewLinkParameterHandler=&stepsDir./portlet/render.viewlink.parameters.sas;

        filename vlhndlr "&viewLinkParameterHandler.";

        %let viewLinkGetter=&filesDir./portlet/render.viewlink.get.xslt;

        %let viewLinkProcessor=&filesDir./portlet/render.viewlink.xslt;

        /*
         *  Make sure we have the metadata info available to include in the parameters
         */

        %getRepoInfo;

        /* 
         *  Get the metadata for the passed path
         */

        filename newxml temp;
        %buildModParameters(newxml,vlhndlr);
        %showFormattedXML(newxml,viewLink getter input);

        filename _vlget "&viewLinkGetter.";
        filename _vlreq temp;

        proc xsl in=newxml xsl=_vlget out=_vlreq;
        run;
        %showFormattedXML(_vlreq,viewLink getter metadata request);

        filename _vlget;
        filename newxml;

        filename _vlrsp temp;
        proc metadata in=_vlreq out=_vlrsp;
        run;

        %let metadataContext=%sysfunc(pathname(_vlrsp));
        %showFormattedXML(_vlrsp,viewLink getter metadata response);

        /*
         * Recreate the newxml format potentially including the link to the metadata context
         */

        filename newxml temp;

        %buildModParameters(newxml,vlhndlr);

        %showFormattedXML(newxml,generated New Metadata xml);

        %if (&_vlRC. = 0) %then %do;

            filename vlxsl "&viewLinkProcessor.";

            proc xsl in=newxml xsl=vlxsl out=&out.;
            ;
            run;

            filename vlxsl;

            %end;
        %else %do;

            %issueMessage(messageKey=metadataGenerationFailed);
            _vlRC=100; 

            %end;

       %if (%sysfunc(fileref(_vlrsp))<1) %then %do;
           filename _vlrsp;
           %end;

       filename newxml;

       filename vlhndlr;

     %if ("&rc." ne "" ) %then %do;
         %global &rc.;
         %let &rc.=&_vlRC.;
         %end;

%mend;
