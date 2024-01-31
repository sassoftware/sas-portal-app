
     %if (%symexist(scope)) %then %do;
         put "<Scope>&scope.</Scope>";
         %end;
     %if (%symexist(deletePortletsOnPage)) %then %do;
         put "<DeletePortletsOnPage>&deletePortletsOnPage.</DeletePortletsOnPage>";
         %end;
