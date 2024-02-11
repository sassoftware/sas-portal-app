%put SYSINCLUDEFILEDIR=&SYSINCLUDEFILEDIR;

     put "<Name>&Name.</Name>";
     %if (%symexist(Desc)) %then %do;
         put "<Desc>&Desc.</Desc>";
         %end;

     %if (%symexist(Keywords)) %then %do;
         put "<Keywords>&Keywords.</Keywords>";
         %end;

