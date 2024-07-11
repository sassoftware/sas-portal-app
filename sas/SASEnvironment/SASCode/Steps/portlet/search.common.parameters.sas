
  put "<Query>%nrbquote(%sysfunc(tranwrd(&query.,&,&amp;)))</Query>";

  %if (%symexist(contentType)) %then %do;
     put "<ContentType>&ContentType.</ContentType>";
     %end;
