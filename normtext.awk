#! /usr/bin/awk -f

#----------------------------------------------
# normtext.awk v. 0.5á [01-Jul-1996] by Pior K³osowski
#                            (pklos@press.umcs.lublin.pl)
# (for UNIX operating system and iso-latin-2 polish letters)
# Convert bad typed text files to better form suitable for TeX.
# Usage:
#	awk -f normtext infile > outfile
#----------------------------------------------
# Na bazie pomys³ów Tomasz Przechlewskiego i Marka Ryæki spóbowa³em 
# skonstruowaæ bardziej uniwersalne rzêdzie do filtrowania kiepskich
# plików tekstowych w~postaæ strawn± dla TeX-a. Piotr K³osowski, maj 1996~r.
# Za³o¿enia: 
# tekst z akapitami odzielonymi wierszami "blanklines" o pocz±tkach
# 	pasuj±cych do wzorca "parbeg",
# jêzyk polski - iso-latin-2; 
# teksty spoza nauk ¶cis³ych; 
# ignorujê tabelki, przypisy... 
# Plan:
#A. Usuniêcie podzia³u na strony wraz z paginowaniem.
#B. Usuniêcie przeniesieñ wyrazów (w trakcie budowania "para").
#C. Nie³amliwe spacje przy spójnikach, inicja³ach i skrótach.
#D. Konstrukcja odpowiednich kresek, cudzys³owów, wielokropków, nawiasów.
#E. Kropki, przecinki, odstêpy w liczbach.
#F. Uporz±dkowanie spacji przy znakach przestankowych.
#G. Symbole spotykane w tekstach niematematycznych: %, $, <, >.
#----------------------------------------------
BEGIN {
   stdio = "/dev/null";
   digit = "[0-9]"; 
   rdigit = "[IVXLCM]";	
   capletter = "[A-Z¡ÊÆ£ÑÓ¦¬¯]";
   lowletter = "[a-z±êæ³ñó¶¼¿]";
   nonlowletter = "[^a-z±êæ³ñó¶¼¿]"; 
   letter = "[A-Z¡ÊÆ£ÑÓ¦¬¯a-z±êæ³ñó¶¼¿]";
   spojnik = "[AIOUWZaiouwz]"; 
   wspaces = "[\\ \\t\\n]+";
   nonwspace = "[^\\ \\t\\n]";
   wspacesornot = "[\\ \\t\\n]*";
   # wzorzec wiersza miêdzyakapitowego (dopasowany do konwersji z TAG-a)
   blanklines = "^[\\ \\t]*(- [0-9]+ -)*[\\ \\t]*$";
   nbl = 0;		# licznik wierszy miêdzyakapitowych
   # wzorzec pocz±tku akapitu
   parbeg = "^[\\ \\t]*[^\\t\\ a-z±æê³ñó¶¿¼].*$";	
#   parbeg = "^[\\ \\t]*[A-Z¡ÆÊ£ÓÑ¦¬¯0-9].*$";
}

# wymieñ _co_ w kontek¶cie _bef_ _aft_ na _na_ (kontekst jednoznakowy)
# _bef_, _co_ i _aft_ s± ³añcuchami interpetowanymi jako wyra¿enia regularne
# (uwaga na podwójne wty³ciachy); _na_ jest ³añcuchem
# pomys³: Marek Ryæko

function exch (bef, co, aft, na) {
   while (match(para, bef co aft) > 0) {
       match(para, bef co aft);
       nowy = substr(para, 1, RSTART) na substr(para, RSTART+RLENGTH-1);
       para = nowy;
   }
}				# koniec funkcji exch(bef, co, aft, na)

# wymieñ _co_ w kontek¶cie _bef_ _aft_ na _na_ (kontekst wieloznakowy)
# _bef_, _co_ i _aft_ s± ³añcuchami interpetowanymi jako wyra¿enia regularne
# (uwaga na podwójne wty³ciachy); _na_ jest ³añcuchem
# pomys³: Marek Ryæko

function xexch (bef, co, aft, na) {			
   while (match(para, bef co aft) > 0) {
       match(para, bef co aft); R1 = RSTART; L1 = RLENGTH;

       test = substr(para,RSTART,RLENGTH);

       test1 = match(test,bef); R2 = RSTART; L2 = RLENGTH;
       test2 = match(test,aft); R3 = RSTART; L3 = RLENGTH;

       nowy = substr(para, 1, R1 + L2 - 1) na substr(para, R1 + L1 - L3);
       para = nowy;
   }
}				# koniec funkcji xech(bef, co, aft, na)

# formatuje akapit na rozs±dn± szeroko¶æ <= 72 zn.

function print_para() {	
   words = split(para, paralist, " ");
   len = length(paralist[1]);
   printf "%s", paralist[1];
   for (i=2; i<=words; i++) {
      len += length(paralist[i]);
      ###print len, paralist[i] >> stdio;

      if (++len>72) {
		  printf "\n%s", paralist[i]; 
		  len = length(paralist[i]);
	  }
      else printf " %s", paralist[i];
   }
   if (len) printf "\n\n"; 
   else  printf "\n";
}				# koniec funkcji print_para()

