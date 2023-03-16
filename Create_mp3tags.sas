/*    %TITLE%\%ARTIST%\%ALBUM%\%YEAR%\%RELEASETIME%\%DATE%\%COMMENT%\%WWW%\%PUBLISHER%\%BPM%\%contentgroup%\%genre%\%composer%\%conductor%\%mood%\%ENCODEDBY%\%Proper_Artist%\%Proper_Album%\%Proper_Name% */
/* C:\Users\Daniel Christen\Dropbox\__Music\iTunes Library\iTunes Analysis\Temp_m3u\Taglist.txt */
options obs=max nosyntaxcheck;
%include "Y:\SAS Projects\Daniels_Library\SAS Macro Library\_setup.sas";

%deleteAll;
%Global Rerun Delete SetBestFlag Compilation
   ObsStart ObsEnd DefaultGenre buydate store storeplace country Googlex Download CoverURL ExecCover Entry Discogs Highyear Precheck Exist;

/** %WINDOW defines the prompt **/
%Let buydate=%sysfunc(today(), YYMMDD10.);
%Let Entry=Go;
%Let Highyear=2023;
%Let storeplace=Zurich;
%Let country=CH;

%Let SetBestFlag=Yes;
%Let Compilation=No;
%Let Rerun=No;                                     /* Yes No Adding */
%Let Delete=Yes;

%Let store=Karl-Heinz Saxer;
%Let store=rutracker.org;
%Let store=iTunes;

%LET ExecCover=No;
%Let CoverURL=https://secondhandsongs.com/artist/37269/covers#nav-entity;
%Let Googlex=iTunes;      /* Yes, No, Manual, Studio, iTunes */
%Let ExecDiscogs=No;
%Let Precheck=No;


%window info
  #5 @5 'Buydate'
  #5 @26 buydate 15 attr=underline
  #6 @5 'Store'
  #6 @26 store 25 attr=underline
  #7 @5 'Storeplace'
  #7 @26 storeplace 15 attr=underline
  #8 @5 'Country'
  #8 @26 country 15 attr=underline
  #9 @5 'DefaultGenre'
  #9 @26 DefaultGenre 15 attr=underline
  #10 @5 'Download'
  #10 @26 Download 15 attr=underline
  #11 @5 'Highest Year'
  #11 @26 Highyear 4 attr=underline
  #13 @5 'Set Best Flag'
  #13 @26 SetBestFlag 4 attr=underline
  #14 @5 'Compilation'
  #14 @26 Compilation 4 attr=underline
  #15 @5 'Rerun'
  #15 @26 Rerun 4 attr=underline
  #16 @5 'Delete After Run'
  #16 @26 Delete 4 attr=underline
  #18 @5 'Execute Cover Search'
  #18 @26 ExecCover 4 attr=underline
  #19 @5 'Cover URL'
  #19 @26 CoverURL 60 attr=underline
  #20 @5 'Execute Year Lookup'
  #20 @26 ExecDiscogs 4 attr=underline
;
/** %DISPLAY invokes the prompt **/
%display info;

%Exist (in=Google);

%if &exist=Yes %then %do;
   Data Googlex; set google; run; 
%end;

%macro precheckit;
   %if &SetBestFlag ne Yes %then %do;
      %Messagebox (message1=Attention, message2=Set Best Flag Deactivated, message3=);
   %end;
   %if &Rerun eq Yes %then %do;
      %Messagebox (message1=Attention, message2=Rerun Activated, message3=);
   %end;
   %if &ExecCover eq Yes %then %do;
      %Messagebox (message1=Attention, message2=Manual Cover Version Search Activated, message3=);
   %end;
%mend;
%precheckit;

%macro compilation2;
%if &compilation=Yes %then %do;
   %mp3tag (Readonly=Yes);
   /* %mp3tag (Correctalbum=No, KeepOrigAlbum=Yes, KeepOrigName=Yes); */
%end;
%else %do;
   %mp3tag (Correctalbum=No); 
%end;
%mend;
%compilation2;


data Keeperx;
   format discogs_k $200. producer_k $600. bonus_k $3. Q95_k $3. X103_k $3. Teenage_k $3. Childhood_k $3. Roadtrip_k $3. Rating_k $20. Chhit_k $3. Upstairs_k $3. London_k $3. Comment_k $600.;
   set mp3tag;
   discogs_k=discogs;
   producer_k=producer;
   bonus_k=bonus;
   Q95_k=Q95;
   X103_k=X103;
   Teenage_k=Teenage;
   Childhood_k=Childhood;
   Roadtrip_k=Roadtrip;
   Rating_k=Rating;
   Chhit_k=Chhit;
   Upstairs_k=Upstairs;
   London_k=London;
   Comment_k=Comment;
   keep songID discogs_k producer_k bonus_k Q95_k X103_k Teenage_k Childhood_k Roadtrip_k Rating_k Chhit_k Upstairs_k London_k Comment_k;
run;

%if &compilation=Yes %then %do;
   %Log(in=On);
   %put Executing Compilations;
   %compilation (first=1793, last=1994);

   data Mp3tag_song_new;
      set mp3tag;
	  drop xorig_artist xorig_album xorig_name;
   run;
   %put Going To Done;
%end;

%if &compilation=No %then %do;

data mp3tag;
   set mp3tag;
   drop xorig_artist xorig_album xorig_name;
run;


/********************************************************************************************************/
/* Keep Discogs and Producer Bonus Q95 X103 Teenage Childhood Roadtrip Information                      */
/********************************************************************************************************/

data _NULL_;
   set mp3tag;
   call symputx('ObsStart',_N_);
run;

/********************************************************************************************************/
/* Check for missing Songs                                                                              */
/********************************************************************************************************/

%Macro Precheck (Execute=Yes);

%if &Execute=Yes %then %do;

%Log (in=On);

%PUT *** Performing Precheck;

%Log (in=Off);

   proc delete data=precheck; run;
   data _NULL_;
      set Mp3tag_artist;
      call symputx("Nobs1",_N_);
   run;

   %do i=1 %TO &Nobs1;
      data _NULL_;
         set Mp3tag_artist;
         if _N_ eq &i;
         call symputx("ST_Artist",ST_Artist);
      run;

      data temp;
         set itunes.main;
         if ST_Artist="&ST_Artist";
         keep ST_Artist ST_Name album_artist album location_na;
      run;

      data temp2;
         set mp3tag_song;
         if ST_Artist="&ST_Artist";
         keep ST_Artist ST_Name;
      run;

      proc sort data=temp nodupkey; by ST_Artist ST_Name; run;
      proc sort data=temp2 nodupkey; by ST_Artist ST_Name; run;

      data temp3;
         merge temp (in=a) temp2 (in=b);
         by ST_Artist ST_Name;
         if a and not b;
      run;

      proc append base=Precheck data=temp3; run;

   %end;
   %obscnt(work.Precheck);

   %if &nobs=0 %then %do;
   /* Nothing */
   %end;
   %else %do;
      %Messagebox (message1=Missing Songs, message2=Check work.Precheck, message3=);
   %end;
   proc delete data=temp temp2 temp3 precheck; run;
%end;
%Mend;

%precheck (Execute=&Precheck);


/********************************************************************************************************/
/* Get Information from Details_Artist Dataset : Album_Release_Year, Release_Date, Product, Buy_Date, Store, Storeorigin                                                                                         */
/********************************************************************************************************/

%Macro Complete_Artist;

%Log (in=On);

%PUT *** Completing Artist;

%Log (in=Off);

   proc delete data=mp3tag_artist_new; run;

   data _NULL_;
      set Mp3tag_artist;
      call symputx("Nobs1",_N_);
   run;

   %do i=1 %TO &Nobs1;

      data _NULL_;
         set Mp3tag_artist;
         if _N_ eq &i;
         call symputx("ST_Artist",ST_Artist);
      run;

      data temp;
         set out.Details_Artist;
         if ST_Artist="&ST_Artist";
      run;

      %obscnt(work.temp);

      %if &nobs=0 %then %do;
         data temp;
		    set out.Details_Artist;
		 run;
        
		 proc sort data=temp; by id; run;

	     data _NULL_;
	        set temp;
			call symputx("LOBS",ID);
		 run;

         %Messagebox (message1=Update Table out.Details_Artist, message2=Last Used ID &LOBS, message3=&ST_Artist);

         data temp;
            set out.Details_Artist;
            if ST_Artist="&ST_Artist";
         run;
      %end;

      data Song_Metadata;
         set out.Song_Metadata;
      run;

      data temp2;
         set Song_metadata;
         if ST_Artist="&ST_Artist";
         keep st_artist tagline;
      run;

      %obscnt(work.temp2);

      %if &nobs=0 %then %do;
         %Messagebox (message1=Update Table, message2=work.Song_Metadata, message3=&ST_Artist);

         data out.Song_Metadata;
            set Song_Metadata;
         run;

         data out.Song_Metadata;
            set out.Song_Metadata;
            if Tagline='' then do;
               Tagline="#Drums("||left(trim(Drums))||") #Bass("||left(trim(put(Bass,2.)))||") #Guitar("||left(trim(put(Guitar,2.)))||") #Synth("||
                                  left(trim(put(Synth,2.)))||") #Strings("||left(trim(put(Strings,2.)))||") #Horns("||left(trim(put(Horns,2.)))||") #Bagpipe("||
                                  left(trim(put(Bagpipe,2.)))||") #Piano("||left(trim(put(Piano,2.)))||") #Heavy("||left(trim(put(Heavy_Factor,2.)))||") #Dance(";
               Tagline2=left(trim(put(Dance_Factor,2.)))||") #Feelgood("||left(trim(put(Feelgood_Factor,2.)))||") #Summer("||left(trim(put(Summer_Factor,2.)))||") #Melancholy("||
                                  left(trim(put(Melancholy_Factor,2.)))||") #Relevance("||left(trim(put(Relevance,2.)))||") #Quirky("||left(trim(put(Quirky,2.)))||") #Decade("||left(trim(put(Decade_Factor,2.)))||")";
               do z=1 to 20;
                  Tagline=TRANWRD(Tagline," )",")");
                  Tagline2=TRANWRD(Tagline2," )",")");
               end;
               Tagline=left(trim(Tagline))||left(trim(Tagline2));
            end;
            drop Tagline2 z;
         run;

         data temp2;
            set out.Song_Metadata;
            if ST_Artist="&ST_Artist";
            keep st_artist tagline;
         run;
      %end;

      data temp3;
         set Mp3tag_artist;
         if ST_Artist="&ST_Artist";
         keep NewLib Artist Artist2 ST_Artist Danchris;
      run;

      proc sort data=temp3 nodupkey; by ST_Artist; run;
      proc sort data=temp nodupkey; by ST_Artist; run;
      proc sort data=temp2 nodupkey;  by ST_Artist; run;

      data temp3;
         merge temp3 temp temp2;
         by ST_Artist;
      run;

      proc append data=temp3 base=mp3tag_artist_new; run;

      proc delete data=temp temp2 temp3 Song_Metadata; run;
   %end;
%mend;

%Complete_Artist;

/*********************************************************************************************************/
/* Complete Album                                                                                        */
/*********************************************************************************************************/

%macro Complete_Album (Replace=No, Google=No, Allmusic=Yes);

%Log (in=On);

%PUT *** Completing Album;

