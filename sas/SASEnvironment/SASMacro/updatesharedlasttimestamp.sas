/*
 *  The passed value must be in a java milliseconds format!
 */

%macro updateSharedLastTimestamp(timestampId=,timestamp=,timestampFormat=javamillis);

/*
 *  Update the last checked timestamp
 */

data _null_;
   
   uri=cats("omsobj:Property?@Id='","&timestampId.","'");
   rc=metadata_setattr(uri,
                        "DefaultValue",
                        "&timestamp.");
    if (rc ne 0) then do;
       put "ERROR: Updating of last sharing check timestamp failed.";
       end;

run;

%mend;