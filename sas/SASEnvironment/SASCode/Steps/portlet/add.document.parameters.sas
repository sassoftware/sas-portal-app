/*
 *  Add some additional information so it's available for the add generation routines.
 */

put '<Tabs>';

put '<Tab Id="create" NameKey="portletEditCreateTitle"/>';
put '<Tab Id="search" NameKey="portletEditSearchTitle"/>';

put '</Tabs>';

/*
 *  Allow some control over the height of the search results table
 */
     %if (%symexist(searchtablemaxheight)) %then %do;
         put "<SearchTableMaxHeight>&searchtablemaxheight.</SearchTableMaxHeight>";
         %end;


