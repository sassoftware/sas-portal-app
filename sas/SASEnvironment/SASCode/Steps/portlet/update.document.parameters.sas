     put "<Name>&name.</Name>";
     put "<Desc>&desc.</Desc>";
     length line $1024;
     line=cats('<URI>',tranwrd("&url.",'&','&amp;'),'</URI>');
     put line;

