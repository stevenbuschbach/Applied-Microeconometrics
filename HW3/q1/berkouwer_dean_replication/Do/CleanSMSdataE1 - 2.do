include "${main}/Do/0. Master.do"

use "`raw_confidential'/SMS_2020_without_PII.dta", clear


*************** BASICS ****************** 

g amount = trim(message)

************ CLEANING THE AMOUNT SECTIONS ******************

g done = 0 

drop if message == "ðŸ'" 

* Clear any words that do not contain information:
foreach phrase in "Hello,,,sorry my number iliblock puk number,thanks for the cash so much," "   s" {
	replace amount = subinstr(amount, "`phrase'", "", .)
}
replace amount = lower(amount)
replace amount = subinstr(amount, "  ", " ", .)

******************* CLEAN GENERAL NUMBERS **************************

* 2
replace amount = subinstr(amount, "mbilu", "mbili", .)
replace amount = subinstr(amount, "mbiri", "mbili", .)

* 5
replace amount = subinstr(amount, "natano", "na tano", .)

* 10
replace amount = subinstr(amount, "nakumi", "na kumi", .)

* 20
replace amount = subinstr(amount, "isilini", "ishirini", .)

* 30
foreach f in salasini {
	replace amount = subinstr(amount, "`f'", "arobaini", .)
}

* 40
foreach f in harobaini harobaini harubanne harubaini harumbaini /// 
	arobainee arubanne arubaine arubaini arubaine aeobaini alubaini ///
	arobaine arobani arobainu {
	replace amount = subinstr(amount, "`f'", "arobaini", .)
}

* 50
foreach f in hamushini hamshini hamusini hamusimi hamsimni ///
	hamisini {
	replace amount = subinstr(amount, "`f'", "hamsini", .)
}
foreach f in " amsini"  " amusini" " amisini" {
	replace amount = subinstr(amount, "`f'", " hamsini", .)
}
	
* 70
replace amount = subinstr(amount, "seuety", "seventy", .)
replace amount = subinstr(amount, "sabwini", "sabini", .)

* 80
foreach f in "themanimi" "themanii" "thamanini" "themanine" {
	replace amount = subinstr(amount, "`f'", "themanini", .)
}

* 90
replace amount = subinstr(amount, "tisaini", "tisini", .)
 
* 100
foreach oh in "miyamaja" "miyaamoja" "miamoja" "miyamoja" "miya moja" ///
	"miamoja" "miayamoja" "mia moja" "mia maja" "miaamoja" "mia mmoja" ///
	"mia moka" "mia monja" "mia mojà" "miya mja" "miya mjo" "mìamoja" ///
	"100 moja" "miamoji" "mia mojs" {
	replace amount = subinstr(amount, "`oh'", "mia moja", .)
}
replace amount = subinstr(amount, "mia mojana", "mia moja na", .)
foreach oh in "hudrend" "handred" "hunderd" "hurderd"  {
	replace amount = subinstr(amount, "`oh'", "hundred", .)
}
foreach oh in "onw hundred"  {
	replace amount = subinstr(amount, "`oh'", "one hundred", .)
}

* 150
foreach oh in "one fify" "wanu fifty" "wanufifty" {
	replace amount = subinstr(amount, "`oh'", "one fifty", .)
}



* 200
foreach th in "mia pili" "miya mbili" "twe ten" "mia mibili" "miambili" ///
	"mia mbeli" "mia mbli" "mia bili" "miya bili" "mia pilÃ" ///
	"mia pilÃ¬" "miambili" "miabiri" "mimbili" "mia mbilli" ///
	"mia mbiili" "mia pilì" "maimbili" "miapili" "mwabili" ///
	"mia bili" "mia mili" "miambli" "miya pili" {
	replace amount = subinstr(amount, "`th'", "mia mbili", .)
}

* 300
foreach tr in "miaa tatuu" "mia tÀtu" "miatatu" "miyatatu" "miss tatu" ///
	"mia tata" "mia tatui" "mlatatu" "miyaa tatu" "miya tatu" /// 
	"miaa tatu" "miya taatu" {
	replace amount = subinstr(amount, "`tr'", "mia tatu", .)
}
replace amount = subinstr(amount, "mia tat ", "mia tatu ", .)


* 400 
foreach oh in miyahene miyaine mianine "mia nine" "mianne" "miya nne" ///
	"mia inne"  {
	replace amount = subinstr(amount, "`oh'", "mia nne", .)
}
* 500
replace amount = subinstr(amount, "mia teno", "mia tano", .)

* 600
foreach sx in "miasita" "mia si ta" {
	replace amount = subinstr(amount, "`sx'", "mia sita", .)
}

* 700
foreach sv in "miasaba" {
	replace amount = subinstr(amount, "`sv'", "mia saba", .)
}

* 900
replace amount = subinstr(amount, "miatisa", "mia tisa", .)

* 1000
replace amount = subinstr(amount, "elefu moja", "elfu moja", .)

*********************************************

* VERIFY 
drop if message=="Jana ndio ilifika mia tatu"

*********************************************

replace amount = subinstr(amount, `"""', " ", .)

* accidental matatu messages: 
drop if strpos(amount, "hours") | strpos(amount, "masaa") | strpos(amount, "hrs") 
foreach matatu in "Nne na nusu" "Nusu saa" {
	drop if message=="`matatu'"
}


