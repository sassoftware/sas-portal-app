/*  Generate the Remove Item page */
%macro removeItem(in=,out=_webout,rc=);

        /*
         *   For each item that the remove page needs to  be generated for, there should be the following routines:
         *    -  a getter (optional)(which retrieves any metadata that is needed to generate the page).
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/add.get.<itemtype>.xslt
         *    -  a generator (which generates the page content). 
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/remove.<itemtype>.xslt
         *   If any of those are not found, then this item type is not supported to be edited.
         */


        %if ("%upcase(&type.)"="PSPORTLET") %then %do;
            %let searchType=&portletType.;
            %end;
        %else %do;
            %let searchType=&type.;
            %end;

        %let removeItemGenerator=&filesDir./portlet/remove.%lowcase(&searchType.).xslt;

        %let _aiRC=0;
        %let _aiRCMessage=;

        %if (%sysfunc(fileexist(&removeItemGenerator.))=0) %then %do;
                %let _aiRC=1;

                %let _aiRCMessage=The generator for type &type. is missing.;

                %issueMessage(messageKey=portletRemoveNotSupported,out=&out.);

             %end;
        %else %do;

           %if ("&in." = "") %then %do;

               /*
                *  Make sure we have the metadata info available to include in the parameters
                */

               %getRepoInfo;

               filename newxml temp;
               %buildModParameters(newxml);

               %let removeItemGetter=&filesDir./portlet/remove.get.%lowcase(&searchType.).xslt;
               %if (%sysfunc(fileexist(&removeItemGetter.)) ne 0) %then %do;

                   filename _aiget "&removeItemGetter.";
                   filename _aireq temp;

                   proc xsl in=newxml xsl=_aiget out=_aireq;
                   run;

                   %showFormattedXML(_aireq,Generated Get Metadata request);

                   filename _aiget;
                   filename newxml;

                   filename _airsp temp;
                   proc metadata in=_aireq out=_airsp;
                   run;

                   %showFormattedXML(_airsp, Generated Get Metadata response);
                   /*
                    * Not the most efficient, but the new xml should be small, so
                    * just recreate it, merging in the retrieved metadata.
                    */

                   filename newxml temp;
                   %buildModParameters(newxml,merge=_airsp);
                   filename _airsp;

                   %end;

               %end;

            filename remxsl "&removeItemGenerator.";

            %showFormattedXML(newxml,Parameter xml passed to page generation);

            proc xsl in=newxml xsl=remxsl out=&out.;
               parameter "appLocEncoded"="&appLocEncoded."
                         "sastheme"="&sastheme."
                         "localizationFile"="&localizationFile."
              ;
            run;

            /*
             * TODO: Remove logic to make sure page generation succeeded.
             */

            filename remxsl;

            %if (&_aiRC. ne 0) %then %do;

              %issueMessage(messageKey=pageGenerationFailed);

              %end;

           %if ("&in." = "") %then %do;
              filename newxml;
              %end;

        %end;

     %if ("&rc." ne "" ) %then %do;
         %global &rc.;
         %let &rc.=&_aiRC.;
         %end;

%mend;
