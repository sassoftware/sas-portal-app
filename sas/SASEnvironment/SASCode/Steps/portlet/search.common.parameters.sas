
  put "<Query>%nrbquote(%sysfunc(tranwrd(&query.,&,&amp;)))</Query>";

  %if (%symexist(searchTypes)) %then %do;
     put "<SearchTypes>&SearchTypes.</SearchTypes>";
     %end;