%Log (in=Off);

   proc delete data=mp3tag_album_new; run;

   data _NULL_;
      set Mp3tag_artist;
      call symputx("Nobs1",_N_);
   run;

   %do i=1 %TO &Nobs1;

      data _NULL_;
         set Mp3tag_artist;
         if _N_ eq &i;
         call symputx("ST_Artist",ST_Artist);
      run;

      data temp (rename=(Compilation=MCompilation Live_Album=MLive_Album Single=MSingle
            albumoverall_best=Malbumoverall_best store=MStore storeplace=MStoreplace Country=MStoreCountry price=MPrice Quality=MQuality
            Album_Rating=MAlbum_Rating Product=MProduct Download=MDownload Manufac=MManufac Bootleg=MBootleg));
         format MBuy_Date $10. x_albumoverall_best $11. AlbumRating $7. MYear $4.;
         set itunes.main;
         if ST_Album_Artist="&ST_Artist";
         MBuy_Date=left(trim(buy_yearc))||"-"||left(trim(buy_monthc))||"-"||left(trim(buy_dayc));
         x_albumoverall_best=put(albumoverall_best,8.3);
         if Album_Rating=100 then AlbumRating='5-Stars';
         else if Album_Rating=80 then AlbumRating='4-Stars';
         else if Album_Rating=60 then AlbumRating='3-Stars';
         else if Album_Rating=40 then AlbumRating='2-Stars';
         else if Album_Rating=20 then AlbumRating='1-Stars';
         else AlbumRating='';
         Chartpos=Chartpos1;
         MYear=put(Year,4.);
      run;

      data temp;
         set temp;
         keep ST_Album_Artist ST_Album MAlbum_Rating MCompilation MLive_Album MSingle MBootleg Malbumoverall_best
            Mstore MStoreplace Mprice MQuality MProduct MStoreCountry MDownload MBuy_Date MManufac MYear AlbumRating x_albumoverall_best Chartpos Allrank Rank;
      run;

      %obscnt(work.temp);

      %if &nobs=0 %then %do;

         data temp3;
            format Album_Type_BU $200.;
            set Mp3tag_album;
            if ST_Artist="&ST_Artist";
            Album_Type_BU=Album_Type;
         run;

      %end;
      %else %do;
         data temp2;
            format Album_Type_BU $200.;
            set Mp3tag_album;
            if ST_Artist="&ST_Artist";
            Album_Type_BU=Album_Type;
         run;

         proc sort data=temp; by st_album_artist st_album descending MYear; run;

         data temp;
            set temp;
            by st_album_artist st_album descending MYear;
            if first.st_album;
         run;

         proc sort data=temp nodupkey; by st_album_artist st_album; run;
         proc sort data=temp2; by st_album_artist st_album; run;

         data temp3;
            merge temp2 (in=a) temp (in=b);
            by st_album_artist st_album;
            if a;
         run;

         data temp3;
            set temp3;
            if Album_Release_Year='                                                                                                                                                                                                       .' then Album_Release_Year='';

            %if &Replace=Yes %then %do;
               if MYear ne '' and left(trim(MYear)) ne '.' then do;
                  Album_Release_Year=MYear;
               end;

               if MLive_Album='Yes' then Album_Type='Live Albums';
               else if MBootleg='Yes' then Album_Type='Bootlegs';
               else if MSingle='Yes' then Album_Type='Singles';
               else if MCompilation='Yes' then Album_Type='Compilations';
               else do;
                  if album_type ne 'Live Albums' and album_type ne 'Singles'
                     and album_type ne 'Compilations' and album_type ne 'Bootlegs' then Album_Type='Studio Albums';
               end;
               if MStore ne '' then Store=MStore;
               if MStoreCountry ne '' then Storeorigin=MStoreCountry;
               if MStorePlace ne '' then Storeplace=MStorePlace;
               if MPrice ne . then Price=put(MPrice,3.2);
               if Price='.00' then Price='0.00';

               if MProduct ne '' then Product=MProduct;
               if MBuy_Date ne '' then Buy_Date=MBuy_Date;
               if MDownload ne '' then Download=MDownload;

               if Download='' then Download='No';

               if MQuality ne '' then Quality=MQuality;

            %end;
            %else %do;

               if MYear ne '' and left(trim(MYear)) ne '.' then do;
                  if Album_Release_Year='' or Album_Release_Year > MYear then Album_Release_Year=MYear;
               end;
               if Album_Type='' then do;
                  if MLive_Album='Yes' then Album_Type='Live Albums';
                  else if MBootleg='Yes' then Album_Type='Bootlegs';
                  else if MSingle='Yes' then Album_Type='Singles';
                  else if MCompilation='Yes' then Album_Type='Compilations';
                  else Album_Type='Studio Albums';
               end;

               if Store='' then Store=MStore;
               if Storeorigin='' then Storeorigin=MStoreCountry;
               if Storeplace='' then Storeplace=MStorePlace;
               if Price='' then Price=put(MPrice,3.2);
               if Price='.00' then Price='0.00';

               if Product='' then Product=MProduct;
               if Buy_Date='' then Buy_Date=MBuy_Date;
               if Download='' then Download=MDownload;

               if Download='' then Download='No';

               if Quality='' then Quality=MQuality;

            %end;

            if Album_Type='Studio Albums' then Studio='Yes';
            else if Album_Type='Live Albums' then LiveAlbum='Yes';
            else if Album_Type='Bootlegs' then Bootleg='Yes';
            else if Album_Type='Compilations' then Compilation='Yes';
            else if Album_Type='Singles' then Single='Yes';

            if Studio='' then Studio='No';
            if Single='' then Single='No';
            if Bootleg='' then Bootleg='No';
            if LiveAlbum='' then LiveAlbum='No';
            if Compilation='' then Compilation='No';

            Album_Release_Year=left(trim(Album_Release_Year));

            drop MAlbum_Rating MCompilation MLive_Album MSingle Malbumoverall_best
                  Mstore Mstoreplace Mprice MQuality MProduct MDownload MBuy_Date MStoreplace MYear MBootleg MStoreCountry;
          run;
      %end;

      proc append data=temp3 base=mp3tag_album_new; run;
      proc delete data=temp temp2 temp3; run;

      data temp;
         set out.Details_album_new;
         if ST_Album_Artist="&ST_Artist";
         w_Producer=Producer;
      run;

      data temp;
         set temp;
         if left(trim(Producer))="&" then Producer='';
         if left(trim(w_Producer))="&" then w_Producer='';
         keep ST_Album_Artist ST_Album a_First_Release_Year w_release_dayc w_release_monthc w_release_yearc a_Label
            a_Catno  w_Producer Single Albumurl;
      run;

      %obscnt(work.temp);

      %if &nobs=0 %then %do;
         data Mp3tag_album_new;
            format w_release_dayc w_release_monthc $2. w_release_yearc $4. a_Catno $70.;
            set Mp3tag_album_new;
            if length(trim(Release_Date))=10 then do;
               w_release_yearc=substr(Release_Date,1,4);
               w_release_monthc=substr(Release_Date,6,2);
               w_release_dayc=substr(Release_Date,9,2);
            end;
            else if length(trim(Release_Date))=7 then do;
               w_release_yearc=substr(Release_Date,1,4);
               w_release_monthc=substr(Release_Date,6,2);
               w_release_dayc='';
            end;
            else if length(trim(Release_Date))=4 then do;
               w_release_yearc=substr(Release_Date,1,4);
               w_release_monthc='';
               w_release_dayc='';
            end;
            else do;
               w_release_yearc='';
               w_release_monthc='';
               w_release_dayc='';
            end;
            a_Catno='';
            if Album_Release_Year='' then Album_Release_Year=w_release_yearc;
            else if w_release_yearc ne '' and Album_Release_Year > w_release_yearc then Album_Release_Year=w_release_yearc;
         run;
      %end;
      %else %do;
         proc sort data=Mp3tag_album_new; by st_album_artist st_album single; run;
         proc sort data=temp nodupkey; by st_album_artist st_album single; run;

         data Mp3tag_album_new;
            merge Mp3tag_album_new (in=a) temp (in=b);
            by st_album_artist st_album single;
            if a;
            %if &Replace=Yes %then %do;
               if w_Producer ne '' then Producer=w_Producer;
               if a_Label ne '' then Label=a_Label;
            %end;
            %else %do;
               if Producer='' then Producer=w_Producer;
               if Label='' then Label=a_Label;
            %end;

            if a_First_Release_Year < Album_Release_Year and a_First_Release_Year ne '' then do;
               Album_Release_Year=a_First_Release_Year;
            end;
            if Release_Date ne '' then do;
               if substr(Release_Date,1,4) gt Album_Release_Year then do;
                  if length(trim(Release_Date))=10 then do;
                     Release_Date=left(trim(Album_Release_Year))||substr(Release_Date,5,6);
                  end;
                  else if length(trim(Release_Date))=7 then do;
                     Release_Date=left(trim(Album_Release_Year))||substr(Release_Date,5,3);
                  end;
                  else if length(trim(Release_Date))=4 then do;
                     Release_Date=Album_Release_Year;
                  end;
               end;
            end;

            if length(trim(Release_Date))=10 then do;
               if w_release_yearc='' then w_release_yearc=substr(Release_Date,1,4);
               if w_release_monthc='' then w_release_monthc=substr(Release_Date,6,2);
               if w_release_dayc='' then w_release_dayc=substr(Release_Date,9,2);
            end;
            else if length(trim(Release_Date))=7 then do;
               if w_release_yearc='' then w_release_yearc=substr(Release_Date,1,4);
               if w_release_monthc='' then w_release_monthc=substr(Release_Date,6,2);
            end;
            drop a_First_Release_Year a_Label w_Producer;
         run;
      %end;
      data Mp3tag_album_new;
         set Mp3tag_album_new;
         if w_release_yearc='' then w_release_yearc=left(trim(Album_Release_Year));
         if Release_Date='' then Release_Date=left(trim(Album_Release_Year));
         if w_release_yearc ne '' and w_release_yearc le substr(Release_Date,1,4) then do;
            Release_Date=w_release_yearc;
            if w_release_monthc ne '' then Release_Date=left(trim(Release_Date))||"-"||left(trim(w_release_monthc));
            if w_release_dayc ne '' then Release_Date=left(trim(Release_Date))||"-"||left(trim(w_release_dayc));
         end;
      run;
   %end;

   data tempmp3tag;
      set Mp3tag_album_new;
      if length(trim(Release_Date)) ne 10;
   run;

   %obscnt(work.tempmp3tag);

   %if &nobs=0 %then %do;
      proc delete data=google; run;
   %end;
   %else %if &Google=Manual %then %do;
      data Google;
	     format Released2 Label2 Producer2 $600.;
	     retain ST_Album_Artist ST_Album AlbumID discogs Released2 Label2 Producer2;
	     set tempmp3tag;
		 keep T_Album_Artist ST_Album AlbumID discogs Released2 Label2 Producer2;
      run;

	  proc sort data=google nodupkey; by AlbumID; run;
	  proc sort data=google; by ST_Album; run;

	  %Messagebox (message1=Check Google Results, message2=work.Google, message3=);
	  %Clean_Up_Google;

      proc sort data=Mp3tag_album_new; by AlbumID; run;
      proc sort data=Google nodupkey; by AlbumID; run;

      data Mp3tag_album_new;
         merge Mp3tag_album_new (in=a) Google (in=b);
         by AlbumID;
         if a;
      run;

      data Mp3tag_album_new;
         retain AlbumID NewLib Artist Album Album_Release_Year Release_Date w_release_yearc w_release_monthc w_release_dayc;
         set Mp3tag_album_new;
/*************************************************************************************************/
/* Find Album_Release_Year                                                                       */
/*************************************************************************************************/
         if Release_Date ne '' then do;                        /* Get Date From Release_Date */
            Album_Release_Year=substr(Release_Date,1,4);
            if length(trim(Release_Date))=10 then do;
               w_release_yearc=substr(Release_Date,1,4);
               w_release_monthc=substr(Release_Date,6,2);
               w_release_dayc=substr(Release_Date,9,2);
            end;
            else if length(trim(Release_Date))=7 then do;
               w_release_yearc=substr(Release_Date,1,4);
               w_release_monthc=substr(Release_Date,6,2);
            end;
         end;
         else do;                                                /* Release Date Is Missing   */
            if w_release_yearc ne '' and google_release_yearc ne '' then do;
			   if google_release_yearc ne '' then Album_Release_Year=google_release_yearc;
               else if w_release_yearc le google_release_yearc then Album_Release_Year=w_release_yearc;
               else Album_Release_Year=google_release_yearc;
            end;
            else if w_release_yearc ne '' then Album_Release_Year=w_release_yearc;
            else Album_Release_Year=google_release_yearc;
            if google_release_yearc='' then google_release_yearc=Album_Release_Year;
         end;
