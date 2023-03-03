include "${main}/Do/0. Master.do"
clear all
use "`raw_confidential'/SMS_2019.dta", clear /*File generated in private repository */


* Drop first month of attention control group (the Matatu SMSes)
format baseline_date %td
sort amount
g preV2=(SMS_date-baseline_date<30) | (SMS_date < midline_date+2)

drop if missing(midline_date) // Don't know when V2 was, in relation

lab var preV2 "SMS pre-Visit 2"

tab amount if treata==0 & preV2==1 
tab amount if treata==0 & preV2==1 & (SMS_date > midline_date-3)

cou
drop if treata==0 & preV2==1
cou

************ CLEANING THE AMOUNT SECTIONS ******************

g done = 0 

* SMS does not contain meaningful information:
foreach empty in ///
	"i jxt want 2 wish a fabulous xapa" "Asanti nimeipokea" SIKUHONAPESA TAITATU ///
	"Thanks" "Dionigependa credit" "Thanks Busara" "thanks." ///
	"Thenks" "Asante" "asante" "shukran" "22876" ///
	"Sawa na asante" "yap" "sijapata credo" "usinisumbue" "sikupata pesa zangu nilizowin." ///
	"Mzuri" "mzuri" Jambo "Hello mbona amukutuma pesa???" ///
	"Cjui" "Thanx" "Asente" "mzuri, asante" "Asanti nimepata" ///
	"ee ningependa kupokea credit" "Stop" "STOT" "thankz" "Usinisumbue" ///
	"Nimepata" "Sawa" "umepata jibu" "Nsawa asante." "Nikipata jiko nitashukuru" ///
	"Sawa Asante" "MLisema mtatupatia siting allowance iko wapi ?" "Ni nani" "We n nani" ///
	"Ningependa" "Nataka" "Ndio" "Sawaa nko ready" "nimejibu. pole i" ///
	"Pole.sikukua,nasimu,karibu" "Nilikuwa.bisi,kidogo.ndio.nimemaliza," ///
	"Kwa siku tatu zilizopita, umetumia pesa ngapi kununua makaa?" ///
	"Asante nimepata credit.alafu tulikua tumeambiwa tutatumia pezd zenye tulishida baada ya siku tatu kwani kulienda anje?" ///
	Qiguppp "bado sijatumiwa. bali ile ya tarehe 4 mwezi wa tano." ///
	"BUT SINA PESA YA KUNUNUA IYO JIKO SAMAHANI" "PLZ NISAJIBU SAA MOJA NA 46" ///
	"Nisawa nangojea" "Gudevvng,ulniambiaje ntapokea airtyme dakika chache jana ata saa hii bado." ///
	"sory please i had left my phone in the house i was not there" ///
	"Mabo honey,,, nilirudikitambo nanilinyesheshewaa,, naendea nyama nipike sikupika lunch" ///
	"nimepata credt na sijaelewa io number ni ya nini" "Uni weke kwamaombi mama yangu ameraswa tumutumu na haongeii" ///
	"Mlituahidi mta2ma pexa kuliendaje?" "Nikiwa na pesa kwa wa katihuo nitaichukua nakama sina siku nyine." ///
	"SIKU TATUTU TU LAKINI HAYAKUTOCHA KWA SABU,JIKO NA LOLITUMIA SIJIKO NZURI KAMA LENU?" ///
	"asante nimepata" "Sawa asante" "Asante  Sana Busara" "Qp" "Nimepokea airtime, asante sana Busara" ///
	"mbona sijapata pesa yoyote" "MBO" "Ok" "O" "sufuri" ///
	"Nili particpate na sijatumiwa kitu kutoka busara"  ///
	"But there is 600 u have  not sent 2me" "Habari,sijai pata pesa" "NIKO TAYARI KUJIBU" ///
	"Mbona hamjanitumia pesa yoyote" "Mbn kimya tena" "Labda siku  nyingine for nao am not OK kipesa" ///
	"Jiko tofauti na yenye nimenunua leo ama?" "inahuswa pesa ngabi" "Hata ile pesa sikupata" ///
	"Hi,Asanti Kw Gift" "I haven't yet received the win of KES 400--Sent from my Phone" "Mike,tano" ///
	"Nasikitika  sitaweza  kushiriki  kwa  utafiti  huu  kwa  sababu za kifamilia.  Sorry for the inconvenience." ///
	"saa nyinyi atanikiwambia amtumi credo" "Alafu kuna pesa mliniahidi mpka Wa Leo hamjatuma kwa ilikuwa c kweli" ///
	"hi i answered the question bt i didnt recieve any credit" "170 shillings 2wks ago." ///
	"Hamukutuma pesa" "A" "B" "Please call me back, thank you." "Iwas promised" "kama ngapi?" "Kesho 8 plain" ///
	"Kwa   malipo  ya. Polepole" "ebu tuwache izo hadi" "shita yako?" "Sina  pesa kwa sai" "Rubisha. Swali" ///
	"Mbona sijapata balance yangu?" "Sawa niko  tayari" "Ni pesa ngapi" "Ni how much" "Nie" ///
	"I have not got your m pesa money since 8 days have passed what is wrong" ///
	"Mbona sijapata balance yangu?" "Ni pesa gapi" "Mi niko nayo" "Unajua unaongea nani" ///
	"WENGINEWAMEPATAJIKOKOASIJAPATA" "Nimekua nikijibu na sijawai tumiwa credit" ///
	"Sawa,naitaka sana interest ya chini kama" "Nigepeda Sana Kuinunua Lakini Pesa Dio Sina" ///
	"CJGDMJDGMWGP.A" "pesa yote," "Nimelipa deni yenu yote ksh 1260 naona tusisubuane sana. Check mpesa message ." ///
	"wenginewaiipata.jikookoasiatukupata." "Mbona nimekwa Nikijibu SMS zenyu namunasema sijawajibu?" ///
	"Kwani mtu hujibu aje kwa busara." "Nalipa yote on the drad  line day" ///
	"UJAMBO  HIYO WEKI ITA NI PATA  KAMA  NIKO NYUMBANI" "BALANCE  YENYU  NI  580  ONLY  SIO  YENYE  MNANIAMBIA" ///
	"Nimekwa niki jibu lakini hamni tumiangi kredo ata sahii nimejibu mara mbili" ///
	"Tangu nipewe jiko wk mbili zimeisha jana na nimelipa mara mbili." ///
	"Maswali yote mnauliza kutoka Busara, najibu lakina niliacha kupokea credit. mnasms mkisema sijajibu lakina ujibu zote, sijui shida ilitokea wapi, mnaenza angalia tafadhali" ///
	"nimejibu.au ninafaa kujibu Mara ngapi?" "G" "gj" "Siku hizi sipati credit" "How was the day,,," ///
	"Mama's" "sii nimejibu" "Sijatumiwa credit afta kujibu swali." "stop" "V" "What's wrong," "saa" ///
	"Tutanunua jikokoa mikikuja hiyo wiki" "ni pesa ngapi?" "Nipesa ngapi" "Asante sana nita lipa hio pesa ." ///
	"Tafadhali Nitalipa Jumapili" "TADHALI NITUMIE PAYBILL YAKULIPIA" ///
	"kila mara nikiwajibu maswali yenu hamnitumiagi credo u better stop askg me ur questonz" ///
	"Nilipa pesa  yote ni  nini mnanitumia sms"  ///
	"Mnataka majibu mara gapi" "Kwani mtu hujibu aje." "Na balance yangu ya 215 yenye mlisema mtanitumia iko wapi." ///
	"We wacha kunitext kama unakitu ya kusema......nkt" "Kwani siku hizi mtu anajibu munasema ajajibu why" ///
	"Plz nashinda nikijibu na mnaniambia sijajibu so muangalie problem ni nini plz coz hata sasa nime jibu mara mbili sioni kama iko smart" ///
	"Hamjanitumia credit Leo mlivyoniahidi" "2lilipia sh 94 kwa wiki ya kwanza nitalipia tena jumanne" ///
	"Congratulations! You have received 27.00 KSH STORO Bonus Airtime expiry midnight. You can use your bonus to Call and SMS." ///
	"Facebook is now FREE on Safaricom! Stay in touch with your friends for free. Go to free.facebook.com/?ref=safk1 to enjoy" ///
	"See" "P" "Y" "Thanks so muchðŸ˜ðŸ˜ðŸ˜ðŸ˜" "sijapatahiyojikoyenywe" ///
	"Sijachelewa sinilikua nilipe baada ya wiki moja 93 ama mimi ndio sijaelewa? nilituma  93 tarehe 15 saa kumi na mbili ya njioni. ama nafaa kulipa aje juu naona mmetuma sms?" ///
	 ///
	"PTPTPTTPTQTPTPTPTWg" "credit cjapata" "I paid my loan on 10th so l will pay my second pay kesho" ///
	 "Tumelipa 94 twice" "Kwa msimu huu watoto" "Ipaid216tuesdayplease" ///
	"nili ambiwa ni lipange,208,KWA hivio mkiogezea sitaweza" "mrng,aky mtoto n mgonjwa;na ata dooh xa kumpeleka hos sijapata.satu do nilikuwa nataka kulipia aky tafadhali" ///
	"Nafuraia sana Asante" "Ni pokea habari hiyo" "nitalipa kabla ya tarehe tano" "Not yet untill the end of thise month" ///
	"I have paid ksh 428 not ksh 214 please !" "nilipe,208,ama?" "PLz namba y kulipia ilipotea sioni so plz nitumia plz" ///
	"Kindly SMS my number and the paybill number..I lost my receipt" "Matatu" "Mwatatu" "Ndfo" "NIJIBU AJE." ///
	"kwa nini pesa inakataa kuinga" "Hio pesa ilikua ya 2 weeks" "C kuwa n xmu bt nta tuma Leo plzz" ///
	"ata nijibu sipati kitu" "C kuwa n xmu bt nta tuma Leo plzz" "asante na pole kwa kukosa kurudisha message" ///
	"Nimelipia mara mbili sasa angalieni mtaona tarehe 15 na 19" "Ni sawa nitaziweka asubuhi" "Pls nitumieni pay bills nitume kesho" ///
	"Sijachelewa, nilikua nianze next week" "Mnani sumbua.hawa watu wenyu,wanapatiana hizo jiko wakitumia ukabila" ///
	"Ž/" "Thanks so much????????" "Nitàlipa" "Ndio nimerudi kutoka home so niko available" "100000002222333355566778899" ///
	"Nilituma Pesa Tarehe 4 Mbona Mnasema Sijalipia Nilituma 99sh" "Nilituma sh.350 on 4 june kwa busara,Ebu confir" ///
	"Nimelipa juzi  sh 93 hamkupata sms yangu?" "Nilituma shilingi 428 siku ya juma pili" ///
	"i will try my best to pay the balance" "i will try my best to buy the balance"  ///
	"STOP" ".T" "Thank u" "Umepata" "under" "We" "We*" "Yah" "Thankyou" "Thankyou So Much God Bless You" "We ivyone" ///
	"NINAFAA KULIPA KILA WIKI SASA HAYA YAMETOKEA WAPI NILIPE 613 SIELEWI NATAKA KUELEWA NAMARA YA KWANZA NILI LIPA 217 NILIPA WIKI MBILI YA TATU NI KESHOKUTWA HOWCAMES NILIPE BE FOR 27.6.2019 NAFAA KULIPA THUSDAY" ///
	"M" "MBONA HAMJIBU" "dint u see jiko okoa kwaku?" "Nimepata asati" "Mbona munasema nimelipia zero" "NDIO nataji credo" "Ni ifo" "NIKO NA SWALI" ///
	"NITAPATA.KESHO" "Thanks. Nitaipata wapi?" "SIJAWAI" "THAK YOU" "Thank You So Much" "Ubwa wewe ivyone" "Thank you very much" ///
	"Asnte xna busara kwasababu Nimekona mumenisaidia xna kunisaidia  kuu save  pesa zaku asnte xna busara na mungu awabariki" ///
	"Thanx for the token" "Cpendi kwarakishwa" "Mimi sijapata credit wacheni  ukora" "Mimi nimelia jiko  389 kwa sasa  sio hio  pesa muna sema haki" ///
	"nataka kuulza kam nimebakisha deni" "Mi huwa najibu sijawahi pata hiyo credit" "mnaeza nipa muda nilipe kesho" ///
	"ndio nafulahi sana am but nimelipa leo 220" "ebu nitumie namba yenye ninatuna" "nami mlibaki na 186 na hadi sasa mjanitumia" ///
	"Naomba. Kusaindiwa na pay bill pliz yangu. Ilipotea pliz" "Kwa sasa naomba mnipee muda maana niko mtoto kwa wodi na sijui nitatoka lini." ///
	"Naomba muda kidogo, wiki hijayo tafadhali,,," "Mimi sina credit na pesa zangu hamjawahi nitumia" "Niko mbali tafadhali nitumie pay bill" ///
	"nitalipa jioni nko hospitali" "Ntamalzia Kesho Asante" "On 22nd  sato nililipa ksh.689. Angalia a/ c yenyu" ///
	"Nitumie pay bill tafadhali tumalizane" "ebu paybil nilixau tafadali" "Pliz u promised me to send me 300 BT up 2 today HV not received" ///
	"Tafadhali by saa nane nitaweka 879 nitumie pay bill" "Salio nilio bakisha ni pesa gapi??" "Tafathali Nita lipa mwish wahuumwezi tukopamoja msiwenawasiwaSi nitalipa pole kwakuwachelewesha" ///
	"Till no iko na shida 844711 imekata kutoka jna"  ///
	"Siku  yangu  yakulipa  jikokoa  imefika  lakini  acaunt  yangu  imepoteya" "MBONA YULE KIJANA ALISEMA ATATUMA PESA MPAKA SAA HII HAMJATUMA" ///
	"Nime jibu sms 4 na akuna credit ninapata nawadai 80 bob" ///
	 "Deni ya last week,na hii week alilipa Jana usiku." ///
	"Nilituma pesa zangu  sote" "Hey, plz hile karatsi ilikuwa na number ya kutuma pesa ilipotea nitumie ile number." ///
	"Makaa imeshuka sai" "I can't  remember the  amount number  and Paybill number  plz send it to this number." /// 
	"Hi tangu nihaze please sija pata pesa sosote" 	"NAULIZA IWAPO MULINITUMIA SHILLING MIA TATU" "Mi hujibu maswali yenu but cjawahi pata kredo" ///
	"Tafadhali hamukunitumia zile 220 Za ile siku niliachiwa ndoo." "Makaa y'all Mia" ".j" ".L" "Malaysia" ///
	 "3dys" "Ak nko box tafadali xaii" "Al" "Nimeshalipa yote  kwa jumla 1151 shillings" ///
	"Amkupa,jiko" "Amukupa,jiko?" "Asati" "Asking about my money to before answering you Questions" "Wachana na mimi" "Wachana nayo" ///
	"Cja Pokea Credit" "Asante sana customers service." ///
	"wafasi wa mashetani nyinyi.we have God in our life" "Gaj" "nimelipa pesa gapi ya jikokoa," "Nimegonjeka adi sijapika" "Pesa yangu haijawai tumwa" ///
	"Have u reicev my balance" "Kwani hii jiko i bought 2606 and each and everyday bei inaongezeka nikilipa hyo 1709 nitakuwa nimelipia 3000 what's happening"  ///
	"Ile pesa ya Monday sina pata" "Ile pesa ya Monday sija pata" "Ill pay by tomorow" "I want my balance" ///
	"It's FURAHI day and we have a special offer just for you. Call for 1 bob per minute only! Simply dial *444*2# to enjoy this offer." ///
	"jesus christ is with me,ame,"  "KIMALA KYALO" "sorry nimekua nimerazwa hosi namtoto kakini nimeregea nyumbani leo nitaripa saturnday" ///	
 "Kweli nalipa pesa nyingi aje" "Lazima nitalipa" ///
	"jana nili lipa jana sai ni weeky tatu" "Nilimaliza. Kulipa" "Nilimaliza kulipa pesa ya jikokoa date 1/7/2009" "Malipo gani" "Nimejibu maswali yenu Mara mbili na mkutuma credit" ///
	"Nimejibu Mara mbili" "Mlini text eti nimebakisha ksh1726na but karatasi imeandikwa inafaa nilipe ksh2526 so balance yangu 1026" ///
	"PLS KWANI MMEKATA LAINI YANGU. YA KULIPA?SIKUWA NA PESA JUU NIKO MGOGWA PLS." "Nilisema mm uwa siharakishwi" "Kwa nini mnaniambia sijalipa pesa ya okoajiko?" ///
	"Mumeniongeza pesa ndio maana cjatuma xaxa jiko likirejeshwa pesa yangu itarudi shwa" "Habari mbona muna songesha  masiku yakulipa jikokoa ? First ilikwa  date 28 then 26 tena ni  25  mbona music set one date ? Mimi ni  mutu wakutafuta tu, I hope mumenielewa than u" ///
	"Musa,la21808felista.nyambura" 	"N00lpllllllppllllllpnlnlnlllllllllnllllnnll please." "Naezatumia namba ingine kulipa" "naeza pata loan plz" ///
	"Naeza saidiwa naumwa na meno ka loan kadogo plz" "nakubuka nitalipa"  "tafadhali naoba nitumie akaunt number ile mlinipea ilipotea domahana nikona dillei" ///
	"Naomba mueze kuniongezea siku tatu nieze kulipa jikokoa lenu maana nlkua nimelaza mtoto alikua amefukuzwa shule nkalipa shule aweze kurudi kwa maana Yuko form three" ///
	"Naomba mueze kusikisikiza ombi langu tafadhali" ".nasema hivi kwa sasa sijapata pesa sahi,nikipa tapesa hiyo wiki yakeso nitalipa hizo miatano imebaki yote,kwa hivyo gojapesa nitatuma zote ni mimi linet kamakuna sida muniambie tafathali." ///
	"Nasinimejibu angalia poa" "Habari.mimi nasikitika kuwa ile bei ambayo tukuwa tume kubaliana na nyinyi si ile yenye mnataka nilipe.Kwa bahasha ile bei ambayo imeandikwa ni elfu mbili ,mia sita sitini na moja." ///
	"Niachie hadi kesho jioni please" "Nigependa kubate credit" "Niketeka. Kupokea credit sana" "Nikipata nitatuma kwa sasa hivi sina" ///
	"Ni tumie paybill number" "Ninateke credit     03"  ///
	"Nireripa,yote," "Nireripa      yote  tafathari" "Mimi Niriripa Elufu Biri Miatano Thate Faii Diyo Inapaki" "Niriripa Erufu Biri Kwanini Munanisubua" ///
	"nitalipa kesho" "nitalipa kwasasa sina pesa nilikua na mtoto mgonjwa deni lilopo nitalipa pls" "nitalipa Leo nifile nimekua mgonjwa pole" "Nitalipa lipa deni amabayo nko nayo mwisho wa mwezi" ///
	"Sawa nitalipa Jioni  , but munafaa  kusema ukwli ,munabadilisha Date na   mukasema  inalipwa for three maths , sai  munataka balance yote  mm.   cwezi pata hiyo  pesa once sai  pia nikona matanga nimewaomba  munipe muda nilipe  date 11th balanc" ///
	"Nitalipa mwezi ikisha tarehe tisa nikipata mshara wangu" "Sawa sawa nitalipa pliz pliz" "SAMAHANI nitalipa jikokoa saturday usininyan'ganye jiko." ///
	"nitalipa tarehe moja" "Nitalipia balance  yote date 11th tafadhali my mum amepass  sai  Niko home pliz, cwezi kataa kulipa" "Nitatumapesa Tarehe Tano" ///
	"asante mimi nlmaliza kulipa deni yangu yote ya 1121" "Nmekw" "Nmelipa 1536,," "Nmelipa 1536,,naambiwa nlipe1872,na nlicheza na nkakula ile pesa napaswa kulipa n 2566 ya jikn okoa ,sasa how cam tena pesa imeongezeka celewi" ///
	"mimi nmemaliza kulipa" "Sawa ntalipa asante" "On a Manisha nini" "ONE CHWANI" "On my way home." "Nimepakisha ngapi nitumie hesabu yangu ndio nilipe" ///
	"NILIPATA ASANTE" "NILIPATA ASANTE" "Ebu nitumie paybiil" "Nitumieni paybill please" "Piz sorry if offended you but i can't answer you coz you have my money you don't want to pay me I work for four days" ///
	"Plz naomba mnivumilia hadi tarehe 13/8/2019 ili niweze kumalizia malipo yaliyozalia kuna pesa ya chama nitapata hiyo tarehe plz naomba mnisamehe tu kwa sasa,ni kwa vile mtoto wangu alikuwa amelazwa hospitali kwa wiki mbili na vile nimetoka huko" ///
 "Sijakosa kulipa nitalipa tafadhali mnipe muda kidogo" "Si lilikuwa linalipiwa kwa miezi tatu." ///
	"Simepaki ngapi" "Special Safaricom offer for YOU ONLY! Get Extra 100MB when you purchase 50 MB+ 50 SMS daily data bundle at only Ksh 20. Dial *544# to buy" ///
	"subirini kidogo Pesa zenyu za jiko okoa nitalipa" "Tarehe 19, nililipa Mara mbili nimebaki na372" "Nilitembelewa  last thursday nika win lotion na sabuni nikaambiwa nitakatwa na nitumiwe balance sijapokea" ///
	"Nilitembelewa na mtu wenu na akapima jivu nikajibu maswali zenu na bado sijatumiwa mia tatu" "Thank you  for the money that you  gave me  watu wa busara" ///
	"Mimi tiari nimelipa Mia tisa mbona mnasema nimelipa ziro pliz" "Kwa visit ya mwisho mlisema mtanitumia Mia tatu na hamjatuma" "We Know Is Not About Maka?" ///
	"Please will pay before Monday I'm having  a problem at the moment please" "yeap" "You have redeemed 10 Bonga Points for 3.00 KSH. Your new points balance is 7. Thank you for staying with Safaricom, the better optio" ///
	"You recharged Ksh 20.00. Your balance is Ksh 21.39 valid until 25-03-2020. Get 20% Bonus on top up with M-Pesa Paybill 777711, Enter Account No. (Mobile No)" ///
	"Zd" "Najibu SMS zenu na sioni credo so ,stop" "Nimeshalipa mia tatu ingine?" "Nimeshalipa mia 700sio mia600" ///
	"NIMETUMIA 1 400 TANGU NIANZE KUTUMIA JIKOKOA" "NIMENUNUA NGUNIA TATU ZA MAKAA KILA NGUNIA SHILLING ELFU MOJA MIA TANO" ///
	"Nmebakisha mia tao na twenty six,mia saba imetokea wp" "Nimelipa Mia Tatu Tisini Na Moja Mara mbili." "nilikuwa na wachukuza kwa sana nyinyi.wizi wa watoto" ///
	"Niliwaabia mnitumie akaudi number yangu ilipotea" "Mbona Mko Hivyo Ilikuwa 414 Tena Pesa Yangu Ya Mwezi Watano Na Wa Sita Sikupata" ///
	"Nafaa kulipa 1137" "please.check well.NILIWEKA 598= or l send  the SMS for mpesa" {
		replace done = 1 if amount == "`empty'"
		replace amount = "" if amount == "`empty'"
}