# g³ówna funkcja dokonuj±ca analizy i przekszta³ceñ akapitu
# pomys³: T. Przechlewski

function process_para() {			
   print "Paragraph: ", length(para), "bytes" >> stdio;

   #spójniki#
   gsub(/[ \t\n]+a[ \t\n]+/, " a~", para); gsub(/\~a /, "~a~", para);
   gsub(/[ \t\n]+i[ \t\n]+/, " i~", para); gsub(/\~i /, "~i~", para);
   gsub(/[ \t\n]+o[ \t\n]+/, " o~", para); gsub(/\~o /, "~o~", para);
   gsub(/[ \t\n]+u[ \t\n]+/, " u~", para); gsub(/\~u /, "~u~", para);
   gsub(/[ \t\n]+w[ \t\n]+/, " w~", para); gsub(/\~w /, "~w~", para);
   gsub(/[ \t\n]+z[ \t\n]+/, " z~", para); gsub(/\~z /, "~z~", para);

   gsub(/[ \t\n]+A[ \t\n]+/, " A~", para); gsub(/\~A /, "~A~", para);
   #ryzykowne - cyfry rzymskie#
   gsub(/[ \t\n]+I[ \t\n]+/, " I~", para); gsub(/\~I /, "~I~", para);
   gsub(/[ \t\n]+O[ \t\n]+/, " O~", para); gsub(/\~O /, "~O~", para);
   gsub(/[ \t\n]+U[ \t\n]+/, " U~", para); gsub(/\~U /, "~U~", para);
   gsub(/[ \t\n]+W[ \t\n]+/, " W~", para); gsub(/\~W /, "~W~", para);
   gsub(/[ \t\n]+Z[ \t\n]+/, " Z~", para); gsub(/\~Z /, "~Z~", para);

   #inicja³y#
   xexch(capletter, "\\." wspacesornot, capletter lowletter, "\.\~");
   xexch(capletter, "\\." wspacesornot, capletter "\\.\\~", "\.\~");

   #skróty - daty#
   exch(digit, wspacesornot "r", "\\.", "~r");
   exch("r", "\\." wspacesornot, digit, ".~");
   exch(digit, wspacesornot "w", "\\.", "~w");
   exch(rdigit, wspaces "w", "\\.", "~w");

   #skróty - bibliografia#
   exch(nonlowletter, "s\\." wspacesornot, digit, "s.~");
   exch(nonlowletter, "ss\\." wspacesornot, digit, "s.~");
   exch(nonlowletter, "t\\." wspacesornot, digit, "t.~");
   exch(nonlowletter, "t\\." wspacesornot, rdigit, "t.~");
   exch(nonlowletter, "z\\." wspacesornot, digit, "z.~");
   exch(nonlowletter, "art\\." wspacesornot, digit, "art.~");
  
   #skróty - inne#  
   exch(nonlowletter, "[Tt]ab\\."  wspacesornot, digit, "tab.~");
   exch(nonlowletter, "[Tt]abl\\."  wspacesornot, digit, "tabl.~");
   exch(nonlowletter, "[Rr]yc\\."  wspacesornot, digit, "ryc.~");
   exch(nonlowletter, "[Rr]ys\\."  wspacesornot, digit, "ryc.~");# ! 
   exch(nonlowletter, "[Rr]ozdz\\."  wspacesornot, digit, "rozdz.~");
   exch(nonlowletter, "nr"  wspacesornot, digit, "nr~");
  
   #skróty - lokalne#
   exch(nonlowletter, "stan\\."  wspaces, digit, "stan.~");
   exch(nonlowletter, "w\\."  wspaces, digit, "w.~");
   exch(nonlowletter, "Mi"  wspaces, digit, "Mi~");
   exch(nonlowletter, "Jr"  wspaces, digit, "Jr~");
   exch(nonlowletter, "Ez"  wspaces, digit, "Ez~");
   exch(nonlowletter, "Za"  wspaces, digit, "Za~");
   exch(nonlowletter, "J"  wspaces, digit, "J~");
   exch(nonlowletter, "Oz"  wspaces, digit, "Oz~");
   exch(nonlowletter, "Jl"  wspaces, digit, "Jl~");
   exch(nonlowletter, "Ps"  wspaces, digit, "Ps~");
   exch(nonlowletter, "Wj"  wspaces, digit, "Wj~");
   
   #liczby, jednostki#
   exch(digit, wspacesornot "tys", nonlowletter, "~tys");
   exch(digit, wspacesornot "mln", nonlowletter, "~mln");
   exch(digit, wspacesornot "z³", nonlowletter, "~z³");
   exch(digit, wspacesornot "ha", nonlowletter, "~ha");
   xexch(digit, wspacesornot, "[kcm][glms]" nonlowletter, "~");	

   #endashes#
   exch(digit, wspacesornot "-" wspacesornot, digit, "--");

   #emdashes#
   gsub(wspaces "-" wspaces, " --- ", para);

   #cudzys³owy#
   exch("[^\\a-z±êæ³ñó¶¼¿]", "\"", letter, ",,");
   exch(wspaces, "\"", nonwspace, ",,");
   #gsub("®", "<<", para);
   #gsub("¯", ">>", para);
	
   #nawiasy uko¶ne - ryzykowne (³amane przez)#
   #exch(wspaces, "/", nonwspace, "(");
   #exch(nonwspace, "/", wspaces, ")");

   #wielokropek#
   gsub(/\.\.\.\.+/, "\\dotfill{}", para); 
   gsub(/\.\.\./, "\\ldots{}", para); 
   gsub(/\(\\ldots\{\}\)/, "[\\ldots{}]", para); 
   
   #pisownia liczb - ryzykowne (psuje dziesiêtn± numeracjê rozdz., wzorów, itp. 
   #dziesiêtn± klasyfikacjê biblioteczn±, klasyfikacjê chorób itp
   #exch(digit, "\\.", digit, ",")	
   									
   xexch("[0-9]", "", "[0-9][0-9][0-9][^0-9]", "\\,");
   xexch("[^0-9][0-9]", "\\\\,", "[0-9][0-9][0-9][^0-9\\\\]", "");
   
   #spacje przy znakach przestankowych - byæ mo¿e ryzykowne#
   exch(nonwspace, wspaces "\\,", "[^\\,]", ",");   
   exch("[^\\,]", ",", letter, ", ");   
   
   exch(nonwspace, wspaces "\\.", "[^\\.]", ".");   
   exch(".", "\\.", letter, ".  ");   
   xexch(".", "\\.", ",,", ".  ");   
   #wyj±tki#
   gsub(/p\. n\. e\./, "p.n.e.", para);
   gsub(/n\. e\./, "n.e.", para);
   gsub(/m\. in\./, "m.in.", para);

   exch(nonwspace, wspaces ";", ".", ";");   
   exch(".", ";", nonwspace , "; ");   
   
   exch(nonwspace, wspaces ":", ".", ":");   
   exch(".", ":", nonwspace, ": ");   
   #wyj±tki#
   gsub(/\[w: \]/,"[w:]",para);
   
   exch(nonwspace, wspaces "\\?", ".", "?");   
   exch(".", "\\?", letter, "? ");   
   
   exch(nonwspace, wspaces "!", ".", "!");   
   exch(".", "!", letter, "! ");   
   
   exch(".", "\\(" wspaces, nonwspace, "(");   
   exch(letter, "\\(", ".", " (");   
   exch(nonwspace, wspaces "\\)", ".", ")");   
   exch(".", "\\)", letter, ") ");   
   
   #spacje przy nawiasach klamrowych (wyró¿nienia)
   xexch(nonwspace, "\\{", "\\\\((bf)|(em)|(it))", " {");
   xexch("(\\~|\\(|(,,)|(>>)|(<<))", "\\ \\{", "\\\\((bf)|(em)|(it))", "{");
   exch(nonwspace, wspaces "\\}", ".", "} ");
   #ryzykowne (np. kropki od dziesiêtnej numeracji rozdz., wzorów, tabel...)
   gsub(/\.\}/, "}.", para);
   gsub(/\}\.\./, ".}.", para);
   gsub(/\,\}/, "},", para);
   
   #symbole niematematyczne#
   exch(digit, wspacesornot "\\%", ".", "\\%");
   exch(digit, wspacesornot "\\$", "[^\\^\\\\]", "\\$");
   gsub("&","\\&")
   exch("[^<\\$]", "<", "[^<\\$]", "$<$");
   exch("[^>\\$]", ">", "[^>\\$]", "$>$");

   #lokalne - litery akcentowe zagraniczne (TAG)#
#   gsub(//, "\\\"u", para);
#   gsub(/Ÿ/, "\\v{c}", para);
#   gsub(/¬/, "\\v{C}", para);
#   gsub(/í/, "\\oo{}", para);
   
   #formatowanie akapitu# 
   print_para();
   para = "";
}				# koniec funkcji process_para()

# pominiêcie wierszy pasuj±cych do "blanklines" 
$0~blanklines {
	nbl++
} 

# po pominiêciu wierszy pasuj±cych do "blanklines"... 
$0!~blanklines {
	# sprawdzenie czy nastêpuj±cy tekst jest pocz±tkiem nowego 
	# akapitu i przetwarzanie poprzedniego akapitu
    if (nbl>0 && $0~parbeg) {process_para()};
    
	# tworzenie ³añcucha "para" zawieraj±cego akapit  z~usuniêtymi
    # przeniesieniami wyrazów i odstêpami lewego marginesu
	# ryzykowne - ³±czniki, przyrostki na koñcu wiersza 
	sub(/^[\ \t\n]+/,"");
    if (match(para, lowletter "-" wspacesornot "$")==0) para = para " " $0
    else para = substr(para, 1, RSTART) $0;
	
	nbl = 0
}

END {process_para();}
