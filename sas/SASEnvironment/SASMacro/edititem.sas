/*  Generate the Edit Item page */
%macro editItem(in=,out=_webout,rc=);

        /*
         *   For each item that the edit page needs to  be generated for, there should be the following routines:
         *    -  a getter (optional)(which retrieves any metadata that is needed to generate the page).
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/edit.<itemtype>.get.xslt
         *    -  a generator (which generates the page content). 
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/edit.<itemtype>.xslt
         *       If this file is not found, then this item type is not supported to be  edited.
         */


        %if ("%upcase(&type.)"="PSPORTLET") %then %do;
            %let searchType=&portletType.;
            %end;
        %else %do;
            %let searchType=&type.;
            %end;

        %let editItemGenerator=&filesDir./portlet/edit.%lowcase(&searchType.).xslt;

        %let _eiRC=0;
        %let _eiRCMessage=;

        %if (%sysfunc(fileexist(&editItemGenerator.))=0) %then %do;
                %let _eiRC=1;

                %let _eiRCMessage=The generator for type &type. is missing.;

                %issueMessage(messageKey=portletEditNotSupported,out=&out.);

             %end;
        %else %do;

           %if ("&in." = "") %then %do;

               /*
                *  Make sure we have the metadata info available to include in the parameters
                */

               %getRepoInfo;

	       filename newxml temp;
	       %buildModParameters(newxml);

               %let editItemGetter=&filesDir./portlet/edit.%lowcase(&searchType.).get.xslt;
               %if (%sysfunc(fileexist(&editItemGetter.)) ne 0) %then %do;
                   filename _eiget "&editItemGetter.";
                   filename _eireq temp;

                   proc xsl in=newxml xsl=_eiget out=_eireq;
                   run;

                   filename _eiget;
                   filename newxml;

                   filename _eirsp temp;
                   proc metadata in=_eireq out=_eirsp;
                   run;

                   /* 
                    * Not the most efficient, but the new xml should be small, so
                    * just recreate it, merging in the retrieved metadata.
                    */

	           filename newxml temp;
                   %buildModParameters(newxml,merge=_eirsp);
                   filename _eirsp;

                   %end;

               %let in=newxml;

               %end;

            filename editxsl "&editItemGenerator.";

            %showFormattedXML(&in.,XML being passed to Edit generator);

            proc xsl in=&in. xsl=editxsl out=&out.;
               parameter "appLocEncoded"="&appLocEncoded."
                         "sastheme"="&sastheme."
                         "localizationFile"="&localizationFile."
              ;
            run;

            /*
             * TODO: Edit logic to make sure page generation succeeded.
             */

            filename editxsl;

            %if (&_eiRC. ne 0) %then %do;

              %issueMessage(messageKey=pageGenerationFailed);

              %end;

           %if ("&in." = "") %then %do;
              filename newxml;
              %end;

        %end;

     %if ("&rc." ne "" ) %then %do;
         %global &rc.;
         %let &rc.=&_eiRC.;
         %end;

%mend;