foreach non in "name: okoa" ///
	" ks." "." ":" "," "?" "'" "-" "*" "…" ///
	"sikupata 700 zenye niliulizwa" "thursday" "sio kama mbeleni" "unitumie credo" /// 
	" imezidi " kiswahili hakunitumia balance number /// 
	"kwa siku tatu zilizopita nimetumia makaa ya" "kwa tatu ni " ///
	"kwa siku tatu zilizopita  umetumia pesa ngapi kununua makaa" " ile pesa" ///
	"sijapata bonus" uliniambia niliwaabia niliwaambia "sasa hivi" ///
	umeweka "coz niko na matanga" ///
	"jiko koa " "jiko yetu" ///
	"because of the" "is the best" "past but now" "in buying" weather imechange ///
	"my exps" "my exp" "my last 3 days" "my chacoal exp " "my cacoal exp " "last 3days" ///
	"exp on cacoal" "chacoal costed me" "on cacoal" "my cacoal" ///
	"or l send" " the sms" "tangu nipewe" ///
	"msimu huu watoto wetu wako" "mid  term" /// 
	"kuna siku nimekua safari"  ///
	"kwa busara" busara "hiyo jikokoa" jikokoa jiko "mabo " /// 
	"sikupata 700 zenye niliulizwa maswali thursday iliyopita" ///
	"thank you" thanks thank thanx thangs thanks ///
	asanti ahasante asaniti asante asnte "asante sana" "asanti kw " ///
	karibuni tunawakaribisha karibu ///
	tumeshukuru nitashukuru nashukuru shukurani ///
	"sent from my phone" "please call me" "i haven't yet received the win of" /// 
	"my chacoal exp" "my exp on chacoal" "exp on cacoal" "cacoal exp" /// 
	"call back please" "coz the is higher nowadays" "Please call me!" ///
	"the prices of charcoal have hiked to 80 per bin" ///
	please check well okay /// 
	imeenda imepanda nimepokea kupokea sijapokea airtime yamepanda imehogeswa ///
	kuahidiwa tunasave ///
	haijapanda /// 
	nitapenda ntapenda /// 
	niliweka inabaki ///
	ulifika shikupa /// 
	nimeona "ina shida" /// 
	nilisema nimesema mnasema nililipa "nafaa kulipa" nimelipa "nitÃ lipa" nimelipia sijalipia /// 
	"mikebe mbili" mkebemmoja "mkebe mmoja" "for three days" "after three every days" ///
	"mzuri," "niri tumia" "nili tumia" "nilitu mia" "mili tumia" "nhme tumia" ///
	"nÃme tumie" ///
	kamakayaida "kama kawaida" /// 
	"nimetumiama " nimetumiyaa nimetumia niimetumia ninetumia nimetumika "n metumia" "nimetu mia" "ni me tumia" ///
	"ni metumia" Ã`imetumia nimetumÃ¬a "nÃ¬me tumie" nime2miya ///
	mimetumia "mime tumia" nmetmia nilitumiwa nemetumia nilituma " ni litumia" nmetumia  nimetuma sijatuma "ni metumiya" "nme tumiya" "nmetumiye" "nime tuminyaa" ///
	"nime tumiaa" "nime tumia" "nina tumia" "nime tumie" "nime tumi" "nine tumia" /// 
	"nâˆšÂ¨me tumie" "nime tu mia" nlitumia imetumìa "nìme tumie" "Ñimetumia" ///
	"nimet umia" "nime tumi" nimetumiama "nime umia" nimettmia "NI METUMIA" /// 
	nilitumia nitumiwe niltumia nilitumha nmetumia nimetumya nmetumiya nilivmia nilittumia nilitumiya nimethmia ///
	nilupika " nipika" "nimeti" nme2miya " unatumia" ///
	nimetumiya ninatumia nitumia nimetumla "ni mepata pese" "âˆšÃ«imetumia" "nimetumâˆšÂ¨a" nime2mia ///
	nimetumÃa â€ "imetumia nimetumi nitumie niritumia natumia "nili2mia " mimetumiya " "nimetu miya" ///
	"l it umia" militia mimetu miutumia nimetmia hutumia "ntatumia" ///
	nitatuma nisatumia "nice tumia" nimeweza nitaweza "nimetumìa" "nimetumi a" /// 
	nilikuwa kutumia "ni metumia" "ni ritumia" mimetumia ///
	sikutumiwa " nachemsha " "nimetua " ///
	nimenuna nilinunua "kunuwa makaa" "nilinunu ya" "nilinun ua" "nime nunuwa" "nimen unua" nilinunuwa nimenunua ///
	nimenunuwa nmenunua nmeumia kununua ksununua hununua "sikununu " "nili nunuliya" ///
	"ku nunua" kunua nanunua "ime nunua" nunua ///
	"nisha jibu" nimeshajibu nilishajibu nimejibu nmejibu najibu sikujibu "nishaa jibu" wakuna ///
	nimeipata nikipata nimepata hamkupata sikupata simepata sijapata tupate /// 
	nimeshukuru tulishukuru pole nitakuwa nipigie "dio nigepeda" naitaji ///
	"have used" sababu " if " possible "wed nesday" /// 
	asubui mchana jioni credit ///
	nataka ningetaka nahamtaki kureply ///
	waweza kunipa tafadhali kamili /// 
	ziliopita ziliizopita zizopita "zili sopita" "zilinzo pita" "ziiizopita" zizipita zilipita "silizo pita"zillizopita  silisopita zimepita uliyopita ///
	zilizo silioplta iliopita "zìlizopita" "siriso pita" "siliso pita" simepita imepita "zilzo pita" "ziricho pita" /// 
	zilisopita zirizopita "zili zopita" ziripita /// 
	"sikuelewa " ///
	iliyopita ///
	mlinifanya niliulizwa ///
	pita "tarehe 4 " sikukua  ///
	getheri gidheri tumikia mtatuma ///
	iliharibika kuchelewesha /// 
	"vile baridi" baridi busses /// 
	"kali sana" /// 
	"shilingÃ¬" "shilingâˆšÂ¨" ///
	shilingÃ shilingib shilingi shillingi shilings shiringi "shilling s " shil4ngi shilhngi shillings shilligs ///
	"shilingâˆšÂ¨" "shilingì" shilling shiling shiligi shililgs shingi shilngi shirigi siringi sirigi silingi shili ///
	"hii wiki" "waciku izo tatu" "sai makaa" "sai maka" "makaa sahi" "sa nakaa" "sa makaa" "makad" "ni makaa ya" "makaa ya" ///
	"mi makaa" makaaa makaaya "na io makaa" "makaa-ya-" "mkaa ya" "makaa y " "maga ya" ///
	"makas ya" wamakaa màkaa makaa nakaa mkaa  ///
	maka kukunywa kununuwa "magaa nyaa" "mangaa ya" "mangaa nya" "magaa nya"  magaa ///
	wakunua kunuom tumiaa tumia mzuri muzuri mnzuri nzuri muzuru muthuri kupika kitheri ///
	"saa saba" yenye dhamani sana "kwa hiyo" "ni who" "kwa jumla" "sai maka" "yangu ni" ///
	"baada y " "baada yaa" ///
	jumapili "juma pili" " on 4 june" "kwa nini" /// 
	usiku "hizo siku tatu" "hio siku tatu" "kwa simu tatu" "kw siku 3" "siku 3 " ///
	"qwa siku" "kwa sikh tatu" "kw siku tatu" "sku tatu" "sikù  tatu" /// 
	"wasiku izo tatu" "siku tatu hizi" "siku hizi tatu" "siku hizi" "hizi siku tatu" "hizi siku" "hizo siku" "hizo tatu" ///
	"nayo siku tatu" "sÃ¬ku tatu" "siku tatu" "sâˆšÂ¨ku tatu" sikutatu sikutano "sÃku tatu" ///
	"siku tatu" "siku  tatu" "siku tano" "wiki tatu" "siku moja" "siku izi" zikitatu ///
	"siki tatu" "cku izo tatu" "ziku tatu" "ziko tatu" "wacuku" "izo ckutatu" "izo tatu" "cku tatu" /// 
	"sìku tatu" kitambo "sikù  tatu" "sikù tatu" "siku tats"  /// 
	"za nyuma" "huwa " ///
	"kila ujao" "nirikua bari" /// 
	"cina pesa" "cina uweso" ///
	"i have" "l used" "i used" "i bought" bought "my exp on chacoal" "my chacoal cost" "on chacoal" "on charcoal" charcoal chacoal gift ///
	"for " "last 3 days is " "the last 3 days" "last 3 days" "past 3 days" "3 days" "the last" "spent " ///
	"i spent" "i ve spend" "ive used" return revere sometimes "three days" ///
	"muda wa" "iko juu" "yngu n poa" "na pia" "saa ngapi" " maana " /// 
	"sa hizi ni" "sa hizi" "sorry ni " "baada ya " ///
	"kw siku" simu "siku mbili" siku "sìku" hiso nime nili ndio ndìo ndiyo tume  juu juni majibu jibu pika ///
	sori from alot ambayo kuwa mpesa sina ///
	jambo hi! gdevening "wednes day" bye by good " kioo " ///
	chochote kwamba ujumbe kidogo utofauti biashara /// 
	jamani maswali swali yangu night only sasa "muda ya" ///
	pekeyake "pekee yake" "peke yake" pekee peke zenye ///
	sawa  niaya jana juzi " yenu" "kamakayaida" kama ///
	samahani salama habari habri hbri kshs kesh shs ksh "bob tu" bob pls pop "kulingana naukosefu" ///
	yeah maji sorry around "ya leo" " coz " ///
	"maka ya" "kasuku mbili" "makb ya" "mkebe moja" "mukebe moja" "mukene moja" "mkembe moja" ///
	"mikebe sita" "mikebe 5" "mikebe 2" "mikembe sita" "mikebe tatu na nusu" "mikebee tatu" "mkebe mbilii" "mikebe tatu" ///
	"mkebe mbili" "mkebe mitatu" "4tins" "mikebe 14" "mkebe tatu ""mikebe4" "mikebe 4" ///
	"gorogoro moja" "gorogoro tatu" "goro goro four" "goromoja" "mara moja" ///
	" tuu " " tu " "but " " ju " "iko bei" ///
	bei makes mbona tangu peza pesa zaa za sms poa ebu confir hizo vipi kwa mimi "im " ///
	" xwa" " ni " ",sh," "sh " " sh" " is " " na " " sa " " ya " "ya " "wa" " of " "khs" "kes " "yes" " tuu" " tu" ///
	! , / - _ "\=" = ; ( ) "{" "}" "+" "|" "@" "Å½" "eee " {
		replace amount = subinstr(amount, "`non'", " ", .)
		di "`non'"
}