/*************************************************************************************************/
/* Get Release_Date                                                                              */
/*************************************************************************************************/
         if length(trim(Release_Date))=10 then do;                /* Full Release Date Available */
            if album_release_year ne '' and trim(album_release_year) lt substr(release_date,1,4) then do;
               release_data=left(trim(album_release_year))||substr(release_date,5,6);
            end;
         end;
         if left(trim(Album_Release_Year)) ne '' then w_release_yearc=left(trim(Album_Release_Year));
         if Release_Date='' then Release_Date=left(trim(Album_Release_Year));
         drop Allmusic_Releasec;
      run;

      proc delete data=Albums; run;



   %end;
/*****************************************************************************************/
/* iTunes                                                                                */
/*****************************************************************************************/

   %else %if &Google=iTunes %then %do;
      data Google;
	     format Released2 Label2 Producer2 $600.;
	     retain ST_Album_Artist ST_Album AlbumID discogs Released2 Label2 Producer2;
	     set tempmp3tag;
		 keep T_Album_Artist ST_Album AlbumID discogs Released2 Label2 Producer2;
      run;

	  proc sort data=google nodupkey; by AlbumID; run;

      data temp;
	     set mp3tag;
		 keep albumid year;
	  run;

	  proc sort data=temp nodupkey; by albumid; run;
	  proc sort data=google; by albumid; run;

	  data google;
	     merge google (in=a) temp (in=b);
		 by albumid;
		 if a;
      run;

	  data google;
	     retain st_album_arist st_album albumid discogs Released2 Label2;
	     set google;
		 released2=year;
		 drop year;
	  run;

	  proc sort data=google; by ST_Album; run;

	  %Messagebox (message1=Check Google Results, message2=work.Google, message3=);
	  %Clean_Up_Google;

      proc sort data=Mp3tag_album_new; by AlbumID; run;
      proc sort data=Google nodupkey; by AlbumID; run;

      data Mp3tag_album_new;
         merge Mp3tag_album_new (in=a) Google (in=b);
         by AlbumID;
         if a;
      run;

      data Mp3tag_album_new;
         retain AlbumID NewLib Artist Album Album_Release_Year Release_Date w_release_yearc w_release_monthc w_release_dayc;
         set Mp3tag_album_new;
/*************************************************************************************************/
/* Find Album_Release_Year                                                                       */
/*************************************************************************************************/
         if Release_Date ne '' then do;                        /* Get Date From Release_Date */
            Album_Release_Year=substr(Release_Date,1,4);
            if length(trim(Release_Date))=10 then do;
               w_release_yearc=substr(Release_Date,1,4);
               w_release_monthc=substr(Release_Date,6,2);
               w_release_dayc=substr(Release_Date,9,2);
            end;
            else if length(trim(Release_Date))=7 then do;
               w_release_yearc=substr(Release_Date,1,4);
               w_release_monthc=substr(Release_Date,6,2);
            end;
         end;
         else do;                                                /* Release Date Is Missing   */
            if w_release_yearc ne '' and google_release_yearc ne '' then do;
			   if google_release_yearc ne '' then Album_Release_Year=google_release_yearc;
               else if w_release_yearc le google_release_yearc then Album_Release_Year=w_release_yearc;
               else Album_Release_Year=google_release_yearc;
            end;
            else if w_release_yearc ne '' then Album_Release_Year=w_release_yearc;
            else Album_Release_Year=google_release_yearc;
            if google_release_yearc='' then google_release_yearc=Album_Release_Year;
         end;
/*************************************************************************************************/
/* Get Release_Date                                                                              */
/*************************************************************************************************/
         if length(trim(Release_Date))=10 then do;                /* Full Release Date Available */
            if album_release_year ne '' and trim(album_release_year) lt substr(release_date,1,4) then do;
               release_data=left(trim(album_release_year))||substr(release_date,5,6);
            end;
         end;
         if left(trim(Album_Release_Year)) ne '' then w_release_yearc=left(trim(Album_Release_Year));
         if Release_Date='' then Release_Date=left(trim(Album_Release_Year));
         drop Allmusic_Releasec;
      run;

      proc delete data=Albums; run;



   %end;

/*****************************************************************************************/
/* Studio Only                                                                           */
/*****************************************************************************************/
   %else %if &Google=Yes Or &Google=Studio %then %do;

      %if &Google=Studio %then %do;
	     data Tempmp3tag;
		    set Tempmp3tag;
	        if Album_Type_BU="Studio Albums";
	     run;
      %end;
      %IF &Rerun=Yes %Then %Do;
         data google; set googlex; run; 
      %END;
	  %ELSE %DO;
         %Google_Search (indata=tempmp3tag);  
	  %END;


      proc sort data=Mp3tag_album_new; by AlbumID; run;
      proc sort data=Google nodupkey; by AlbumID; run;

      data Mp3tag_album_new;
         merge Mp3tag_album_new (in=a) Google (in=b);
         by AlbumID;
         if a;
      run;

      %if &Allmusic=Yes %then %do;
         %Allmusic_Search (indata=Mp3tag_album_new, Album=Album2, Artist=Artist2, AlbumID=AlbumID);

         proc sort data=Mp3tag_album_new; by AlbumID; run;
         proc sort data=Allmusic_release nodupkey; by AlbumID; run;

         data Mp3tag_album_new;
            merge Mp3tag_album_new (in=a) Allmusic_release (in=b);
            by albumid;
            if a;
         run;

         data Mp3tag_album_new;
            retain artist album Release_Date Google_Release Allmusic_releasec Flag1 Producer Google_Producer Flag2 Label Google_Label Flag3 Discogs Google_Discogs Flag4;
            format flag1 flag2 flag3 flag4 $1.;
            set Mp3tag_album_new;
            if substr(Release_Date,1,4) > substr(Allmusic_Releasec,1,4) and Allmusic_Releasec ne '' then Flag1='Y';
         run;
      %end;

      /* %Messagebox (message1=Check Google Results, message2=work.Mp3tag_Album_new, message3=); */

      data Mp3tag_album_new;
         retain AlbumID NewLib Artist Album Album_Release_Year Release_Date w_release_yearc w_release_monthc w_release_dayc;
         set Mp3tag_album_new;
/*************************************************************************************************/
/* Find Album_Release_Year                                                                       */
/*************************************************************************************************/
         if Release_Date ne '' then do;                        /* Get Date From Release_Date */
            Album_Release_Year=substr(Release_Date,1,4);
            if length(trim(Release_Date))=10 then do;
               w_release_yearc=substr(Release_Date,1,4);
               w_release_monthc=substr(Release_Date,6,2);
               w_release_dayc=substr(Release_Date,9,2);
            end;
            else if length(trim(Release_Date))=7 then do;
               w_release_yearc=substr(Release_Date,1,4);
               w_release_monthc=substr(Release_Date,6,2);
            end;
         end;
         else do;                                                /* Release Date Is Missing   */
            if w_release_yearc ne '' and google_release_yearc ne '' then do;
			   if google_release_yearc ne '' then Album_Release_Year=google_release_yearc;
               else if w_release_yearc le google_release_yearc then Album_Release_Year=w_release_yearc;
               else Album_Release_Year=google_release_yearc;
            end;
            else if w_release_yearc ne '' then Album_Release_Year=w_release_yearc;
            else Album_Release_Year=google_release_yearc;
            if google_release_yearc='' then google_release_yearc=Album_Release_Year;
         end;
/*************************************************************************************************/
/* Get Release_Date                                                                              */
/*************************************************************************************************/
         if length(trim(Release_Date))=10 then do;                /* Full Release Date Available */
            if album_release_year ne '' and trim(album_release_year) lt substr(release_date,1,4) then do;
               release_data=left(trim(album_release_year))||substr(release_date,5,6);
            end;
         end;
         if left(trim(Album_Release_Year)) ne '' then w_release_yearc=left(trim(Album_Release_Year));
         if Release_Date='' then Release_Date=left(trim(Album_Release_Year));
         drop Allmusic_Releasec;
      run;

      proc delete data=Albums; run;
   %end;
   %else %do;  /* Google Not Activated */
      data Mp3tag_album_new;
         format google_release_yearc $4. google_release_monthc google_release_dayc $2. google_producer google_label $70.
            google_discogs $600.;
         set Mp3tag_album_new;
         Google_Label='';
         Google_release_yearc='';
         Google_release_monthc='';
         Google_release_dayc='';
         google_producer='';
         google_discogs='';
      run;
   %end;

/*******************************************************************************************/
/* Add Google Date If Entered                                                              */
/*******************************************************************************************/

   data Mp3tag_album_new;
      set Mp3tag_album_new;
      if left(trim(Producer))="&" then Producer='';
      if Producer='' and google_producer ne '' then Producer=google_producer;
      if Albumurl='' then discogs=google_discogs;
      if Label='' then Label=google_label;
      if google_release_yearc ne '' and google_release_yearc le substr(Release_Date,1,4) and substr(Release_Date,1,4) ne '' and google_release_dayc ne '' then do;
            Release_Date=google_release_yearc;
            if google_release_monthc ne '' then Release_Date=left(trim(Release_Date))||"-"||left(trim(google_release_monthc));
            if google_release_dayc ne '' then Release_Date=left(trim(Release_Date))||"-"||left(trim(google_release_dayc));
      end;
      drop google_release_yearc google_release_monthc google_release_dayc google_producer google_label google_discogs;
   run;
%mend;


%Complete_Album (Replace=Yes, Google=&Googlex, Allmusic=No);


/****************************************************************************************************************/
/* Complete Song Information                                                                                    */
/****************************************************************************************************************/



%macro Complete_Song;


%Log (in=On);

%PUT *** Completing Songs;

%Log (in=Off);

   proc delete data=Mp3tag_song_new; run;

   data temp_album_artist;
      set Mp3tag_artist;
   run;

   proc sort data=temp_album_artist nodupkey; by st_artist; run;

   data _NULL_;
      set temp_album_artist;
      call symputx("Nobs1",_N_);
   run;

   %do i=1 %TO &Nobs1;

      data _NULL_;
         set temp_album_artist;
         if _N_ eq &i;
         call symputx("ST_Artist",ST_Artist);
      run;

      data main;
         set itunes.main;
         if st_album_artist="&ST_Artist";
      run;

      %obscnt(work.main);

      %if &nobs=0 or &ExecDiscogs=Yes %then %do;
         data temp3;
            format lowest_year $20.;
            set Mp3tag_song;
            if st_artist="&ST_Artist";
         run;
         %Log (in=On);

         %if &ExecDiscogs=Yes %then %do;

            proc sort data=Discogs_name; by ST_Artist ST_Name; run;
            proc sort data=temp3; by ST_Artist ST_Name; run;

            data temp3;
               merge temp3 (in=a) Discogs_name (in=b);
               by ST_Artist ST_Name;
               if a;
               if d_Name_Year ne '' then do;
			      if d_Name_Year ne '' then year=d_Name_Year;
                  /* if year='' or year > d_Name_Year then year=d_Name_Year; */ 
               end;
               lowest_year=year;
            run;

         %end;

         %Log (in=Off);

