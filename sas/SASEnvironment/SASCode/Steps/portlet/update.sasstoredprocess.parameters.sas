
  %if (%symexist(portletPath)) %then %do;     
     put "<PortletPath>&portletPath.</PortletPath>";
     %end;

  %if (%symexist(portletHeight)) %then %do;     
     put "<PortletHeight>&portletHeight.</PortletHeight>";
     %end;

