%macro getRepoInfo;

   /*
    *  Check to see if the repoxml fileref is already assigned.
    *  If it is, then just use it.
    *  If it isn't, then get it now.
    */

   %let repoxmlFileref=repoxml;

   %if (%sysfunc(fileref(&repoxmlFileref.))>0) %then %do;

       /*
        *  Make the current repository name available as a macro variable.
        */

       %global reposname;
       %let reposname=%sysfunc(dequote(%sysfunc(getoption(METAREPOSITORY))));

       /* 
        *  Doesn't exist, get it now
        */
       filename &repoxmlFileref. temp;

       /*
        *  Get the repository information from the server
        */

       filename _cptrxml "&filesDir./portal/getRepositories.xml";

       proc metadata in=_cptrxml out=&repoxmlFileref.;
       run;

       filename _cptrxml;

       /*
        *  Get the id of the current repository
        */

       filename repomap "&filesDir./portal/getRepositories.map";

      libname repoxml xmlv2 xmlmap=repomap xmlfileref=repoxml;
       %global reposid;
      proc sql noprint;
        select id into :reposid
        from repoxml.repos
        where name="&reposname.";
        run;
        quit;

       libname repoxml;
       filename repomap;


       %end;

%mend;