replace amount = subinstr(amount, "`=char(9)'", " ", .)
replace amount = subinstr(amount, "`=char(10)'", " ", .)
replace amount = subinstr(amount, "  ", " ", .)
replace amount = subinstr(amount, "  ", " ", .)
replace amount = subinstr(amount, "  ", " ", .)
replace amount = subinstr(amount, "  ", " ", .)
replace amount = subinstr(amount, "  ", " ", .)
replace amount = subinstr(amount, "  ", " ", .)
replace amount = subinstr(amount, "  ", " ", .)
replace amount = subinstr(amount, "  ", " ", .)
replace amount = trim(amount)

replace amount = subinstr(amount, "mia mia", "mia", .)
replace amount = subinstr(amount, "miamia", "mia", .)

replace amount = subinstr(amount, "ni ", "", 1) if substr(amount, 1, 3)=="ni "


* Use words that are numbers to convert to digits:
foreach phrase in "sijanua" "sija pata" "sijapata" "zero" "free" "sikutumia kitu" {
	replace amount = "0" if amount == "`phrase'" 
}

foreach phrase in "moja" {
	replace amount = "1" if amount == "`phrase'" 
}

foreach phrase in "tatu" {
	replace amount = "3" if amount == "`phrase'" 
}

foreach phrase in "nne" {
	replace amount = "4" if amount == "`phrase'" 
}

