
  put "<Query>&query.</Query>";

  %if (%symexist(contentType)) %then %do;
     put "<ContentType>&ContentType.</ContentType";
     %end;
