%macro genItems;

  %if (%symexist(PORTLETITEMSELECT_COUNT)) %then %do;
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
      %end;

%mend;

     %if (%symexist(selectedShowDescription)) %then %do;
        put "<ShowDescription>&selectedShowDescription.</ShowDescription>";
        %end;
     %if (%symexist(selectedShowLocation)) %then %do;
        put "<ShowLocation>&selectedShowLocation.</ShowLocation>";
        %end;
     %if (%symexist(selectedPackageSortOrder)) %then %do;
        put "<PackageSortOrder>&selectedPackageSortOrder.</PackageSortOrder>";
        %end;
     %if (%symexist(listChanged)) %then %do;
        put "<ListChanged>&listChanged.</ListChanged>";
        %end;

     put '<Items>';

     %genItems;

     put '</Items>';

