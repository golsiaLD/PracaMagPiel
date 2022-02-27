#! /usr/bin/awk -f

#----------------------------------------------
# normtext.awk v. 0.5� [01-Jul-1996] by Pior K�osowski
#                            (pklos@press.umcs.lublin.pl)
# (for UNIX operating system and iso-latin-2 polish letters)
# Convert bad typed text files to better form suitable for TeX.
# Usage:
#	awk -f normtext infile > outfile
#----------------------------------------------
# Na bazie pomys��w Tomasz Przechlewskiego i Marka Ry�ki sp�bowa�em 
# skonstruowa� bardziej uniwersalne rz�dzie do filtrowania kiepskich
# plik�w tekstowych w~posta� strawn� dla TeX-a. Piotr K�osowski, maj 1996~r.
# Za�o�enia: 
# tekst z akapitami odzielonymi wierszami "blanklines" o pocz�tkach
# 	pasuj�cych do wzorca "parbeg",
# j�zyk polski - iso-latin-2; 
# teksty spoza nauk �cis�ych; 
# ignoruj� tabelki, przypisy... 
# Plan:
#A. Usuni�cie podzia�u na strony wraz z paginowaniem.
#B. Usuni�cie przeniesie� wyraz�w (w trakcie budowania "para").
#C. Nie�amliwe spacje przy sp�jnikach, inicja�ach i skr�tach.
#D. Konstrukcja odpowiednich kresek, cudzys�ow�w, wielokropk�w, nawias�w.
#E. Kropki, przecinki, odst�py w liczbach.
#F. Uporz�dkowanie spacji przy znakach przestankowych.
#G. Symbole spotykane w tekstach niematematycznych: %, $, <, >.
#----------------------------------------------
BEGIN {
   stdio = "/dev/null";
   digit = "[0-9]"; 
   rdigit = "[IVXLCM]";	
   capletter = "[A-Z��ƣ�Ӧ��]";
   lowletter = "[a-z����󶼿]";
   nonlowletter = "[^a-z����󶼿]"; 
   letter = "[A-Z��ƣ�Ӧ��a-z����󶼿]";
   spojnik = "[AIOUWZaiouwz]"; 
   wspaces = "[\\ \\t\\n]+";
   nonwspace = "[^\\ \\t\\n]";
   wspacesornot = "[\\ \\t\\n]*";
   # wzorzec wiersza mi�dzyakapitowego (dopasowany do konwersji z TAG-a)
   blanklines = "^[\\ \\t]*(- [0-9]+ -)*[\\ \\t]*$";
   nbl = 0;		# licznik wierszy mi�dzyakapitowych
   # wzorzec pocz�tku akapitu
   parbeg = "^[\\ \\t]*[^\\t\\ a-z����󶿼].*$";	
#   parbeg = "^[\\ \\t]*[A-Z��ʣ�Ѧ��0-9].*$";
}

# wymie� _co_ w kontek�cie _bef_ _aft_ na _na_ (kontekst jednoznakowy)
# _bef_, _co_ i _aft_ s� �a�cuchami interpetowanymi jako wyra�enia regularne
# (uwaga na podw�jne wty�ciachy); _na_ jest �a�cuchem
# pomys�: Marek Ry�ko

function exch (bef, co, aft, na) {
   while (match(para, bef co aft) > 0) {
       match(para, bef co aft);
       nowy = substr(para, 1, RSTART) na substr(para, RSTART+RLENGTH-1);
       para = nowy;
   }
}				# koniec funkcji exch(bef, co, aft, na)

# wymie� _co_ w kontek�cie _bef_ _aft_ na _na_ (kontekst wieloznakowy)
# _bef_, _co_ i _aft_ s� �a�cuchami interpetowanymi jako wyra�enia regularne
# (uwaga na podw�jne wty�ciachy); _na_ jest �a�cuchem
# pomys�: Marek Ry�ko

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

# formatuje akapit na rozs�dn� szeroko�� <= 72 zn.

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

# g��wna funkcja dokonuj�ca analizy i przekszta�ce� akapitu
# pomys�: T. Przechlewski