drop if message=="Nilituma sh.350 on 4 june kwa busara,Ebu confir"
replace amount = subinstr(amount, "kuna pesa nilishinda nikaa mbiwa nitatumiwa baada ya siku tatu na sijaona", "", .)

// If message contains a weird enough phrase, delete ENTIRE message:
foreach unknown in "DhfhNv" "NFR0UXCJ0Q" "pinki~mascarlenor" "Please call me thank you" "Please Call Me Thank You" ///
	"For the second time now,  I repeat,  I don't want to be part" "Hujajibu SMS kutoka Busara" ///
	"Tafadhali ukiweza uwe unanipigia simu kwa sababu hata nikisoma message siwezangi kuandika." ///
	"Tunatarajia unafurahia Jikokoa lako!" "New M-PESA balance is Ksh" "DOUBLE your airtime now!" ///
	"imetumwa kwa BUSARA CENTER" "Customer Transfer" "Habari, baada ya dakika tano utapata swali la SMS kutoka Busara." ///
	"You attempted to call me but I was not available." "Bonus yangu ya 200 Bob iko wapi??" ///
	"I can't answer anymore piz don't ask me any questions ok" ///
	"Best Offer Just for you today! Call for less than 1 bob per minute. Get 30 minutes at 20 bob only! Dial *444*2# to enjoy this offer, valid till 6 PM today." {
	replace amount = "" if strpos(amount, "`unknown'")
}	


