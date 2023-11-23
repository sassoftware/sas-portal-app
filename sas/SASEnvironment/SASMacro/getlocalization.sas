/*
 *  This macro will return the appropriate file containing the localizations
 *  for the passed locale variable.
 */

%macro getLocalization(localeVar=_userlocale);
                %global localizationFile;
                
                /*
                 *  Calculate the appropriate localization file to use
                 */
                %let localizationDir=&filesDir./localization;
                %let defaultLocalization=&localizationDir./resources_en.xml;
                %let localizationFile=&defaultLocalization.;
                
                %if (%symexist(&localeVar.)) %then %do;
                
                    %let checkLocale=%lowcase(&&&localeVar.);
                    
                    %if ("&checkLocale." ne "en") %then %do;
                    
	                    %let localeFile=&localizationDir./resources_&checkLocale..xml;
	
	                    %if (%sysfunc(fileexist(&localeFile.))) %then %do;
	                        %let localizationFile=&localeFile.;
	                        %end;
	                    %else %do;
	
	                        /*
	                         * If the locale is in the form language_territory then see
	                         * if there is a file for the language only.
	                         */
	                        %if (%scan(&checkLocale.,2,'_') ne ) %then %do;
	                            %let localeFile=&localizationDir./resources_%scan(&checkLocale.,1,'_').xml;
	                            %if (%sysfunc(fileexist(&localeFile.))) %then %do;
	                                %let localizationFile=&localeFile.;
	                                %end;
	                            %else %do;
	                                %put User locale, &checkLocale., localization file does not exist.;
	                                %end;
	                            %end;    
	                        %else %do;
	                            %put User locale, &checkLocale., localization file does not exist.;
	                            %end;
	                        %end;
	                    %end;
	                    
                    %end;

%mend;