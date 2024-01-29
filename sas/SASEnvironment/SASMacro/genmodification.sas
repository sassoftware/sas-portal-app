/* This macro will encapsulate the processing of generating
   an update metadata from the passed "new" xml
   The intent is that it should be able to handle different
   types of generated modifications (update, add, delete).

   Parameters:
     modxsl=a fileref pointing to the xsl to create the update
     newxml = the metadata xml in the "new" metadata format
     action = an indication of what type of modification is being generated
         update = an UpdateMetadata is being generated
         add    = an AddMetadata is being generated
         delete = a DeleteMetadata is being generated

     rc=a macro variable to set the return code of this macro execution
 */
%macro genModification(modxsl=,newxml=,rc=,action=);

    /*
     *  Now generate the necessary request
     */

    filename modreq temp;

    proc xsl in=&newxml. xsl=&modxsl. out=modreq;
       parameter "appLocEncoded"="&appLocEncoded."
                 "sastheme"="&sastheme."
                 "localizationFile"="&localizationFile."
      ;
    run;

    %if ("%lowcase(&action.)"="update") %then %do;

        %let searchMessage=UpdateMetadata;
        %end;
    %else %if ("%lowcase(&action.)"="add") %then %do;

        %let searchMessage=AddMetadata;
        %end;
    %else %if ("%lowcase(&action.)"="delete") %then %do;

        %let searchMessage=DeleteMetadata;
        %end;
    %else %do;

        /*  No additional searching will be done on the result */

        %let searchMessage=;

        %end;
   
    %checkXSLResult(xml=modreq,rc=_genmodrc,msg=Generate &searchMessage. request,search=&searchMessage.);

    %if ( &_genmodrc.<=0) %then %do;

        %if (&_genmodrc.=0) %then %do;

            /*
             *  The request was created successfully, execute it
             */

            filename modresp temp;

            /*
             * If we are in dryrun mode, then only display the request that would have
             * been submitted, don't execute it.
             */

            %if (%symexist(dryrun)) %then %do;

                %showFormattedXML(modreq,DryRun: Metadata Request that would have been submitted.,force=1);

                %end;
            %else %do;
                proc metadata in=modreq out=modresp;
                run;
                %showFormattedXML(modresp,Metadata Response);
                %end;

            filename modresp;

            %end;
        %else %do;

            %put "TODO: What should we do here";
            %put "Modification request as not created.";

            %showFormattedXML(modreq,Generated Metadata Request that that did not meet search criteria.,force=1);

            %let _genmodrc=-1;

            %end;
        %end;

    %else %do;

        %put "TODO: What should we do here?";
        %put "ERROR: Modification request generation failed.";
        %end;

    filename modreq;

    %if  ("&rc." ne "") %then %do;
         %global &rc.;
         %let &rc.=&_genmodrc.;
         %end;

%mend;

