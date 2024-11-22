
  put "<Path>&Path.</Path>";

  %if (%symexist(objectFilter)) %then %do;
     put "<ObjectFilter>&ObjectFilter.</ObjectFilter>";
     %end;

  %if (%symexist(folderId)) %then %do;
     put "<FolderId>&folderId.</FolderId>";
     %end;


  %if (%symexist(navigatorId)) %then %do;
     put "<NavigatorId>&navigatorId.</NavigatorId>";
     %end;
