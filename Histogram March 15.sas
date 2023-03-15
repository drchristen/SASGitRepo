title "Histogram of Sepal Length";

proc sgplot data=sashelp.iris;
histogram sepallength / group=species transparency=0.5 scale=count; 
density sepallength / type=normal group=species; 
keylegend / location=inside position=topright across=1; 
run ; 
title;