/*****************************************************************************************/
/* Do I need to invoke the Cover Version Search                                          */
/*****************************************************************************************/

         %if &ExecCover=No %then %do;
            %Log (in=On);

            %PUT *** Cover Search Not Executed - &CoverURL;

            %Log (in=Off);
         %end;
         %else %do;

            %Log (in=On);

            %PUT *** Executing Cover Search - &CoverURL - &ST_Artist;

            %Log (in=Off);
            %Get_Secondhandsongs (inurl=&CoverURL, inartist=&ST_Artist);

            %obscnt(work.Cover);

            %if &nobs=0 %then %do;
               /* Nothing */
            %end;
            %else %do;
               data cover;
                  format Coverversion $3.;
                  set cover;
                  Coverversion='Yes';
                  keep ST_Artist ST_Name Orig_Artist Coverversion CoverName CoverURL;
               run;

               data temp3;
                  set temp3;
                  drop Coverversion CoverName CoverURL Orig_Artist ;
               run;

               proc sort data=cover nodupkey; by ST_Artist ST_Name; run;
               proc sort data=temp3; by ST_Artist ST_Name; run;

               data temp3;
                  merge temp3 (in=a) cover (in=b);
                  by ST_Artist ST_Name;
                  if a;
               run;

               data temp3;
                  set temp3;
                  if Coverversion ne 'Yes' then Coverversion='No';
               run;
            %end;
         %end;
      %end;
      %else %do;

         data temp3;
            set Mp3tag_song;
            if st_album_artist="&ST_Artist";
            drop Acoustic Alt Chhit Chartyear Composer Danchris Demo Different Genre Holiday Language Livesong Newversion No1
               Rating Aftermarriage Australia Childhood ClassicPunk Dance Disco DIY Glam Goth HardRock ItaloDisco Kids
               London Gaby Madeleine Mainstream Mami Melancholia NDW NewWave Oldies PowerBallade Psychobilly Q95 Rap Rave Roadtrip
               Rochelle Rockabilly Sensless Sleaze Summer Teenage Upstairs USA X103 Rating;
         run;


         data main;
            format main_song_release_year $20.;
            set main;
            main_song_release_year=put(year,4.);
            if main_song_release_year='   .' then main_song_release_year='';
            keep ST_Artist ST_Name Acoustic Alt CH_Hit chartyear1 Composer DanChris Demo Different Genre Holiday Language_New /* Live_Song */ New_Version
               No1 Rating_New x_After_Marriage x_Australia x_Childhood x_Classic_Punk x_Dance x_Disco x_DIY x_Glam x_Goth
               x_Hard_Rock x_Italo_Disco x_Kids x_London x_Gaby x_Madeleine x_Mainstream_Rock x_Mami x_Melancholia x_NDW x_New_Wave
               x_Oldies x_Power_Ballade x_Psychobilly x_Q95 x_Rap x_Rave x_Roadtrip x_Rochelle x_Rockabilly x_Sensless x_Sleaze x_Summer
               x_Teenage x_Upstairs x_USA x_X103 main_song_release_year Rating_New;
         run;


         data main (rename=(CH_Hit=Chhit chartyear1=Chartyear Language_New=Language /* Live_Song=Livesong */ New_Version=Newversion
            x_After_Marriage=Aftermarriage x_Australia=Australia x_Childhood=Childhood x_Classic_Punk=ClassicPunk x_Dance=Dance
            x_Disco=Disco x_DIY=DIY x_Glam=Glam x_Goth=Goth x_Hard_Rock=HardRock x_Italo_Disco=ItaloDisco x_Kids=Kids x_London=London x_Gaby=Gaby
            x_Madeleine=Madeleine x_Mainstream_Rock=Mainstream x_Mami=Mami x_Melancholia=Melancholia x_NDW=NDW x_New_Wave=NewWave x_Oldies=Oldies
            x_Power_Ballade=PowerBallade x_Psychobilly=Psychobilly x_Q95=Q95 x_Rap=Rap x_Rave=Rave x_Roadtrip=Roadtripx x_Rochelle=Rochelle
            x_Rockabilly=Rockabilly x_Sensless=Sensless x_Sleaze=Sleaze x_Summer=Summer x_Teenage=Teenage x_Upstairs=Upstairs x_USA=USA
            x_X103=X103));
            set main;
         run;

         data main;
            format Rating;
            set main;
            if Rating_New=100 then Rating='5-Stars';
            else if Rating_New=80 then Rating='4-Stars';
            else if Rating_New=60 then Rating='3-Stars';
            else if Rating_New=40 then Rating='2-Stars';
            else if Rating_New=20 then Rating='1-Stars';
            drop Rating_New;
         run;

         proc sort data=main; by st_artist st_name main_song_release_year; run;

         data main;
            retain ST_Artist ST_Name main_song_release_year;
            set main;
            by st_artist st_name main_song_release_year;
            if first.st_name;
         run;

         data Details_Songs_new;
            set out.Details_Songs_new;
            if st_artist="&ST_Artist";
            if ST_Name ne '';
            ST_Name=TRIM(ST_Name);
         run;

         data Details_Songs_new;
            set Details_Songs_new;
            song_release_year=a_First_Release_Year;
            drop a_First_Release_Year;
         run;

         proc sort data=temp3; by st_Artist st_Name; run;
         proc sort data=main; by st_Artist st_Name; run;
         proc sort data=Details_Songs_new nodupkey; by st_Artist st_Name; run;

         data temp3;
            merge temp3 (in=a) main (in=b) Details_Songs_new (in=c);
            by ST_Artist ST_Name;
            if a;
         run;

/*****************************************************************************************/
/* Do I need to invoke the Cover Version Search                                          */
/*****************************************************************************************/

         %if &ExecCover=No %then %do;
            %Log (in=On);

            %PUT *** Cover Search Not Executed - &CoverURL;

            %Log (in=Off);
         %end;
         %else %do;

            %Log (in=On);

            %PUT *** Executing Cover Search - &CoverURL - &ST_Artist;

            %Log (in=Off);
            %Get_Secondhandsongs (inurl=&CoverURL, inartist=&ST_Artist);

            %obscnt(work.Cover);

            %if &nobs=0 %then %do;
               /* Nothing */
            %end;
            %else %do;
               data cover;
                  format Coverversion $3.;
                  set cover;
                  Coverversion='Yes';
                  keep ST_Artist ST_Name Orig_Artist Coverversion CoverName CoverURL;
               run;

               data temp3;
                  set temp3;
                  drop Coverversion CoverName CoverURL Orig_Artist ;
               run;

               proc sort data=cover nodupkey; by ST_Artist ST_Name; run;
               proc sort data=temp3; by ST_Artist ST_Name; run;

               data temp3;
                  merge temp3 (in=a) cover (in=b);
                  by ST_Artist ST_Name;
                  if a;
               run;

               data temp3;
                  set temp3;
                  if Coverversion ne 'Yes' then Coverversion='No';
               run;
            %end;
         %end;

/*****************************************************************************************/
/* See if there are already songs in the main database from this artist                  */
/*****************************************************************************************/

         data temp4;
            format existing_year $20.;
            set out.mp3tag;
            existing_year=Year;
            if st_artist="&ST_Artist";
            keep st_artist st_name name existing_year;
         run;

         %obscnt(work.temp4);

         %if &nobs=0 %then %do;
            data temp3;
               format existing_year $20.;
               set temp3;
               existing_year='';
            run;
         %end;
         %else %do;

            proc sort data=temp4 nodupkey; by st_artist st_name name; run;
            proc sort data=temp3; by st_artist st_name name; run;

            data temp3;
               merge temp3 (in=a) temp4 (in=b);
               by st_artist st_name name;
               if a;
            run;
         %end;

/*****************************************************************************************/
/* Get Lowest Year                                                                       */
/*****************************************************************************************/

         %if &ExecDiscogs=Yes %Then %do;
            proc sort data=Discogs_name; by ST_Artist ST_Name; run;
            proc sort data=temp3; by ST_Artist ST_Name; run;

            data temp3;
               merge temp3 (in=a) Discogs_name (in=b);
               by ST_Artist ST_Name;
               if a;
            run;
         %end;
         %else %do;
            data temp3;
               format d_Name_Year $4.;
               set temp3;
               d_Name_Year='';
            run;
         %end;

         data temp3;
            retain Artist Name year main_song_release_year song_release_year Chartyear;
            format lowest_year $20.;
            set temp3;
            if year ne '' then lowest_year=year;
            else if main_song_release_year ne '' then year=main_song_release_year;
            else if song_release_year ne '' then year=song_release_year;
            else if Chartyear ne '' then year=Chartyear;
            else if d_Name_Year ne '' then year=d_Name_Year;
            lowest_year=year;
            if lowest_year > main_song_release_year and main_song_release_year ne '' then lowest_year=main_song_release_year;
            if lowest_year > song_release_year and song_release_year ne '' then lowest_year=song_release_year;
            if lowest_year > Chartyear and Chartyear ne '' then lowest_year=Chartyear;
            if lowest_year > existing_year and existing_year ne '' then lowest_year=existing_year;
            if lowest_year > d_Name_Year and d_Name_Year ne '' then lowest_year=d_Name_Year;
            year=lowest_year;
            drop main_song_release_year song_release_year lowest_year;
         run;

         data temp;
            set temp3;
            if year='';
         run;

         %obscnt(work.temp);

         %if &nobs=0 %then %do;
         /* Nothing */
         %end;
         %else %do;
            %Messagebox (message1=Years Missing - Check, message2=work.temp3, message3=);
         %end;
      %end;

      data temp;
         set temp3;
         if cluster eq 2;
         keep ST_Artist ST_Name;
      run;

      %obscnt(work.temp);

      %if &nobs=0 %then %do;
         /* Nothing */
      %end;
      %else %do;

         data temp2;
            set temp3;
            keep ST_Artist ST_Name SongID Cluster Length timesec NameAddon NameAddon2;
         run;

         proc sort data=temp; by ST_Artist ST_Name; run;
         proc sort data=temp2; by ST_Artist ST_Name; run;

         data temp2;
            merge temp2 (in=a) temp (in=b);
            by ST_Artist ST_Name;
            if b;
         run;

         data temp2;
            set temp2;
            if index(NameAddon2,'Live')=0;
         run;

         data temp2;
            format x 8.;
            set temp2;
            if NameAddon2='Album Version';
            x=1;
         run;

         proc sort data=temp2; by ST_Artist ST_Name NameAddon2; run;

         proc freq data=temp2 noprint;
            by ST_Artist ST_Name NameAddon2;
            table Cluster * x /norow nocol nopercent out=Sum1;
         run;

         data sum1;
            set sum1;
            if PERCENT lt 99;
            keep st_artist st_name cluster;
         run;

         proc sort data=sum1 nodupkey; by st_artist st_name cluster; run;
         proc sort data=temp2; by st_artist st_name cluster; run;

         data temp2;
            merge temp2 (in=a) sum1 (in=b);
            by st_artist st_name cluster;
            if a and b;
         run;

         data temp2;
            set temp2;
            if index(NameAddon,'7 Mix') or index(NameAddon,'7" Mix') then NameAddon2='Singlemix';
            else if index(NameAddon,'Instrumental') then NameAddon2='Instrumental';
            else if index(NameAddon,'Mix') or index(NameAddon,'Remix') then NameAddon2='Remix';
            else if index(NameAddon,'Live') then NameAddon2='Live Version';
            else if index(NameAddon,'Session') then NameAddon2='Alt';
            else if index(NameAddon,'BBC') or index(NameAddon,'Bbc') then NameAddon2='Live Version';
         run;

         proc sort data=temp2 nodupkey; by ST_Artist ST_Name Cluster; run;

         proc sort data=temp2; by ST_Name timesec; run;

         data temp2;
            set temp2;
            by ST_Name timesec;
            if first.ST_Name then do;
               NameAddon2='Single Mix';
            end;
         run;

         data temp2;
            set temp2;
            if NameAddon2='Album Version';
         run;

         proc sort data=temp2; by ST_Artist ST_Name Cluster; run;

         %obscnt(work.temp2);
         %if &nobs=0 %then %do;
            /* Nothing */
         %end;
         %else %do;
		    proc sort data=temp2; by ST_Name timesec; run;

		    data temp2;
			   format z v w q 1.;
			   set temp2;
			   by ST_Name timesec;
			   if first.ST_Name then do;
			      z=1;
				  v=0;
				  w=0;
				  q=1;
			   end;
               if index(upcase(SongID),'MIX') then do;
                  NameAddon='Remix '||put(q,1.);
				  q=q+1;
			   end;
			   else if index(SongID,'Studio Albums') and v=0 then do;
                  NameAddon2='Album Version';
				  v=1;
			   end;
			   else if (index(SongID,'Compilations') and w=0) or (index(SongID,'Singles') and w=0) then do;
                  NameAddon='Single Mix';
			      w=1;
			   end;
			   else if index(SongID,'Live Albums') or index(SongID,'Bootlegs') then NameAddon2='Live Version';
			   else do;
                  NameAddon='Alt Version '||put(z,1.);
				  z=z+1;
			   end;
			   if not first.ST_Name and last.ST_Name then do;
                  if index(NameAddon,'Alt ') then NameAddon='Long Version';
			   end;
			   if first.ST_Name and last.ST_Name then NameAddon='Album Version';
			   retain z v w q;
			run;

            %Messagebox (message1=Check Cluster - work.temp2, message2=Live Version/Remix/Alt Version/Demo Version, message3=Acoustic Version/Different Version/Single Mix/New Version);

			data temp2;
			   set temp2;
			   if NameAddon ne '' then NameAddon2=NameAddon;
			run;

         %end;
         data temp2;
            set temp2;
            NameAddon2x=NameAddon2;
            keep ST_Artist ST_Name Cluster NameAddon2x;
         run;

         proc sort data=temp3; by ST_Artist ST_Name Cluster; run;
         proc sort data=temp2 nodupkey; by ST_Artist ST_Name Cluster; run;

         data temp3;
            merge temp3 (in=a) temp2 (in=b);
            by ST_Artist ST_Name Cluster;
            if a;
            if NameAddon2x ne '' then NameAddon2=NameAddon2x;
            drop NameAddon2x; 
         run;

		 data temp2x; retain ST_Artist ST_Name Cluster NameAddon NameAddon2; set temp2; run;
		 data temp3x; retain ST_Artist ST_Name Cluster NameAddon NameAddon2; set temp3; run;

         data temp3;
            set temp3;
            if NameAddon2='Live Version' then Livesong='Yes';
            else if index(NameAddon2,'Remix') then Remix='Yes';
            else if NameAddon2='Edit' then Singlemix='Yes';
            else if index(NameAddon2,'Alt Version') then Alt='Yes';
			else if index(NameAddon2,'Long Version') then Alt='Yes';
            else if NameAddon2='Demo Version' then Demo='Yes';
            else if NameAddon2='Acoustic Version' then Acoustic='Yes';
            else if NameAddon2='Different Version' then Different='Yes';
            else if NameAddon2='Single Mix' then SingleMix='Yes';
            else if NameAddon2='New Version' then NewVersion='Yes';
            else if NameAddon2='Acoustic' then Acoustic='Yes';
            else if substr(NameAddon2,1,2)='19' and index(NameAddon2,' Version') then NewVersion='Yes';
            else if substr(NameAddon2,1,2)='20' and index(NameAddon2,' Version') then NewVersion='Yes';
            else if substr(NameAddon2,1,5)='Live ' then Livesong='Yes';

            if substr(NameAddon,1,2)='19' and substr(NameAddon,5,1)='-' then NameAddon='';
            else if substr(NameAddon,1,2)='20' and substr(NameAddon,5,1)='-' then NameAddon='';
            if substr(NameAddon2,1,2)='19' and substr(NameAddon2,5,1)='-' then NameAddon2='';
            else if substr(NameAddon2,1,2)='20' and substr(NameAddon2,5,1)='-' then NameAddon2='';
         run;
      %end;

      proc append base=Mp3tag_song_New data=temp3; run;
   %end;
