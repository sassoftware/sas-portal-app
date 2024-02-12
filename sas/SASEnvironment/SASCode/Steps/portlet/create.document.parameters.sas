     length line $1024;
     line=cats('<URI>',tranwrd("&url.",'&','&amp;'),'</URI>');
     put line;
     put "<ContentType>&contentType.</ContentType>";