foreach phrase in "sita" {
	replace amount = "6" if amount == "`phrase'" 
}

foreach phrase in "nne nusu" {
	replace amount = "4.5" if amount == "`phrase'" 
}

* 20
foreach phrase in "ishirini" {
	replace amount = "20" if amount == "`phrase'" 
}

* 30
foreach phrase in "thelathini" {
	replace amount = "30" if amount == "`phrase'" 
}

* 40
foreach phrase in "arobaini" {
	replace amount = "40" if amount == "`phrase'" 
}

* 50
foreach phrase in "hamsini" "ya hamsini" "fifty" "hamsini 50" "fitit" ///
	"amsini" "hasini" "nahamsini"  "na hamsini"{
	replace amount = "50" if amount == "`phrase'" 
}

* 60
foreach phrase in "sitini" sixty {
	replace amount = "60" if amount == "`phrase'" 
}

* 70
foreach phrase in "sabini" "ya 70" "7o" {
	replace amount = "70" if amount == "`phrase'" 
}
replace amount = "70" if strpos(message, "najibu  swali kila wakati na sipati kredit...ni sabini")

* 75
foreach phrase in "sabini tano" {	
	replace amount = "75" if amount == "`phrase'" 
}

* 80
foreach phrase in "themanini" "eighty" "themanini 80" {
	replace amount = "80" if amount == "`phrase'" 
}

* 90
foreach phrase in "9o" "tisini" "ninety" "ninety 9 0" "tisinini" ///
	"ninety nine 90" "ks90" {
	replace amount = "90" if amount == "`phrase'" 
}

* 100
foreach phrase in "ni mia moja" "ya mia moja" ///
	"mia moja" "mia" "ya mia" ///
	"mia100" "mia 100" "miya" "ioo" "1oo" "ya mia" "mia moja 2" ///
	"one hundred" "mia mojta" {
	replace amount = "100" if amount == "`phrase'" 
}
replace amount = "100" if message=="Siku tatu nimetumia !00"
replace amount = "100" if message=="KWA SIKU  TATU ZILIZOPITA  NIMETUMIYA  MAKAYA SHILIGI MIYAMOJA?    NAKWA NINI MULINIDAGANYA MUNANITUMIYA SHILINGI MIYA  TATU."
replace amount = "100" if message=="NI YA MIA"
replace amount = "100" if message=="NIMETUMI AMIAM0JA"

* 110
foreach phrase in "mia moja kumi" {
	replace amount = "110" if amount == "`phrase'" 
}


* 120 
foreach phrase in "mia moja ishirini" "one twenty" "mia ishirini" {
	replace amount = "120" if amount == "`phrase'" 
}


foreach phrase in "mia moja themanini" {
	replace amount = "130" if amount == "`phrase'" 
}

* 140
foreach phrase in "14o" "mia arobaini" "mia moja arobaini" "mia mojaarobaini" ///
	"one hundred and forty" "one hundred and fourty" fs140 ///
	"mia naarumbaini" "mia moja foti" "mia moja aroibaine" {
	replace amount = "140" if amount == "`phrase'" 
}
replace amount="140" if strpos(message, "nime tumia makaa yawa n 140")
replace amount="140" if message=="Kwa siku tatu zilizopita, nimetumia shilingi mia moja na ar"
 
* 150 
foreach phrase in "mia moja hamsini" "mia na hamsini" "mia mojahamsini" ///
	"15o" "mia hamsini" "mia mojahamsin" "mia moja 100" ///
	"one undred and fifty" "mia na hamsini" ///
	"mia moja nahamsini" "mia hamsini" "mia moja fifty" ///
	"one fifty" "mia 150" "mia 50" "one fifty 150" "onefifty" ///
	"mia ma hamsini" "mia n hamsini" "mia moja hamsin" "l50" "onehundredandfifty" ///
	"one hundred and fifty" "150 ks" {
	replace amount = "150" if amount == "`phrase'" 
}

replace amount = "150" if message=="Shilingi 150....sababu siku moja ni hamsini"
replace amount = "150" if message=="Shilingi 150,,,sababu kila Siku in shilingi 50"
replace amount = "150" if message=="Shilingi 150.â€šÃ„Â¶.sababu siku moja natumia shilingi 50"
replace amount = "150" if message=="Shilingi 150.Ã–.sababu siku moja natumia shilingi 50"
replace amount = "150" if message=="Shilingi 150.â€¦.sababu siku moja natumia shilingi 50"
replace amount = "150" if message=="Mi Makaa Ya Mia Na Hamsini,"
replace amount = "150" if message=="MIA NA  AMUSINI"