%mend;

%Complete_Song;

/********************************************************************************************************/
/* Merge Artist, Album and Song together                                                                */
/********************************************************************************************************/
%Log (in=On);

%PUT *** Merge Datasets;

%Log (in=Off);


proc sort data=Mp3tag_artist_new; by ST_Artist; run;
proc sort data=Mp3tag_album_new; by ST_Artist; run;

data Mp3tag_album_new;
   merge Mp3tag_album_new (in=a) Mp3tag_artist_new (in=b);
   by ST_Artist;
   Album_Release_Year=left(trim(Album_Release_Year));
   if a;
run;

data Mp3tag_song_new;
   set Mp3tag_song_new;
   drop
   Album
Album2
AlbumAddon
AlbumRating
Album_Artist
Album_Artist2
Album_Artist_Prop
Album_Bitrate
Album_Prop
Album_Release_Year
Album_Type
Albumurl
Bootleg
Buy_Date
Chartpos
Compilation
Cover_Count
Danchris
Discogs
Download
Label
LiveAlbum
MManufac
NewLib
Price
Producer
Product
Quality
Release_Date
ST_Album
ST_Album_Artist
Single
Store
Storeorigin
Storeplace
Studio
Tagline
Type
a_Catno
allrank
country
default_language
default_vocals
google_discogs
google_label
google_producer
google_release_dayc
google_release_monthc
google_release_yearc
id
rank
related_artist1
related_artist2
related_artist3
related_artist4
related_artist5
related_artist6
related_artist7
related_artist8
related_artist9
related_artist10
w_release_dayc
w_release_monthc
w_release_yearc
x_albumoverall_best;
run;

proc sort data=Mp3tag_song_new; by AlbumID; run;
proc sort data=Mp3tag_album_new; by AlbumID; run;

data Mp3tag_song_new Error1 Error2;
   merge Mp3tag_song_new (in=a) Mp3tag_album_new (in=b);
   by AlbumID;
   if a and b then output Mp3tag_song_new;
   else if a then output Error1;
   else if b then output Error2;
   if Year > Album_Release_Year and Album_Release_Year ne '' then Year=Album_Release_Year;
   if Livesong='' then Livesong='No';
   if Remix='' then Remix='No';
   if Bootleg='' then Bootleg='No';
   if Newversion='' then Newversion='No';
run;

data temp temp2;
   set Mp3tag_song_new;
   if Livesong='No' and Remix='No' and Bootleg='No' and Different='No' and Newversion='No' then output temp;
   else output temp2;
run;


proc sort data=temp; by ST_Artist ST_Name Compilation year; run;

data temp;
   format yearx $20.;
   set temp;
   by ST_Artist ST_Name Compilation year;
   if first.ST_Name then yearx=year;
   retain yearx;
run;

data temp;
   set temp;
   year=yearx;
   drop yearx;
run;

data Mp3tag_song_new;
   set temp temp2;
run;



%end;


/*****************************************************************************************************/
/* Done - Compilation Processing Continues Here                                                      */
/*****************************************************************************************************/


%log(in=On);
%Put Now Running Validation Checks;
%log(in=off);

/******************************************************************************************************/
/* Run Validation Checks                                                                              */
/******************************************************************************************************/

%Macro Validate(invar=, outvar=, id=);

   data temp;
      set Mp3tag_song_new;
      if &invar='';
      keep artist album name &id &invar;
   run;

   %obscnt(work.temp);

   %if &nobs=0 %then %do;
      /* Nothing */
   %end;
   %else %do;

	  proc sort data=temp nodupkey; by &id; run;

      %Messagebox (message1=Check for missing &invar, message2=work.temp, message3=Or Enter Global Value);

	  %if &Entry=Go %then %do;
	      /* Nothing */
	  %end;
	  %else %do;
	     data temp;
		    set temp;
			&invar="&Entry";
         run;
	  %end;

      data temp;
         set temp;
         &outvar=&invar;
         keep &id &outvar;
      run;

      proc sort data=temp nodupkey; by &id; run;
      proc sort data=Mp3tag_song_new; by &id; run;

      data Mp3tag_song_new;
         merge Mp3tag_song_new (in=a) temp (in=b);
         by &id;
         if a;
      run;

      data Mp3tag_song_new;
         set Mp3tag_song_new;
         if &invar='' then &invar=&outvar;  
         %if &invar=Album_Release_Year %then %do;
		    if Release_Date='' then Release_Date=&outvar; 
	     %end;
         drop &outvar;
      run;

   %end;
%mend;

%Macro Set_Flag (in=);
   if &in='' then &in='No';
%Mend;

%Validate(invar=Name, outvar=Namex, id=SongID);
%Validate(invar=Name2, outvar=Name2x, id=SongID);
%Validate(invar=Artist, outvar=Artistx, id=SongID);
%Validate(invar=Artist2, outvar=Artist2x, id=SongID);
%Validate(invar=Album, outvar=Albumx, id=SongID);
%Validate(invar=Album2, outvar=Album2x, id=SongID);
%Validate(invar=Year, outvar=Yearx, id=SongID);
%Validate(invar=Album_Bitrate, outvar=Album_Bitratex, id=AlbumID);

/*********************************************************************************************/
/* Clean Up Dataset                                                                          */
/*********************************************************************************************/

