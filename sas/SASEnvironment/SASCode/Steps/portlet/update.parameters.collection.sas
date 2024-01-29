%macro genItems;

  %if (&PORTLETITEMSELECT_COUNT. > 1) %then %do;

      %do i=1 %to &PORTLETITEMSELECT_COUNT;
          put "<Item>%superq(PORTLETITEMSELECT&i.)</Item>";
      %end;
  %end;
  %else %do;
      %if (&PORTLETITEMSELECT_COUNT. = 1) %then %do;

          put "<Item>%superq(PORTLETITEMSELECT)</Item>";
      %end;
    %end;

%mend;

     put "<ShowDescription>&selectedShowDescription.</ShowDescription>";
     put "<ShowLocation>&selectedShowLocation.</ShowLocation>";
     put "<PackageSortOrder>&selectedPackageSortOrder.</PackageSortOrder>";
     put "<ListChanged>&listChanged.</ListChanged>";

     put '<Items>';

     %genItems;

     put '</Items>';