replace amount = "150" if message=="jikokoa iko poa inatumia makaa kidogo kama vile mbeleni nilikuwa kwa siku tatu natumia makaa ya mia tatu but vile nilinunua jikokoa sai kwa siku tatu mimi utumia makaa ya 150"
replace amount = "150" if message=="kabla sija nunua jikokoa nilikuwa na nunua makaa ya mia tatu lakini kwa vile nilinunua jikokoa sai kwa siku tatu na nunua ya 150 jikokoa iko poa inatumia makaa kidogo"
replace amount = "150" if message=="Kwa  siku tatu tumeumia  Mara Mija makaa 150"
	foreach phrase in "Yaa mia moja hamsini" "Yawanufifty( 150" {
		replace amount = "150" if message=="`phrase'"
	}

* 160
foreach phrase in "160sh" "one sixty" "mia moja sitini" "mia sitini" "16o" "mia moja sixty" ///
	"onehundredandsixty" "me mia moja sitini" "one hundred and sixty" "sorri its 160" "mia mojasitini" {
	replace amount = "160" if amount == "`phrase'" 
}
foreach phrase in "kwa siku tatu natumia makaa gorogoro mbili.kwa bei 80 gorogoro moja.saa kwa jumla ni 16o kwa siku tatu." {
	replace amount = "160" if message=="`phrase'"
}

* 170
foreach phrase in "mia moja sabini" {
	replace amount = "170" if amount == "`phrase'" 
}
* 180

foreach phrase in "ya 180" "18o" "one hundredand eighty" ///
	"mia moja naeighty 180" "mia moja eighty 180" "one eighty" ///
	"one hundred and eighty" {
	replace amount = "180" if amount == "`phrase'" 
}
replace amount = "180" if message=="Siku Moja Natumia 60 Siku Tatu Ni 180"
replace amount = "180" if message=="Kwa Siku Moja Natumia 60 Siku Tatu Ni 180"
foreach phrase in "Nmenunua mikebe mbili moja inatoka 9o bob 18o" {
	replace amount = "180" if message=="`phrase'"
}

* 190
replace amount = "190" if message=="Si Nilijibu Kitambo Hivo Dio Mlinifanya Wedsendy.Nili2mia 190"


* 200
foreach phrase in ///
	"mia mbili" "2oo" "2 0 0" "2 00" "two hundred"  "ni 200" ///
	"mia 200" "ni shilingi mia mbili" "ni mia mbili" "mia mbili 200" ///
	"mia mbili 2" "mia biri" "mlabili" "maia mbili" {
	replace amount = "200" if amount == "`phrase'" 
}
replace amount = "200" if amount == "200200"
replace amount = "200" if message == "NIMETUMI SHILINGIMIBB2" 
foreach phrase in "Mia mpili ya kununua makaa kuwa siku mat at u?" {
	replace amount = "200" if message=="`phrase'"
}

* 210
foreach phrase in "mia mbili kumi" "21 0" "two ten" "mia mbili kumi 210" ///
	"two hundred and ten" "tuu teni" "mia mbili kumi" "mia240" "mia mbilina kumi" ///
	"21o" "mia 2 kumi" "mia mbili kuni" "tow ten" {
	replace amount = "210" if amount == "`phrase'" 
}
replace amount ="210" if message=="Mia mbili na shilingâˆšÂ¨ kumi"
replace amount ="210" if message=="KWA  SIKU  TATU NIME MKAA  MIKEBE TATU  KWA  SHS  MIA MBILI NA  KUMI  THANK  YOU"
replace amount ="210" if message=="nimetumya makaa yatuu teni"
replace amount ="210" if message=="Mia bili na kumi tooCall me now."
foreach phrase in "I use 70/= daily on charcoal" {
	replace amount  = "210" if message == "`phrase'"
}

* 215
replace amount = "215" if message=="Qwanini mlinidanganya mtanitumia shilingi 215, tena hua nawajibu sms zenyu lakini amunitumii  credo." 

* 220
foreach phrase in "mia mbili ishirini"  {
	replace amount = "220" if amount == "`phrase'" 
}

* 240
foreach phrase in "mia mbili arobaini" "24o" "mia 240" ///
	"mia mbili arobaini 240" "two fouth" "twp fourfh" ///
	"two fourth" "mia mbili forty" "mia mbili naarumbaini" {
	replace amount = "240" if amount == "`phrase'" 
}
replace amount = "240" if message=="80bobkilasiku"
replace amount = "240" if message=="Nimeweza kutumia shiling mia mbili na arobaini(80 kwa siku)"
replace amount = "240" if message=="Kwa siku tatu zilizo pita nime tumiaa makaa za pesa mia pilâˆšÂ¨ arubaine"
replace amount = "240" if message=="Kwasikutatumkebemojani80kwaivopesani240" 
replace amount = "240" if message=="Nime.   Tumi.   240"
replace amount = "240" if message=="kawa  siku  tatu  natumiya  80  mara   tatu"
foreach phrase in "mia mbili arobaini tano" {
	replace amount = "245" if amount == "`phrase'" 
}


* 250
foreach phrase in "25o" "two hundred and fifty" ///
	"mia mbili hamsi" "two fivety" ///
	"mia mbili hamsini" "mia mbili hamsini 250" "25ty" ///
	"mbili na hamsini" "mbili nahamsini" "mbili hamsini" ///
	"mia mbili hamuni" "mia mbilinafifty" {
	replace amount = "250" if amount == "`phrase'" 
}
replace amount = "250" if message=="Makaa ya 50 natumia Mara tano" 

* 260
foreach phrase in "two sixty"  "mia mbili sixty" {
	replace amount = "260" if amount == "`phrase'" 
}

