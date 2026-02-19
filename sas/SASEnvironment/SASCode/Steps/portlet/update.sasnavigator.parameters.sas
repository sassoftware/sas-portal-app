
  %if (%symexist(Path)) %then %do;     
     put "<Path>&Path.</Path>";
     %end;


  %if (%symexist(checkboxIM)) %then %do;     
     put "<IM_SELECTED>&checkboxIM.</IM_SELECTED>";
     %end;
     %else %do;
         put "<IM_SELECTED>off</IM_SELECTED>";
     %end;


   %if (%symexist(hiddenIM)) %then %do;     
     put "<IM_ID>&hiddenIM.</IM_ID>";
     %end;

  %if (%symexist(checkboxSTP)) %then %do;     
     put "<STP_SELECTED>&checkboxSTP.</STP_SELECTED>";
     %end;
     %else %do;
         put "<STP_SELECTED>off</STP_SELECTED>";
     %end;


  %if (%symexist(hiddenSTP)) %then %do;     
     put "<STP_ID>&hiddenSTP.</STP_ID>";
     %end;


  %if (%symexist(checkboxReport)) %then %do;     
     put "<REPORT_SELECTED>&checkboxReport.</REPORT_SELECTED>";
     %end;
     %else %do;
         put "<REPORT_SELECTED>off</REPORT_SELECTED>";
     %end;

  %if (%symexist(hiddenReport)) %then %do;     
     put "<REPORT_ID>&hiddenReport.</REPORT_ID>";
     %end;




