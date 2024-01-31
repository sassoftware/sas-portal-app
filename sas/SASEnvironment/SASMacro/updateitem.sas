/*  Save the changes made to an Item page */
%macro updateItem(rc=);

        /*
         *   For each item that is to be saved, there should be the following routines:
         *    -  a getter (that gets the existing metadata).
         *       NOTE: This is an xml file containing the metadata xml to get the existing info.
         *       The name of the file must be in the form &filesDir/portlet/edit.<itemtype>.get.xml.
         *       NOTE: This should be the same xml used to generate the edit page!
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

        %let updateItemGetter=&filesDir./portlet/edit.%lowcase(&searchType.).get.xml;

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

            filename inxml "&updateItemGetter.";

            filename request temp;

            data _null_;

              infile inxml ;
              file request;
              input;

              length line $400;
              /*
               *  Replace the passed id in the metadata request
               */
              line=transtrn(_infile_,'${TYPEID}',"&Id.");
              put line;
            run;

            /*
             *  Get the current values
             */

            filename outxml temp;

            proc metadata in=request out=outxml;
            run;

            filename inxml;
            filename request;

            %showFormattedXML(outxml,existing metadata xml);

            /*
             *  Append the parameters containing the new metadata to existing metadata
             */

            filename newxml temp;

            data _null_;
              infile outxml end=last;
              file newxml;
              input;
              if (_n_=1) then do;
                 put '<Mod_Request>';
                 end;
              put _infile_;

              if (last) then do;

                 parameterGenRC=0;

                 put '<NewMetadata>';

                 /*
                  *  Process Some common parameters
                  */

                 %if (%symexist(type)) %then %do;
                     put "<Type>&type.</Type>";
                     %end;

                 /*
                  * If the related object information was passed, pass that along
                  * so it can be included in any parameters that this page may call.
                  */

                 %if (%symexist(relatedId)) %then %do;
                     put "<RelatedId>&relatedId.</RelatedId>";
                     %end;

                 %if (%symexist(relatedType)) %then %do;
                     put "<RelatedType>&relatedType.</RelatedType>";
                     %end;

                 %if (%symexist(relatedRelationship) ne 0) %then %do;
                     put "<RelatedRelationship>&relatedRelationship.</RelatedRelationship>";
                     %end;

                 %if (%symexist(parentTreeId) ne 0) %then %do;
                     put "<ParentTreeId>&parentTreeId.</ParentTreeId>";
                     %end;

                 /* NOTE:  The parameter handler can set a return code, parameterGenRC,
                  *        that indicates a parameter error has occurred.
                  *        The return codes are:
                  *            0 = parameters processed successfully.
                  *            1 = parameters seem valid, but this type of update not supported
                  *            2 = invalid/missing parameters.  Details in parameterGenMsg.
                  */

                 %inc "&updateItemParameterHandler." / source2;

                 put "</NewMetadata>";
                 put "</Mod_Request>";

                 if (parameterGenRC ne 0) then do;

                    call symputx('_uiRC',parameterGenRC);
                    call symputx('_uiRCMessage',parameterGenMsg);

                    end;

                 end;
              run;

            filename outxml;

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

            filename newxml;

        %end;

     %if ("&rc." ne "" ) %then %do;
         %global &rc.;
         %let &rc.=&_uiRC.;
         %end;

%mend;