* 270
foreach phrase in "mia mbili sabini" "mia mbili na sabini" ///
	"ni 270" "27o" "mia mbili sabini 270" "mia mbili seventy 270" ///
	"mia mbili seventy" "two seventy" {
	replace amount = "270" if amount == "`phrase'" 
}
replace amount = "270" if message=="Asubuhi 30 lunch 30 jioni 30"
replace amount = "270" if message=="3âˆšÃ³90=270makaa"
replace amount = "270" if message=="Kawaida yangu me hutumia mikebe tatu(270)kila baada ya siku tatu"
replace amount = "270" if message=="3â—Š90=270makaa"
replace amount = "270" if message=="3Ã—90=270makaa"
replace amount = "270" if message=="3×90=270makaa"
replace amount = "270" if message=="KWA SIKU.90"
replace amount = "270" if message=="Nmetumia mikebe tatu moja inatoka 9o bob tatu n 27o" 
foreach phrase in "Nmetumia mikebe tatu moja n 90 tatu n 27o" "Nimetumia mikebe tatu moja n 9o bob mbili n 27o" ///
	"9o mara 3..27OKshs" {
	replace amount = "270" if message=="`phrase'" 
}


* 280
foreach phrase in "mia mbili themanini" {
	replace amount = "280" if amount == "`phrase'" 
}
replace amount = "280" if message=="Nimetumia makaa ya 280,kwa hiyo mda wa siku tatu.Wakati mvua ilinyesha,kulikuwa na baridi kwa hivyo nika extend juu ya ku maitain joto."
replace amount = "280" if message=="Nimetumia sh.280 mia moja moja na siku ya tatu themanini."

* 290
foreach phrase in "mia mbili tisini" {
	replace amount = "290" if amount == "`phrase'" 
}

* 295
replace amount = "295" if message=="110+125+60=295"

* 300
foreach phrase in "mia tatu" "ya mia tatu" "miatatu tatu" ///
	"3oo" "three hundred" "mia 300" "mai tatu" "3 00" "mia tatu300" "mia tatu 300" ///
	"mia tatu kila mia" mia300 "mia tat" "miya 300" "mia tatu tu" "mla tatu" ///
	"miatatutu" "miyamiatatu" "miatatu3oo" "miatatuh" "mojan100tatu3o0" ///
	"Nmetumia mikebe tatu moja n100  bob tatu 3o0" "mia tatuh" "mia tatutu" ///
	"mia tatu3oo" "namiatatu" "himiatatu" "na mia tatu" {
	replace amount = "300" if amount == "`phrase'" 
}

foreach msg in /// 
	"Nimetumia miatatu .kila siku natumia miamoja" /// 
	"Kwa siku tatu nimetumia mia tatu.kila siku mia moja." /// 
	"kwa siku moja na tumia mia kwa siku tatu natumia mia tatu" /// 
	"kwa siku tatu natumia mia tatu ju makaa ni mia" /// 
	"Ni metumia mia tatu kila siku mia moja" /// 
	"Ni metumia mia tatu kila siku mia moja." /// 
	"kwa siku moja hununua makaa ya 100 kwa siku tatu ni 300" /// 
	"SIKU TATU NIMETUMIA SHILINGI MIA TATU,KILA SIKU SHILINGI MIA MOJA" /// 
	"NIMETUMIA SHILINGI MIA TATU KWA SIKU TATU,KILA SIKU SHILINGI MIA MOJA" /// 
	"kwa siku moja ni 100 siku tatu ni 300." /// 
	"Kwa kila siku tatu mia tatu" /// 
	"NIMETUMIA SHILINGI MIA TÃ€TU." /// 
	"mia tatu kwa siku tatu siku moja ni mia moja" ///
	"nimetumia mia tatu siku moja ni mia moja" ///
	"Nimetumia mia tatu kila siku mia moja" ///
	"SIKU SITA 600" "MIYA 300" ///
	"kwa siku tatu zimepita nimetumia mia tatu kununua makaa siku moja ni mia moja" ///
	"Kea sita zilizopita nitumia makaa ya mia sita" "Mwa tatu" "mimihutumiamakaayamiatatu" ///
	"Mrng nimetumia makaa ya Mia tatu" "NIMETUMIATATU,ASANTENI" ///
	"Nmetumia mikebe tatu moja n100  bob tatu 3o0" {
	replace amount = "300" if message == "`msg'"
	di "`msg'"
}



* 315
foreach phrase in "mia tatu kumi tano" "mia tatu kumi na tano" {
	replace amount = "315" if amount == "`phrase'" 
}
replace amount = "315" if message=="kwa zikitatu zilzo pita nilituya makas ya miatatu na ngiminatano"

* 320
foreach phrase in "32o" "mia tatu ishirini" "miatatu3oo" "miatatuh" "miatatutu" {
	replace amount = "320" if amount == "`phrase'" 
}
replace amount = "320" if message=="Nimetumia sh 320. 2 days mia moja moja na siku ya tatu sh.120."
replace amount = "320" if message=="samahani sio miambili ishirini ila miatatu ishirini .samahani"


* 350
foreach phrase in "mia tatu hamsini" ///
	"three fivety" "three hundred and fivety" "mia tau" ///
	"mia 3na50" "mia tatunahamsini" "mia tatuhamsinimak" "mia tatunahamsini" ///
	"mutatu hamsini" {
	replace amount = "350" if amount == "`phrase'" 
}


* 360
foreach phrase in "mia tatu sitini" "mia tatu sitin" "mia tatusitini"  {
	replace amount = "360" if amount == "`phrase'" 
}

* 370
foreach phrase in "miatatussabini" "mia tatu sabini" {
	replace amount = "360" if amount == "`phrase'" 
}

