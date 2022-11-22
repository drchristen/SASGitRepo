/****************************************************************************************************************
Change input parameter to GET_CH_Charts Macro (Singles or Albums)
*****************************************************************************************************************/

proc delete data=out.CH_albums_charts out.CH_singles_charts CH_albums_charts CH_singles_charts; run;

%Global NextURL;

%macro GET_CH_Charts(inurl=, Charts=Singles);

options nosource nosource nonotes errors=0; 

proc printto log="C:\Users\&sysuserid\Dropbox\__SAS Projects\_Temp_Area\UKChartsLog.log";
run;

%log (in=Off);

filename out "C:\Users\&sysuserid\Dropbox\__SAS Projects\_Temp_Area\UKCharts.html";

proc http out=out url="&inurl"    /* &inurl */
   /* PROXYHOST="srv01swt.unx.sas.com"
   PROXYPORT=80 */  
   method="get"
   ct="application/x-www-form-urlencoded";
run;

data tempin;
   infile out length=len truncover pad;
   input record $varying2000. len;
run;

data tempin;
   set tempin;
   %CHASCII (in=record,out=record);
run;

data tempin;
   set tempin;
   record2=record;
   %remove_html (infield=record2);
   record2=TRANWRD(record2,"amp;","and"); 
run;

data temp;
   set tempin;
   if record2 ne '';
run;

data temp; 
   format Artist Name $70.;
   set temp;
   if index(record2,'Schweizer')=0 then do;
      if index(record2,'2022') then do;
	     if index(record2,'Fred Again')=0 then do;
            if index(record2,'Januar ') or index(record2,'Februar ') or index(record2,'M�rz ')or index(record2,'April ') 
               or (index(record2,'Mai ') and index(record2,'Kunz')=0 ) or index(record2,'Juni ') or index(record2,'Juli ') or index(record2,'August ') 
	           or index(record2,'September ') or index(record2,'Oktober ') or index(record2,'November ') or index(record2,'Dezember ') then do;
	           call symputx('CHDate',left(trim(record2)));
		    end;
         end;
      end;
   end;
   %if &Charts=Singles %then %do;
      if index(record,'<a href="/song/') then do;
         artist=substr(record,index(record,'<a href="/song/')+15,70);
   %end;
   %else %do;
      if index(record,'<a href="/album/') or index(record,'<a href="/compilation/') then do;
	     if index(record,'<a href="/album/') then do;
            artist=substr(record,index(record,'<a href="/album/')+16,70);
	     end;
		 else do;
		    artist=substr(record,index(record,'<a href="/compilation/')+22,70);
		 end;
   %end; 
	  artist=substr(artist,1,index(artist,'/')-1);
      artist=TRANWRD(artist,"-"," ");
	  artist=TRANWRD(artist,"& ","");
	  artist=TRANWRD(artist,"  "," ");

      record2=TRANWRD(record2," - "," ");	
      record2=TRANWRD(record2,".","");
      record2=TRANWRD(record2,"ä","i"); 
	  
	  name=substr(record2,index(record2,left(trim(artist)))+length(left(trim(artist))),70);
   end;
run;

data temp;
   format Chart_Date $30.;
   set temp;
   Chart_Date="&CHDate";
   if artist ne '';
run;


data debug1; retain Chart_Date; set temp; run;