function process_para() {			
   print "Paragraph: ", length(para), "bytes" >> stdio;

   #sp�jniki#
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

   #inicja�y#
   xexch(capletter, "\\." wspacesornot, capletter lowletter, "\.\~");
   xexch(capletter, "\\." wspacesornot, capletter "\\.\\~", "\.\~");

   #skr�ty - daty#
   exch(digit, wspacesornot "r", "\\.", "~r");
   exch("r", "\\." wspacesornot, digit, ".~");
   exch(digit, wspacesornot "w", "\\.", "~w");
   exch(rdigit, wspaces "w", "\\.", "~w");

   #skr�ty - bibliografia#
   exch(nonlowletter, "s\\." wspacesornot, digit, "s.~");
   exch(nonlowletter, "ss\\." wspacesornot, digit, "s.~");
   exch(nonlowletter, "t\\." wspacesornot, digit, "t.~");
   exch(nonlowletter, "t\\." wspacesornot, rdigit, "t.~");
   exch(nonlowletter, "z\\." wspacesornot, digit, "z.~");
   exch(nonlowletter, "art\\." wspacesornot, digit, "art.~");
  
   #skr�ty - inne#  
   exch(nonlowletter, "[Tt]ab\\."  wspacesornot, digit, "tab.~");
   exch(nonlowletter, "[Tt]abl\\."  wspacesornot, digit, "tabl.~");
   exch(nonlowletter, "[Rr]yc\\."  wspacesornot, digit, "ryc.~");
   exch(nonlowletter, "[Rr]ys\\."  wspacesornot, digit, "ryc.~");# ! 
   exch(nonlowletter, "[Rr]ozdz\\."  wspacesornot, digit, "rozdz.~");
   exch(nonlowletter, "nr"  wspacesornot, digit, "nr~");
  
   #skr�ty - lokalne#
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
   exch(digit, wspacesornot "z�", nonlowletter, "~z�");
   exch(digit, wspacesornot "ha", nonlowletter, "~ha");
   xexch(digit, wspacesornot, "[kcm][glms]" nonlowletter, "~");	

   #endashes#
   exch(digit, wspacesornot "-" wspacesornot, digit, "--");

   #emdashes#
   gsub(wspaces "-" wspaces, " --- ", para);

   #cudzys�owy#
   exch("[^\\a-z����󶼿]", "\"", letter, ",,");
   exch(wspaces, "\"", nonwspace, ",,");
   #gsub("�", "<<", para);
   #gsub("�", ">>", para);
	
   #nawiasy uko�ne - ryzykowne (�amane przez)#
   #exch(wspaces, "/", nonwspace, "(");
   #exch(nonwspace, "/", wspaces, ")");

   #wielokropek#
   gsub(/\.\.\.\.+/, "\\dotfill{}", para); 
   gsub(/\.\.\./, "\\ldots{}", para); 
   gsub(/\(\\ldots\{\}\)/, "[\\ldots{}]", para); 
   
   #pisownia liczb - ryzykowne (psuje dziesi�tn� numeracj� rozdz., wzor�w, itp. 
   #dziesi�tn� klasyfikacj� biblioteczn�, klasyfikacj� chor�b itp
   #exch(digit, "\\.", digit, ",")	
   									
   xexch("[0-9]", "", "[0-9][0-9][0-9][^0-9]", "\\,");
   xexch("[^0-9][0-9]", "\\\\,", "[0-9][0-9][0-9][^0-9\\\\]", "");
   
   #spacje przy znakach przestankowych - by� mo�e ryzykowne#
   exch(nonwspace, wspaces "\\,", "[^\\,]", ",");   
   exch("[^\\,]", ",", letter, ", ");   
   
   exch(nonwspace, wspaces "\\.", "[^\\.]", ".");   
   exch(".", "\\.", letter, ".  ");   
   xexch(".", "\\.", ",,", ".  ");   
   #wyj�tki#
   gsub(/p\. n\. e\./, "p.n.e.", para);
   gsub(/n\. e\./, "n.e.", para);
   gsub(/m\. in\./, "m.in.", para);

   exch(nonwspace, wspaces ";", ".", ";");   
   exch(".", ";", nonwspace , "; ");   
   
   exch(nonwspace, wspaces ":", ".", ":");   
   exch(".", ":", nonwspace, ": ");   
   #wyj�tki#
   gsub(/\[w: \]/,"[w:]",para);
   
   exch(nonwspace, wspaces "\\?", ".", "?");   
   exch(".", "\\?", letter, "? ");   
   
   exch(nonwspace, wspaces "!", ".", "!");   
   exch(".", "!", letter, "! ");   
   
   exch(".", "\\(" wspaces, nonwspace, "(");   
   exch(letter, "\\(", ".", " (");   
   exch(nonwspace, wspaces "\\)", ".", ")");   
   exch(".", "\\)", letter, ") ");   
   
   #spacje przy nawiasach klamrowych (wyr�nienia)
   xexch(nonwspace, "\\{", "\\\\((bf)|(em)|(it))", " {");
   xexch("(\\~|\\(|(,,)|(>>)|(<<))", "\\ \\{", "\\\\((bf)|(em)|(it))", "{");
   exch(nonwspace, wspaces "\\}", ".", "} ");
   #ryzykowne (np. kropki od dziesi�tnej numeracji rozdz., wzor�w, tabel...)
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
#   gsub(/�/, "\\\"u", para);
#   gsub(/�/, "\\v{c}", para);
#   gsub(/�/, "\\v{C}", para);
#   gsub(/�/, "\\oo{}", para);
   
   #formatowanie akapitu# 
   print_para();
   para = "";
}				# koniec funkcji process_para()

# pomini�cie wierszy pasuj�cych do "blanklines" 
$0~blanklines {
	nbl++
} 

# po pomini�ciu wierszy pasuj�cych do "blanklines"... 
$0!~blanklines {
	# sprawdzenie czy nast�puj�cy tekst jest pocz�tkiem nowego 
	# akapitu i przetwarzanie poprzedniego akapitu
    if (nbl>0 && $0~parbeg) {process_para()};
    
	# tworzenie �a�cucha "para" zawieraj�cego akapit  z~usuni�tymi
    # przeniesieniami wyraz�w i odst�pami lewego marginesu
	# ryzykowne - ��czniki, przyrostki na ko�cu wiersza 
	sub(/^[\ \t\n]+/,"");
    if (match(para, lowletter "-" wspacesornot "$")==0) para = para " " $0
    else para = substr(para, 1, RSTART) $0;
	
	nbl = 0
}

END {process_para();}