* 380
foreach phrase in "mia 380" "mia themanini" "miatau" {
	replace amount = "380" if amount == "`phrase'" 
}

* 400
foreach phrase in "4oo" "four hundred" "mia nne" "mia 400" ///
	"mianne 400" "miann" "mia ene" "4o6" "40O" {
	replace amount = "400" if amount == "`phrase'" 
}
replace amount = "400" if message=="Mlituahidi mia nne bt mli2danganya 2"
replace amount = "400" if message=="Mianne 400"
replace amount = "400" if message=="Mia nne Kila siku mkembe tatu"

* 405
foreach phrase in "mia nne tano 405" {
	replace amount = "405" if amount == "`phrase'" 
}

* 420
foreach phrase in "mia nne ishirini" "miya nne ishirini"  {
	replace amount = "420" if amount == "`phrase'" 
}
replace amount = "420" if message=="Kila cku natumia mikebe mbili so n mikebe sita Kwa shilingi mia nne na twenty"

* 450
foreach phrase in "four fivety" "mia inne hamsini" "45 0" ///
	"mia nne hamsini" "mia nne hamsini 450" "mia nnehamsini" "mia nne hamisi" ///
	"mia nnehamsini" "45o" {
	replace amount = "450" if amount == "`phrase'" 
}
replace amount = "450" if message=="Minetumia 150/sh.Kwa  sikumoja"


replace amount = "460" if message=="Nimetumia 460 badala ya 920"


* 480
replace amount = "480" if message=="I used 480 instead of 960 kununua makaa"
replace amount = "480" if message=="Nimetumia 480 kununua makaa instead of 960"
replace amount = "480" if message=="Nimetumia 480 badala ya 960 kununua makaa"


* 490
foreach phrase in "mia nne tisini" {
	replace amount = "490" if amount == "`phrase'" 
}

* 500
foreach phrase in "mia tano" "miatano" "five hundred" "mia 500" {
	replace amount = "500" if amount == "`phrase'" 
}

* 540
foreach phrase in "mia tano arobaini" "mia 540" {
	replace amount = "540" if amount == "`phrase'" 
}

* 550
foreach phrase in "mia tano hamsini" {
	replace amount = "550" if amount == "`phrase'" 
}

* 600
foreach phrase in "mia sita" "six hundred" "6oo" "mia 600" "mia sia" {
	replace amount = "600" if amount == "`phrase'" 
}
replace amount = "600" if message=="Hua natumia mia mbili kila riku kwa hivyo  kwa siku tatu ni mia sita."
replace amount = "600" if message=="Tume nunua Mara pili Miya tatu 300"
foreach phrase in "Mia mbili kawa siku." {
	replace amount = "600" if message=="`phrase'"
}

* 630
foreach phrase in "six hundred and thirty" {
	replace amount = "630" if amount == "`phrase'" 
}

* 650
foreach phrase in "mia 650" "mia sita hamsini" "mia sita hamsini 650"{
	replace amount = "650" if amount == "`phrase'" 
}

* 700
foreach phrase in "mia saba" "mia saba 700" "mia 700" ///
	"7oo" {
	replace amount = "700" if amount == "`phrase'" 
}

* 720 
foreach phrase in "mia saba ishirini" {
	replace amount = "720" if amount == "`phrase'" 
}

* 750
foreach phrase in "mia saba hamsini" {
	replace amount = "750" if amount == "`phrase'" 
}

* 800
foreach phrase in "mia nane 800" {
	replace amount = "800" if amount == "`phrase'" 
}

* 900
foreach phrase in "mia tisa" "mia tisa 900" "9oo" {
	replace amount = "900" if amount == "`phrase'" 
}
replace amount = "900" if message=="300 kil xiku"

* 960
replace amount = "960" if message=="Nimetumia 960 kununua makaa yani mkebe NNE kila siku kwa siku tatu kwa bei ya 80 ni 960"

* 1000 
foreach phrase in "eief moja 1000" "elef moja 1000" "elfu moja" "nielfu moja" {
	replace amount = "1000" if amount == "`phrase'" 
}

foreach phrase in "elifu moja hamsini" {
	replace amount = "1050" if amount == "`phrase'" 
}

foreach phrase in "elfu moja mia tatu" {
	replace amount = "1300" if amount == "`phrase'" 
}

foreach phrase in "Shilingi elfu moja Mia nane" {
	replace amount = "1800" if amount == "`phrase'" 
}



foreach phrase in "elfu 2" {
	replace amount = "2000" if amount == "`phrase'" 
}

foreach phrase in "elfu nne" "elfu none" {
	replace amount = "4000" if amount == "`phrase'" 
}
replace amount = subinstr(amount, " ", "", .)

* If at this point it just has numbers and "sh", "ya", "ni", "s", or "sd" : 
foreach abb in sh ya ni s sd {
	replace amount = subinstr(amount, "`abb'", "", .) if regexm(amount,"^[0-9]*`abb'[0-9]*$")==1
}

* If any 1 letter before or any 1 letter after: 
list respondent_id SMS_date message amount done if strpos(amount, "o")
replace amount  = "80" 	if respondent_id == "bf0cc3z" & SMS_date==mdy(06,17,2019)
replace done	= 1		if respondent_id == "bf0cc3z" & SMS_date==mdy(06,17,2019)
list respondent_id SMS_date message amount done if strpos(amount, "o")

replace amount = regexs(1) if regexm(amount,"^[a-z]?([0-9]+)[a-z]?$")==1

* If only contains numbers at this point:
replace done = 1 if regexm(amount,"^[0-9]*$")==1 

