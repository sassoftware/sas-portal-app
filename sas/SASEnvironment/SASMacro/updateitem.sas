/*  Save the changes made to an Item page */
%macro updateItem(rc=);

        /*
         *   For each item that is to be saved, there should be the following routines:
         *    -  a getter (which retrieves any metadata that is needed to update the object).
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/update.<itemtype>.get.xslt
         *    -  a parameter handler (that looks at the incoming requests and prepares the "new" metadata format.
         *       NOTE: This is a .sas file that has data step code snippets in it.
         *       The name of the file must be in the form &stepsDir./portlet/update.<itemtype>.parameters.sas
         *    -  a processor (which generates the metadata update to save the metadata). 
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/save.<itemtype>.xslt
         *   If any of those are not found, then this item type is not supported to be edited.
         */


        %if ("%upcase(&type.)"="PSPORTLET") %then %do;
            %let searchType=&portletType.;
            %end;
        %else %do;
            %let searchType=&type.;
            %end;

        %let updateItemGetter=&filesDir./portlet/update.%lowcase(&searchType.).get.xslt;

        %let updateItemParameterHandler=&stepsDir./portlet/update.%lowcase(&searchType.).parameters.sas;

        %let updateItemProcessor=&filesDir./portlet/update.%lowcase(&searchType.).xslt;

        %let _uiRC=0;
        %let _uiRCMessage=;

        %if ((%sysfunc(fileexist(&updateItemGetter.))=0) 
             or (%sysfunc(fileexist(&updateItemParameterHandler.))=0)
             or (%sysfunc(fileexist(&updateItemProcessor.))=0))
             %then %do;
                %let _uiRC=1;

                %let _uiRCMessage=One of the type handlers for type &type. is missing.;

                %issueMessage(messageKey=portletEditNotSupported);

             %end;
        %else %do;

             /*
              *  Make sure we have the metadata info available to include in the parameters
              */

             %getRepoInfo;

             filename newxml temp;
             %buildModParameters(newxml);

             filename _uiget "&updateItemGetter.";
             filename _uireq temp;

             proc xsl in=newxml xsl=_uiget out=_uireq;
             run;

             filename _uiget;
             filename newxml;

             filename _uirsp temp;
             proc metadata in=_uireq out=_uirsp;
             run;

             %let metadataContext=%sysfunc(pathname(_uirsp));
             %showFormattedXML(_uirsp,Update Item getter metadata response);

             /*
              * Recreate the newxml format including the link to the metadata context
              */

             filename newxml temp;

             filename updhndlr "&updateItemParameterHandler.";

             %buildModParameters(newxml,updhndlr);
             filename updhndlr;

             %showFormattedXML(newxml,generated New Metadata xml);

             %if (&_uiRC. = 0) %then %do;

                 filename updtxsl "&updateItemProcessor.";

                 %genModification(modxsl=updtxsl,newxml=newxml,action=update,rc=genUpdateRC);

                 %let _uiRC=&genUpdateRC.;

                 filename updtxsl;
                 %end;
             %else %do;

                 %issueMessage(messageKey=metadataGenerationFailed);

                 %end;

            %if (%sysfunc(fileref(_uirsp))<1) %then %do;
                filename _uirsp;
                %end;

            filename newxml;

        %end;

     %if ("&rc." ne "" ) %then %do;
         %global &rc.;
         %let &rc.=&_uiRC.;
         %end;

%mend;