data Mp3tag_song_new;
   format x $4.;
   set Mp3tag_song_new;
   if NameAddon2='' and NameAddon ne '' then NameAddon2=NameAddon;
   if NameAddon2='' then NameAddon2='Album Version';

   if Vocals='' then Vocals=Default_Vocals;
   if Genre='' then Genre="&DefaultGenre";
   if Language='' then Language=Default_Language;
   if xVocals='' then xVocals=Default_Vocals;

   if Release_Date='' then Release_Date=Album_Release_Year;

   if Livesong='Yes' and year ne '' then NameAddon2="Live "||left(trim(year));

   if length(trim(nameaddon2))=4 then do;
      do i=1948 to 2023;
         x=put(i,4.);
         if index(NameAddon2,x) then do;
            NameAddon2='';
         end;
      end;
   end;

   if length(trim(nameaddon))=4 then do;
      do i=1948 to 2023;
         x=put(i,4.);
         if index(NameAddon,x) then do;
            NameAddon='';
         end;
      end;
   end;

   if NameAddon2 ne '' and NameAddon2 ne 'Album Version' then do;
      if index(Name,' (')=0 then do;
         Name=left(trim(Name))||" ("||left(trim(NameAddon2))||")";
         Name2=left(trim(Name2))||" ("||left(trim(NameAddon2))||")";
      end;
   end;

   if AlbumAddon ne '' and index(AlbumAddon,'Released:')=0 then do;
      Album=left(trim(Album))||" ("||left(trim(AlbumAddon2))||")";
      Album2=left(trim(Album2))||" ("||left(trim(AlbumAddon2))||")";
   end;

   if index(NameAddon,'Demo') or index(NameAddon2,'Demo') or index(Name,'Demo') or index(SongID,'Demo') then Demo='Yes';


   if substr(album_release_year,1,4) ne substr(Release_Date,1,4) and Release_Date ne '' then album_release_year=substr(Release_Date,1,4);

   if Acoustic='' then Acoustic='No';
   if Alt='' then Alt='No';
   if Demo='' then Demo='No';
   if Different='' then Different='No';
   if Holiday='' then Holiday='No';
   if DanChris='' then DanChris='No';
   if Chhit='' then Chhit='No';
   if No1='' then No1='No';
   if index(Name,'Santa') or index(Name,'Christmas') then Holiday='Yes';

   if Chhit='Yes' then do;
      if substr(year,1,3)='196' then _60s='Yes';
      else if substr(year,1,3)='197' then _70s='Yes';
      else if substr(year,1,3)='198' then _80s='Yes';
      else if substr(year,1,3)='199' then _90s='Yes';
      else if substr(year,1,3)='200' then _00s='Yes';
      else if substr(year,1,3)='201' then _10s='Yes';
   end;

   if Buy_Date='' then Buy_Date="&buydate";
   if Store='' then Store="&Store";
   if Storeorigin='' then Storeorigin="&country";
   if Storeplace='' then Storeplace="&storeplace";

   if index(Albumid,'\Compilations\') then do;
      Compilation='Yes';
      Studio='No';
      Livealbum='No';
      Single='No';
      Bootleg='No';
   end;
   if index(Albumid,'\Studio Albums\') then do;
      Compilation='No';
      Studio='Yes';
      Livealbum='No';
      Single='No';
      Bootleg='No';
   end;
   if index(Albumid,'\Bootlegs\') or Album_Type_BU='Bootlegs' then do;
      Compilation='No';
      Studio='No';
      Livealbum='No';
      Single='No';
      Bootleg='Yes';
   end;
   if index(Albumid,'\Live Albums\') or Album_Type_BU='Live Albums' then do;
      Compilation='No';
      Studio='No';
      Livealbum='Yes';
      Single='No';
      Bootleg='No';
   end;
   if index(Albumid,'\Singles\') or Album_Type_BU='Singles' then do;
      Compilation='No';
      Studio='No';
      Livealbum='No';
      Single='Yes';
      Bootleg='No';
   end;

   if Remix='No' then do;
      if index(Name,' Mix') or index(Name,' Extended') or index(Name,' Version') or index(Name,' Remix') then Remix='Yes';
   end;

   if Product='' and substr(Buy_Date,1,4) gt '2000' then Product='mp3';
   if Quality='' and substr(Buy_Date,1,4) gt '2000' then Quality='5';

   if release_date='' and album_release_year='' then do;
      do i=1948 to 2023;
         x=put(i,4.);
         if index(AlbumID,x) then do;
            release_date=x;
            album_release_year=x;
         end;
      end;
   end;

   if Genre ne 'Alternative' and Genre ne 'Blues' and index(Genre,'Children')=0 and Genre ne 'Classical' and Genre ne 'Comedy' and
      Genre ne 'Country' and Genre ne 'Easy' and Genre ne 'Folk' and Genre ne 'Irish Folk' and Genre ne 'Jazz' and Genre ne 'Jingle' and
      Genre ne 'Pop' and Genre ne 'Punk' and Genre ne 'Reggae' and Genre ne 'Rock' and Genre ne "Rock'n'Roll" and Genre ne 'Ska' and
      Genre ne 'Swiss Folk' then Genre="&DefaultGenre";

   drop x;
run;

data Mp3tag_song_new;
   format x $4.;
   set Mp3tag_song_new;
   do i=1968 to 2023;
      x=put(i,4.);
      if index(NameAddon2,x) or index(NameAddon,x) then Year=x;
   end;
   if index(Name,' (Live') then do;
      if index(Name,x) then Year=x;
   end;
   drop x i;
run;

data Mp3tag_song_new;
   set Mp3tag_song_new;
   If LiveAlbum ne 'Yes' Then LiveAlbum='No';

   if Single='' then Single='No';
   if LiveSong='' then LiveSong='No';
   else if LiveSong ne 'Yes' then LiveSong='No';

   if Compilation='' then Compilation='No';
   if Bootleg='' then Bootleg='No';
   if Studio='' then Studio='No';

   if No1='' then No1='No';
   if Summer='' then Summer='No';
   if DanChris='' then DanChris='No';
   if CHHit='' then CHHit='No';

   if Vocals eq 'I' then do;
      Language='';
   end;

   if rochelle='' then rochelle='No';

   if st_album_artist='AB_CD' then st_album_artist='ABCD';

   producer=TRANWRD(producer,"*","");
   producer=TRANWRD(producer,"amp;","/");
   producer=TRANWRD(producer,"aeùÑrzte","ƒrzte");
   producer=TRANWRD(producer," /","/");
   producer=TRANWRD(producer," /","/");
   producer=TRANWRD(producer," *","");
   producer=TRANWRD(producer,"quot;","");

   song_producer=TRANWRD(song_producer,"*","");
   song_producer=TRANWRD(song_producer,"amp;","/");
   song_producer=TRANWRD(song_producer,"aeùÑrzte","ƒrzte");
   song_producer=TRANWRD(song_producer," /","/");
   song_producer=TRANWRD(song_producer," /","/");
   song_producer=TRANWRD(song_producer," *","");
   song_producer=TRANWRD(song_producer,"quot;","");

   song_writer=TRANWRD(song_writer,"*","");
   song_writer=TRANWRD(song_writer,"amp;","/");
   song_writer=TRANWRD(song_writer,"aeùÑrzte","ƒrzte");
   song_writer=TRANWRD(song_writer," /","/");
   song_writer=TRANWRD(song_writer," /","/");
   song_writer=TRANWRD(song_writer," *","");
   song_writer=TRANWRD(song_writer,"quot;","");

   if left(trim(pricex))='.' then pricex='0';

   if index(AlbumID,'\Studio Albums\') or index(AlbumID,'\Live Albums\') or index(AlbumID,'\Bootlegs\') or
      index(AlbumID,'\Singles\') or index(AlbumID,'\Compilations\') then do;

      Studio='No';
      Compilation='No';
      Single='No';
      Bootleg='No';
      LiveAlbum='No';

      if index(AlbumID,'\Studio Albums\') then Studio='Yes';
      else if index(AlbumID,'\Live Albums\') then LiveAlbum='Yes';
      else if index(AlbumID,'\Bootlegs\') then Bootleg='Yes';
      else if index(AlbumID,'\Singles\') then Single='Yes';
      else if index(AlbumID,'\Compilations\') then Compilation='Yes';
   end;

   if index(Name,' (Live') then LiveSong='Yes';
   if index(Name,'Acoustic') then Acoustic='Yes';

   if Download='' then Download="&download";

   %Set_Flag (in=Childhood);
   %Set_Flag (in=Teenage);
   %Set_Flag (in=Gaby);
   %Set_Flag (in=Madeleine);
   %Set_Flag (in=Rochelle);
   %Set_Flag (in=Aftermarriage);
   %Set_Flag (in=Australia);
   %Set_Flag (in=USA);
   %Set_Flag (in=Kids);
   %Set_Flag (in=Roadtrip);
   %Set_Flag (in=Sensless);
   %Set_Flag (in=Rockabilly);
   %Set_Flag (in=Melancholia);
   %Set_Flag (in=Mami);
   %Set_Flag (in=Upstairs);
   %Set_Flag (in=London);
   %Set_Flag (in=NDW);
   %Set_Flag (in=ClassicPunk);
   %Set_Flag (in=Q95);
   %Set_Flag (in=X103);
   %Set_Flag (in=Goth);
   %Set_Flag (in=Glam);
   %Set_Flag (in=Sleaze);
   %Set_Flag (in=HardRock);
   %Set_Flag (in=Dance);
   %Set_Flag (in=Disco);
   %Set_Flag (in=DIY);
   %Set_Flag (in=ItaloDisco);
   %Set_Flag (in=Mainstream);
   %Set_Flag (in=NewWave);
   %Set_Flag (in=Oldies);
   %Set_Flag (in=Rap);
   %Set_Flag (in=Rave);
   %Set_Flag (in=Psychobilly);
   %Set_Flag (in=PowerBallade);

run;


%Validate(invar=Album_Release_Year, outvar=Album_Release_Yearx, id=AlbumID);
%Validate(invar=Release_Date, outvar=Release_Datex, id=AlbumID);
%Validate(invar=Genre, outvar=Genrex, id=SongID);
%Validate(invar=Product, outvar=Productx, id=AlbumID);
%Validate(invar=Quality, outvar=Qualityx, id=AlbumID);
%Validate(invar=Download, outvar=Downloadx, id=AlbumID);
%Validate(invar=Language, outvar=Languagex, id=SongID);
%Validate(invar=xVocals, outvar=xVocalsx, id=SongID);
%Validate(invar=Country, outvar=Countryx, id=SongID);
%Validate(invar=Store, outvar=Storex, id=AlbumID);
%Validate(invar=Storeplace, outvar=Storeplacex, id=AlbumID);
%Validate(invar=StoreOrigin, outvar=StoreOriginx, id=AlbumID);
%Validate(invar=Buy_Date, outvar=Buy_Datex, id=AlbumID);



/****************************************************************************/
/* Check for Album Release Year Inconsistency                               */
/****************************************************************************/

data temp;
   format x 8.;
   set Mp3tag_song_new;
   x=1;
   keep AlbumID album_release_year x;
run;

proc sort data=temp; by AlbumId; run;

proc freq data=temp noprint;
   by AlbumId;
   table album_release_year * x /norow nocol nopercent out=Sum1;
run;

data Sum1;
   set Sum1;
   if PERCENT lt 99;
run;

%obscnt(work.Sum1);

%if &nobs=0 %then %do;
   /* Nothing */
%end;
%else %do;
   %Messagebox (message1=Check Release Date - work.Sum1, message2=, message3=);
   data sum1;
      format album_release_year2 $200.;
      set sum1;
      album_release_year2=album_release_year;
      keep AlbumId album_release_year2;
   run;

   proc sort data=Mp3tag_song_new; by AlbumId; run;
   proc sort data=Sum1 nodupkey; by AlbumId; run;

   data Mp3tag_song_new;
      merge Mp3tag_song_new (in=a) Sum1 (in=b);
      by AlbumId;
      if a;
   run;

   data Mp3tag_song_new;
      set Mp3tag_song_new;
      if album_release_year2 ne '' then album_release_year=album_release_year2;
      drop album_release_year2;
   run;
%end;

/****************************************************************************/
/* Check for Song Release Year Inconsistency                                */
/****************************************************************************/

%macro Song_Inconsistency;

data temp;
   format x 8.;
   set Mp3tag_song_new;
   x=1;
   keep Songid Name Year x;
run;

proc sort data=temp; by Name; run;

proc freq data=temp noprint;
   by Name;
   table year * x /norow nocol nopercent out=Sum1;
run;

data Sum1;
   set Sum1;
   if PERCENT lt 99;
run;

%obscnt(work.Sum1);

%if &nobs=0 %then %do;
   /* Nothing */
%end;
%else %do;

   %Messagebox (message1=Check Song Release Date - work.Sum1, message2=, message3=);
   %If &Entry=Auto %then %do;
      %Log (in=On);

      %PUT *** Autocomplete Song Year Correction;

      %Log (in=Off);

      proc sort data=sum1; by Name year; run;
      data sum1;
         format year2 $20.;
         set sum1;
         by Name year;
         if first.Name then do;
            year2=year;
         end;
         retain year2;
         keep Name year2;
      run;

      %Messagebox (message1=Check Song Release Date After Auto Completion - work.Sum1, message2=, message3=);

   %end;
   %else %do;
      data sum1;
         format year2 $20.;
         set sum1;
         year2=year;
         keep Name year2;
      run;
   %end;
   proc sort data=Mp3tag_song_new; by Name; run;
   proc sort data=Sum1 nodupkey; by Name; run;

   data Mp3tag_song_new;
      merge Mp3tag_song_new (in=a) Sum1 (in=b);
      by Name;
      if a;
   run;

   data Mp3tag_song_new;
      set Mp3tag_song_new;
      if year2 ne '' then year=year2;
      drop year2;
   run;
%end;
%mend;
%Song_Inconsistency;


/****************************************************************************/
/* Check for Song Release Year Equal Compilation Release Year               */
/****************************************************************************/

data temp;
   set Mp3tag_song_new;
   if Compilation='Yes' and year=album_release_year;
   keep Songid artist album Name Year album_release_year;
run;

%obscnt(work.temp);

%if &nobs=0 %then %do;
   /* Nothing */
%end;
%else %do;
   %Messagebox (message1=Check Song Release Date on Compilation - work.temp, message2=, message3=);
   data temp;
      format year2 $20.;
      set temp;
      year2=year;
      keep SongID year2;
   run;

   proc sort data=Mp3tag_song_new; by SongId; run;
   proc sort data=Temp nodupkey; by SongId; run;

   data Mp3tag_song_new;
      merge Mp3tag_song_new (in=a) Temp (in=b);
      by SongId;
      if a;
   run;

   data Mp3tag_song_new;
      set Mp3tag_song_new;
      if year2 ne '' then year=year2;
      drop year2;
   run;
%end;

/****************************************************************************/
/* Check for Bitrate Inconsistency                                          */
/****************************************************************************/

data temp;
   format x 8.;
   set Mp3tag_song_new;
   x=1;
   keep AlbumID Album_Bitrate x;
run;

proc sort data=temp; by AlbumId; run;

proc freq data=temp noprint;
   by AlbumId;
   table Album_Bitrate * x /norow nocol nopercent out=Sum1;
run;

data Sum1;
   set Sum1;
   if PERCENT lt 99;
run;

%obscnt(work.Sum1);

%if &nobs=0 %then %do;
   /* Nothing */
%end;
%else %do;
   %Messagebox (message1=Check Bitrate - work.Sum1, message2=, message3=);
   data sum1;
      format Album_Bitrate2 $200.;
      set sum1;
      Album_Bitrate2=Album_Bitrate;
      keep AlbumId Album_Bitrate2;
   run;

   proc sort data=Mp3tag_song_new; by AlbumId; run;
   proc sort data=Sum1 nodupkey; by AlbumId; run;

   data Mp3tag_song_new;
      merge Mp3tag_song_new (in=a) Sum1 (in=b);
      by AlbumId;
      if a;
   run;

   data Mp3tag_song_new;
      set Mp3tag_song_new;
      if Album_Bitrate2 ne '' then Album_Bitrate=Album_Bitrate2;
      drop Album_Bitrate2;
   run;
%end;

/******************************************************************************************/
/* Check for missing Artist Album Name                                                    */
/******************************************************************************************/

data Mp3tag_song_new;
   retain Artist Album Name Albumid Songid;
   set Mp3tag_song_new;
run;

data temp;
   set Mp3tag_song_new;
   if artist='' or album='' or name='';
run;

%obscnt(work.temp);

%if &nobs=0 %then %do;
   /* Nothing */
%end;
%else %do;
   %Messagebox (message1=Check for missing Artist Album Name, message2=work.Mp3tag_song_new;, message3=);
%end;

data Mp3tag_song_new;
   set Mp3tag_song_new;
   if Name2='' then Name2=Name;
   if Album2='' then Album2=Album;
   if Artist2='' then Artist2=Artist;
   if ST_Artist='' then ST_Artist=upcase(Artist);
   if ST_Name='' then ST_Name=upcase(Name);
   if ST_Album='' then ST_Album=upcase(Album);
run;

/******************************************************************************************/
/* Set BEST and DUPLICATE Indicator                                                       */
/******************************************************************************************/

%if &Compilation=Yes %then %do;
   /* Nothing */
%end;
%else %do;

   proc sort data=Mp3tag_song_new; by ST_Artist ST_Name Name descending rating descending bitrate descending timesec; run;

   data Mp3tag_song_new;
      set Mp3tag_song_new;
      by ST_Artist ST_Name Name descending rating descending bitrate descending timesec;
      if first.ST_Name then do;
         if existing_year eq '' then do;
            Best='Yes';
            Duplicate='No';
         end;
         else do;
            Best='No';
            Duplicate='Yes';
         end;
      end;
      else if first.Name then do;
         Best='No';
         Duplicate='No';
      end;
      else do;
         Best='No';
         Duplicate='Yes';
      end;
   run;

%end;

/******************************************************************************************************/
/* Check For Duplicate Output Filename                                                                */
/******************************************************************************************************/

data temp;
   format out_location $200. newaddon $20.;
   set Mp3tag_song_new;
   newaddon='';
   out_location=left(trim(Album_Artist))||" "||left(trim(Album2))||" "||left(trim(Album_Bitrate))||" "||left(trim(Name2))||" "||substr(Track_No,1,index(Track_No,'/')-1);
   keep AlbumID Album_Artist Album2 Name2 Album_Bitrate out_location newaddon;
run;

proc sort data=temp; by Out_Location; run;

data temp;
   set temp;
   by Out_Location;
   if first.Out_Location then do;
      /* Nothing */
   end;
   else do;
      output;
   end;
run;

%obscnt(work.temp);

%if &nobs=0 %then %do;
   /* Nothing */
%end;
%else %do;
      proc sort data=temp nodupkey; by AlbumID; run;
      %Messagebox (message1=Duplicate Output Location, message2=Check work.temp, message3=);

      data temp;
         set temp;
         keep albumid newaddon;
      run;

      proc sort data=temp; by albumid nodupkey; run;
      proc sort data=Mp3tag_song_new; by albumid; run;

      data Mp3tag_song_new;
         merge Mp3tag_song_new (in=a) temp (in=b);
         by albumid;
         if a;
      run;

      data Mp3tag_song_new;
         set Mp3tag_song_new;
         if newaddon ne '' then do;
            album=left(trim(album))||" ("||left(trim(newaddon))||")";
            album2=left(trim(album2))||" ("||left(trim(newaddon))||")";
         end;
      run;
%end;


/********************************************************************************************************/
/* Add Producer and Discogs if this was present in the original file - See if Best Flag needs to be set */
/********************************************************************************************************/

proc sort data=Mp3tag_song_new; by songid; run;
proc sort data=Keeperx; by songid; run;

/*
proc sort data=keep_discogs; by songid; run;
proc sort data=keep_producer; by songid; run;
proc sort data=keep_bonus; by songid; run;

data mp3tag_song_new;
   merge mp3tag_song_new (in=a) keep_producer (in=b) keep_discogs (in=c) keep_bonus (in=d);
   by songid; run;
   if a;
run;

*/


data mp3tag_song_new;
   merge mp3tag_song_new (in=a) keeperx (in=b);
   by songid; 
   if a;
run;


data mp3tag_song_new;
   set mp3tag_song_new;
   if discogs_k ne '' then discogs=discogs_k;
   if producer_k ne '' then producer=producer_k;
   if bonus_k ne '' then bonus=bonus_k;
   if Q95_k eq 'Yes' then Q95=Q95_k;
   if X103_k eq 'Yes' then X103=X103_k;
   if Teenage_k eq 'Yes' then Teenage=Teenage_k;
   if Chhit_k eq 'Yes' then Chhit=Chhit_k;
   if Upstairs_k eq 'Yes' then Upstairs=Upstairs_k;
   if London_k eq 'Yes' then London=London_k;
   if Childhood_k eq 'Yes' then Childhood=Childhood_k;
   if Roadtrip_k eq 'Yes' then Roadtrip=Roadtrip_k;
   if Rating_k ne '' then Rating=Rating_k;
   %if &SetBestFlag=No %then %do;
      Best='No';
	  Duplicate='No';
   %end;
   drop discogs_k producer_k bonus_k Q95_k X103_K Teenage_k Childhood_k Roadtrip_k Rating_k Comment_k Chhit_k; 
run;


/******************************************************************************************************/
/* Retain Rating                                                                                      */
/******************************************************************************************************/

proc sort data=Mp3tag_song_new; by cluster st_name descending rating; run;

data Mp3tag_song_new;
   format ratingx $20.;
   set Mp3tag_song_new;
   by cluster st_name descending rating;
   if first.st_name then do;
      ratingx=rating;
   end;
   if ratingx ne '' then do;
      if rating eq '' or rating lt ratingx then rating=ratingx;
   end;
   retain ratingx;
run;

data Mp3tag_song_new;
   set Mp3tag_song_new;
   drop ratingx;
run;


/******************************************************************************************************/
/* Write mp3tag file                                                                                  */
/******************************************************************************************************/

%if &Compilation=Yes %then %do;
   data Mp3tag_song_new;
      set Mp3tag_song_new;
	  if Buy_Date=' - -' then Buy_Date='2020-11-29';
   run;
%end;

proc sort data=Mp3tag_song_new; by Orig_Countern; run;

data Temp;
   format comment $700. outstr $32000. xVocals $12. AType $15. Discogs $200.;
   set Mp3tag_song_new;
   Comment='';
   Album=TRANWRD(Album," (.           )","");
   Album2=TRANWRD(Album2," (.           )","");
   Album_Prop=TRANWRD(Album_Prop," (.           )","");


   if Vocals='M' or xVocals='M' then xVocals='Male';
   else if Vocals='F' or xVocals='F' then xVocals='Female';
   else if Vocals='I' or xVocals='I' then xVocals='Instrumental';

   if Studio='Yes' then AType='Studio Albums';
   else if Compilation='Yes' then AType='Compilations';
   else if Single='Yes' then AType='Singles';
   else if Bootleg='Yes' then AType='Bootlegs';
   else if LiveAlbum='Yes' then AType='Live Albums';
   else do;
      Studio='Yes';
      AType='Studio Albums';
   end;

   
   if index(NameAddon,'Instrumental') or index(NameAddon2,'Instrumental') then do;
      xVocals='Instrumental';
	  Language='';
   end;

   if left(trim(year)) gt "&Highyear" then year="&Highyear"; 

   if Discogs='' then Discogs=AlbumUrl;

   file "C:\Music Library\Temp\Taglist.txt" encoding='utf-8' lrecl=32000;
   if Single='Yes' then Comment=left(trim(Comment))||" #Single";
   if LiveSong='Yes' or index(Name,' (Live') then Comment=left(trim(Comment))||" #Livesong";
   if Compilation='Yes' then Comment=left(trim(Comment))||" #Compilation";
   if Bootleg='Yes' then Comment=left(trim(Comment))||" #Bootleg";
   if Studio='Yes' then Comment=left(trim(Comment))||" #Studio";
   if LiveAlbum='Yes' then Comment=left(trim(Comment))||" #Livealbum";
   if upcase(product) ne '' then Comment=left(trim(Comment))||" #"||left(trim(upcase(product)));
   if Quality ne '' then Comment=left(trim(Comment))||" #Q"||left(trim(Quality));
   if Download='Yes' then Comment=left(trim(Comment))||" #Download";

   if x_albumoverall_best ne '' then Comment=left(trim(Comment))||" #"||left(trim(x_albumoverall_best));
   if AlbumRating ne '' then Comment=left(trim(Comment))||" #"||left(trim(AlbumRating));

   if CHHit='Yes' then Comment=left(trim(Comment))||" #Chhit";
   if No1='Yes' then Comment=left(trim(Comment))||" #No1";
   if Summer='Yes' or Summer='Yes' then Comment=left(trim(Comment))||" #Summer";
   if Chartyear ne . then Comment=left(trim(Comment))||" #"||put(Chartyear,4.);
   if Chartpos ne . then Comment=left(trim(Comment))||" #Yearrank"||put(Chartpos,Z5.);
   if Allrank ne . then Comment=left(trim(Comment))||" #Allrank"||put(Allrank,Z5.);
   if Rank ne . then Comment=left(trim(Comment))||" #Albumrank"||put(Rank,Z5.);
   if Acoustic='Yes' then Comment=left(trim(Comment))||" #Acoustic";
   if Alt='Yes' then Comment=left(trim(Comment))||" #Alt";
   if Bonus='Yes' then Comment=left(trim(Comment))||" #Bonus"; 
   if Demo='Yes' then Comment=left(trim(Comment))||" #Demo";
   if Different='Yes' then Comment=left(trim(Comment))||" #Different";
   if Holiday='Yes' then Comment=left(trim(Comment))||" #Holiday";
   if DanChris='Yes' then Comment=left(trim(Comment))||" #Danchris";

   if Newversion='Yes' then Comment=left(trim(Comment))||" #Newversion";
   if Remix='Yes' then Comment=left(trim(Comment))||" #Remix";
   if Singlemix='Yes' then Comment=left(trim(Comment))||" #Singlemix";

   if Language ne '' then Comment=left(trim(Comment))||" #"||left(trim(Language));
   if xVocals ne '' then Comment=left(trim(Comment))||" #"||left(trim(xVocals));

   if Producer ne '' then Comment=left(trim(Comment))||" #Producer("||left(trim(Producer))||")";

   if Label='' then Label=google_label;
   if Label ne '' then Comment=left(trim(Comment))||" #Label("||left(trim(Label))||")";
   if a_Catno ne '' then Comment=left(trim(Comment))||" #Catno("||left(trim(a_Catno))||")";

   if Coverversion eq 'Yes' then Comment=left(trim(Comment))||" #Cover("||left(trim(Orig_Artist))||")";
   if Selfcover='Yes' then Comment=left(trim(Comment))||" #Selfcover";

   if Country ne '' then Comment=left(trim(Comment))||" #ArtistOrigin("||left(trim(Country))||")";
   if MManufac ne '' then Comment=left(trim(Comment))||" #Manufactured("||left(trim(MManufac))||")";

   /* if artist_origin ne '' then Comment=left(trim(Comment))||" #Artistorigin("||left(trim(Artist_Origin))||")"; */
   if related_artist1 ne '' then Comment=left(trim(Comment))||" #Related("||left(trim(related_artist1))||")";
   if related_artist2 ne '' then Comment=left(trim(Comment))||" #Related("||left(trim(related_artist2))||")";
   if related_artist3 ne '' then Comment=left(trim(Comment))||" #Related("||left(trim(related_artist3))||")";
   if related_artist4 ne '' then Comment=left(trim(Comment))||" #Related("||left(trim(related_artist4))||")";
   if related_artist5 ne '' then Comment=left(trim(Comment))||" #Related("||left(trim(related_artist5))||")";
   if related_artist6 ne '' then Comment=left(trim(Comment))||" #Related("||left(trim(related_artist6))||")";

   /*
   if store='' then store='rutracker.org';
   if storeplace='' then storeplace='Zurich';
   if countryx='' then countryx='CH';
   if left(trim(Buy_Date))='--' then Buy_Date='2018-02-11';
   */

   if store ne '' then Comment=left(trim(Comment))||" #Store("||left(trim(Store))||")";
   if storeplace ne '' then Comment=left(trim(Comment))||" #Storeplace("||left(trim(Storeplace))||")";
   if Storeorigin ne '' then Comment=left(trim(Comment))||" #Storeorigin("||left(trim(Storeorigin))||")";
   if Buy_Date ne '' then Comment=left(trim(Comment))||" #BuyDate("||left(trim(Buy_Date))||")";
   if pricex ne '.00' then Comment=left(trim(Comment))||" #Price("||left(trim(pricex))||")";

   if _60s='Yes' then Comment=left(trim(Comment))||" #60s";
   if _70s='Yes' then Comment=left(trim(Comment))||" #70s";
   if _80s='Yes' then Comment=left(trim(Comment))||" #80s";
   if _90s='Yes' then Comment=left(trim(Comment))||" #90s";
   if _00s='Yes' then Comment=left(trim(Comment))||" #00s";
   if _10s='Yes' then Comment=left(trim(Comment))||" #10s";
   if Childhood='Yes' then Comment=left(trim(Comment))||" #Childhood";
   if Teenage='Yes' then Comment=left(trim(Comment))||" #Teenage";
   if Gaby='Yes' then Comment=left(trim(Comment))||" #Gaby";
   if Madeleine='Yes' then Comment=left(trim(Comment))||" #Madeleine";
   if Rochelle='Yes' then Comment=left(trim(Comment))||" #Rochelle";
   if Aftermarriage='Yes' then Comment=left(trim(Comment))||" #Aftermarriage";
   if Australia='Yes' then Comment=left(trim(Comment))||" #Australia";
   if USA='Yes' then Comment=left(trim(Comment))||" #USA";
   if Kids='Yes' then Comment=left(trim(Comment))||" #Kids";
   if Roadtripx='Yes' then Comment=left(trim(Comment))||" #Roadtrip";
   if Sensless='Yes' then Comment=left(trim(Comment))||" #Sensless";
   if Melancholia='Yes' then Comment=left(trim(Comment))||" #Melancholia";
   if Mami='Yes' then Comment=left(trim(Comment))||" #Mami";
   if Upstairs='Yes' then Comment=left(trim(Comment))||" #Upstairs";
   if London='Yes' then Comment=left(trim(Comment))||" #London";
   if NDW='Yes' then Comment=left(trim(Comment))||" #NDW";
   if ClassicPunk='Yes' then Comment=left(trim(Comment))||" #ClassicPunk";
   if Q95='Yes' then Comment=left(trim(Comment))||" #Q95";
   if X103='Yes' then Comment=left(trim(Comment))||" #X103";
   if Goth='Yes' then Comment=left(trim(Comment))||" #Goth";
   if Glam='Yes' then Comment=left(trim(Comment))||" #Glam";
   if Sleaze='Yes' then Comment=left(trim(Comment))||" #Sleaze";
   if HardRock='Yes' then Comment=left(trim(Comment))||" #HardRock";
   if Dance='Yes' then Comment=left(trim(Comment))||" #Dance";
   if Disco='Yes' then Comment=left(trim(Comment))||" #Disco";
   if DIY='Yes' then Comment=left(trim(Comment))||" #DIY";
   if ItaloDisco='Yes' then Comment=left(trim(Comment))||" #ItaloDisco";
   if Mainstream='Yes' then Comment=left(trim(Comment))||" #Mainstream";
   if NewWave='Yes' then Comment=left(trim(Comment))||" #NewWave";
   if Oldies='Yes' then Comment=left(trim(Comment))||" #Oldies";
   if Rap='Yes' then Comment=left(trim(Comment))||" #Rap";
   if Rave='Yes' then Comment=left(trim(Comment))||" #Rave";
   if Psychobilly='Yes' then Comment=left(trim(Comment))||" #Psychobilly";
   if Rockabilly='Yes' then Comment=left(trim(Comment))||" #Rockabilly";
   if PowerBallade='Yes' then Comment=left(trim(Comment))||" #PowerBallade";
   if Exclude='Yes' then Comment=left(trim(Comment))||" #Exclude";
   if Best='Yes' then Comment=left(trim(Comment))||" #Best";
   if Duplicate='Yes' then Comment=left(trim(Comment))||" #Duplicate";

   if index(Comment,'#Bootleg')=0 and index(Comment,'#Single')=0 and index(Comment,'#Compilation')=0 and index(Comment,'#Livealbum')=0
      and index(Comment,'#Studio')=0 then do;
      Comment="#Studio "||left(trim(Comment));
   end;

   Comment=left(trim(Comment))||" "||Tagline;

   Name=TRANWRD(Name," Can T "," Can't ");
   Name=TRANWRD(Name,"Don T ","Don't ");
   Name=TRANWRD(Name,"Won T ","Won't ");
   Name=TRANWRD(Name,"It S ","It's ");
   Name=TRANWRD(Name,"That S ","That's ");
   Name=TRANWRD(Name,"I M ","I'm ");
   Name=TRANWRD(Name,"I Ve ","I've ");
   Name=TRANWRD(Name,"He S ","He's ");
   Name=TRANWRD(Name,"She S ","She's ");
   Name=TRANWRD(Name,"Rock Roll ","Rock And Roll ");


   if trim(x_albumoverall_bestx)='.' then x_albumoverall_bestx='';
/* %TITLE%\%ARTIST%\%ALBUM%\%YEAR%\%RELEASETIME%\%DATE%\%COMMENT%\%WWW%\%PUBLISHER%\%BPM%\%contentgroup%\%genre%\%composer%\%conductor%\%mood%\%ENCODEDBY%\%Proper_Artist%\%Proper_Album%\%Proper_Name% */
   /* outstr=left(trim(Album))||" (Released: "||left(trim(Release_Date))||")\"||trim(put(First_Album_Release_Year,4.))||"\"||Release_Date||"\"||Buy_Date||"\"||left(trim(Comment))||"\"||left(trim(Discogs))||"\"||left(trim(Producer))||"\"||left(trim(x_albumoverall_bestx))||"\"||left(trim(Rating))||"\"||left(trim(Genre))||"\"||left(trim(Composer))||"\"||left(trim(Product))||"\"||Album_Release_Year||"\"||Album_Bitrate; */
   outstr=left(trim(Name))||"\"||left(trim(artist))||"\"||left(trim(Album))||" (Released: "||left(trim(Release_Date))||")\"||left(trim(Year))||"\"||left(trim(Release_Date))||"\"||left(trim(Buy_Date))||"\"||left(trim(Comment))||"\"||left(trim(Discogs))||"\"||left(trim(Producer))||"\"||left(trim(x_albumoverall_best))||"\"||left(trim(Rating))||"\"||left(trim(Genre))||"\"||left(trim(Composer))||"\"||left(trim(AType))||"\"||left(trim(Album_Release_Year))||"\"||left(trim(Album_Bitrate))||"\"||left(trim(Album_Artist2))||"\"||left(trim(Album2))||"\"||left(trim(Name2));
   outstr=TRANWRD(outstr,"#"," #");
   outstr=TRANWRD(outstr,"  "," ");
   outstr=TRANWRD(outstr,"  #"," #");
   outstr=TRANWRD(outstr,"\ #","\#");
   outstr=TRANWRD(outstr,"   \","\");
   outstr=TRANWRD(outstr,"\          ","");
   outstr=TRANWRD(outstr,"#Swiss German","#SwissGerman");
   if substr(outstr,length(trim(outstr)),1)='\' then do;
      zzz=substr(outstr,1,length(trim(outstr))-1);
      outstr=zzz;
   end;
   put outstr;
   /* keep outstr; */
   output;
   call symputx("TNUM",_N_);
run;

/******************************************************************************************************/
/* Cover Search                                                                                       */
/******************************************************************************************************/


/***************************************************************************************/
/* Get Album Covers                                                                    */
/***************************************************************************************/

data albums;
   format sstring2 $400.;
   set Mp3tag_song_new;
run;

proc sort data=albums nodupkey; by albumid; run;

data albums;
   set albums;
   sstring2=cats('cd /d C:\Program Files\AlbumArtDownloader2 & AlbumArt.exe /artist "',left(trim(album_artist)),'" /album "',left(trim(album)),'" /path "',trim(Albumid),'\folder.jpg" /autoclose /sources all /sort size- /minSize 500 /coverType front');
run;

options noxwait noxsync;

/***************************************************************************/
/* Open Web Pages                                                          */
/***************************************************************************/

%macro open_web_pages;

data _NULL_;
   set albums;
   call symputx("nobs",_N_);
run;

%do i=1 %to &nobs;

   data _null_;
      set albums;
      if _N_=&i;
      call symputx("url",sstring2);
   run;

   x &url;
%end;
%mend;

%macro open_selective_web_pages;

   Filename SEL "C:\Temp\Covers.txt" encoding='utf-8' lrecl=32000;

   data CoverSearch ;
      length Artist Album Folder $100. sstring2 $400. line $1024;
      retain path ;

      infile SEL length=reclen ;
      input line $varying1024. reclen ;

      if reclen = 0 then delete ;

      Artist=scan(line,1,';');
      Album=scan(line,2,';');
      Folder=scan(line,3,';');

      if index(album,'(') then album=substr(album,1,index(album,'(')-1);
      sstring2=cats('cd /d C:\Program Files\AlbumArtDownloader & AlbumArt.exe /artist "',left(trim(artist)),'" /album "',left(trim(album)),'" /path "',trim(folder),'\folder.jpg" /autoclose /sources all /sort size- /minSize 500 /coverType front');

   run;


data _NULL_;
   set CoverSearch;
   call symputx("nobs",_N_);
run;

%do i=1 %to &nobs;

   data _null_;
      set CoverSearch;
      if _N_=&i;
      call symputx("url",sstring2);
   run;

   x &url;
%end;
%mend;

%macro open_windows;
/** %WINDOW defines the prompt **/
%Let id=No;
%window info
  #4 @5 'Activate Cover Search: Yes No Sel'
  #6 @30 id 8 attr=underline
;
/** %DISPLAY invokes the prompt **/
%display info;

%put Response &id;

%IF &id EQ No %then %do;

/* Nothing */

%END;
%ELSE %IF &id EQ Sel %then %do;

%open_selective_web_pages;

%END;
%ELSE %DO;

%open_web_pages;

%END;

%mend;
%open_windows;

proc delete data=Albums temp4 tempinx tempiny tempinz Temp_album_artist; run;


proc delete data=Error Main Missing Temp Temp2 Temp3 Tempmp3tag Sum1; run;

data _NULL_;
   set Mp3tag_song_new;
   call symputx('ObsEnd',_N_);
run;

proc sort data=Mp3tag_song_new; by Orig_Countern; run;

%Log (in=On);



x start notepad "C:\Music Library\Temp\Taglist.txt";

%If delete=Yes %Then %Do;
   proc delete data=error1 error2 Mp3tag_album Mp3tag_album_new Mp3tag_artist Mp3tag_artist_new Mp3tag_song Mp3tag_song_new Googlex Temx2 Tempx3 Temp2x Temp3x keep_producer keep_discogs 
      Keeperx Keep_childhood Keep_comment Keep_q95 Keep_rating Keep_roadtrip Keep_teenage Keep_x103 keep_bonus Prev_playlist Tempin Tempin2 Tempx Temp2x Temp3x
      Mp3tag_song_new Mp3tag_song Mp3tag_artist_new Mp3tag_artist Mp3tag_album_new Mp3tag_album; run;
%end;
%PUT *** In Obs &ObsStart - Out Obs &ObsEnd;

/*

proc datasets library=work kill;
run;
quit;

%mp3tag (Correctalbum=No, Append=Yes);
*/

/* Get Buy Date 
data temp;
   retain store buy_yearc buy_monthc buy_dayc st_album;
   set itunes.main; 
   if index(st_artist,'REPLACEMENTS') and index(st_album,'GOLDPLATED') ;
run;

proc sort data=temp nodupkey; by st_artist st_album buy_yearc; run;
*/
%obscnt(work.Mp3tag_song_new);

%Put ****** &nobs Written To Output File;
%Put ****** &nobs Written To Output File;
%Put ****** &nobs Written To Output File;
%Put ****** &nobs Written To Output File;
%Put ****** &nobs Written To Output File;
