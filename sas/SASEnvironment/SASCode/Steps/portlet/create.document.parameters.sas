     length line $1024;
     line=cats('<URI>',tranwrd("&url.",'&','&amp;'),'</URI>');
     put line;
     put "<ContentType>&contentType.</ContentType>";

     %if (%symexist(referenceId)) %then %do;
         put "<ReferenceId>&referenceId.</ReferenceId>";
         %end;
     %if (%symexist(referenceType)) %then %do;
         put "<ReferenceType>&referenceType.</ReferenceType>";
         %end;
