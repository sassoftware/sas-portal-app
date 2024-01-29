/*
 *  Macro to generate an html page back to the user
 *  containing the message retrieved by the passed messageKey.
 */
%macro issueMessage(messageKey=,additionalText=,out=);

      %if ("&messageKey." = "") %then %do;

          %let _messageKey=genericError;

          %end;
      %else %do;

          %let _messageKey=&messageKey.;

          %end;

      %let messageProcessor=&filesDir./portlet/issue.message.xslt;
      filename _msgxsl "&messageProcessor.";

      filename _tmproot "&filesDir/portal/root.xml";

      %if ("&out."="") %then %do;

         %let _outfile=_webout;
         %end;

       %else %do;
         %let _outfile=&out.;
         %end;

      proc xsl in=_tmproot xsl=_msgxsl out=&_outfile.;
       parameter "appLocEncoded"="&appLocEncoded."
                 "sastheme"="&sastheme."
                 "localizationFile"="&localizationFile."
                 "messageKey"="&messageKey"
                 "additionalText"="&additionalText.";
      run;

      filename _tmproot;
      filename _msgxsl;

%mend;