data temp2; 
   retain year month day Chart_Type ChartPos Artist Artist2 ST_Artist Name Name2 
      ST_Name featuring Label Url Orig_Obs;
   format day month z2. year z4. ChartPos 8. Label Name url $100.;
   set temp;
   Chart_Date=TRANWRD(Chart_Date,"Januar",".01.");
   Chart_Date=TRANWRD(Chart_Date,"Februar",".02.");
   Chart_Date=TRANWRD(Chart_Date,"März",".03.");
   Chart_Date=TRANWRD(Chart_Date,"April",".04.");
   Chart_Date=TRANWRD(Chart_Date,"Mai",".05.");
   Chart_Date=TRANWRD(Chart_Date,"Juni",".06.");
   Chart_Date=TRANWRD(Chart_Date,"Juli",".07.");
   Chart_Date=TRANWRD(Chart_Date,"August",".08.");
   Chart_Date=TRANWRD(Chart_Date,"September",".09.");
   Chart_Date=TRANWRD(Chart_Date,"Oktober",".10.");
   Chart_Date=TRANWRD(Chart_Date,"November",".11.");
   Chart_Date=TRANWRD(Chart_Date,"Dezember",".12.");
   Chart_Date=substr(Chart_Date,index(Chart_Date,".")-2,30);
   Chart_Date=left(trim(Chart_Date));
   Chart_Date=TRANWRD(Chart_Date,". .",".");
   Chart_Date=TRANWRD(Chart_Date,". 2",".2");
   day=input(substr(Chart_Date,1,2),2.);
   month=input(substr(Chart_Date,4,2),2.);
   year=input(substr(Chart_Date,7,4),4.);
   Chartpos=_N_;
   %if &Charts=Singles %then %do;
      url="https://hitparade.ch/charts/singles/"||left(trim(put(day,z2.)))||"-"||left(trim(put(month,z2.)))||"-"||left(trim(put(year,z4.))); 
      Chart_Type="CH Single"; 
   %end;
   %else %do;
      url="https://hitparade.ch/charts/alben/"||left(trim(put(day,z2.)))||"-"||left(trim(put(month,z2.)))||"-"||left(trim(put(year,z4.))); 
      Chart_Type="CH Album"; 
   %end;
   Orig_Obs=_N_;
   Keep year month day Chart_Type ChartPos Artist Artist2 ST_Artist Name Name2 
      ST_Name featuring Label Url Orig_Obs;
run;

/****************************************************************************************************************/
/* Get Next URL                                                                                                 */
/****************************************************************************************************************/

data temp;
   format yearn 4. monthn dayn nextdayn z2. nextday nextmonth $2. tempyear nextyear $4. nexturl $100.;   
   set temp2; 
   if _N_=1;
   dayn=day;
   yearn=year;
   monthn=month;

   if monthn=2 then do;
      if yearn=1968 or yearn=1972 or yearn=1976 or yearn=1980 or yearn=1984 or yearn=1988 or yearn=1992 or yearn=1996 or yearn=2000 or
         yearn=2004 or yearn=2008 or yearn=2016 or yearn=2020 or yearn=2024 or yearn=2028 then leap=29;
      else leap=28;
   end;
   else if month=1 or month=3 or month=5 or month=7 or month=8 or month=10 or month=12 then leap=31;
   else leap=30; 

   nextdayn=dayn+7;
   nextmonthn=monthn;
   nextyearn=yearn;

   if nextdayn gt leap then do;
      nextdayn=nextdayn-leap;
	  nextmonthn=monthn+1;
   end;
   if nextmonthn=13 then do;
      nextmonthn=1;
	  nextyearn=yearn+1;
   end;

   nextday=put(nextdayn,z2.);
   nextmonth=put(nextmonthn,z2.);
   nextyear=put(nextyearn,z4.);

   %if &Charts=Singles %then %do;
      nexturl="https://hitparade.ch/charts/singles/"||left(trim(nextday))||"-"||left(trim(nextmonth))||"-"||left(trim(nextyear)); 
   %end;
   %else %do;
      nexturl="https://hitparade.ch/charts/alben/"||left(trim(nextday))||"-"||left(trim(nextmonth))||"-"||left(trim(nextyear)); 
   %end;
   call symputx("NextURL",nexturl);
run;

%log (in=On);
%put ***** &NextURL;
%put &CHDate;
%log (in=Off);

%if &Charts=Singles %then %do;
   proc append data=temp2 base=CH_Singles_charts; run; 
%end;
%else %do;
   proc append data=temp2 base=CH_Albums_charts; run; 
%end;


options source source notes errors=0;

proc printto;
run; 


%mend;


%macro Loop_Through_Charts;

   %GET_CH_Charts(inurl=https://hitparade.ch/charts/alben/06-11-2022, Charts=Albums);;

   %do i=1 %to 1;

      %GET_CH_Charts(inurl=&NextURL,Charts=Albums);
   %end;
%mend;

%Loop_Through_Charts;



options source source notes errors=0;

proc printto;
run; 
