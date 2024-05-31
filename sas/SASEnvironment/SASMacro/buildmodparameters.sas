/*
 *  This macro will build the "Mod_Request" xml format
 *  that will be processed later by an xslt file.
 *  Parameters:
 *    fileref=the fileref to add the content to
 *    handler=(optional) a fileref that will be called to include other parameters.
 *      NOTE:  The parameter handler can set a return code, parameterGenRC,
 *               that indicates a parameter error has occurred.
 *              The return codes are:
 *                  0 = parameters processed successfully.
 *                  1 = parameters seem valid, but this type of create not supported
 *                  2 = invalid/missing parameters.  Details in parameterGenMsg.
 *   rc= a macro variable that should contain the return code of the parameter generation.
 *   merge=a fileref pointing to a Metadata response that should be merged into the output file
 *         for example, the output file will look like:
 *         <Mod_Request>
 *           content of file pointed to by the merge parameter
 *           
 *           new content created by this macro
 *         </Mod_Request>
 */

%macro buildModParameters(fileref,handler,rc=,merge=);

       %if ("&merge." ne "") %then %do;
            data _null_;
              infile &merge. end=last;
              file &fileref.;
              input;
              if (_n_=1) then do;
                 put '<Mod_Request>';
                 end;
              put _infile_;
        
              if (last) then do;
            %end;
         %else %do;
                
            data _null_;
              file &fileref.;
              put '<Mod_Request>';
            %end;

              parameterGenRC=0;

              put '<NewMetadata>';

              put "<Type>&type.</Type>";

              /*
               * Current metadata context 
               */

              put "<Metauser>&_metauser.</Metauser>";
              put "<Metaperson>&_metaperson.</Metaperson>";
              %if (%symexist(reposname)) %then %do;
                  put "<Metarepos>&reposname.</Metarepos>";
                  %end;
              %if (%symexist(reposid)) %then %do;
                  put "<Metareposid>&reposid.</Metareposid>";
                  %end;

              %if (%symexist(metadataContext)) %then %do;
                  put "<MetadataContext>&metadataContext.</MetadataContext>";
                  %end;

              /*
               *  Current environment context
               */
               %if (%symexist(appLocEncoded)) %then %do;
                   put "<AppLocEncoded>&appLocEncoded.</AppLocEncoded>";
                   %end;
               %if (%symexist(sastheme)) %then %do;
                   put "<SASTheme>&sastheme.</SASTheme>";
                   %end;
               %if (%symexist(localizationFile)) %then %do;
                   put "<LocalizationFile>&localizationFile.</LocalizationFile>";
                   %end;
 
              /*
               * For an update or delete request, the Id field should be filled in.
               */

              %if (%symexist(id)) %then %do;
                  put "<Id>&Id.</Id>";
                  %end;

              %if (%symexist(portletType)) %then %do;
                  put "<PortletType>&portletType.</PortletType>";
                  %end;

              %if (%symexist(name)) %then %do;
                  put "<Name>%nrbquote(%sysfunc(tranwrd(&Name.,&,&amp;)))</Name>";
                  %end;
              %if (%symexist(desc)) %then %do;
                  put "<Desc>%nrbquote(%sysfunc(tranwrd(&desc.,&,&amp;)))</Desc>";
                  %end;
              %if (%symexist(keywords)) %then %do;
                  put "<Keywords>%nrbquote(%sysfunc(tranwrd(&Keywords.,&,&amp;)))</Keywords>";
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

              %if ("&handler." ne "") %then %do;
   
                  %inc &handler. / source2;

                  %end;

              put "</NewMetadata>";
              put "</Mod_Request>";

              %if ("&rc" ne "") %then %do;
                call symputx("&rc.",parameterGenRC,'G');
                %end;
       %if ("&merge." ne "") %then %do;
              end;
           %end;
      run;
%mend;