* Put an actual quantity: 
foreach q in "3 TINS" "gorogoro moja" "goro moja" "mikebe 3" "Mikebe .   2   ya.    Makaa" ///
	"Mikebe3" "mkebe nne" {
		replace done = 1 if amount == "`q'"
		replace amount = "" if amount == "`q'"
}

* Purchased an amount of 0:
foreach zero in "Nisiku Mbili Nime Tumia Na Sija Maliza" "None" ///
	"Sorry,I've not started using it I've not recovered," "Bado sijatumia makb" ///
	"Bado sijatumia makaa" "Siku hizi tatu nime  save pasa  ya makaa" ///
	"Oksh." "Kwa sai makaa imepotea sijanunua" "Oku" "Sija nunua makaa hii wiki" ///
	"Sijatumia" "sijanunua" "Kwa siku tatu zilizopita zijatumia peza zozote kununua makaa." ///
	"Akuna" "Huwa situmii makaa." "What about 400 that u promise" "umeamua tw kulala hvyo gud nyt" ///
	"sijatumia kitu juu nilikua mwani sana nilitumia mafuta ya taa" ///
	"Mimi nimefnga singependa uongo siktumia  makaa" "Sikupata" ///
	"sijatumia makaa kwa siku tatu" "sijatumia makaa" "sijafiri  hii wiki" ///
	"Siku tatu zilizopita sikutumia. Pesa yeyote kununua makaa" "Hakuna" no non "NON" ///
	Sijanunua "Mimi Sina deni yeyote asanti" "Natamani sana lakini   kama nitakua na pesa nitanunua" ///
	"Sijatumia makaa kwa siku Tatu" "Sijatumia makaa kwa wiki mbili sasa" "please.check well.NILIWEKA 598= or l send  the SMS for mpesa" ///
	"bado sijanunua" "bado sijanunua makaa" "bado sijatumia pesa yoyote" "AKUNA" "AKUNA KITU" ///
	"sijatumia" "sijatumia." "sijatumia makaa." "Sijatumia makaa kwa siku Tatu zilizopita" "nome" "akuna" ///
	"Na sijanunua makaa izi siku mbili" "izo siku zote sija nunua makaa nimetumia mabakio yaizosiku zimepita." ///
	"Sijanunua makaa." "Sinunui" "BADO NATUMIA MAKAA YA GUNIA" "Sikununu makaa bahada ya siku tatu nilitumia yajuzi." {
	replace done = 1 if amount == "`zero'" 
	replace amount = "0" if amount == "`zero'" 
}


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
drop if message=="walinitu mia tano"