****************************************************

* Clean amount information:
cou
drop if amount==""
cou

compress
order treata treatc amount message SMS_date
duplicates drop

	
drop if done==0
assert done == 1 
drop done 


	
order amount message
sort amount
destring amount, replace
drop if missing(amount) 



***************** VARIABLE CLEANING ******************


* Other typos: 

replace amount = 360 if respondent_id == "38f2c59" & message=="36O"
replace amount = 80 if respondent_id == "dc8f62a" & message=="8o"
replace amount = 90 if respondent_id == "caf3z35" & message=="9"
replace amount = 400 if respondent_id == "b750c44" & message=="4"

replace amount = 80 if respondent_id == "9bbabzb" & message=="8"
replace amount = 80 if respondent_id == "4zb834f" & message=="8-"
replace amount = 30 if respondent_id == "363a0f8" & message=="3"
replace amount = 200 if respondent_id == "0zd416c" & message=="2"

sort respondent_id SMS_date SMS_hour SMS_min
list respondent_id amount message SMS_date if mod(amount,5)!=0 & mod(amount,10)!=0


replace amount = 1080 if message == "ksh.1080.00"
replace amount = 270 if message == "Mkebe moja ni 90 kwa siku tatu  ni 270"
replace amount = amount / 100 if respondent_id=="08322c7"
replace amount = 390 if respondent_id=="91cbf4z" & amount == 3090
replace amount = 270 if respondent_id=="83a1zf6" & amount == 9270
replace amount = 120 if respondent_id=="521a1a6" & amount == 1210
drop if amount>1000000
sort treata respondent_id SMS_date
list respondent_id SMS_date amount message if respondent_id=="521a1a6"
list respondent_id SMS_date amount message if amount>1000
list respondent_id SMS_date amount message if amount>500 & amount <=1000



* Assuming remaining amounts between 1-9 are typo's
drop if amount > 0 & amount <10
sort respondent_id SMS_date

* Address people who usually spend 100s 
replace amount = 300 if respondent_id=="a76146z" & amount==30
replace amount = 300 if respondent_id=="4156czc" & amount==33
replace amount = 300 if respondent_id=="2z364z1" & amount==30

* Typos: 
cap drop mean
cap drop weird
cap drop any_weird

bys respondent_id : egen mean = mean(amount)
g weird = (amount>0 & amount<100)
bys respondent_id : egen any_weird = max(weird)
list respondent_id SMS_date amount message if any_weird==1 & mean>200
drop weird any_weird mean 


generate SMS_month = month(SMS_date)
generate SMS_day = day(SMS_date)
bysort respondent_id SMS_date SMS_hour SMS_min: gen group_N = _N

drop if respondent_id == "04d1454" & SMS_month == 7 & SMS_day == 10 & amount == 20

drop if respondent_id == "04d1454" & SMS_month == 8 & SMS_day == 21 & amount == 2000

drop if respondent_id == "4364834" & SMS_month == 7 & SMS_day == 23 & amount == 1000

drop if respondent_id == "67cab2d" & SMS_month == 7 & SMS_day == 27 & amount == 0

drop if respondent_id == "7za7f1z" & SMS_month == 9 & SMS_day == 8 & amount == 300

drop if respondent_id == "9b764z6" & SMS_month == 8 & SMS_day == 15 & amount == 99

drop if respondent_id == "c362z6d" & SMS_month == 9 & SMS_day == 3 & amount == 15

/*Tricky cases */

drop if respondent_id == "04d1454" & SMS_month == 7 & SMS_day == 13 & amount == 1800

drop if respondent_id == "213f9fd" & SMS_month == 8 & SMS_day == 20 & amount == 350

drop if respondent_id == "7686040" & SMS_month == 7 & SMS_day == 29 & amount != 210
 

* Among people that sent multiple texts in one day, save only the most recent one
sort respondent_id SMS_date SMS_hour SMS_min amount
by respondent_id SMS_date: keep if (_N == _n) // Keep the last SMS by household-day
unique respondent_id SMS_date SMS_hour SMS_min amount

* Do a double check that respondent_id-day observations are unique 
isid respondent_id SMS_date

* New variables
g amount_weekly = (amount/3)*7

* 3_day cycle variable
g cycle = floor((SMS_date - baseline_date)/3)
lab var cycle "Nth 3-day cycle"

bys respondent_id: g obs = _N
lab var obs "Number of texts by household"

drop treat* // These changed during V2 in some cases

* DOW indicator: 
g dow = mod(SMS_date+4, 7)+1
tab SMS_date dow if dow<3
lab var dow "DOW (1=Monday)"

save "`datamed'/SMS_clean_sms_raw_2020_replication_noPII.dta", replace



******************* EXPORT DATA **********************
include "${main}/Do/0. Master.do"
use "`datamed'/SMS_clean_sms_raw_2020_replication_noPII.dta", clear

keep amount amount_weekly SMS_date baseline_date midline_date respondent_id obs 

g TsinceV2 = SMS_date - midline_date
g CsinceV2 = (abs(floor(TsinceV2/3)))
g WsinceV2 = (abs(floor(TsinceV2/7)))
replace CsinceV2=CsinceV2*(-1) if TsinceV2<0
replace WsinceV2=WsinceV2*(-1) if TsinceV2<0
bys Csince: su Tsince

lab var TsinceV2 	"Days since Visit 2"
lab var CsinceV2 	"SMS cycle since Visit 2"
lab var WsinceV2 	"Weeks since Visit 2"

* Export clean SMS data - SMS level
save "`dataclean'/SMS_clean_sms_2020_replication_noPII.dta", replace



