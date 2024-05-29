%macro searchQuery(out=_webout,rc=);

%let _sqRC=0;

        /*
         *   For each type to be queried, there should be the following routines:
         *    -  a getter (optional) (which retrieves any metadata that is needed as context for the query ).
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/search.<itemtype>.get.xslt
         *    -  a parameter handler (that looks at the incoming requests and prepares the "new" metadata format.
         *       NOTE: This is a .sas file that has data step code snippets in it.
         *       The name of the file must be in the form &stepsDir./portlet/search.<itemtype>.parameters.sas
         *    -  a processor (which generates the html response with the query results). 
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/search.<itemtype>.xslt
         *   If any of those are not found, then this item type is not supported to be edited.
         */


        %if ("%upcase(&type.)"="PSPORTLET") %then %do;
            %let searchType=&portletType.;
            %end;
        %else %do;
            %let searchType=&type.;
            %end;

        %let searchItemGetter=&filesDir./portlet/search.%lowcase(&searchType.).get.xslt;

        %let searchItemParameterHandler=&stepsDir./portlet/search.%lowcase(&searchType.).parameters.sas;

        %let searchItemProcessor=&filesDir./portlet/search.%lowcase(&searchType.).xslt;

        %let _sqRC=0;
        %let _sqRCMessage=;

        %if ((%sysfunc(fileexist(&searchItemParameterHandler.))=0)
             or (%sysfunc(fileexist(&searchItemProcessor.))=0))
             %then %do;
                %let _sqRC=1;

                %let _sqRCMessage=One of the type handlers for type &type. is missing.;

                %issueMessage(messageKey=portletSearchNotSupported);

             %end;
        %else %do;

             filename schhndlr "&searchItemParameterHandler.";

             /*
              *  Make sure we have the metadata info available to include in the parameters
              */

             %getRepoInfo;

             %if (%sysfunc(fileexist(&searchItemGetter.))=1) %then %do;

                 filename newxml temp;
                 %buildModParameters(newxml,schhndlr);

                 filename _sqget "&searchItemGetter.";
                 filename _sqreq temp;

                 proc xsl in=newxml xsl=_sqget out=_sqreq;
                 run;

                 filename _sqget;
                 filename newxml;

                 filename _sqrsp temp;
                 proc metadata in=_sqreq out=_sqrsp;
                 run;

                 %let metadataContext=%sysfunc(pathname(_sqrsp));
                 %showFormattedXML(_sqrsp,Update Item getter metadata response);

                 %end;

             /*
              * Recreate the newxml format potentially including the link to the metadata context
              */

             filename newxml temp;

             %buildModParameters(newxml,schhndlr);

             %showFormattedXML(newxml,generated New Metadata xml);

             %if (&_sqRC. = 0) %then %do;

                 filename srchxsl "&searchItemProcessor.";

                 proc xsl in=newxml xsl=srchxsl out=&out.;
                 ;
                 run;

                 filename srchxsl;

                 %end;
             %else %do;

                 %issueMessage(messageKey=metadataGenerationFailed);
                 _sqRC=100; 

                 %end;

            %if (%sysfunc(fileref(_sqrsp))<1) %then %do;
                filename _sqrsp;
                %end;

            filename newxml;

            filename schhndlr;

        %end;

     %if ("&rc." ne "" ) %then %do;
         %global &rc.;
         %let &rc.=&_sqRC.;
         %end;

%mend;