*********************************************

replace amount = subinstr(amount, `"""', " ", .)

* accidental matatu messages: 
drop if strpos(amount, "hours") | strpos(amount, "masaa") | strpos(amount, "hrs") 
foreach matatu in "Nne na nusu" "Nusu saa" {
	drop if message=="`matatu'"
}

foreach non in 	" ks." "." ":" "," "?" "'" "-" "*" "…" ///
	"sikupata 700 zenye niliulizwa" "thursday" "sio kama mbeleni" "unitumie credo" /// 
	" imezidi " kiswahili hakunitumia balance number /// 
	"kwa siku tatu zilizopita nimetumia makaa ya" ///
	"kwa siku tatu zilizopita  umetumia pesa ngapi kununua makaa" " ile pesa" ///
	"sijapata bonus" uliniambia niliwaabia niliwaambia "sasa hivi" ///
	umeweka "coz niko na matanga" ///
	"teresia" "wanjiko" "jiko koa " "jiko yetu" ///
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
	"nimet umia" "nime tumi" nimetumiama "nime umia" nimettmia /// 
	nilitumia nitumiwe niltumia nilitumha nmetumia nimetumya nmetumiya nilivmia nilittumia nilitumiya nimethmia ///
	nilupika " nipika" "nimeti" nme2miya ///
	nimetumiya ninatumia nitumia nimetumla "ni mepata pese" "âˆšÃ«imetumia" "nimetumâˆšÂ¨a" nime2mia ///
	nimetumÃa nimetumi nitumie niritumia natumia "nili2mia" mimetumiya "nimetu miya" ///
	"l it umia" militia mimetu miutumia nimetmia hutumia "ntatumia" ///
	nitatuma nisatumia "nice tumia" nimeweza nitaweza "nimetumìa" "nimetumi a" /// 
	nilikuwa kutumia "ni metumia" "ni ritumia" mimetumia ///
	sikutumiwa " nachemsha " "nimetua " ///
	nimenuna nilinunua "kunuwa makaa" "nilinunu ya" "nilinun ua" "nime nunuwa" "nimen unua" nilinunuwa nimenunua ///
	nimenunuwa kununua ksununua hununua "sikununu " "nili nunuliya" ///
	kunua nanunua "ime nunua" nunua ///
	"nisha jibu" nimeshajibu nilishajibu nimejibu nmejibu najibu sikujibu "nishaa jibu" wakuna ///
	nimeipata nikipata nimepata hamkupata sikupata simepata sijapata tupate /// 
	nimeshukuru tulishukuru pole nitakuwa nipigie "dio nigepeda" naitaji ///
	"have used" sababu " if " possible "wed nesday" /// 
	asubui mchana jioni credit ///
	nataka ningetaka nahamtaki kureply ///
	waweza kunipa tafadhali kamili /// 
	ziliopita ziliizopita zizopita "zili sopita" zizipita zilipita "silizo pita" silisopita zimepita uliyopita ///
	zilizo silioplta iliopita "zìlizopita" "siriso pita" "siliso pita" simepita imepita "zilzo pita" "ziricho pita" /// 
	zilisopita zirizopita "zili zopita" /// 
	iliyopita ///
	mlinifanya niliulizwa ///
	pita "tarehe 4 " sikukua  ///
	getheri gidheri tumikia mtatuma ///
	iliharibika kuchelewesha /// 
	"vile baridi" baridi busses /// 
	"kali sana" /// 
	"shilingÃ¬" "shilingâˆšÂ¨" ///
	shilingÃ shilingib shilingi shillingi shilings shiringi "shilling s " shillings ///
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
	for "last 3 days is " "the last 3 days" "last 3 days" "past 3 days" "3 days" "the last" ///
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
	"maka ya" "kasuku mbili" "makb ya" "mkebe moja" "mukebe moja" "mukene moja" "mkembe moja" "mike,tano" ///
	"mikebe sita" "mikebe 5" "mikebe 2" "mikembe sita" "mikebe tatu na nusu" "mkebe mbilii" "mikebe tatu" ///
	"mkebe mbili" "mkebe mitatu" "4tins" "mikebe 14" "mkebe tatu ""mikebe4" "mikebe 4" ///
	"gorogoro moja" "gorogoro tatu" "goro goro four" "goromoja" "mara moja" ///
	" tuu " " tu " "but " " ju " "iko bei" ///
	bei makes mbona tangu peza pesa zaa za sms poa ebu confir hizo vipi kwa mimi "im " ///
	" xwa" " ni " ",sh," "sh " " sh" " is " " na " " sa " " ya " "ya " "wa" " of " "khs" "kes " "yes" " tuu" " tu" ///
	! , / - _ "\=" = ; ( ) "{" "}" "+" "|" "@" "Å½" "eee " {
		replace amount = subinstr(amount, "`non'", " ", .)
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
foreach phrase in "sijanua" "sija pata" "sijapata" {
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
	"amsini" "hasini" {
	replace amount = "50" if amount == "`phrase'" 
}

* 60
foreach phrase in "sitini" {
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

foreach phrase in "9o" "tisini" "ninety" "ninety 9 0" "tisinini" ///
	"ninety nine 90" {
	replace amount = "90" if amount == "`phrase'" 
}

* 100
foreach phrase in "ni mia moja" "ya mia moja" ///
	"mia moja" "mia" "ya mia" ///
	"mia100" "mia 100" "miya" "ioo" "1oo" "ya mia" "mia moja 2" {
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
	"mia naarumbaini" "mia moja foti" {
	replace amount = "140" if amount == "`phrase'" 
}
replace amount="140" if strpos(message, "nime tumia makaa yawa n 140")
 
* 150 
foreach phrase in "mia moja hamsini" "mia na hamsini" "mia mojahamsini" ///
	"15o" "mia hamsini" "mia mojahamsin" "mia moja 100" ///
	"one undred and fifty" "mia na hamsini" ///
	"mia moja nahamsini" "mia hamsini" ///
	"one fifty" "mia 150" "mia 50" "one fifty 150" "onefifty" ///
	"mia ma hamsini" "mia n hamsini" "mia moja hamsin" "l50" {
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
replace amount = "150" if message=="Yawanufifty( 150"

* 160
foreach phrase in "160sh" "one sixty" "mia moja sitini" "mia sitini" "16o" {
	replace amount = "160" if amount == "`phrase'" 
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

* 190
replace amount = "190" if message=="Si Nilijibu Kitambo Hivo Dio Mlinifanya Wedsendy.Nili2mia 190"


* 200
foreach phrase in ///
	"mia mbili" "2oo" "2 0 0" "2 00" "two hundred"  "ni 200" ///
	"mia 200" "ni shilingi mia mbili" "ni mia mbili" "mia mbili 200" ///
	"mia mbili 2" {
	replace amount = "200" if amount == "`phrase'" 
}
replace amount = "200" if amount == "200200"
replace amount = "200" if message == "NIMETUMI SHILINGIMIBB2" 

* 210
foreach phrase in "mia mbili kumi" "21 0" "two ten" "mia mbili kumi 210" ///
	"two hundred and ten" "tuu teni" "mia mbili kumi" "mia240" "mia mbilina kumi" ///
	"21o" "mia 2 kumi" "mia mbili kuni" {
	replace amount = "210" if amount == "`phrase'" 
}
replace amount ="210" if message=="Mia mbili na shilingâˆšÂ¨ kumi"
replace amount ="210" if message=="KWA  SIKU  TATU NIME MKAA  MIKEBE TATU  KWA  SHS  MIA MBILI NA  KUMI  THANK  YOU"
replace amount ="210" if message=="nimetumya makaa yatuu teni"
replace amount ="210" if message=="Mia bili na kumi tooCall me now."

* 215
replace amount = "215" if message=="Qwanini mlinidanganya mtanitumia shilingi 215, tena hua nawajibu sms zenyu lakini amunitumii  credo." 

* 220
foreach phrase in "mia mbili ishirini"  {
	replace amount = "220" if amount == "`phrase'" 
}

* 240
foreach phrase in "mia mbili arobaini" "24o" "mia 240" ///
	"mia mbili arobaini 240" "two fouth" "twp fourfh" ///
	"two fourth" {
	replace amount = "240" if amount == "`phrase'" 
}
replace amount = "240" if message=="80bobkilasiku"
replace amount = "240" if message=="Nimeweza kutumia shiling mia mbili na arobaini(80 kwa siku)"
replace amount = "240" if message=="Kwa siku tatu zilizo pita nime tumiaa makaa za pesa mia pilâˆšÂ¨ arubaine"
replace amount = "240" if message=="Kwasikutatumkebemojani80kwaivopesani240" 
replace amount = "240" if message=="Nime.   Tumi.   240"


* 250
foreach phrase in "25o" "two hundred and fifty" ///
	"mia mbili hamsi" "two fivety" ///
	"mia mbili hamsini" "mia mbili hamsini 250" "25ty" ///
	"mbili na hamsini" "mbili nahamsini" "mbili hamsini" ///
	"mia mbili hamuni" {
	replace amount = "250" if amount == "`phrase'" 
}
replace amount = "250" if message=="Makaa ya 50 natumia Mara tano" 

* 260
foreach phrase in "two sixty"  {
	replace amount = "260" if amount == "`phrase'" 
}

* 270
foreach phrase in "mia mbili sabini" "mia mbili na sabini" ///
	"ni 270" "27o" "mia mbili sabini 270" "mia mbili seventy 270" ///
	"mia mbili seventy" {
	replace amount = "270" if amount == "`phrase'" 
}
replace amount = "270" if message=="Asubuhi 30 lunch 30 jioni 30"
replace amount = "270" if message=="3âˆšÃ³90=270makaa"
replace amount = "270" if message=="Kawaida yangu me hutumia mikebe tatu(270)kila baada ya siku tatu"
replace amount = "270" if message=="3â—Š90=270makaa"
replace amount = "270" if message=="3Ã—90=270makaa"
replace amount = "270" if message=="3×90=270makaa"
replace amount = "270" if message=="KWA SIKU.90"


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
	"mia tatu kila mia" mia300 "mia tat" "miya 300" {
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
	"Nlituma pesa on monday date 3 100sh na ikarudisha sms nimetuma busara center pls angalia." ///
	"SIKU SITA 600" "MIYA 300" ///
	"kwa siku tatu zimepita nimetumia mia tatu kununua makaa siku moja ni mia moja" ///
	"Kea sita zilizopita nitumia makaa ya mia sita" {
	replace amount = "300" if message == "`msg'"
}



* 315
foreach phrase in "mia tatu kumi tano" "mia tatu kumi na tano" {
	replace amount = "315" if amount == "`phrase'" 
}
replace amount = "315" if message=="kwa zikitatu zilzo pita nilituya makas ya miatatu na ngiminatano"

* 320
foreach phrase in "32o" "mia tatu ishirini" {
	replace amount = "320" if amount == "`phrase'" 
}
replace amount = "320" if message=="Nimetumia sh 320. 2 days mia moja moja na siku ya tatu sh.120."
replace amount = "320" if message=="samahani sio miambili ishirini ila miatatu ishirini .samahani"


* 350
foreach phrase in "mia tatu hamsini" ///
	"three fivety" "three hundred and fivety" "mia tau" ///
	"mia 3na50" {
	replace amount = "350" if amount == "`phrase'" 
}

* 360
foreach phrase in "mia tatu sitini" "mia tatu sitin" {
	replace amount = "360" if amount == "`phrase'" 
}

* 380
foreach phrase in "mia 380" "mia themanini" {
	replace amount = "380" if amount == "`phrase'" 
}

* 400
foreach phrase in "4oo" "four hundred" "mia nne" "mia 400" ///
	"mianne 400" "miann" {
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
	"mia nne hamsini" "mia nne hamsini 450" {
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
foreach phrase in "mia tisa" "mia tisa 900" {
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
drop if message=="123456789"
replace amount = 240 if message=="Nimetumia ksh2401" 
replace amount = 300 if respondent_id == "03dc4f2" & SMS_date==mdy(05,15,2019)
replace amount = 350 if respondent_id == "2f8zz9a" & SMS_date==mdy(05,31,2019)
replace amount = 210 if respondent_id == "7686040" & SMS_date==mdy(06,04,2019)
replace amount = 150 if respondent_id == "224fzaf" & SMS_date==mdy(05,31,2019)
replace amount = 240 if respondent_id == "669ab0a" & SMS_date==mdy(05,13,2019)
replace amount = 240 if respondent_id == "669ab0a" & SMS_date==mdy(05,24,2019)
replace amount = 800 if respondent_id == "1c561d5" & SMS_date==mdy(06,09,2019)
replace amount = 140 if respondent_id == "4f50d0f" & SMS_date==mdy(05,15,2019)
replace amount = 100 if respondent_id == "66bcf38" & SMS_date==mdy(05,29,2019)
replace amount = 120 if respondent_id == "7109287" & SMS_date==mdy(06,09,2019)
replace amount = 600 if respondent_id == "745f7f0" & SMS_date==mdy(05,02,2019)
replace amount = 210 if respondent_id == "91ff2zc" & SMS_date==mdy(06,05,2019)
replace amount = 140 if respondent_id == "97zf229" & SMS_date==mdy(06,16,2019)
replace amount = 300 if respondent_id == "d9f3a22" & SMS_date==mdy(05,18,2019)
replace amount = 300 if respondent_id == "dczaddd" & SMS_date==mdy(05,17,2019)
replace amount = 200 if respondent_id == "z8a2416" & SMS_date==mdy(06,02,2019)
replace amount = 150 if respondent_id == "zf948c5" & SMS_date==mdy(06,05,2019)
replace amount = 420 if respondent_id == "2zacz17" & SMS_date==mdy(05,16,2019)

drop if respondent_id=="3d51z07" & SMS_date==mdy(05,03,2019) & amount == 30
drop if respondent_id=="868696b" & SMS_date==mdy(06,14,2019) & amount == 34

* Looking at this respondent's payment pattern, it's clear these were typos (e.g. 140 140 140 14 140 140 140)
replace amount = 140 if respondent_id == "254798f" & amount==14
replace amount = 240 if respondent_id == "698aa32" & amount==24
replace amount = 240 if respondent_id == "827492d" & amount==249
replace amount = 150 if respondent_id == "84fb54f" & amount==159
replace amount = 300 if respondent_id == "95d605z" & amount==3
replace amount = 420 if respondent_id == "9af266f" & amount==428
replace amount = 210 if respondent_id == "a324b24" & amount==219

replace amount = 300 if respondent_id == "b1fa772" & amount==3
replace amount = 100 if respondent_id == "b1fa772" & amount==1
replace amount = 300 if respondent_id == "b1fzdbc" & amount==3
replace amount = 300 if respondent_id == "c27aa83" & amount==3
replace amount = 100 if respondent_id == "c362z6d" & amount==1
replace amount = 300 if respondent_id == "c56f52d" & amount==3
replace amount = 300 if respondent_id == "c9b1z40" & amount==3
drop if amount==23 & respondent_id=="d25514a"
replace amount = 300 if respondent_id == "d88066z" & amount==3
replace amount = 400 if respondent_id == "f017cc6" & amount==4
replace amount = 70 if respondent_id == "z545cb2" & amount==7

sort respondent_id SMS_date
list respondent_id amount message if mod(amount,5)!=0 & mod(amount,10)!=0


sort treata respondent_id SMS_date
list respondent_id SMS_date amount message if respondent_id=="84fb54f"
list respondent_id SMS_date amount message if amount>1000
list respondent_id baseline_date midline_date SMS_date treata preV2 amount message if amount>0 & amount<10
list respondent_id baseline_date midline_date SMS_date treata preV2 amount message if amount>10 & amount<30

* Assuming amounts between 1-9 are typo's
drop if amount > 0 & amount <10

sort respondent_id SMS_date

* Address people who usually spend 100s 
replace amount = 500 if respondent_id=="0485bb7" & amount==50
replace amount = 600 if respondent_id=="6a0zd12" & amount==60

* Outliers: 
replace amount = 200 if respondent_id=="306b3z6" & amount==200200
replace amount = 210 if respondent_id=="27fzfd2" & amount==210210
cap drop mean
by respondent_id : egen mean = mean(amount)
list respondent_id SMS_date amount message if mean>1000 
drop if amount > 1000000

* Typos: 
cap drop weird
cap drop any_weird
g weird = (amount>0 & amount<100)
by respondent_id : egen any_weird = max(weird)
replace amount = 80 if respondent_id=="b16bf75" & message=="W80"
replace amount = 350 if respondent_id=="b7bzd4a" & amount==35

list respondent_id SMS_date amount message if any_weird==1 & mean>200

drop weird any_weird mean 

/*** Check for duplicates among people who sent many SMSes in a given point in time*/
gen SMS_month = month(SMS_date)
gen SMS_day = day(SMS_date)


 /*Clean typos */
 
drop if respondent_id == "db20zb5" & SMS_month == 6 & SMS_day == 14 & amount == 0 

drop if respondent_id == "a3zdd5b" & SMS_month == 5 & SMS_day == 9 & amount == 240

drop if respondent_id == "819b028" & SMS_month == 6 & SMS_day == 21 & amount == 2010

drop if respondent_id == "b16bf75" & SMS_month == 7 & SMS_day == 18 & amount == 80

/*Clean other cases of duplicates in a given minute */
drop if respondent_id == "45c8b87" & SMS_month == 6 & SMS_day == 16 & amount == 0 

drop if respondent_id == "67a3fb8" & SMS_month == 5 & SMS_day == 23 & amount == 300

drop if respondent_id == "1ba5292" & SMS_month == 5 & SMS_day == 29 & amount == 1200

drop if respondent_id == "2zf1347" & SMS_month == 6 & SMS_day == 21 & amount == 600

drop if respondent_id == "084zz46" & SMS_month == 7 & SMS_day == 29 & amount == 320

drop if respondent_id == "06c20db" & SMS_month == 6 & SMS_day == 21 & amount == 360

drop if respondent_id == "5bz3854" & SMS_month == 6 & SMS_day == 5 & amount == 280

drop if respondent_id == "7bzcb24" & SMS_month == 6 & SMS_day == 25 & amount == 400

drop SMS_month SMS_day


* Among people that sent multiple texts in one day, save only the most recent one
sort respondent_id SMS_date SMS_hour SMS_min amount
by respondent_id SMS_date: keep if (_N == _n) // Keep the last SMS by household-day

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

save "`datamed'/SMS_clean_sms_raw_replication.dta", replace


******************* EXPORT DATA **********************
include "${main}/Do/0. Master.do"
use "`datamed'/SMS_clean_sms_raw_replication.dta", clear

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
include "${main}/Do/0. Master.do"
save "`dataclean'/SMS_clean_sms_replication.dta", replace


* Export clean SMS data - respondent level 
g amount_weekly_pre  = amount_weekly if (SMS_date-baseline_date <30) | (SMS_date <  midline_date+2)
g amount_weekly_post = amount_weekly if (SMS_date-baseline_date>=30) & (SMS_date >= midline_date+2)

collapse (mean) amount_weekly_pre amount_weekly_post, by(respondent_id obs)
	
rename amount_weekly_pre sms_amount_weekly_pre
rename amount_weekly_post sms_amount_weekly_post
rename obs sms_obs
lab var sms_amount_weekly_pre	"Charcoal consumption pre-adoption (Ksh/week - SMS)"
lab var sms_amount_weekly_post	"Charcoal consumption post-adoption (Ksh/week - SMS)"
lab var sms_obs 				"Number of SMSes from respondent "

save "`dataclean'/SMS_clean_resp_replication.dta", replace




