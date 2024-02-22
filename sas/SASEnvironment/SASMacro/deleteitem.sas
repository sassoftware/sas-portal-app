/*  Create the item deleted from a page */
%macro deleteItem(rc=);

        /*
         *   For each item that is to be deleted, there should be the following routines:
         *    -  (optional) a getter, that will retrieve any existing metadata that may be required
         *       to have available when generating the DeleteMetadata Request.
         *       The name of the file must be in the form &filesDir./portlet/delete.<itemtype>.get.xslt
         *       NOTE: This file is optional and processing will continue if not found!
         *    -  (optional) a parameter handler (that looks at the incoming requests and prepares the "new" metadata format.
         *       NOTE: This is a .sas file that has data step code snippets in it.
         *       The name of the file must be in the form &stepsDir./portlet/delete.<itemtype>.parameters.sas
         *    -  a processor (which generates the metadata delete to delete the metadata). 
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/delete.<itemtype>.xslt
         *   If any of those are not found, then this item type is not supported to be edited.
         */


        %if ("%upcase(&type.)"="PSPORTLET") %then %do;
            %let searchType=&portletType.;
            %end;
        %else %do;
            %let searchType=&type.;
            %end;

        %let deleteItemGetter=&filesDir./portlet/delete.%lowcase(&searchType.).get.xslt;

        %let deleteItemParameterHandler=&stepsDir./portlet/delete.%lowcase(&searchType.).parameters.sas;
        %let deleteItemProcessor=&filesDir./portlet/delete.%lowcase(&searchType.).xslt;

        %let _ciRC=0;
        %let _ciRCMessage=;

        %if (%sysfunc(fileexist(&deleteItemProcessor.))=0)
             %then %do;
                %let _ciRC=1;

                %let _ciRCMessage=One of the type handlers for type &type. is missing.;

                %issueMessage(messageKey=portletRemoveNotSupported);

             %end;
        %else %do;

            %getRepoInfo;

            /*
             * if we have a getter, then go ahead and set up the response file
             * in a variable to be included by buildModParameters.
             */
            %if (%sysfunc(fileexist(&deleteItemGetter.)) ne 0) %then %do;
                filename getrsp temp;
                %let metadataContext=%sysfunc(pathname(getrsp));
                %end;

            filename newxml temp;
            %if (%sysfunc(fileexist(&deleteItemParameterHandler.)) ne 0)
                %then %do;

                filename delhndlr "&deleteItemParameterHandler.";

                %buildModParameters(newxml,delhndlr,rc=_ciRC);

                filename delhndlr;

                %end;
            %else %do;
                %buildModParameters(newxml,rc=_ciRC);
                %end;

            %showFormattedXML(newxml,generated New Metadata xml);

            %if (&_ciRC. = 0) %then %do;

                /*
                 *  If this type has a getter, run it and upon successful
                 *  completion, merge it back into the new xml.
                 */

                %if (%sysfunc(fileexist(&deleteItemGetter.)) ne 0) %then %do;

                    /*
                     *  Generate the Delete Metadata request
                     */

                    filename getreq temp;

                    filename getxsl "&deleteItemGetter.";

                    proc xsl in=newxml xsl=getxsl out=getreq;
                    run;

                    filename getxsl;

                    %showFormattedXML(getreq,Metadata Query to retrieve input for modification request.);

                    /*
                     *  Issue the metadata request
                     */

                    proc metadata in=getreq out=getrsp;
                    run;

                    filename getreq;

                    %showFormattedXML(getrsp,Metadata Response for input for modification request.);
                    %end;

                filename remxsl "&deleteItemProcessor.";

                /*
                 *  Generate and execute the metadata modification
                 */

                %genModification(modxsl=remxsl,newxml=newxml,action=delete,rc=genModRC);

                %let _ciRC=&genModRC.;

                filename remxsl;

                %end;
            %else %do;

                %issueMessage(messageKey=metadataGenerationFailed);

                %end;

            %if (%sysfunc(fileref(getrsp))<1) %then %do;
                filename getrsp;
                %end;
            filename newxml;

        %end;

     %if ("&rc." ne "" ) %then %do;
         %global &rc.;
         %let &rc.=&_ciRC.;
         %end;

%mend;
