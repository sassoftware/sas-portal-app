/*  Generate the Add Item page */
%macro addItem(in=,out=_webout,rc=);

        /*
         *   For each item that the add page needs to  be generated for, there should be the following routines:
         *    -  a getter (optional)(which retrieves any metadata that is needed to generate the page).
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/add.get.<itemtype>.xslt
         *    -  a generator (which generates the page content). 
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/add.<itemtype>.xslt
         *       If this file is not found, then this item type is not supported to be  added.
         */


        %if ("%upcase(&type.)"="PSPORTLET") %then %do;
            %let searchType=&portletType.;
            %end;
        %else %do;
            %let searchType=&type.;
            %end;

        %let addItemGenerator=&filesDir./portlet/add.%lowcase(&searchType.).xslt;

        %let _aiRC=0;
        %let _aiRCMessage=;

        %if (%sysfunc(fileexist(&addItemGenerator.))=0) %then %do;
                %let _aiRC=1;

                %let _aiRCMessage=The generator for type &type. is missing.;

                %issueMessage(messageKey=portletAddNotSupported,out=&out.);

             %end;
        %else %do;

           %if ("&in." = "") %then %do;

               /*
                *  Make sure we have the metadata info available to include in the parameters
                */

               %getRepoInfo;

	       filename newxml temp;
	       %buildModParameters(newxml);

               %let addItemGetter=&filesDir./portlet/add.get.%lowcase(&searchType.).xslt;
               %if (%sysfunc(fileexist(&addItemGetter.)) ne 0) %then %do;
                   filename _aiget "&addItemGetter.";
                   filename _aireq temp;

                   proc xsl in=newxml xsl=_aiget out=_aireq;
                   run;

                   filename _aiget;
                   filename newxml;

                   filename _airsp temp;
                   proc metadata in=_aireq out=_airsp;
                   run;

                   /* 
                    * Not the most efficient, but the new xml should be small, so
                    * just recreate it, merging in the retrieved metadata.
                    */

	           filename newxml temp;
                   %buildModParameters(newxml,merge=_airsp);
                   filename _airsp;

                   %end;

               %let in=newxml;

               %end;

            filename addxsl "&addItemGenerator.";

            %showFormattedXML(&in.,XML being passed to Add generator);

            proc xsl in=&in. xsl=addxsl out=&out.;
               parameter "appLocEncoded"="&appLocEncoded."
                         "sastheme"="&sastheme."
                         "localizationFile"="&localizationFile."
              ;
            run;

            /*
             * TODO: Add logic to make sure page generation succeeded.
             */

            filename addxsl;

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
