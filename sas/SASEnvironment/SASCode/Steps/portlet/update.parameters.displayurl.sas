     put "<PortletHeight>&portletHeight.</PortletHeight>";
     length line $1024;
     line=cats('<PortletURL>',tranwrd("&portletURL.",'&','&amp;'),'</PortletURL>');
     put line;
