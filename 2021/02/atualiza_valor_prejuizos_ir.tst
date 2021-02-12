PL/SQL Developer Test script 3.0
882
-- Created on 13/01/2021 by T0032717 
DECLARE
  
  CURSOR cr_principal IS
    SELECT e.cdcooper, e.nrdconta, e.nrctremp, e.inprejuz, e.vlsdprej, e.vlttmupr, e.vlpgmupr, e.vlttjmpr, e.vlpgjmpr, e.vltiofpr, e.vlpiofpr, e.dtprejuz
      FROM crapepr e
     WHERE e.inprejuz = 1
       AND e.tpemprst = 1
       AND e.dtprejuz >= '01/01/2016'
       AND e.dtprejuz <= '31/12/2020'
       AND e.vlsdprej > 0
	   AND ((e.cdcooper = 1	AND e.nrdconta = 2151	AND e.nrctremp = 1543112) OR (e.cdcooper = 1	AND e.nrdconta = 2917	AND e.nrctremp = 1064814) OR
(e.cdcooper = 1	AND e.nrdconta = 3255	AND e.nrctremp = 1293002) OR (e.cdcooper = 1	AND e.nrdconta = 4014	AND e.nrctremp = 1397244) OR
(e.cdcooper = 1	AND e.nrdconta = 4898	AND e.nrctremp = 898865) OR (e.cdcooper = 1	AND e.nrdconta = 5231	AND e.nrctremp = 495397) OR
(e.cdcooper = 1	AND e.nrdconta = 5410	AND e.nrctremp = 5410) OR (e.cdcooper = 1	AND e.nrdconta = 6793	AND e.nrctremp = 974642) OR
(e.cdcooper = 1	AND e.nrdconta = 8311	AND e.nrctremp = 621067) OR (e.cdcooper = 1	AND e.nrdconta = 9024	AND e.nrctremp = 497518) OR
(e.cdcooper = 1	AND e.nrdconta = 9105	AND e.nrctremp = 1145711) OR (e.cdcooper = 1	AND e.nrdconta = 9334	AND e.nrctremp = 743054) OR
(e.cdcooper = 1	AND e.nrdconta = 9644	AND e.nrctremp = 1438131) OR (e.cdcooper = 1	AND e.nrdconta = 9644	AND e.nrctremp = 1599852) OR
(e.cdcooper = 1	AND e.nrdconta = 9911	AND e.nrctremp = 1112259) OR (e.cdcooper = 1	AND e.nrdconta = 10383	AND e.nrctremp = 896514) OR
(e.cdcooper = 1	AND e.nrdconta = 10677	AND e.nrctremp = 821670) OR (e.cdcooper = 1	AND e.nrdconta = 11266	AND e.nrctremp = 708097) OR
(e.cdcooper = 1	AND e.nrdconta = 11568	AND e.nrctremp = 670033) OR (e.cdcooper = 1	AND e.nrdconta = 11592	AND e.nrctremp = 1118718) OR
(e.cdcooper = 1	AND e.nrdconta = 11932	AND e.nrctremp = 716567) OR (e.cdcooper = 1	AND e.nrdconta = 12017	AND e.nrctremp = 792941) OR
(e.cdcooper = 1	AND e.nrdconta = 12750	AND e.nrctremp = 705090) OR (e.cdcooper = 1	AND e.nrdconta = 12858	AND e.nrctremp = 1278575) OR
(e.cdcooper = 1	AND e.nrdconta = 15326	AND e.nrctremp = 634563) OR (e.cdcooper = 1	AND e.nrdconta = 15822	AND e.nrctremp = 15822) OR
(e.cdcooper = 1	AND e.nrdconta = 16756	AND e.nrctremp = 16756) OR (e.cdcooper = 1	AND e.nrdconta = 16837	AND e.nrctremp = 839837) OR
(e.cdcooper = 1	AND e.nrdconta = 16853	AND e.nrctremp = 498663) OR (e.cdcooper = 1	AND e.nrdconta = 17515	AND e.nrctremp = 1619147) OR
(e.cdcooper = 1	AND e.nrdconta = 17809	AND e.nrctremp = 17809) OR (e.cdcooper = 1	AND e.nrdconta = 18961	AND e.nrctremp = 1665189) OR
(e.cdcooper = 1	AND e.nrdconta = 19356	AND e.nrctremp = 805798) OR (e.cdcooper = 1	AND e.nrdconta = 19917	AND e.nrctremp = 967074) OR
(e.cdcooper = 1	AND e.nrdconta = 21857	AND e.nrctremp = 993550) OR (e.cdcooper = 1	AND e.nrdconta = 22586	AND e.nrctremp = 691069) OR
(e.cdcooper = 1	AND e.nrdconta = 22918	AND e.nrctremp = 22918) OR (e.cdcooper = 1	AND e.nrdconta = 22934	AND e.nrctremp = 762762) OR
(e.cdcooper = 1	AND e.nrdconta = 22993	AND e.nrctremp = 22993) OR (e.cdcooper = 1	AND e.nrdconta = 23523	AND e.nrctremp = 23523) OR
(e.cdcooper = 1	AND e.nrdconta = 23787	AND e.nrctremp = 982100) OR (e.cdcooper = 1	AND e.nrdconta = 23876	AND e.nrctremp = 23876) OR
(e.cdcooper = 1	AND e.nrdconta = 24287	AND e.nrctremp = 824204) OR (e.cdcooper = 1	AND e.nrdconta = 24422	AND e.nrctremp = 1921674) OR
(e.cdcooper = 1	AND e.nrdconta = 24511	AND e.nrctremp = 1214602) OR (e.cdcooper = 1	AND e.nrdconta = 24813	AND e.nrctremp = 1325723) OR
(e.cdcooper = 1	AND e.nrdconta = 24970	AND e.nrctremp = 1186963) OR (e.cdcooper = 1	AND e.nrdconta = 25801	AND e.nrctremp = 1135083) OR
(e.cdcooper = 1	AND e.nrdconta = 26859	AND e.nrctremp = 657329) OR (e.cdcooper = 1	AND e.nrdconta = 27251	AND e.nrctremp = 1131549) OR
(e.cdcooper = 1	AND e.nrdconta = 28177	AND e.nrctremp = 715895) OR (e.cdcooper = 1	AND e.nrdconta = 29220	AND e.nrctremp = 709635) OR
(e.cdcooper = 1	AND e.nrdconta = 267511	AND e.nrctremp = 1289999) OR (e.cdcooper = 1	AND e.nrdconta = 387355	AND e.nrctremp = 11607) OR
(e.cdcooper = 1	AND e.nrdconta = 387355	AND e.nrctremp = 147601) OR (e.cdcooper = 1	AND e.nrdconta = 387355	AND e.nrctremp = 350093) OR
(e.cdcooper = 1	AND e.nrdconta = 387355	AND e.nrctremp = 814840) OR (e.cdcooper = 1	AND e.nrdconta = 566608	AND e.nrctremp = 1270358) OR
(e.cdcooper = 1	AND e.nrdconta = 595780	AND e.nrctremp = 812574) OR (e.cdcooper = 1	AND e.nrdconta = 596698	AND e.nrctremp = 628228) OR
(e.cdcooper = 1	AND e.nrdconta = 616885	AND e.nrctremp = 616885) OR (e.cdcooper = 1	AND e.nrdconta = 643513	AND e.nrctremp = 1016561) OR
(e.cdcooper = 1	AND e.nrdconta = 644110	AND e.nrctremp = 747686) OR (e.cdcooper = 1	AND e.nrdconta = 644587	AND e.nrctremp = 512492) OR
(e.cdcooper = 1	AND e.nrdconta = 645079	AND e.nrctremp = 1052375) OR (e.cdcooper = 1	AND e.nrdconta = 741221	AND e.nrctremp = 726242) OR
(e.cdcooper = 1	AND e.nrdconta = 748927	AND e.nrctremp = 104574) OR (e.cdcooper = 1	AND e.nrdconta = 749389	AND e.nrctremp = 1599898) OR
(e.cdcooper = 1	AND e.nrdconta = 754668	AND e.nrctremp = 696643) OR (e.cdcooper = 1	AND e.nrdconta = 755958	AND e.nrctremp = 755958) OR
(e.cdcooper = 1	AND e.nrdconta = 757799	AND e.nrctremp = 757799) OR (e.cdcooper = 1	AND e.nrdconta = 757837	AND e.nrctremp = 708580) OR
(e.cdcooper = 1	AND e.nrdconta = 760056	AND e.nrctremp = 1204933) OR (e.cdcooper = 1	AND e.nrdconta = 761583	AND e.nrctremp = 881073) OR
(e.cdcooper = 1	AND e.nrdconta = 765775	AND e.nrctremp = 1110171) OR (e.cdcooper = 1	AND e.nrdconta = 768570	AND e.nrctremp = 1268999) OR
(e.cdcooper = 1	AND e.nrdconta = 773670	AND e.nrctremp = 98205) OR (e.cdcooper = 1	AND e.nrdconta = 776033	AND e.nrctremp = 1138300) OR
(e.cdcooper = 1	AND e.nrdconta = 790800	AND e.nrctremp = 1076618) OR (e.cdcooper = 1	AND e.nrdconta = 795020	AND e.nrctremp = 190610) OR
(e.cdcooper = 1	AND e.nrdconta = 795410	AND e.nrctremp = 1545945) OR (e.cdcooper = 1	AND e.nrdconta = 820598	AND e.nrctremp = 369342) OR
(e.cdcooper = 1	AND e.nrdconta = 827053	AND e.nrctremp = 945946) OR (e.cdcooper = 1	AND e.nrdconta = 831719	AND e.nrctremp = 933386) OR
(e.cdcooper = 1	AND e.nrdconta = 838250	AND e.nrctremp = 1374683) OR (e.cdcooper = 1	AND e.nrdconta = 838250	AND e.nrctremp = 1921065) OR
(e.cdcooper = 1	AND e.nrdconta = 840297	AND e.nrctremp = 512423) OR (e.cdcooper = 1	AND e.nrdconta = 841943	AND e.nrctremp = 342688) OR
(e.cdcooper = 1	AND e.nrdconta = 842613	AND e.nrctremp = 245703) OR (e.cdcooper = 1	AND e.nrdconta = 842613	AND e.nrctremp = 426842) OR
(e.cdcooper = 1	AND e.nrdconta = 843733	AND e.nrctremp = 816483) OR (e.cdcooper = 1	AND e.nrdconta = 843733	AND e.nrctremp = 816487) OR
(e.cdcooper = 1	AND e.nrdconta = 843733	AND e.nrctremp = 1155518) OR (e.cdcooper = 1	AND e.nrdconta = 857025	AND e.nrctremp = 500511) OR
(e.cdcooper = 1	AND e.nrdconta = 859664	AND e.nrctremp = 722569) OR (e.cdcooper = 1	AND e.nrdconta = 865834	AND e.nrctremp = 768548) OR
(e.cdcooper = 1	AND e.nrdconta = 866458	AND e.nrctremp = 664156) OR (e.cdcooper = 1	AND e.nrdconta = 876844	AND e.nrctremp = 170513) OR
(e.cdcooper = 1	AND e.nrdconta = 876844	AND e.nrctremp = 439027) OR (e.cdcooper = 1	AND e.nrdconta = 877190	AND e.nrctremp = 1517565) OR
(e.cdcooper = 1	AND e.nrdconta = 878685	AND e.nrctremp = 827971) OR (e.cdcooper = 1	AND e.nrdconta = 879690	AND e.nrctremp = 427321) OR
(e.cdcooper = 1	AND e.nrdconta = 888028	AND e.nrctremp = 392227) OR (e.cdcooper = 1	AND e.nrdconta = 897132	AND e.nrctremp = 758104) OR
(e.cdcooper = 1	AND e.nrdconta = 912620	AND e.nrctremp = 749235) OR (e.cdcooper = 1	AND e.nrdconta = 912751	AND e.nrctremp = 353280) OR
(e.cdcooper = 1	AND e.nrdconta = 921793	AND e.nrctremp = 364438) OR (e.cdcooper = 1	AND e.nrdconta = 925594	AND e.nrctremp = 636891) OR
(e.cdcooper = 1	AND e.nrdconta = 928305	AND e.nrctremp = 455869) OR (e.cdcooper = 1	AND e.nrdconta = 932418	AND e.nrctremp = 932418) OR
(e.cdcooper = 1	AND e.nrdconta = 941034	AND e.nrctremp = 818707) OR (e.cdcooper = 1	AND e.nrdconta = 949124	AND e.nrctremp = 581117) OR
(e.cdcooper = 1	AND e.nrdconta = 970506	AND e.nrctremp = 101435) OR (e.cdcooper = 1	AND e.nrdconta = 972304	AND e.nrctremp = 651584) OR
(e.cdcooper = 1	AND e.nrdconta = 972703	AND e.nrctremp = 1345993) OR (e.cdcooper = 1	AND e.nrdconta = 973661	AND e.nrctremp = 807311) OR
(e.cdcooper = 1	AND e.nrdconta = 974722	AND e.nrctremp = 838620) OR (e.cdcooper = 1	AND e.nrdconta = 974927	AND e.nrctremp = 974927) OR
(e.cdcooper = 1	AND e.nrdconta = 976113	AND e.nrctremp = 196214) OR (e.cdcooper = 1	AND e.nrdconta = 978191	AND e.nrctremp = 76734) OR
(e.cdcooper = 1	AND e.nrdconta = 979040	AND e.nrctremp = 628927) OR (e.cdcooper = 1	AND e.nrdconta = 983926	AND e.nrctremp = 1027941) OR
(e.cdcooper = 1	AND e.nrdconta = 1199854	AND e.nrctremp = 402871) OR (e.cdcooper = 1	AND e.nrdconta = 1253794	AND e.nrctremp = 567523) OR
(e.cdcooper = 1	AND e.nrdconta = 1254421	AND e.nrctremp = 784673) OR (e.cdcooper = 1	AND e.nrdconta = 1291297	AND e.nrctremp = 707067) OR
(e.cdcooper = 1	AND e.nrdconta = 1292030	AND e.nrctremp = 426272) OR (e.cdcooper = 1	AND e.nrdconta = 1386603	AND e.nrctremp = 1070949) OR
(e.cdcooper = 1	AND e.nrdconta = 1388789	AND e.nrctremp = 26528) OR (e.cdcooper = 1	AND e.nrdconta = 1397958	AND e.nrctremp = 21458) OR
(e.cdcooper = 1	AND e.nrdconta = 1500775	AND e.nrctremp = 446697) OR (e.cdcooper = 1	AND e.nrdconta = 1503707	AND e.nrctremp = 304046) OR
(e.cdcooper = 1	AND e.nrdconta = 1508512	AND e.nrctremp = 1401770) OR (e.cdcooper = 1	AND e.nrdconta = 1516230	AND e.nrctremp = 319177) OR
(e.cdcooper = 1	AND e.nrdconta = 1518321	AND e.nrctremp = 1518321) OR (e.cdcooper = 1	AND e.nrdconta = 1520741	AND e.nrctremp = 660339) OR
(e.cdcooper = 1	AND e.nrdconta = 1527720	AND e.nrctremp = 1218906) OR (e.cdcooper = 1	AND e.nrdconta = 1562568	AND e.nrctremp = 501844) OR
(e.cdcooper = 1	AND e.nrdconta = 1563190	AND e.nrctremp = 170332) OR (e.cdcooper = 1	AND e.nrdconta = 1709003	AND e.nrctremp = 479549) OR
(e.cdcooper = 1	AND e.nrdconta = 1710419	AND e.nrctremp = 121234) OR (e.cdcooper = 1	AND e.nrdconta = 1713132	AND e.nrctremp = 133379) OR
(e.cdcooper = 1	AND e.nrdconta = 1714120	AND e.nrctremp = 1380019) OR (e.cdcooper = 1	AND e.nrdconta = 1716336	AND e.nrctremp = 1409321) OR
(e.cdcooper = 1	AND e.nrdconta = 1717090	AND e.nrctremp = 544735) OR (e.cdcooper = 1	AND e.nrdconta = 1822314	AND e.nrctremp = 334730) OR
(e.cdcooper = 1	AND e.nrdconta = 1825453	AND e.nrctremp = 294798) OR (e.cdcooper = 1	AND e.nrdconta = 1826220	AND e.nrctremp = 1826220) OR
(e.cdcooper = 1	AND e.nrdconta = 1832751	AND e.nrctremp = 1832751) OR (e.cdcooper = 1	AND e.nrdconta = 1834681	AND e.nrctremp = 309741) OR
(e.cdcooper = 1	AND e.nrdconta = 1834681	AND e.nrctremp = 312223) OR (e.cdcooper = 1	AND e.nrdconta = 1834681	AND e.nrctremp = 1834681) OR
(e.cdcooper = 1	AND e.nrdconta = 1838270	AND e.nrctremp = 1164325) OR (e.cdcooper = 1	AND e.nrdconta = 1839683	AND e.nrctremp = 448349) OR
(e.cdcooper = 1	AND e.nrdconta = 1842447	AND e.nrctremp = 535595) OR (e.cdcooper = 1	AND e.nrdconta = 1846183	AND e.nrctremp = 71988) OR
(e.cdcooper = 1	AND e.nrdconta = 1846906	AND e.nrctremp = 83126) OR (e.cdcooper = 1	AND e.nrdconta = 1850784	AND e.nrctremp = 767452) OR
(e.cdcooper = 1	AND e.nrdconta = 1856910	AND e.nrctremp = 363948) OR (e.cdcooper = 1	AND e.nrdconta = 1858319	AND e.nrctremp = 723381) OR
(e.cdcooper = 1	AND e.nrdconta = 1877780	AND e.nrctremp = 1877780) OR (e.cdcooper = 1	AND e.nrdconta = 1880276	AND e.nrctremp = 486779) OR
(e.cdcooper = 1	AND e.nrdconta = 1889150	AND e.nrctremp = 963084) OR (e.cdcooper = 1	AND e.nrdconta = 1889150	AND e.nrctremp = 1082886) OR
(e.cdcooper = 1	AND e.nrdconta = 1893068	AND e.nrctremp = 105289) OR (e.cdcooper = 1	AND e.nrdconta = 1894218	AND e.nrctremp = 495735) OR
(e.cdcooper = 1	AND e.nrdconta = 1904655	AND e.nrctremp = 2194871) OR (e.cdcooper = 1	AND e.nrdconta = 1906569	AND e.nrctremp = 769065) OR
(e.cdcooper = 1	AND e.nrdconta = 1907263	AND e.nrctremp = 290812) OR (e.cdcooper = 1	AND e.nrdconta = 1907263	AND e.nrctremp = 740135) OR
(e.cdcooper = 1	AND e.nrdconta = 1910639	AND e.nrctremp = 996871) OR (e.cdcooper = 1	AND e.nrdconta = 1910701	AND e.nrctremp = 185554) OR
(e.cdcooper = 1	AND e.nrdconta = 1915258	AND e.nrctremp = 988725) OR (e.cdcooper = 1	AND e.nrdconta = 1916491	AND e.nrctremp = 1166713) OR
(e.cdcooper = 1	AND e.nrdconta = 1920480	AND e.nrctremp = 881283) OR (e.cdcooper = 1	AND e.nrdconta = 1923153	AND e.nrctremp = 175749) OR
(e.cdcooper = 1	AND e.nrdconta = 1923366	AND e.nrctremp = 910911) OR (e.cdcooper = 1	AND e.nrdconta = 1926594	AND e.nrctremp = 121121) OR
(e.cdcooper = 1	AND e.nrdconta = 1929631	AND e.nrctremp = 14419) OR (e.cdcooper = 1	AND e.nrdconta = 1931288	AND e.nrctremp = 611983) OR
(e.cdcooper = 1	AND e.nrdconta = 1935356	AND e.nrctremp = 621811) OR (e.cdcooper = 1	AND e.nrdconta = 1939432	AND e.nrctremp = 1017422) OR
(e.cdcooper = 1	AND e.nrdconta = 1944258	AND e.nrctremp = 649788) OR (e.cdcooper = 1	AND e.nrdconta = 1948237	AND e.nrctremp = 1244395) OR
(e.cdcooper = 1	AND e.nrdconta = 1949870	AND e.nrctremp = 297787) OR (e.cdcooper = 1	AND e.nrdconta = 1952080	AND e.nrctremp = 11344) OR
(e.cdcooper = 1	AND e.nrdconta = 1960164	AND e.nrctremp = 667814) OR (e.cdcooper = 1	AND e.nrdconta = 1961780	AND e.nrctremp = 373749) OR
(e.cdcooper = 1	AND e.nrdconta = 1961900	AND e.nrctremp = 805511) OR (e.cdcooper = 1	AND e.nrdconta = 1963171	AND e.nrctremp = 867863) OR
(e.cdcooper = 1	AND e.nrdconta = 1976028	AND e.nrctremp = 356651) OR (e.cdcooper = 1	AND e.nrdconta = 1977458	AND e.nrctremp = 1117675) OR
(e.cdcooper = 1	AND e.nrdconta = 1979345	AND e.nrctremp = 695908) OR (e.cdcooper = 1	AND e.nrdconta = 1986384	AND e.nrctremp = 1986384) OR
(e.cdcooper = 1	AND e.nrdconta = 1986520	AND e.nrctremp = 11240) OR (e.cdcooper = 1	AND e.nrdconta = 1987453	AND e.nrctremp = 111042) OR
(e.cdcooper = 1	AND e.nrdconta = 1995413	AND e.nrctremp = 994869) OR (e.cdcooper = 1	AND e.nrdconta = 1997394	AND e.nrctremp = 462046) OR
(e.cdcooper = 1	AND e.nrdconta = 2005654	AND e.nrctremp = 1107051) OR (e.cdcooper = 1	AND e.nrdconta = 2007541	AND e.nrctremp = 2007541) OR
(e.cdcooper = 1	AND e.nrdconta = 2009250	AND e.nrctremp = 1413116) OR (e.cdcooper = 1	AND e.nrdconta = 2010585	AND e.nrctremp = 341428) OR
(e.cdcooper = 1	AND e.nrdconta = 2010585	AND e.nrctremp = 503293) OR (e.cdcooper = 1	AND e.nrdconta = 2012278	AND e.nrctremp = 27735) OR
(e.cdcooper = 1	AND e.nrdconta = 2016591	AND e.nrctremp = 1096784) OR (e.cdcooper = 1	AND e.nrdconta = 2019574	AND e.nrctremp = 1992548) OR
(e.cdcooper = 1	AND e.nrdconta = 2021226	AND e.nrctremp = 1614837) OR (e.cdcooper = 1	AND e.nrdconta = 2031540	AND e.nrctremp = 681272) OR
(e.cdcooper = 1	AND e.nrdconta = 2032414	AND e.nrctremp = 2032414) OR (e.cdcooper = 1	AND e.nrdconta = 2034018	AND e.nrctremp = 2034018) OR
(e.cdcooper = 1	AND e.nrdconta = 2034450	AND e.nrctremp = 2325828) OR (e.cdcooper = 1	AND e.nrdconta = 2034999	AND e.nrctremp = 770067) OR
(e.cdcooper = 1	AND e.nrdconta = 2039095	AND e.nrctremp = 2039095) OR (e.cdcooper = 1	AND e.nrdconta = 2039141	AND e.nrctremp = 482969) OR
(e.cdcooper = 1	AND e.nrdconta = 2043432	AND e.nrctremp = 2043432) OR (e.cdcooper = 1	AND e.nrdconta = 2046970	AND e.nrctremp = 1009128) OR
(e.cdcooper = 1	AND e.nrdconta = 2046970	AND e.nrctremp = 1019083) OR (e.cdcooper = 1	AND e.nrdconta = 2050765	AND e.nrctremp = 296020) OR
(e.cdcooper = 1	AND e.nrdconta = 2051931	AND e.nrctremp = 2051931) OR (e.cdcooper = 1	AND e.nrdconta = 2056992	AND e.nrctremp = 119292) OR
(e.cdcooper = 1	AND e.nrdconta = 2061406	AND e.nrctremp = 659195) OR (e.cdcooper = 1	AND e.nrdconta = 2061830	AND e.nrctremp = 2061830) OR
(e.cdcooper = 1	AND e.nrdconta = 2062062	AND e.nrctremp = 1001501) OR (e.cdcooper = 1	AND e.nrdconta = 2064383	AND e.nrctremp = 412058) OR
(e.cdcooper = 1	AND e.nrdconta = 2064855	AND e.nrctremp = 89893) OR (e.cdcooper = 1	AND e.nrdconta = 2065061	AND e.nrctremp = 776359) OR
(e.cdcooper = 1	AND e.nrdconta = 2068621	AND e.nrctremp = 774512) OR (e.cdcooper = 1	AND e.nrdconta = 2069610	AND e.nrctremp = 1277592) OR
(e.cdcooper = 1	AND e.nrdconta = 2069644	AND e.nrctremp = 349172) OR (e.cdcooper = 1	AND e.nrdconta = 2072580	AND e.nrctremp = 701300) OR
(e.cdcooper = 1	AND e.nrdconta = 2074702	AND e.nrctremp = 1155529) OR (e.cdcooper = 1	AND e.nrdconta = 2076110	AND e.nrctremp = 2076110) OR
(e.cdcooper = 1	AND e.nrdconta = 2080761	AND e.nrctremp = 690011) OR (e.cdcooper = 1	AND e.nrdconta = 2083124	AND e.nrctremp = 11243) OR
(e.cdcooper = 1	AND e.nrdconta = 2083124	AND e.nrctremp = 198299) OR (e.cdcooper = 1	AND e.nrdconta = 2089114	AND e.nrctremp = 348913) OR
(e.cdcooper = 1	AND e.nrdconta = 2089360	AND e.nrctremp = 1853052) OR (e.cdcooper = 1	AND e.nrdconta = 2095378	AND e.nrctremp = 11022) OR
(e.cdcooper = 1	AND e.nrdconta = 2096285	AND e.nrctremp = 1134231) OR (e.cdcooper = 1	AND e.nrdconta = 2096315	AND e.nrctremp = 741071) OR
(e.cdcooper = 1	AND e.nrdconta = 2098784	AND e.nrctremp = 817934) OR (e.cdcooper = 1	AND e.nrdconta = 2098814	AND e.nrctremp = 380189) OR
(e.cdcooper = 1	AND e.nrdconta = 2099128	AND e.nrctremp = 204856) OR (e.cdcooper = 1	AND e.nrdconta = 2110261	AND e.nrctremp = 370918) OR
(e.cdcooper = 1	AND e.nrdconta = 2115514	AND e.nrctremp = 427113) OR (e.cdcooper = 1	AND e.nrdconta = 2115549	AND e.nrctremp = 648536) OR
(e.cdcooper = 1	AND e.nrdconta = 2118181	AND e.nrctremp = 116858) OR (e.cdcooper = 1	AND e.nrdconta = 2119110	AND e.nrctremp = 2119110) OR
(e.cdcooper = 1	AND e.nrdconta = 2120097	AND e.nrctremp = 989400) OR (e.cdcooper = 1	AND e.nrdconta = 2121794	AND e.nrctremp = 860720) OR
(e.cdcooper = 1	AND e.nrdconta = 2126575	AND e.nrctremp = 2126575) OR (e.cdcooper = 1	AND e.nrdconta = 2127350	AND e.nrctremp = 163732) OR
(e.cdcooper = 1	AND e.nrdconta = 2129000	AND e.nrctremp = 2129000) OR (e.cdcooper = 1	AND e.nrdconta = 2141779	AND e.nrctremp = 995453) OR
(e.cdcooper = 1	AND e.nrdconta = 2142210	AND e.nrctremp = 837266) OR (e.cdcooper = 1	AND e.nrdconta = 2143577	AND e.nrctremp = 921772) OR
(e.cdcooper = 1	AND e.nrdconta = 2143577	AND e.nrctremp = 1513412) OR (e.cdcooper = 1	AND e.nrdconta = 2145227	AND e.nrctremp = 1090578) OR
(e.cdcooper = 1	AND e.nrdconta = 2146010	AND e.nrctremp = 396109) OR (e.cdcooper = 1	AND e.nrdconta = 2146010	AND e.nrctremp = 821842) OR
(e.cdcooper = 1	AND e.nrdconta = 2146126	AND e.nrctremp = 684784) OR (e.cdcooper = 1	AND e.nrdconta = 2146126	AND e.nrctremp = 1362908) OR
(e.cdcooper = 1	AND e.nrdconta = 2147076	AND e.nrctremp = 360831) OR (e.cdcooper = 1	AND e.nrdconta = 2147750	AND e.nrctremp = 1060421) OR
(e.cdcooper = 1	AND e.nrdconta = 2151197	AND e.nrctremp = 2012611) OR (e.cdcooper = 1	AND e.nrdconta = 2153807	AND e.nrctremp = 166109) OR
(e.cdcooper = 1	AND e.nrdconta = 2154927	AND e.nrctremp = 669999) OR (e.cdcooper = 1	AND e.nrdconta = 2160560	AND e.nrctremp = 667305) OR
(e.cdcooper = 1	AND e.nrdconta = 2162210	AND e.nrctremp = 150110) OR (e.cdcooper = 1	AND e.nrdconta = 2163306	AND e.nrctremp = 1295242) OR
(e.cdcooper = 1	AND e.nrdconta = 2165368	AND e.nrctremp = 342670) OR (e.cdcooper = 1	AND e.nrdconta = 2165872	AND e.nrctremp = 741720) OR
(e.cdcooper = 1	AND e.nrdconta = 2169916	AND e.nrctremp = 685002) OR (e.cdcooper = 1	AND e.nrdconta = 2180162	AND e.nrctremp = 689123) OR
(e.cdcooper = 1	AND e.nrdconta = 2181533	AND e.nrctremp = 598980) OR (e.cdcooper = 1	AND e.nrdconta = 2186179	AND e.nrctremp = 921071) OR
(e.cdcooper = 1	AND e.nrdconta = 2187701	AND e.nrctremp = 1145218) OR (e.cdcooper = 1	AND e.nrdconta = 2188473	AND e.nrctremp = 2039893) OR
(e.cdcooper = 1	AND e.nrdconta = 2190397	AND e.nrctremp = 506574) OR (e.cdcooper = 1	AND e.nrdconta = 2190397	AND e.nrctremp = 2190397) OR
(e.cdcooper = 1	AND e.nrdconta = 2191598	AND e.nrctremp = 476819) OR (e.cdcooper = 1	AND e.nrdconta = 2191679	AND e.nrctremp = 408934) OR
(e.cdcooper = 1	AND e.nrdconta = 2192535	AND e.nrctremp = 639855) OR (e.cdcooper = 1	AND e.nrdconta = 2194490	AND e.nrctremp = 739733) OR
(e.cdcooper = 1	AND e.nrdconta = 2195062	AND e.nrctremp = 719571) OR (e.cdcooper = 1	AND e.nrdconta = 2195925	AND e.nrctremp = 647698) OR
(e.cdcooper = 1	AND e.nrdconta = 2198967	AND e.nrctremp = 442286) OR (e.cdcooper = 1	AND e.nrdconta = 2202026	AND e.nrctremp = 914959) OR
(e.cdcooper = 1	AND e.nrdconta = 2202093	AND e.nrctremp = 1170757) OR (e.cdcooper = 1	AND e.nrdconta = 2202620	AND e.nrctremp = 876285) OR
(e.cdcooper = 1	AND e.nrdconta = 2203669	AND e.nrctremp = 1059773) OR (e.cdcooper = 1	AND e.nrdconta = 2203782	AND e.nrctremp = 1150994) OR
(e.cdcooper = 1	AND e.nrdconta = 2203979	AND e.nrctremp = 1254648) OR (e.cdcooper = 1	AND e.nrdconta = 2209837	AND e.nrctremp = 1596284) OR
(e.cdcooper = 1	AND e.nrdconta = 2213141	AND e.nrctremp = 2213141) OR (e.cdcooper = 1	AND e.nrdconta = 2214911	AND e.nrctremp = 472927) OR
(e.cdcooper = 1	AND e.nrdconta = 2215268	AND e.nrctremp = 2215268) OR (e.cdcooper = 1	AND e.nrdconta = 2220890	AND e.nrctremp = 574759) OR
(e.cdcooper = 1	AND e.nrdconta = 2221721	AND e.nrctremp = 625914) OR (e.cdcooper = 1	AND e.nrdconta = 2222078	AND e.nrctremp = 1038878) OR
(e.cdcooper = 1	AND e.nrdconta = 2222205	AND e.nrctremp = 435206) OR (e.cdcooper = 1	AND e.nrdconta = 2222205	AND e.nrctremp = 435212) OR
(e.cdcooper = 1	AND e.nrdconta = 2225360	AND e.nrctremp = 2225360) OR (e.cdcooper = 1	AND e.nrdconta = 2227797	AND e.nrctremp = 1041831) OR
(e.cdcooper = 1	AND e.nrdconta = 2235951	AND e.nrctremp = 2235951) OR (e.cdcooper = 1	AND e.nrdconta = 2236680	AND e.nrctremp = 1654503) OR
(e.cdcooper = 1	AND e.nrdconta = 2238144	AND e.nrctremp = 585358) OR (e.cdcooper = 1	AND e.nrdconta = 2238365	AND e.nrctremp = 11431) OR
(e.cdcooper = 1	AND e.nrdconta = 2241412	AND e.nrctremp = 1587491) OR (e.cdcooper = 1	AND e.nrdconta = 2249120	AND e.nrctremp = 1378891) OR
(e.cdcooper = 1	AND e.nrdconta = 2253321	AND e.nrctremp = 410718) OR (e.cdcooper = 1	AND e.nrdconta = 2253321	AND e.nrctremp = 488933) OR
(e.cdcooper = 1	AND e.nrdconta = 2253321	AND e.nrctremp = 854732) OR (e.cdcooper = 1	AND e.nrdconta = 2253321	AND e.nrctremp = 854900) OR
(e.cdcooper = 1	AND e.nrdconta = 2253887	AND e.nrctremp = 2253887) OR (e.cdcooper = 1	AND e.nrdconta = 2256657	AND e.nrctremp = 767545) OR
(e.cdcooper = 1	AND e.nrdconta = 2257840	AND e.nrctremp = 176563) OR (e.cdcooper = 1	AND e.nrdconta = 2257874	AND e.nrctremp = 537789) OR
(e.cdcooper = 1	AND e.nrdconta = 2258323	AND e.nrctremp = 1089249) OR (e.cdcooper = 1	AND e.nrdconta = 2258854	AND e.nrctremp = 362079) OR
(e.cdcooper = 1	AND e.nrdconta = 2259800	AND e.nrctremp = 486851) OR (e.cdcooper = 1	AND e.nrdconta = 2260484	AND e.nrctremp = 30206) OR
(e.cdcooper = 1	AND e.nrdconta = 2262410	AND e.nrctremp = 897914) OR (e.cdcooper = 1	AND e.nrdconta = 2264188	AND e.nrctremp = 1949405) OR
(e.cdcooper = 1	AND e.nrdconta = 2268000	AND e.nrctremp = 2268000) OR (e.cdcooper = 1	AND e.nrdconta = 2268973	AND e.nrctremp = 508065) OR
(e.cdcooper = 1	AND e.nrdconta = 2271630	AND e.nrctremp = 1413869) OR (e.cdcooper = 1	AND e.nrdconta = 2271630	AND e.nrctremp = 1581609) OR
(e.cdcooper = 1	AND e.nrdconta = 2272474	AND e.nrctremp = 1630089) OR (e.cdcooper = 1	AND e.nrdconta = 2273705	AND e.nrctremp = 120032) OR
(e.cdcooper = 1	AND e.nrdconta = 2276003	AND e.nrctremp = 137135) OR (e.cdcooper = 1	AND e.nrdconta = 2276003	AND e.nrctremp = 556339) OR
(e.cdcooper = 1	AND e.nrdconta = 2276003	AND e.nrctremp = 556344) OR (e.cdcooper = 1	AND e.nrdconta = 2276003	AND e.nrctremp = 556347) OR
(e.cdcooper = 1	AND e.nrdconta = 2276003	AND e.nrctremp = 556353) OR (e.cdcooper = 1	AND e.nrdconta = 2276003	AND e.nrctremp = 556356) OR
(e.cdcooper = 1	AND e.nrdconta = 2276003	AND e.nrctremp = 814867) OR (e.cdcooper = 1	AND e.nrdconta = 2276151	AND e.nrctremp = 156277) OR
(e.cdcooper = 1	AND e.nrdconta = 2276151	AND e.nrctremp = 577932) OR (e.cdcooper = 1	AND e.nrdconta = 2276585	AND e.nrctremp = 2276585) OR
(e.cdcooper = 1	AND e.nrdconta = 2277549	AND e.nrctremp = 711299) OR (e.cdcooper = 1	AND e.nrdconta = 2278324	AND e.nrctremp = 104057) OR
(e.cdcooper = 1	AND e.nrdconta = 2279797	AND e.nrctremp = 198351) OR (e.cdcooper = 1	AND e.nrdconta = 2288214	AND e.nrctremp = 1187350) OR
(e.cdcooper = 1	AND e.nrdconta = 2289652	AND e.nrctremp = 61097) OR (e.cdcooper = 1	AND e.nrdconta = 2289970	AND e.nrctremp = 952798) OR
(e.cdcooper = 1	AND e.nrdconta = 2297981	AND e.nrctremp = 155326) OR (e.cdcooper = 1	AND e.nrdconta = 2299151	AND e.nrctremp = 447035) OR
(e.cdcooper = 1	AND e.nrdconta = 2303523	AND e.nrctremp = 2303523) OR (e.cdcooper = 1	AND e.nrdconta = 2305836	AND e.nrctremp = 1128687) OR
(e.cdcooper = 1	AND e.nrdconta = 2308843	AND e.nrctremp = 666281) OR (e.cdcooper = 1	AND e.nrdconta = 2309831	AND e.nrctremp = 2309831) OR
(e.cdcooper = 1	AND e.nrdconta = 2312832	AND e.nrctremp = 852611) OR (e.cdcooper = 1	AND e.nrdconta = 2312832	AND e.nrctremp = 942298) OR
(e.cdcooper = 1	AND e.nrdconta = 2314126	AND e.nrctremp = 1481330) OR (e.cdcooper = 1	AND e.nrdconta = 2314983	AND e.nrctremp = 1061019) OR
(e.cdcooper = 1	AND e.nrdconta = 2316455	AND e.nrctremp = 584455) OR (e.cdcooper = 1	AND e.nrdconta = 2316838	AND e.nrctremp = 2316838) OR
(e.cdcooper = 1	AND e.nrdconta = 2317109	AND e.nrctremp = 663866) OR (e.cdcooper = 1	AND e.nrdconta = 2318334	AND e.nrctremp = 204340) OR
(e.cdcooper = 1	AND e.nrdconta = 2321971	AND e.nrctremp = 2013065) OR (e.cdcooper = 1	AND e.nrdconta = 2325713	AND e.nrctremp = 832754) OR
(e.cdcooper = 1	AND e.nrdconta = 2326795	AND e.nrctremp = 173623) OR (e.cdcooper = 1	AND e.nrdconta = 2332841	AND e.nrctremp = 1300132) OR
(e.cdcooper = 1	AND e.nrdconta = 2332841	AND e.nrctremp = 1407835) OR (e.cdcooper = 1	AND e.nrdconta = 2336880	AND e.nrctremp = 928631) OR
(e.cdcooper = 1	AND e.nrdconta = 2336880	AND e.nrctremp = 1097818) OR (e.cdcooper = 1	AND e.nrdconta = 2336910	AND e.nrctremp = 1503796) OR
(e.cdcooper = 1	AND e.nrdconta = 2338572	AND e.nrctremp = 386232) OR (e.cdcooper = 1	AND e.nrdconta = 2342006	AND e.nrctremp = 1255972) OR
(e.cdcooper = 1	AND e.nrdconta = 2347318	AND e.nrctremp = 726123) OR (e.cdcooper = 1	AND e.nrdconta = 2347350	AND e.nrctremp = 423530) OR
(e.cdcooper = 1	AND e.nrdconta = 2349248	AND e.nrctremp = 328296) OR (e.cdcooper = 1	AND e.nrdconta = 2351315	AND e.nrctremp = 1142787) OR
(e.cdcooper = 1	AND e.nrdconta = 2351943	AND e.nrctremp = 158155) OR (e.cdcooper = 1	AND e.nrdconta = 2353636	AND e.nrctremp = 863086) OR
(e.cdcooper = 1	AND e.nrdconta = 2360390	AND e.nrctremp = 188432) OR (e.cdcooper = 1	AND e.nrdconta = 2362180	AND e.nrctremp = 111659) OR
(e.cdcooper = 1	AND e.nrdconta = 2363143	AND e.nrctremp = 186797) OR (e.cdcooper = 1	AND e.nrdconta = 2363542	AND e.nrctremp = 1330413) OR
(e.cdcooper = 1	AND e.nrdconta = 2363542	AND e.nrctremp = 2101940) OR (e.cdcooper = 1	AND e.nrdconta = 2364271	AND e.nrctremp = 1422538) OR
(e.cdcooper = 1	AND e.nrdconta = 2365944	AND e.nrctremp = 146461) OR (e.cdcooper = 1	AND e.nrdconta = 2370620	AND e.nrctremp = 156550) OR
(e.cdcooper = 1	AND e.nrdconta = 2371529	AND e.nrctremp = 828924) OR (e.cdcooper = 1	AND e.nrdconta = 2372070	AND e.nrctremp = 366478) OR
(e.cdcooper = 1	AND e.nrdconta = 2372070	AND e.nrctremp = 2372070) OR (e.cdcooper = 1	AND e.nrdconta = 2372380	AND e.nrctremp = 1103946) OR
(e.cdcooper = 1	AND e.nrdconta = 2373742	AND e.nrctremp = 57162) OR (e.cdcooper = 1	AND e.nrdconta = 2375176	AND e.nrctremp = 101437) OR
(e.cdcooper = 1	AND e.nrdconta = 2375311	AND e.nrctremp = 528294) OR (e.cdcooper = 1	AND e.nrdconta = 2378019	AND e.nrctremp = 1237077) OR
(e.cdcooper = 1	AND e.nrdconta = 2378680	AND e.nrctremp = 2378680) OR (e.cdcooper = 1	AND e.nrdconta = 2379392	AND e.nrctremp = 809694) OR
(e.cdcooper = 1	AND e.nrdconta = 2384345	AND e.nrctremp = 2384345) OR (e.cdcooper = 1	AND e.nrdconta = 2388057	AND e.nrctremp = 458668) OR
(e.cdcooper = 1	AND e.nrdconta = 2390868	AND e.nrctremp = 642172) OR (e.cdcooper = 1	AND e.nrdconta = 2391864	AND e.nrctremp = 2391864) OR
(e.cdcooper = 1	AND e.nrdconta = 2396335	AND e.nrctremp = 486126) OR (e.cdcooper = 1	AND e.nrdconta = 2397269	AND e.nrctremp = 478) OR
(e.cdcooper = 1	AND e.nrdconta = 2398931	AND e.nrctremp = 2398931) OR (e.cdcooper = 1	AND e.nrdconta = 2401576	AND e.nrctremp = 503097) OR
(e.cdcooper = 1	AND e.nrdconta = 2402521	AND e.nrctremp = 1257579) OR (e.cdcooper = 1	AND e.nrdconta = 2402530	AND e.nrctremp = 1257907) OR
(e.cdcooper = 1	AND e.nrdconta = 2402793	AND e.nrctremp = 1096852) OR (e.cdcooper = 1	AND e.nrdconta = 2404680	AND e.nrctremp = 110412) OR
(e.cdcooper = 1	AND e.nrdconta = 2404800	AND e.nrctremp = 184879) OR (e.cdcooper = 1	AND e.nrdconta = 2407280	AND e.nrctremp = 681236) OR
(e.cdcooper = 1	AND e.nrdconta = 2410389	AND e.nrctremp = 830659) OR (e.cdcooper = 1	AND e.nrdconta = 2415445	AND e.nrctremp = 609664) OR
(e.cdcooper = 1	AND e.nrdconta = 2416484	AND e.nrctremp = 519896) OR (e.cdcooper = 1	AND e.nrdconta = 2417723	AND e.nrctremp = 922187) OR
(e.cdcooper = 1	AND e.nrdconta = 2417880	AND e.nrctremp = 489270) OR (e.cdcooper = 1	AND e.nrdconta = 2421720	AND e.nrctremp = 2421720) OR
(e.cdcooper = 1	AND e.nrdconta = 2423405	AND e.nrctremp = 467805) OR (e.cdcooper = 1	AND e.nrdconta = 2427427	AND e.nrctremp = 1655634) OR
(e.cdcooper = 1	AND e.nrdconta = 2430380	AND e.nrctremp = 118629) OR (e.cdcooper = 1	AND e.nrdconta = 2431246	AND e.nrctremp = 118541) OR
(e.cdcooper = 1	AND e.nrdconta = 2432447	AND e.nrctremp = 120689) OR (e.cdcooper = 1	AND e.nrdconta = 2432501	AND e.nrctremp = 869468) OR
(e.cdcooper = 1	AND e.nrdconta = 2434687	AND e.nrctremp = 1140018) OR (e.cdcooper = 1	AND e.nrdconta = 2434687	AND e.nrctremp = 1140036) OR
(e.cdcooper = 1	AND e.nrdconta = 2435101	AND e.nrctremp = 647107) OR (e.cdcooper = 1	AND e.nrdconta = 2435691	AND e.nrctremp = 332035) OR
(e.cdcooper = 1	AND e.nrdconta = 2436370	AND e.nrctremp = 187873) OR (e.cdcooper = 1	AND e.nrdconta = 2436434	AND e.nrctremp = 132486) OR
(e.cdcooper = 1	AND e.nrdconta = 2437295	AND e.nrctremp = 363491) OR (e.cdcooper = 1	AND e.nrdconta = 2439727	AND e.nrctremp = 1008717) OR
(e.cdcooper = 1	AND e.nrdconta = 2440563	AND e.nrctremp = 1145425) OR (e.cdcooper = 1	AND e.nrdconta = 2440865	AND e.nrctremp = 1885127) OR
(e.cdcooper = 1	AND e.nrdconta = 2441977	AND e.nrctremp = 2441977) OR (e.cdcooper = 1	AND e.nrdconta = 2443252	AND e.nrctremp = 1515355) OR
(e.cdcooper = 1	AND e.nrdconta = 2443732	AND e.nrctremp = 1491660) OR (e.cdcooper = 1	AND e.nrdconta = 2444232	AND e.nrctremp = 519030) OR
(e.cdcooper = 1	AND e.nrdconta = 2444380	AND e.nrctremp = 365715) OR (e.cdcooper = 1	AND e.nrdconta = 2444917	AND e.nrctremp = 758476) OR
(e.cdcooper = 1	AND e.nrdconta = 2446065	AND e.nrctremp = 573706) OR (e.cdcooper = 1	AND e.nrdconta = 2450496	AND e.nrctremp = 927808) OR
(e.cdcooper = 1	AND e.nrdconta = 2452308	AND e.nrctremp = 2452308) OR (e.cdcooper = 1	AND e.nrdconta = 2454394	AND e.nrctremp = 477312) OR
(e.cdcooper = 1	AND e.nrdconta = 2457970	AND e.nrctremp = 1587360) OR (e.cdcooper = 1	AND e.nrdconta = 2458748	AND e.nrctremp = 702329) OR
(e.cdcooper = 1	AND e.nrdconta = 2462184	AND e.nrctremp = 393502) OR (e.cdcooper = 1	AND e.nrdconta = 2464527	AND e.nrctremp = 587674) OR
(e.cdcooper = 1	AND e.nrdconta = 2464837	AND e.nrctremp = 593948) OR (e.cdcooper = 1	AND e.nrdconta = 2466449	AND e.nrctremp = 177230) OR
(e.cdcooper = 1	AND e.nrdconta = 2466449	AND e.nrctremp = 180105) OR (e.cdcooper = 1	AND e.nrdconta = 2466660	AND e.nrctremp = 377855) OR
(e.cdcooper = 1	AND e.nrdconta = 2467119	AND e.nrctremp = 21116) OR (e.cdcooper = 1	AND e.nrdconta = 2467844	AND e.nrctremp = 313730) OR
(e.cdcooper = 1	AND e.nrdconta = 2470918	AND e.nrctremp = 18982) OR (e.cdcooper = 1	AND e.nrdconta = 2473828	AND e.nrctremp = 1030224) OR
(e.cdcooper = 1	AND e.nrdconta = 2474930	AND e.nrctremp = 845391) OR (e.cdcooper = 1	AND e.nrdconta = 2476606	AND e.nrctremp = 121755) OR
(e.cdcooper = 1	AND e.nrdconta = 2478226	AND e.nrctremp = 1026856) OR (e.cdcooper = 1	AND e.nrdconta = 2479222	AND e.nrctremp = 111309) OR
(e.cdcooper = 1	AND e.nrdconta = 2480859	AND e.nrctremp = 672128) OR (e.cdcooper = 1	AND e.nrdconta = 2480999	AND e.nrctremp = 126310) OR
(e.cdcooper = 1	AND e.nrdconta = 2482355	AND e.nrctremp = 413821) OR (e.cdcooper = 1	AND e.nrdconta = 2482355	AND e.nrctremp = 2482355) OR
(e.cdcooper = 1	AND e.nrdconta = 2483793	AND e.nrctremp = 1835406) OR (e.cdcooper = 1	AND e.nrdconta = 2484005	AND e.nrctremp = 137681) OR
(e.cdcooper = 1	AND e.nrdconta = 2486636	AND e.nrctremp = 2486636) OR (e.cdcooper = 1	AND e.nrdconta = 2488973	AND e.nrctremp = 1186366) OR
(e.cdcooper = 1	AND e.nrdconta = 2491630	AND e.nrctremp = 1357338) OR (e.cdcooper = 1	AND e.nrdconta = 2492075	AND e.nrctremp = 422408) OR
(e.cdcooper = 1	AND e.nrdconta = 2492121	AND e.nrctremp = 407046) OR (e.cdcooper = 1	AND e.nrdconta = 2492237	AND e.nrctremp = 905401) OR
(e.cdcooper = 1	AND e.nrdconta = 2494043	AND e.nrctremp = 1169073) OR (e.cdcooper = 1	AND e.nrdconta = 2494450	AND e.nrctremp = 1094039) OR
(e.cdcooper = 1	AND e.nrdconta = 2495350	AND e.nrctremp = 1062233) OR (e.cdcooper = 1	AND e.nrdconta = 2495554	AND e.nrctremp = 165019) OR
(e.cdcooper = 1	AND e.nrdconta = 2502771	AND e.nrctremp = 408507) OR (e.cdcooper = 1	AND e.nrdconta = 2504316	AND e.nrctremp = 2504316) OR
(e.cdcooper = 1	AND e.nrdconta = 2511347	AND e.nrctremp = 566810) OR (e.cdcooper = 1	AND e.nrdconta = 2511479	AND e.nrctremp = 564120) OR
(e.cdcooper = 1	AND e.nrdconta = 2511924	AND e.nrctremp = 11547) OR (e.cdcooper = 1	AND e.nrdconta = 2522896	AND e.nrctremp = 289508) OR
(e.cdcooper = 1	AND e.nrdconta = 2523574	AND e.nrctremp = 695250) OR (e.cdcooper = 1	AND e.nrdconta = 2527006	AND e.nrctremp = 377702) OR
(e.cdcooper = 1	AND e.nrdconta = 2528541	AND e.nrctremp = 1272666) OR (e.cdcooper = 1	AND e.nrdconta = 2529602	AND e.nrctremp = 156180) OR
(e.cdcooper = 1	AND e.nrdconta = 2529688	AND e.nrctremp = 1015832) OR (e.cdcooper = 1	AND e.nrdconta = 2531194	AND e.nrctremp = 225242) OR
(e.cdcooper = 1	AND e.nrdconta = 2536587	AND e.nrctremp = 812472) OR (e.cdcooper = 1	AND e.nrdconta = 2537095	AND e.nrctremp = 137779) OR
(e.cdcooper = 1	AND e.nrdconta = 2538334	AND e.nrctremp = 1511465) OR (e.cdcooper = 1	AND e.nrdconta = 2538423	AND e.nrctremp = 76500) OR
(e.cdcooper = 1	AND e.nrdconta = 2538458	AND e.nrctremp = 944874) OR (e.cdcooper = 1	AND e.nrdconta = 2545799	AND e.nrctremp = 656176) OR
(e.cdcooper = 1	AND e.nrdconta = 2549441	AND e.nrctremp = 1359642) OR (e.cdcooper = 1	AND e.nrdconta = 2551055	AND e.nrctremp = 2551055) OR
(e.cdcooper = 1	AND e.nrdconta = 2551292	AND e.nrctremp = 505889) OR (e.cdcooper = 1	AND e.nrdconta = 2551292	AND e.nrctremp = 898993) OR
(e.cdcooper = 1	AND e.nrdconta = 2551845	AND e.nrctremp = 2551845) OR (e.cdcooper = 1	AND e.nrdconta = 2555093	AND e.nrctremp = 1618950) OR
(e.cdcooper = 1	AND e.nrdconta = 2555638	AND e.nrctremp = 111244) OR (e.cdcooper = 1	AND e.nrdconta = 2558637	AND e.nrctremp = 1028595) OR
(e.cdcooper = 1	AND e.nrdconta = 2558831	AND e.nrctremp = 893501) OR (e.cdcooper = 1	AND e.nrdconta = 2558831	AND e.nrctremp = 894204) OR
(e.cdcooper = 1	AND e.nrdconta = 2561611	AND e.nrctremp = 1775662) OR (e.cdcooper = 1	AND e.nrdconta = 2564211	AND e.nrctremp = 2564211) OR
(e.cdcooper = 1	AND e.nrdconta = 2564424	AND e.nrctremp = 485372) OR (e.cdcooper = 1	AND e.nrdconta = 2564815	AND e.nrctremp = 1696603) OR
(e.cdcooper = 1	AND e.nrdconta = 2565951	AND e.nrctremp = 2565951) OR (e.cdcooper = 1	AND e.nrdconta = 2567270	AND e.nrctremp = 316415) OR
(e.cdcooper = 1	AND e.nrdconta = 2567687	AND e.nrctremp = 1032421) OR (e.cdcooper = 1	AND e.nrdconta = 2570025	AND e.nrctremp = 1153792) OR
(e.cdcooper = 1	AND e.nrdconta = 2571757	AND e.nrctremp = 405567) OR (e.cdcooper = 1	AND e.nrdconta = 2572095	AND e.nrctremp = 12057) OR
(e.cdcooper = 1	AND e.nrdconta = 2572257	AND e.nrctremp = 2572257) OR (e.cdcooper = 1	AND e.nrdconta = 2572265	AND e.nrctremp = 778268) OR
(e.cdcooper = 1	AND e.nrdconta = 2574101	AND e.nrctremp = 1022125) OR (e.cdcooper = 1	AND e.nrdconta = 2577607	AND e.nrctremp = 101265) OR
(e.cdcooper = 1	AND e.nrdconta = 2577976	AND e.nrctremp = 845591) OR (e.cdcooper = 1	AND e.nrdconta = 2580462	AND e.nrctremp = 2580462) OR
(e.cdcooper = 1	AND e.nrdconta = 2581779	AND e.nrctremp = 551264) OR (e.cdcooper = 1	AND e.nrdconta = 2581787	AND e.nrctremp = 738258) OR
(e.cdcooper = 1	AND e.nrdconta = 2583895	AND e.nrctremp = 739340) OR (e.cdcooper = 1	AND e.nrdconta = 2585146	AND e.nrctremp = 116098) OR
(e.cdcooper = 1	AND e.nrdconta = 2586312	AND e.nrctremp = 2586312) OR (e.cdcooper = 1	AND e.nrdconta = 2587319	AND e.nrctremp = 1511794) OR
(e.cdcooper = 1	AND e.nrdconta = 2591219	AND e.nrctremp = 502852) OR (e.cdcooper = 1	AND e.nrdconta = 2595990	AND e.nrctremp = 2595990) OR
(e.cdcooper = 1	AND e.nrdconta = 2598078	AND e.nrctremp = 1334603) OR (e.cdcooper = 1	AND e.nrdconta = 2600366	AND e.nrctremp = 1619234) OR
(e.cdcooper = 1	AND e.nrdconta = 2600846	AND e.nrctremp = 1401951) OR (e.cdcooper = 1	AND e.nrdconta = 2604469	AND e.nrctremp = 825326) OR
(e.cdcooper = 1	AND e.nrdconta = 2605180	AND e.nrctremp = 835158) OR (e.cdcooper = 1	AND e.nrdconta = 2605422	AND e.nrctremp = 2605422) OR
(e.cdcooper = 1	AND e.nrdconta = 2610485	AND e.nrctremp = 1474986) OR (e.cdcooper = 1	AND e.nrdconta = 2611040	AND e.nrctremp = 1173643) OR
(e.cdcooper = 1	AND e.nrdconta = 2617145	AND e.nrctremp = 111612) OR (e.cdcooper = 1	AND e.nrdconta = 2617951	AND e.nrctremp = 437218) OR
(e.cdcooper = 1	AND e.nrdconta = 2619962	AND e.nrctremp = 2619962) OR (e.cdcooper = 1	AND e.nrdconta = 2621363	AND e.nrctremp = 879038) OR
(e.cdcooper = 1	AND e.nrdconta = 2623854	AND e.nrctremp = 107249) OR (e.cdcooper = 1	AND e.nrdconta = 2624222	AND e.nrctremp = 467736) OR
(e.cdcooper = 1	AND e.nrdconta = 2624605	AND e.nrctremp = 625738) OR (e.cdcooper = 1	AND e.nrdconta = 2625679	AND e.nrctremp = 1494011) OR
(e.cdcooper = 1	AND e.nrdconta = 2626748	AND e.nrctremp = 153658) OR (e.cdcooper = 1	AND e.nrdconta = 2626799	AND e.nrctremp = 329288) OR
(e.cdcooper = 1	AND e.nrdconta = 2628716	AND e.nrctremp = 361655) OR (e.cdcooper = 1	AND e.nrdconta = 2629046	AND e.nrctremp = 665958) OR
(e.cdcooper = 1	AND e.nrdconta = 2629712	AND e.nrctremp = 436299) OR (e.cdcooper = 1	AND e.nrdconta = 2630494	AND e.nrctremp = 1360110) OR
(e.cdcooper = 1	AND e.nrdconta = 2632314	AND e.nrctremp = 1429302) OR (e.cdcooper = 1	AND e.nrdconta = 2634791	AND e.nrctremp = 824048) OR
(e.cdcooper = 1	AND e.nrdconta = 2634791	AND e.nrctremp = 973675) OR (e.cdcooper = 1	AND e.nrdconta = 2636930	AND e.nrctremp = 849120) OR
(e.cdcooper = 1	AND e.nrdconta = 2637120	AND e.nrctremp = 1949409) OR (e.cdcooper = 1	AND e.nrdconta = 2638339	AND e.nrctremp = 979143) OR
(e.cdcooper = 1	AND e.nrdconta = 2640260	AND e.nrctremp = 179838) OR (e.cdcooper = 1	AND e.nrdconta = 2641437	AND e.nrctremp = 2641437) OR
(e.cdcooper = 1	AND e.nrdconta = 2643766	AND e.nrctremp = 771878) OR (e.cdcooper = 1	AND e.nrdconta = 2644606	AND e.nrctremp = 556549) OR
(e.cdcooper = 1	AND e.nrdconta = 2644843	AND e.nrctremp = 34635) OR (e.cdcooper = 1	AND e.nrdconta = 2647036	AND e.nrctremp = 729127) OR
(e.cdcooper = 1	AND e.nrdconta = 2647087	AND e.nrctremp = 2647087) OR (e.cdcooper = 1	AND e.nrdconta = 2654571	AND e.nrctremp = 471284) OR
(e.cdcooper = 1	AND e.nrdconta = 2656477	AND e.nrctremp = 2656477) OR (e.cdcooper = 1	AND e.nrdconta = 2657570	AND e.nrctremp = 111470) OR
(e.cdcooper = 1	AND e.nrdconta = 2659905	AND e.nrctremp = 394122) OR (e.cdcooper = 1	AND e.nrdconta = 2664216	AND e.nrctremp = 804431) OR
(e.cdcooper = 1	AND e.nrdconta = 2665433	AND e.nrctremp = 403281) OR (e.cdcooper = 1	AND e.nrdconta = 2665433	AND e.nrctremp = 2665433) OR
(e.cdcooper = 1	AND e.nrdconta = 2666413	AND e.nrctremp = 159926) OR (e.cdcooper = 1	AND e.nrdconta = 2667460	AND e.nrctremp = 622871) OR
(e.cdcooper = 1	AND e.nrdconta = 2667622	AND e.nrctremp = 1270771) OR (e.cdcooper = 1	AND e.nrdconta = 2668076	AND e.nrctremp = 628059) OR
(e.cdcooper = 1	AND e.nrdconta = 2668181	AND e.nrctremp = 2668181) OR (e.cdcooper = 1	AND e.nrdconta = 2669153	AND e.nrctremp = 2669153) OR
(e.cdcooper = 1	AND e.nrdconta = 2669498	AND e.nrctremp = 1257656) OR (e.cdcooper = 1	AND e.nrdconta = 2669986	AND e.nrctremp = 313353) OR
(e.cdcooper = 1	AND e.nrdconta = 2672227	AND e.nrctremp = 629082) OR (e.cdcooper = 1	AND e.nrdconta = 2674874	AND e.nrctremp = 440524) OR
(e.cdcooper = 1	AND e.nrdconta = 2676389	AND e.nrctremp = 1337095) OR (e.cdcooper = 1	AND e.nrdconta = 2677610	AND e.nrctremp = 667011) OR
(e.cdcooper = 1	AND e.nrdconta = 2681641	AND e.nrctremp = 1920860) OR (e.cdcooper = 1	AND e.nrdconta = 2681820	AND e.nrctremp = 361224) OR
(e.cdcooper = 1	AND e.nrdconta = 2682893	AND e.nrctremp = 2682893) OR (e.cdcooper = 1	AND e.nrdconta = 2685388	AND e.nrctremp = 803056) OR
(e.cdcooper = 1	AND e.nrdconta = 2689693	AND e.nrctremp = 2689693) OR (e.cdcooper = 1	AND e.nrdconta = 2690101	AND e.nrctremp = 825163) OR
(e.cdcooper = 1	AND e.nrdconta = 2691000	AND e.nrctremp = 1237663) OR (e.cdcooper = 1	AND e.nrdconta = 2691647	AND e.nrctremp = 754805) OR
(e.cdcooper = 1	AND e.nrdconta = 2698048	AND e.nrctremp = 1384411) OR (e.cdcooper = 1	AND e.nrdconta = 2699249	AND e.nrctremp = 557298) OR
(e.cdcooper = 1	AND e.nrdconta = 2700140	AND e.nrctremp = 442260) OR (e.cdcooper = 1	AND e.nrdconta = 2703343	AND e.nrctremp = 1575061) OR
(e.cdcooper = 1	AND e.nrdconta = 2705311	AND e.nrctremp = 670698) OR (e.cdcooper = 1	AND e.nrdconta = 2705796	AND e.nrctremp = 467006) OR
(e.cdcooper = 1	AND e.nrdconta = 2707306	AND e.nrctremp = 857956) OR (e.cdcooper = 1	AND e.nrdconta = 2708647	AND e.nrctremp = 1269501) OR
(e.cdcooper = 1	AND e.nrdconta = 2708949	AND e.nrctremp = 578254) OR (e.cdcooper = 1	AND e.nrdconta = 2713853	AND e.nrctremp = 188421) OR
(e.cdcooper = 1	AND e.nrdconta = 2713900	AND e.nrctremp = 1141704) OR (e.cdcooper = 1	AND e.nrdconta = 2714884	AND e.nrctremp = 144318) OR
(e.cdcooper = 1	AND e.nrdconta = 2723581	AND e.nrctremp = 629684) OR (e.cdcooper = 1	AND e.nrdconta = 2723719	AND e.nrctremp = 125767) OR
(e.cdcooper = 1	AND e.nrdconta = 2724545	AND e.nrctremp = 811743) OR (e.cdcooper = 1	AND e.nrdconta = 2728184	AND e.nrctremp = 682717) OR
(e.cdcooper = 1	AND e.nrdconta = 2730448	AND e.nrctremp = 371562) OR (e.cdcooper = 1	AND e.nrdconta = 2736888	AND e.nrctremp = 1604557) OR
(e.cdcooper = 1	AND e.nrdconta = 2742853	AND e.nrctremp = 370412) OR (e.cdcooper = 1	AND e.nrdconta = 2746980	AND e.nrctremp = 722038) OR
(e.cdcooper = 1	AND e.nrdconta = 2748312	AND e.nrctremp = 1593180) OR (e.cdcooper = 1	AND e.nrdconta = 2751780	AND e.nrctremp = 2751780) OR
(e.cdcooper = 1	AND e.nrdconta = 2752360	AND e.nrctremp = 699387) OR (e.cdcooper = 1	AND e.nrdconta = 2753588	AND e.nrctremp = 1358072) OR
(e.cdcooper = 1	AND e.nrdconta = 2754622	AND e.nrctremp = 364136) OR (e.cdcooper = 1	AND e.nrdconta = 2754789	AND e.nrctremp = 581224) OR
(e.cdcooper = 1	AND e.nrdconta = 2759055	AND e.nrctremp = 1388544) OR (e.cdcooper = 1	AND e.nrdconta = 2759640	AND e.nrctremp = 2759640) OR
(e.cdcooper = 1	AND e.nrdconta = 2760746	AND e.nrctremp = 511848) OR (e.cdcooper = 1	AND e.nrdconta = 2762978	AND e.nrctremp = 1005738) OR
(e.cdcooper = 1	AND e.nrdconta = 2764075	AND e.nrctremp = 57944) OR (e.cdcooper = 1	AND e.nrdconta = 2765411	AND e.nrctremp = 1208098) OR
(e.cdcooper = 1	AND e.nrdconta = 2768151	AND e.nrctremp = 1311063) OR (e.cdcooper = 1	AND e.nrdconta = 2769522	AND e.nrctremp = 2769522) OR
(e.cdcooper = 1	AND e.nrdconta = 2773988	AND e.nrctremp = 2773988) OR (e.cdcooper = 1	AND e.nrdconta = 2781018	AND e.nrctremp = 1006447) OR
(e.cdcooper = 1	AND e.nrdconta = 2786400	AND e.nrctremp = 1579532) OR (e.cdcooper = 1	AND e.nrdconta = 2787466	AND e.nrctremp = 2787466) OR
(e.cdcooper = 1	AND e.nrdconta = 2789965	AND e.nrctremp = 684858) OR (e.cdcooper = 1	AND e.nrdconta = 2793474	AND e.nrctremp = 1430665) OR
(e.cdcooper = 1	AND e.nrdconta = 2794403	AND e.nrctremp = 1501312) OR (e.cdcooper = 1	AND e.nrdconta = 2794403	AND e.nrctremp = 1835389) OR
(e.cdcooper = 1	AND e.nrdconta = 2798344	AND e.nrctremp = 762408) OR (e.cdcooper = 1	AND e.nrdconta = 2798476	AND e.nrctremp = 1137222) OR
(e.cdcooper = 1	AND e.nrdconta = 2798565	AND e.nrctremp = 751010) OR (e.cdcooper = 1	AND e.nrdconta = 2799502	AND e.nrctremp = 577885) OR
(e.cdcooper = 1	AND e.nrdconta = 2808641	AND e.nrctremp = 701610) OR (e.cdcooper = 1	AND e.nrdconta = 2812606	AND e.nrctremp = 641483) OR
(e.cdcooper = 1	AND e.nrdconta = 2815737	AND e.nrctremp = 684842) OR (e.cdcooper = 1	AND e.nrdconta = 2818299	AND e.nrctremp = 387781) OR
(e.cdcooper = 1	AND e.nrdconta = 2818710	AND e.nrctremp = 2012667) OR (e.cdcooper = 1	AND e.nrdconta = 2818841	AND e.nrctremp = 21623) OR
(e.cdcooper = 1	AND e.nrdconta = 2828014	AND e.nrctremp = 963941) OR (e.cdcooper = 1	AND e.nrdconta = 2828340	AND e.nrctremp = 553206) OR
(e.cdcooper = 1	AND e.nrdconta = 2837650	AND e.nrctremp = 641578) OR (e.cdcooper = 1	AND e.nrdconta = 2842513	AND e.nrctremp = 902323) OR
(e.cdcooper = 1	AND e.nrdconta = 2842513	AND e.nrctremp = 903145) OR (e.cdcooper = 1	AND e.nrdconta = 2845695	AND e.nrctremp = 2845695) OR
(e.cdcooper = 1	AND e.nrdconta = 2855950	AND e.nrctremp = 961420) OR (e.cdcooper = 1	AND e.nrdconta = 2858134	AND e.nrctremp = 646930) OR
(e.cdcooper = 1	AND e.nrdconta = 2863898	AND e.nrctremp = 1003977) OR (e.cdcooper = 1	AND e.nrdconta = 2865432	AND e.nrctremp = 2865432) OR
(e.cdcooper = 1	AND e.nrdconta = 2867052	AND e.nrctremp = 97838) OR (e.cdcooper = 1	AND e.nrdconta = 2867052	AND e.nrctremp = 307350) OR
(e.cdcooper = 1	AND e.nrdconta = 2867052	AND e.nrctremp = 2867052) OR (e.cdcooper = 1	AND e.nrdconta = 2871173	AND e.nrctremp = 1015999) OR
(e.cdcooper = 1	AND e.nrdconta = 2871521	AND e.nrctremp = 568522) OR (e.cdcooper = 1	AND e.nrdconta = 2877694	AND e.nrctremp = 641616) OR
(e.cdcooper = 1	AND e.nrdconta = 2878810	AND e.nrctremp = 196702) OR (e.cdcooper = 1	AND e.nrdconta = 2892197	AND e.nrctremp = 1696252) OR
(e.cdcooper = 1	AND e.nrdconta = 2893177	AND e.nrctremp = 1119384) OR (e.cdcooper = 1	AND e.nrdconta = 2897261	AND e.nrctremp = 1476806) OR
(e.cdcooper = 1	AND e.nrdconta = 2898047	AND e.nrctremp = 20958) OR (e.cdcooper = 1	AND e.nrdconta = 2898667	AND e.nrctremp = 315559) OR
(e.cdcooper = 1	AND e.nrdconta = 2899361	AND e.nrctremp = 1586746) OR (e.cdcooper = 1	AND e.nrdconta = 2899841	AND e.nrctremp = 993475) OR
(e.cdcooper = 1	AND e.nrdconta = 2900173	AND e.nrctremp = 766473) OR (e.cdcooper = 1	AND e.nrdconta = 2902370	AND e.nrctremp = 902945) OR
(e.cdcooper = 1	AND e.nrdconta = 2903261	AND e.nrctremp = 870554) OR (e.cdcooper = 1	AND e.nrdconta = 2909170	AND e.nrctremp = 33058) OR
(e.cdcooper = 1	AND e.nrdconta = 2910470	AND e.nrctremp = 2910470) OR (e.cdcooper = 1	AND e.nrdconta = 2914913	AND e.nrctremp = 544044) OR
(e.cdcooper = 1	AND e.nrdconta = 2915103	AND e.nrctremp = 1505419) OR (e.cdcooper = 1	AND e.nrdconta = 2917122	AND e.nrctremp = 144216) OR
(e.cdcooper = 1	AND e.nrdconta = 2917246	AND e.nrctremp = 189721) OR (e.cdcooper = 1	AND e.nrdconta = 2917980	AND e.nrctremp = 143493) OR
(e.cdcooper = 1	AND e.nrdconta = 2918960	AND e.nrctremp = 994048) OR (e.cdcooper = 1	AND e.nrdconta = 2925931	AND e.nrctremp = 1911381) OR
(e.cdcooper = 1	AND e.nrdconta = 2926008	AND e.nrctremp = 1191449) OR (e.cdcooper = 1	AND e.nrdconta = 2926709	AND e.nrctremp = 638481) OR
(e.cdcooper = 1	AND e.nrdconta = 2927691	AND e.nrctremp = 101309) OR (e.cdcooper = 1	AND e.nrdconta = 2927691	AND e.nrctremp = 495210) OR
(e.cdcooper = 1	AND e.nrdconta = 2933055	AND e.nrctremp = 573032) OR (e.cdcooper = 1	AND e.nrdconta = 2934680	AND e.nrctremp = 1010174) OR
(e.cdcooper = 1	AND e.nrdconta = 2936160	AND e.nrctremp = 114211) OR (e.cdcooper = 1	AND e.nrdconta = 2939312	AND e.nrctremp = 2939312) OR
(e.cdcooper = 1	AND e.nrdconta = 2939754	AND e.nrctremp = 70822) OR (e.cdcooper = 1	AND e.nrdconta = 2941317	AND e.nrctremp = 692308) OR
(e.cdcooper = 1	AND e.nrdconta = 2946076	AND e.nrctremp = 2104782) OR (e.cdcooper = 1	AND e.nrdconta = 2946327	AND e.nrctremp = 1775004) OR
(e.cdcooper = 1	AND e.nrdconta = 2951223	AND e.nrctremp = 1343456) OR (e.cdcooper = 1	AND e.nrdconta = 2952424	AND e.nrctremp = 871197) OR
(e.cdcooper = 1	AND e.nrdconta = 2954435	AND e.nrctremp = 2954435) OR (e.cdcooper = 1	AND e.nrdconta = 2956136	AND e.nrctremp = 2956136) OR
(e.cdcooper = 1	AND e.nrdconta = 2956926	AND e.nrctremp = 802113) OR (e.cdcooper = 1	AND e.nrdconta = 2960230	AND e.nrctremp = 1274937) OR
(e.cdcooper = 1	AND e.nrdconta = 2962110	AND e.nrctremp = 2962110) OR (e.cdcooper = 1	AND e.nrdconta = 2962284	AND e.nrctremp = 169016) OR
(e.cdcooper = 1	AND e.nrdconta = 2964198	AND e.nrctremp = 69171) OR (e.cdcooper = 1	AND e.nrdconta = 2966042	AND e.nrctremp = 515765) OR
(e.cdcooper = 1	AND e.nrdconta = 2966093	AND e.nrctremp = 1279607) OR (e.cdcooper = 1	AND e.nrdconta = 2967740	AND e.nrctremp = 901334) OR
(e.cdcooper = 1	AND e.nrdconta = 2968193	AND e.nrctremp = 715972) OR (e.cdcooper = 1	AND e.nrdconta = 2970384	AND e.nrctremp = 2970384) OR
(e.cdcooper = 1	AND e.nrdconta = 2973227	AND e.nrctremp = 2973227) OR (e.cdcooper = 1	AND e.nrdconta = 2977087	AND e.nrctremp = 921109) OR
(e.cdcooper = 1	AND e.nrdconta = 2978768	AND e.nrctremp = 379074) OR (e.cdcooper = 1	AND e.nrdconta = 2983036	AND e.nrctremp = 1320414) OR
(e.cdcooper = 1	AND e.nrdconta = 2984717	AND e.nrctremp = 1474347) OR (e.cdcooper = 1	AND e.nrdconta = 2985306	AND e.nrctremp = 744226) OR
(e.cdcooper = 1	AND e.nrdconta = 2986060	AND e.nrctremp = 372252) OR (e.cdcooper = 1	AND e.nrdconta = 2988739	AND e.nrctremp = 1187592) OR
(e.cdcooper = 1	AND e.nrdconta = 2990822	AND e.nrctremp = 733899) OR (e.cdcooper = 1	AND e.nrdconta = 2992108	AND e.nrctremp = 1586904) OR
(e.cdcooper = 1	AND e.nrdconta = 2992833	AND e.nrctremp = 352980) OR (e.cdcooper = 1	AND e.nrdconta = 2999951	AND e.nrctremp = 783500) OR
(e.cdcooper = 1	AND e.nrdconta = 3000796	AND e.nrctremp = 148106) OR (e.cdcooper = 1	AND e.nrdconta = 3000796	AND e.nrctremp = 420536) OR
(e.cdcooper = 1	AND e.nrdconta = 3002683	AND e.nrctremp = 95198) OR (e.cdcooper = 1	AND e.nrdconta = 3004325	AND e.nrctremp = 866477) OR
(e.cdcooper = 1	AND e.nrdconta = 3004406	AND e.nrctremp = 782504) OR (e.cdcooper = 1	AND e.nrdconta = 3012247	AND e.nrctremp = 603584) OR
(e.cdcooper = 1	AND e.nrdconta = 3012476	AND e.nrctremp = 1586914) OR (e.cdcooper = 1	AND e.nrdconta = 3016650	AND e.nrctremp = 188106) OR
(e.cdcooper = 1	AND e.nrdconta = 3019136	AND e.nrctremp = 3019136) OR (e.cdcooper = 1	AND e.nrdconta = 3021483	AND e.nrctremp = 619354) OR
(e.cdcooper = 1	AND e.nrdconta = 3021912	AND e.nrctremp = 173098) OR (e.cdcooper = 1	AND e.nrdconta = 3021912	AND e.nrctremp = 173825) OR
(e.cdcooper = 1	AND e.nrdconta = 3023923	AND e.nrctremp = 306455) OR (e.cdcooper = 1	AND e.nrdconta = 3024580	AND e.nrctremp = 111501) OR
(e.cdcooper = 1	AND e.nrdconta = 3025489	AND e.nrctremp = 333498) OR (e.cdcooper = 1	AND e.nrdconta = 3029611	AND e.nrctremp = 2104109) OR
(e.cdcooper = 1	AND e.nrdconta = 3031527	AND e.nrctremp = 692332) OR (e.cdcooper = 1	AND e.nrdconta = 3032140	AND e.nrctremp = 3032140) OR
(e.cdcooper = 1	AND e.nrdconta = 3032388	AND e.nrctremp = 611256) OR (e.cdcooper = 1	AND e.nrdconta = 3033120	AND e.nrctremp = 3033120) OR
(e.cdcooper = 1	AND e.nrdconta = 3033457	AND e.nrctremp = 134415) OR (e.cdcooper = 1	AND e.nrdconta = 3033791	AND e.nrctremp = 768349) OR
(e.cdcooper = 1	AND e.nrdconta = 3037363	AND e.nrctremp = 778907) OR (e.cdcooper = 1	AND e.nrdconta = 3042090	AND e.nrctremp = 1217339) OR
(e.cdcooper = 1	AND e.nrdconta = 3042090	AND e.nrctremp = 1296539) OR (e.cdcooper = 1	AND e.nrdconta = 3043231	AND e.nrctremp = 723844) OR
(e.cdcooper = 1	AND e.nrdconta = 3048128	AND e.nrctremp = 1199017) OR (e.cdcooper = 1	AND e.nrdconta = 3049183	AND e.nrctremp = 811010) OR
(e.cdcooper = 1	AND e.nrdconta = 3051030	AND e.nrctremp = 574646) OR (e.cdcooper = 1	AND e.nrdconta = 3052958	AND e.nrctremp = 1354708) OR
(e.cdcooper = 1	AND e.nrdconta = 3054551	AND e.nrctremp = 740212) OR (e.cdcooper = 1	AND e.nrdconta = 3054810	AND e.nrctremp = 776958) OR
(e.cdcooper = 1	AND e.nrdconta = 3054934	AND e.nrctremp = 162147) OR (e.cdcooper = 1	AND e.nrdconta = 3060373	AND e.nrctremp = 1125188) OR
(e.cdcooper = 1	AND e.nrdconta = 3062201	AND e.nrctremp = 1513334) OR (e.cdcooper = 1	AND e.nrdconta = 3067505	AND e.nrctremp = 11112) OR
(e.cdcooper = 1	AND e.nrdconta = 3078019	AND e.nrctremp = 186238) OR (e.cdcooper = 1	AND e.nrdconta = 3078345	AND e.nrctremp = 1084177) OR
(e.cdcooper = 1	AND e.nrdconta = 3079228	AND e.nrctremp = 625315) OR (e.cdcooper = 1	AND e.nrdconta = 3080226	AND e.nrctremp = 1152150) OR
(e.cdcooper = 1	AND e.nrdconta = 3083519	AND e.nrctremp = 1028764) OR (e.cdcooper = 1	AND e.nrdconta = 3083748	AND e.nrctremp = 154569) OR
(e.cdcooper = 1	AND e.nrdconta = 3083748	AND e.nrctremp = 477929) OR (e.cdcooper = 1	AND e.nrdconta = 3084671	AND e.nrctremp = 3084671) OR
(e.cdcooper = 1	AND e.nrdconta = 3087816	AND e.nrctremp = 796279) OR (e.cdcooper = 1	AND e.nrdconta = 3087930	AND e.nrctremp = 705417) OR
(e.cdcooper = 1	AND e.nrdconta = 3091279	AND e.nrctremp = 1248003) OR (e.cdcooper = 1	AND e.nrdconta = 3093980	AND e.nrctremp = 3093980) OR
(e.cdcooper = 1	AND e.nrdconta = 3094804	AND e.nrctremp = 3094804) OR (e.cdcooper = 1	AND e.nrdconta = 3096149	AND e.nrctremp = 1582329) OR
(e.cdcooper = 1	AND e.nrdconta = 3096815	AND e.nrctremp = 530503) OR (e.cdcooper = 1	AND e.nrdconta = 3098133	AND e.nrctremp = 1372722) OR
(e.cdcooper = 1	AND e.nrdconta = 3098133	AND e.nrctremp = 1640386) OR (e.cdcooper = 1	AND e.nrdconta = 3098745	AND e.nrctremp = 107401) OR
(e.cdcooper = 1	AND e.nrdconta = 3099636	AND e.nrctremp = 821378) OR (e.cdcooper = 1	AND e.nrdconta = 3100316	AND e.nrctremp = 623602) OR
(e.cdcooper = 1	AND e.nrdconta = 3100421	AND e.nrctremp = 754821) OR (e.cdcooper = 1	AND e.nrdconta = 3100472	AND e.nrctremp = 511740) OR
(e.cdcooper = 1	AND e.nrdconta = 3101681	AND e.nrctremp = 587930) OR (e.cdcooper = 1	AND e.nrdconta = 3103234	AND e.nrctremp = 1087387) OR
(e.cdcooper = 1	AND e.nrdconta = 3105903	AND e.nrctremp = 3105903) OR (e.cdcooper = 1	AND e.nrdconta = 3119300	AND e.nrctremp = 1067997) OR
(e.cdcooper = 1	AND e.nrdconta = 3122794	AND e.nrctremp = 629029) OR (e.cdcooper = 1	AND e.nrdconta = 3127095	AND e.nrctremp = 1085523) OR
(e.cdcooper = 1	AND e.nrdconta = 3127427	AND e.nrctremp = 757667) OR (e.cdcooper = 1	AND e.nrdconta = 3128920	AND e.nrctremp = 573828) OR
(e.cdcooper = 1	AND e.nrdconta = 3135357	AND e.nrctremp = 542954) OR (e.cdcooper = 1	AND e.nrdconta = 3135608	AND e.nrctremp = 952610) OR
(e.cdcooper = 1	AND e.nrdconta = 3135713	AND e.nrctremp = 1147531) OR (e.cdcooper = 1	AND e.nrdconta = 3135861	AND e.nrctremp = 154742) OR
(e.cdcooper = 1	AND e.nrdconta = 3136736	AND e.nrctremp = 11406) OR (e.cdcooper = 1	AND e.nrdconta = 3137597	AND e.nrctremp = 1366348) OR
(e.cdcooper = 1	AND e.nrdconta = 3139042	AND e.nrctremp = 1724257) OR (e.cdcooper = 1	AND e.nrdconta = 3145700	AND e.nrctremp = 329291) OR
(e.cdcooper = 1	AND e.nrdconta = 3145816	AND e.nrctremp = 141570) OR (e.cdcooper = 1	AND e.nrdconta = 3148084	AND e.nrctremp = 3148084) OR
(e.cdcooper = 1	AND e.nrdconta = 3148157	AND e.nrctremp = 869573) OR (e.cdcooper = 1	AND e.nrdconta = 3149838	AND e.nrctremp = 331636) OR
(e.cdcooper = 1	AND e.nrdconta = 3150933	AND e.nrctremp = 1345118) OR (e.cdcooper = 1	AND e.nrdconta = 3150968	AND e.nrctremp = 1111649) OR
(e.cdcooper = 1	AND e.nrdconta = 3151140	AND e.nrctremp = 1514719) OR (e.cdcooper = 1	AND e.nrdconta = 3152103	AND e.nrctremp = 1531459) OR
(e.cdcooper = 1	AND e.nrdconta = 3152200	AND e.nrctremp = 688823) OR (e.cdcooper = 1	AND e.nrdconta = 3152782	AND e.nrctremp = 822427) OR
(e.cdcooper = 1	AND e.nrdconta = 3155323	AND e.nrctremp = 1131935) OR (e.cdcooper = 1	AND e.nrdconta = 3155706	AND e.nrctremp = 706802) OR
(e.cdcooper = 1	AND e.nrdconta = 3156346	AND e.nrctremp = 994676) OR (e.cdcooper = 1	AND e.nrdconta = 3158063	AND e.nrctremp = 851742) OR
(e.cdcooper = 1	AND e.nrdconta = 3158373	AND e.nrctremp = 3158373) OR (e.cdcooper = 1	AND e.nrdconta = 3159000	AND e.nrctremp = 3159000) OR
(e.cdcooper = 1	AND e.nrdconta = 3161030	AND e.nrctremp = 1053056) OR (e.cdcooper = 1	AND e.nrdconta = 3161986	AND e.nrctremp = 4667) OR
(e.cdcooper = 1	AND e.nrdconta = 3162389	AND e.nrctremp = 110904) OR (e.cdcooper = 1	AND e.nrdconta = 3162419	AND e.nrctremp = 77168) OR
(e.cdcooper = 1	AND e.nrdconta = 3162508	AND e.nrctremp = 818405) OR (e.cdcooper = 1	AND e.nrdconta = 3163547	AND e.nrctremp = 563131) OR
(e.cdcooper = 1	AND e.nrdconta = 3169278	AND e.nrctremp = 897461) OR (e.cdcooper = 1	AND e.nrdconta = 3169987	AND e.nrctremp = 882818) OR
(e.cdcooper = 1	AND e.nrdconta = 3170179	AND e.nrctremp = 1271795) OR (e.cdcooper = 1	AND e.nrdconta = 3171531	AND e.nrctremp = 1954555) OR
(e.cdcooper = 1	AND e.nrdconta = 3172457	AND e.nrctremp = 749541) OR (e.cdcooper = 1	AND e.nrdconta = 3172856	AND e.nrctremp = 148398) OR
(e.cdcooper = 1	AND e.nrdconta = 3173208	AND e.nrctremp = 54714) OR (e.cdcooper = 1	AND e.nrdconta = 3173704	AND e.nrctremp = 332820) OR
(e.cdcooper = 1	AND e.nrdconta = 3175898	AND e.nrctremp = 1578679) OR (e.cdcooper = 1	AND e.nrdconta = 3176835	AND e.nrctremp = 101533) OR
(e.cdcooper = 1	AND e.nrdconta = 3179834	AND e.nrctremp = 1614816) OR (e.cdcooper = 1	AND e.nrdconta = 3182983	AND e.nrctremp = 997855) OR
(e.cdcooper = 1	AND e.nrdconta = 3185362	AND e.nrctremp = 3185362) OR (e.cdcooper = 1	AND e.nrdconta = 3186016	AND e.nrctremp = 905236) OR
(e.cdcooper = 1	AND e.nrdconta = 3188329	AND e.nrctremp = 1586811) OR (e.cdcooper = 1	AND e.nrdconta = 3191893	AND e.nrctremp = 140918) OR
(e.cdcooper = 1	AND e.nrdconta = 3193179	AND e.nrctremp = 511730) OR (e.cdcooper = 1	AND e.nrdconta = 3195040	AND e.nrctremp = 27893) OR
(e.cdcooper = 1	AND e.nrdconta = 3195040	AND e.nrctremp = 57587) OR (e.cdcooper = 1	AND e.nrdconta = 3197166	AND e.nrctremp = 749542) OR
(e.cdcooper = 1	AND e.nrdconta = 3197379	AND e.nrctremp = 448084) OR (e.cdcooper = 1	AND e.nrdconta = 3198812	AND e.nrctremp = 1308483) OR
(e.cdcooper = 1	AND e.nrdconta = 3200590	AND e.nrctremp = 3200590) OR (e.cdcooper = 1	AND e.nrdconta = 3207218	AND e.nrctremp = 3207218) OR
(e.cdcooper = 1	AND e.nrdconta = 3207480	AND e.nrctremp = 867193) OR (e.cdcooper = 1	AND e.nrdconta = 3209334	AND e.nrctremp = 508908) OR
(e.cdcooper = 1	AND e.nrdconta = 3210820	AND e.nrctremp = 1161032) OR (e.cdcooper = 1	AND e.nrdconta = 3212904	AND e.nrctremp = 1519119) OR
(e.cdcooper = 1	AND e.nrdconta = 3213226	AND e.nrctremp = 673645) OR (e.cdcooper = 1	AND e.nrdconta = 3215300	AND e.nrctremp = 845873) OR
(e.cdcooper = 1	AND e.nrdconta = 3217116	AND e.nrctremp = 678371) OR (e.cdcooper = 1	AND e.nrdconta = 3217191	AND e.nrctremp = 3217191) OR
(e.cdcooper = 1	AND e.nrdconta = 3218384	AND e.nrctremp = 407732) OR (e.cdcooper = 1	AND e.nrdconta = 3218392	AND e.nrctremp = 877882) OR
(e.cdcooper = 1	AND e.nrdconta = 3218490	AND e.nrctremp = 1002439) OR (e.cdcooper = 1	AND e.nrdconta = 3221199	AND e.nrctremp = 3221199) OR
(e.cdcooper = 1	AND e.nrdconta = 3222870	AND e.nrctremp = 929740) OR (e.cdcooper = 1	AND e.nrdconta = 3224309	AND e.nrctremp = 559680) OR
(e.cdcooper = 1	AND e.nrdconta = 3225119	AND e.nrctremp = 1513745) OR (e.cdcooper = 1	AND e.nrdconta = 3227049	AND e.nrctremp = 1109731) OR
(e.cdcooper = 1	AND e.nrdconta = 3229017	AND e.nrctremp = 808949) OR (e.cdcooper = 1	AND e.nrdconta = 3229475	AND e.nrctremp = 2004939) OR
(e.cdcooper = 1	AND e.nrdconta = 3229572	AND e.nrctremp = 3229572) OR (e.cdcooper = 1	AND e.nrdconta = 3229823	AND e.nrctremp = 509957) OR
(e.cdcooper = 1	AND e.nrdconta = 3231178	AND e.nrctremp = 979814) OR (e.cdcooper = 1	AND e.nrdconta = 3231526	AND e.nrctremp = 1802184) OR
(e.cdcooper = 1	AND e.nrdconta = 3232026	AND e.nrctremp = 1775098) OR (e.cdcooper = 1	AND e.nrdconta = 3232166	AND e.nrctremp = 682023) OR
(e.cdcooper = 1	AND e.nrdconta = 3232620	AND e.nrctremp = 1591661) OR (e.cdcooper = 1	AND e.nrdconta = 3232670	AND e.nrctremp = 1274889) OR
(e.cdcooper = 1	AND e.nrdconta = 3233588	AND e.nrctremp = 962656) OR (e.cdcooper = 1	AND e.nrdconta = 3233987	AND e.nrctremp = 898561) OR
(e.cdcooper = 1	AND e.nrdconta = 3234053	AND e.nrctremp = 764794) OR (e.cdcooper = 1	AND e.nrdconta = 3234517	AND e.nrctremp = 548761) OR
(e.cdcooper = 1	AND e.nrdconta = 3236749	AND e.nrctremp = 3236749) OR (e.cdcooper = 1	AND e.nrdconta = 3236897	AND e.nrctremp = 1642800) OR
(e.cdcooper = 1	AND e.nrdconta = 3501892	AND e.nrctremp = 3501892) OR (e.cdcooper = 1	AND e.nrdconta = 3504603	AND e.nrctremp = 600778) OR
(e.cdcooper = 1	AND e.nrdconta = 3506657	AND e.nrctremp = 3506657) OR (e.cdcooper = 1	AND e.nrdconta = 3508196	AND e.nrctremp = 1047438) OR
(e.cdcooper = 1	AND e.nrdconta = 3509168	AND e.nrctremp = 3509168) OR (e.cdcooper = 1	AND e.nrdconta = 3509427	AND e.nrctremp = 120955) OR
(e.cdcooper = 1	AND e.nrdconta = 3509460	AND e.nrctremp = 58931) OR (e.cdcooper = 1	AND e.nrdconta = 3515133	AND e.nrctremp = 462257) OR
(e.cdcooper = 1	AND e.nrdconta = 3515320	AND e.nrctremp = 147369) OR (e.cdcooper = 1	AND e.nrdconta = 3517160	AND e.nrctremp = 3517160) OR
(e.cdcooper = 1	AND e.nrdconta = 3519279	AND e.nrctremp = 735276) OR (e.cdcooper = 1	AND e.nrdconta = 3519465	AND e.nrctremp = 61837) OR
(e.cdcooper = 1	AND e.nrdconta = 3519465	AND e.nrctremp = 111709) OR (e.cdcooper = 1	AND e.nrdconta = 3519643	AND e.nrctremp = 1063629) OR
(e.cdcooper = 1	AND e.nrdconta = 3519708	AND e.nrctremp = 150585) OR (e.cdcooper = 1	AND e.nrdconta = 3522598	AND e.nrctremp = 1505388) OR
(e.cdcooper = 1	AND e.nrdconta = 3527999	AND e.nrctremp = 998618) OR (e.cdcooper = 1	AND e.nrdconta = 3530469	AND e.nrctremp = 1257502) OR
(e.cdcooper = 1	AND e.nrdconta = 3531686	AND e.nrctremp = 464091) OR (e.cdcooper = 1	AND e.nrdconta = 3531961	AND e.nrctremp = 3531961) OR
(e.cdcooper = 1	AND e.nrdconta = 3537315	AND e.nrctremp = 98004) OR (e.cdcooper = 1	AND e.nrdconta = 3537315	AND e.nrctremp = 100638) OR
(e.cdcooper = 1	AND e.nrdconta = 3538621	AND e.nrctremp = 1495793) OR (e.cdcooper = 1	AND e.nrdconta = 3539008	AND e.nrctremp = 804274) OR
(e.cdcooper = 1	AND e.nrdconta = 3539024	AND e.nrctremp = 1040307) OR (e.cdcooper = 1	AND e.nrdconta = 3545342	AND e.nrctremp = 920311) OR
(e.cdcooper = 1	AND e.nrdconta = 3545954	AND e.nrctremp = 574800) OR (e.cdcooper = 1	AND e.nrdconta = 3546551	AND e.nrctremp = 3546551) OR
(e.cdcooper = 1	AND e.nrdconta = 3547140	AND e.nrctremp = 98083) OR (e.cdcooper = 1	AND e.nrdconta = 3547140	AND e.nrctremp = 431818) OR
(e.cdcooper = 1	AND e.nrdconta = 3547329	AND e.nrctremp = 548261) OR (e.cdcooper = 1	AND e.nrdconta = 3548198	AND e.nrctremp = 402225) OR
(e.cdcooper = 1	AND e.nrdconta = 3556930	AND e.nrctremp = 121022) OR (e.cdcooper = 1	AND e.nrdconta = 3557723	AND e.nrctremp = 11546) OR
(e.cdcooper = 1	AND e.nrdconta = 3557723	AND e.nrctremp = 618725) OR (e.cdcooper = 1	AND e.nrdconta = 3560422	AND e.nrctremp = 637793) OR
(e.cdcooper = 1	AND e.nrdconta = 3561909	AND e.nrctremp = 1398053) OR (e.cdcooper = 1	AND e.nrdconta = 3563324	AND e.nrctremp = 35509) OR
(e.cdcooper = 1	AND e.nrdconta = 3564916	AND e.nrctremp = 1514779) OR (e.cdcooper = 1	AND e.nrdconta = 3571025	AND e.nrctremp = 3571025) OR
(e.cdcooper = 1	AND e.nrdconta = 3571238	AND e.nrctremp = 11113) OR (e.cdcooper = 1	AND e.nrdconta = 3574270	AND e.nrctremp = 380323) OR
(e.cdcooper = 1	AND e.nrdconta = 3574270	AND e.nrctremp = 380327) OR (e.cdcooper = 1	AND e.nrdconta = 3575497	AND e.nrctremp = 594467) OR
(e.cdcooper = 1	AND e.nrdconta = 3577813	AND e.nrctremp = 1014719) OR (e.cdcooper = 1	AND e.nrdconta = 3581551	AND e.nrctremp = 707463) OR
(e.cdcooper = 1	AND e.nrdconta = 3583694	AND e.nrctremp = 117425) OR (e.cdcooper = 1	AND e.nrdconta = 3583848	AND e.nrctremp = 537415) OR
(e.cdcooper = 1	AND e.nrdconta = 3589056	AND e.nrctremp = 632212) OR (e.cdcooper = 1	AND e.nrdconta = 3590291	AND e.nrctremp = 1775197) OR
(e.cdcooper = 1	AND e.nrdconta = 3596176	AND e.nrctremp = 794132) OR (e.cdcooper = 1	AND e.nrdconta = 3597180	AND e.nrctremp = 823590) OR
(e.cdcooper = 1	AND e.nrdconta = 3599485	AND e.nrctremp = 1127666) OR (e.cdcooper = 1	AND e.nrdconta = 3600050	AND e.nrctremp = 844816) OR
(e.cdcooper = 1	AND e.nrdconta = 3601374	AND e.nrctremp = 996012) OR (e.cdcooper = 1	AND e.nrdconta = 3602184	AND e.nrctremp = 349023) OR
(e.cdcooper = 1	AND e.nrdconta = 3602656	AND e.nrctremp = 942333) OR (e.cdcooper = 1	AND e.nrdconta = 3603067	AND e.nrctremp = 27433) OR
(e.cdcooper = 1	AND e.nrdconta = 3605973	AND e.nrctremp = 388181) OR (e.cdcooper = 1	AND e.nrdconta = 3607500	AND e.nrctremp = 710983) OR
(e.cdcooper = 1	AND e.nrdconta = 3607739	AND e.nrctremp = 3607739) OR (e.cdcooper = 1	AND e.nrdconta = 3608743	AND e.nrctremp = 618791) OR
(e.cdcooper = 1	AND e.nrdconta = 3609049	AND e.nrctremp = 899481) OR (e.cdcooper = 1	AND e.nrdconta = 3609928	AND e.nrctremp = 3609928) OR
(e.cdcooper = 1	AND e.nrdconta = 3612244	AND e.nrctremp = 825766) OR (e.cdcooper = 1	AND e.nrdconta = 3615090	AND e.nrctremp = 1619405) OR
(e.cdcooper = 1	AND e.nrdconta = 3616193	AND e.nrctremp = 110695) OR (e.cdcooper = 1	AND e.nrdconta = 3616371	AND e.nrctremp = 104018) OR
(e.cdcooper = 1	AND e.nrdconta = 3618579	AND e.nrctremp = 1353787) OR (e.cdcooper = 1	AND e.nrdconta = 3618951	AND e.nrctremp = 509956) OR
(e.cdcooper = 1	AND e.nrdconta = 3624463	AND e.nrctremp = 750139) OR (e.cdcooper = 1	AND e.nrdconta = 3625168	AND e.nrctremp = 305239) OR
(e.cdcooper = 1	AND e.nrdconta = 3625508	AND e.nrctremp = 694460) OR (e.cdcooper = 1	AND e.nrdconta = 3629724	AND e.nrctremp = 507134) OR
(e.cdcooper = 1	AND e.nrdconta = 3629767	AND e.nrctremp = 798992) OR (e.cdcooper = 1	AND e.nrdconta = 3629805	AND e.nrctremp = 1098698) OR
(e.cdcooper = 1	AND e.nrdconta = 3630552	AND e.nrctremp = 162787) OR (e.cdcooper = 1	AND e.nrdconta = 3630790	AND e.nrctremp = 750826) OR
(e.cdcooper = 1	AND e.nrdconta = 3631737	AND e.nrctremp = 120741) OR (e.cdcooper = 1	AND e.nrdconta = 3634361	AND e.nrctremp = 2432631) OR
(e.cdcooper = 1	AND e.nrdconta = 3634515	AND e.nrctremp = 540399) OR (e.cdcooper = 1	AND e.nrdconta = 3634540	AND e.nrctremp = 692659) OR
(e.cdcooper = 1	AND e.nrdconta = 3635210	AND e.nrctremp = 152279) OR (e.cdcooper = 1	AND e.nrdconta = 3635503	AND e.nrctremp = 1185725) OR
(e.cdcooper = 1	AND e.nrdconta = 3636739	AND e.nrctremp = 829545) OR (e.cdcooper = 1	AND e.nrdconta = 3637620	AND e.nrctremp = 49153) OR
(e.cdcooper = 1	AND e.nrdconta = 3639592	AND e.nrctremp = 831980) OR (e.cdcooper = 1	AND e.nrdconta = 3639835	AND e.nrctremp = 108255) OR
(e.cdcooper = 1	AND e.nrdconta = 3643123	AND e.nrctremp = 503283) OR (e.cdcooper = 1	AND e.nrdconta = 3643697	AND e.nrctremp = 113892) OR
(e.cdcooper = 1	AND e.nrdconta = 3644294	AND e.nrctremp = 105235) OR (e.cdcooper = 1	AND e.nrdconta = 3644766	AND e.nrctremp = 587925) OR
(e.cdcooper = 1	AND e.nrdconta = 3645207	AND e.nrctremp = 942087) OR (e.cdcooper = 1	AND e.nrdconta = 3650219	AND e.nrctremp = 495010) OR
(e.cdcooper = 1	AND e.nrdconta = 3650995	AND e.nrctremp = 685740) OR (e.cdcooper = 1	AND e.nrdconta = 3651339	AND e.nrctremp = 43726) OR
(e.cdcooper = 1	AND e.nrdconta = 3653285	AND e.nrctremp = 1229398) OR (e.cdcooper = 1	AND e.nrdconta = 3655490	AND e.nrctremp = 1045977) OR
(e.cdcooper = 1	AND e.nrdconta = 3655741	AND e.nrctremp = 752129) OR (e.cdcooper = 1	AND e.nrdconta = 3657639	AND e.nrctremp = 798895) OR
(e.cdcooper = 1	AND e.nrdconta = 3657914	AND e.nrctremp = 21031) OR (e.cdcooper = 1	AND e.nrdconta = 3660478	AND e.nrctremp = 664087) OR
(e.cdcooper = 1	AND e.nrdconta = 3660699	AND e.nrctremp = 1015102) OR (e.cdcooper = 1	AND e.nrdconta = 3661440	AND e.nrctremp = 27606) OR
(e.cdcooper = 1	AND e.nrdconta = 3661482	AND e.nrctremp = 3661482) OR (e.cdcooper = 1	AND e.nrdconta = 3662403	AND e.nrctremp = 633431) OR
(e.cdcooper = 1	AND e.nrdconta = 3662926	AND e.nrctremp = 3662926) OR (e.cdcooper = 1	AND e.nrdconta = 3663949	AND e.nrctremp = 1992575) OR
(e.cdcooper = 1	AND e.nrdconta = 3674266	AND e.nrctremp = 745432) OR (e.cdcooper = 1	AND e.nrdconta = 3674380	AND e.nrctremp = 120756) OR
(e.cdcooper = 1	AND e.nrdconta = 3678296	AND e.nrctremp = 177248) OR (e.cdcooper = 1	AND e.nrdconta = 3680673	AND e.nrctremp = 1440449) OR
(e.cdcooper = 1	AND e.nrdconta = 3685390	AND e.nrctremp = 628055) OR (e.cdcooper = 1	AND e.nrdconta = 3688402	AND e.nrctremp = 1117584) OR
(e.cdcooper = 1	AND e.nrdconta = 3690172	AND e.nrctremp = 511497) OR (e.cdcooper = 1	AND e.nrdconta = 3691756	AND e.nrctremp = 494671) OR
(e.cdcooper = 1	AND e.nrdconta = 3693520	AND e.nrctremp = 455698) OR (e.cdcooper = 1	AND e.nrdconta = 3694712	AND e.nrctremp = 1132888) OR
(e.cdcooper = 1	AND e.nrdconta = 3695956	AND e.nrctremp = 1264272) OR (e.cdcooper = 1	AND e.nrdconta = 3700321	AND e.nrctremp = 491582) OR
(e.cdcooper = 1	AND e.nrdconta = 3700534	AND e.nrctremp = 559447) OR (e.cdcooper = 1	AND e.nrdconta = 3702871	AND e.nrctremp = 3702871) OR
(e.cdcooper = 1	AND e.nrdconta = 3703622	AND e.nrctremp = 3703622) OR (e.cdcooper = 1	AND e.nrdconta = 3705021	AND e.nrctremp = 1654580) OR
(e.cdcooper = 1	AND e.nrdconta = 3705528	AND e.nrctremp = 1446353) OR (e.cdcooper = 1	AND e.nrdconta = 3705609	AND e.nrctremp = 344703) OR
(e.cdcooper = 1	AND e.nrdconta = 3706842	AND e.nrctremp = 707629) OR (e.cdcooper = 1	AND e.nrdconta = 3707008	AND e.nrctremp = 701214) OR
(e.cdcooper = 1	AND e.nrdconta = 3708128	AND e.nrctremp = 3708128) OR (e.cdcooper = 1	AND e.nrdconta = 3708616	AND e.nrctremp = 3708616) OR
(e.cdcooper = 1	AND e.nrdconta = 3711285	AND e.nrctremp = 600684) OR (e.cdcooper = 1	AND e.nrdconta = 3711668	AND e.nrctremp = 72907) OR
(e.cdcooper = 1	AND e.nrdconta = 3712664	AND e.nrctremp = 3712664) OR (e.cdcooper = 1	AND e.nrdconta = 3713288	AND e.nrctremp = 1045093) OR
(e.cdcooper = 1	AND e.nrdconta = 3714160	AND e.nrctremp = 51642) OR (e.cdcooper = 1	AND e.nrdconta = 3716058	AND e.nrctremp = 902487) OR
(e.cdcooper = 1	AND e.nrdconta = 3716090	AND e.nrctremp = 500032) OR (e.cdcooper = 1	AND e.nrdconta = 3717097	AND e.nrctremp = 1287364) OR
(e.cdcooper = 1	AND e.nrdconta = 3720217	AND e.nrctremp = 1349353) OR (e.cdcooper = 1	AND e.nrdconta = 3721760	AND e.nrctremp = 1771580) OR
(e.cdcooper = 1	AND e.nrdconta = 3725278	AND e.nrctremp = 408274) OR (e.cdcooper = 1	AND e.nrdconta = 3725278	AND e.nrctremp = 408279) OR
(e.cdcooper = 1	AND e.nrdconta = 3726967	AND e.nrctremp = 3726967) OR (e.cdcooper = 1	AND e.nrdconta = 3727130	AND e.nrctremp = 479587) OR
(e.cdcooper = 1	AND e.nrdconta = 3728498	AND e.nrctremp = 3728498) OR (e.cdcooper = 1	AND e.nrdconta = 3730190	AND e.nrctremp = 330540) OR
(e.cdcooper = 1	AND e.nrdconta = 3730190	AND e.nrctremp = 3730190) OR (e.cdcooper = 1	AND e.nrdconta = 3734048	AND e.nrctremp = 788852) OR
(e.cdcooper = 1	AND e.nrdconta = 3735982	AND e.nrctremp = 99029) OR (e.cdcooper = 1	AND e.nrdconta = 3736962	AND e.nrctremp = 21341) OR
(e.cdcooper = 1	AND e.nrdconta = 3737861	AND e.nrctremp = 2930) OR (e.cdcooper = 1	AND e.nrdconta = 3737861	AND e.nrctremp = 761808) OR
(e.cdcooper = 1	AND e.nrdconta = 3739538	AND e.nrctremp = 1370893) OR (e.cdcooper = 1	AND e.nrdconta = 3741290	AND e.nrctremp = 166173) OR
(e.cdcooper = 1	AND e.nrdconta = 3741427	AND e.nrctremp = 3741427) OR (e.cdcooper = 1	AND e.nrdconta = 3743055	AND e.nrctremp = 854755) OR
(e.cdcooper = 1	AND e.nrdconta = 3743683	AND e.nrctremp = 415415) OR (e.cdcooper = 1	AND e.nrdconta = 3744060	AND e.nrctremp = 1105681) OR
(e.cdcooper = 1	AND e.nrdconta = 3747697	AND e.nrctremp = 750741) OR (e.cdcooper = 1	AND e.nrdconta = 3748146	AND e.nrctremp = 46930) OR
(e.cdcooper = 1	AND e.nrdconta = 3748677	AND e.nrctremp = 989273) OR (e.cdcooper = 1	AND e.nrdconta = 3749681	AND e.nrctremp = 410925) OR
(e.cdcooper = 1	AND e.nrdconta = 3755878	AND e.nrctremp = 2101876) OR (e.cdcooper = 1	AND e.nrdconta = 3759547	AND e.nrctremp = 3759547) OR
(e.cdcooper = 1	AND e.nrdconta = 3760790	AND e.nrctremp = 1275734) OR (e.cdcooper = 1	AND e.nrdconta = 3760863	AND e.nrctremp = 3760863) OR
(e.cdcooper = 1	AND e.nrdconta = 3763870	AND e.nrctremp = 895188) OR (e.cdcooper = 1	AND e.nrdconta = 3764168	AND e.nrctremp = 488433) OR
(e.cdcooper = 1	AND e.nrdconta = 3765350	AND e.nrctremp = 637315) OR (e.cdcooper = 1	AND e.nrdconta = 3766721	AND e.nrctremp = 1655093) OR
(e.cdcooper = 1	AND e.nrdconta = 3768449	AND e.nrctremp = 130276) OR (e.cdcooper = 1	AND e.nrdconta = 3768562	AND e.nrctremp = 3768562) OR
(e.cdcooper = 1	AND e.nrdconta = 3768708	AND e.nrctremp = 1596415) OR (e.cdcooper = 1	AND e.nrdconta = 3768783	AND e.nrctremp = 827983) OR
(e.cdcooper = 1	AND e.nrdconta = 3768945	AND e.nrctremp = 21552) OR (e.cdcooper = 1	AND e.nrdconta = 3771440	AND e.nrctremp = 3771440) OR
(e.cdcooper = 1	AND e.nrdconta = 3771733	AND e.nrctremp = 11945) OR (e.cdcooper = 1	AND e.nrdconta = 3772209	AND e.nrctremp = 494145) OR
(e.cdcooper = 1	AND e.nrdconta = 3777871	AND e.nrctremp = 107651) OR (e.cdcooper = 1	AND e.nrdconta = 3777936	AND e.nrctremp = 748096) OR
(e.cdcooper = 1	AND e.nrdconta = 3780805	AND e.nrctremp = 567144) OR (e.cdcooper = 1	AND e.nrdconta = 3783243	AND e.nrctremp = 862813) OR
(e.cdcooper = 1	AND e.nrdconta = 3786820	AND e.nrctremp = 219801) OR (e.cdcooper = 1	AND e.nrdconta = 3791653	AND e.nrctremp = 1153743) OR
(e.cdcooper = 1	AND e.nrdconta = 3792730	AND e.nrctremp = 1517861) OR (e.cdcooper = 1	AND e.nrdconta = 3794717	AND e.nrctremp = 193412) OR
(e.cdcooper = 1	AND e.nrdconta = 3794768	AND e.nrctremp = 111540) OR (e.cdcooper = 1	AND e.nrdconta = 3794768	AND e.nrctremp = 536232) OR
(e.cdcooper = 1	AND e.nrdconta = 3795527	AND e.nrctremp = 1806212) OR (e.cdcooper = 1	AND e.nrdconta = 3797139	AND e.nrctremp = 530565) OR
(e.cdcooper = 1	AND e.nrdconta = 3798569	AND e.nrctremp = 1198641) OR (e.cdcooper = 1	AND e.nrdconta = 3798658	AND e.nrctremp = 150038) OR
(e.cdcooper = 1	AND e.nrdconta = 3798984	AND e.nrctremp = 128200) OR (e.cdcooper = 1	AND e.nrdconta = 3804356	AND e.nrctremp = 1326328) OR
(e.cdcooper = 1	AND e.nrdconta = 3805000	AND e.nrctremp = 857856) OR (e.cdcooper = 1	AND e.nrdconta = 3805140	AND e.nrctremp = 175479) OR
(e.cdcooper = 1	AND e.nrdconta = 3805760	AND e.nrctremp = 850208) OR (e.cdcooper = 1	AND e.nrdconta = 3805760	AND e.nrctremp = 1362892) OR
(e.cdcooper = 1	AND e.nrdconta = 3806480	AND e.nrctremp = 1135269) OR (e.cdcooper = 1	AND e.nrdconta = 3807630	AND e.nrctremp = 730941) OR
(e.cdcooper = 1	AND e.nrdconta = 3809269	AND e.nrctremp = 172693) OR (e.cdcooper = 1	AND e.nrdconta = 3812367	AND e.nrctremp = 944520) OR
(e.cdcooper = 1	AND e.nrdconta = 3812375	AND e.nrctremp = 3812375) OR (e.cdcooper = 1	AND e.nrdconta = 3812650	AND e.nrctremp = 1170368) OR
(e.cdcooper = 1	AND e.nrdconta = 3813118	AND e.nrctremp = 175512) OR (e.cdcooper = 1	AND e.nrdconta = 3814726	AND e.nrctremp = 130748) OR
(e.cdcooper = 1	AND e.nrdconta = 3815137	AND e.nrctremp = 465571) OR (e.cdcooper = 1	AND e.nrdconta = 3815196	AND e.nrctremp = 865316) OR
(e.cdcooper = 1	AND e.nrdconta = 3816079	AND e.nrctremp = 682885) OR (e.cdcooper = 1	AND e.nrdconta = 3816150	AND e.nrctremp = 223478) OR
(e.cdcooper = 1	AND e.nrdconta = 3820726	AND e.nrctremp = 4195) OR (e.cdcooper = 1	AND e.nrdconta = 3823431	AND e.nrctremp = 3823431) OR
(e.cdcooper = 1	AND e.nrdconta = 3823482	AND e.nrctremp = 764348) OR (e.cdcooper = 1	AND e.nrdconta = 3826015	AND e.nrctremp = 404203) OR
(e.cdcooper = 1	AND e.nrdconta = 3826015	AND e.nrctremp = 1959992) OR (e.cdcooper = 1	AND e.nrdconta = 3826937	AND e.nrctremp = 862074) OR
(e.cdcooper = 1	AND e.nrdconta = 3827291	AND e.nrctremp = 1041454) OR (e.cdcooper = 1	AND e.nrdconta = 3827569	AND e.nrctremp = 1215851) OR
(e.cdcooper = 1	AND e.nrdconta = 3828638	AND e.nrctremp = 1309130) OR (e.cdcooper = 1	AND e.nrdconta = 3829499	AND e.nrctremp = 170030) OR
(e.cdcooper = 1	AND e.nrdconta = 3829901	AND e.nrctremp = 364697) OR (e.cdcooper = 1	AND e.nrdconta = 3830101	AND e.nrctremp = 3830101) OR
(e.cdcooper = 1	AND e.nrdconta = 3830217	AND e.nrctremp = 1192986) OR (e.cdcooper = 1	AND e.nrdconta = 3830802	AND e.nrctremp = 452420) OR
(e.cdcooper = 1	AND e.nrdconta = 3832244	AND e.nrctremp = 1333733) OR (e.cdcooper = 1	AND e.nrdconta = 3832511	AND e.nrctremp = 1775436) OR
(e.cdcooper = 1	AND e.nrdconta = 3833780	AND e.nrctremp = 3833780) OR (e.cdcooper = 1	AND e.nrdconta = 3834611	AND e.nrctremp = 680857) OR
(e.cdcooper = 1	AND e.nrdconta = 3835189	AND e.nrctremp = 1438309) OR (e.cdcooper = 1	AND e.nrdconta = 3836843	AND e.nrctremp = 1921160) OR
(e.cdcooper = 1	AND e.nrdconta = 3838536	AND e.nrctremp = 3838536) OR (e.cdcooper = 1	AND e.nrdconta = 3838978	AND e.nrctremp = 833472) OR
(e.cdcooper = 1	AND e.nrdconta = 3839680	AND e.nrctremp = 668047) OR (e.cdcooper = 1	AND e.nrdconta = 3841359	AND e.nrctremp = 1389661) OR
(e.cdcooper = 1	AND e.nrdconta = 3841359	AND e.nrctremp = 1539810) OR (e.cdcooper = 1	AND e.nrdconta = 3841944	AND e.nrctremp = 749565) OR
(e.cdcooper = 1	AND e.nrdconta = 3842622	AND e.nrctremp = 836405) OR (e.cdcooper = 1	AND e.nrdconta = 3842622	AND e.nrctremp = 893695) OR
(e.cdcooper = 1	AND e.nrdconta = 3845710	AND e.nrctremp = 111539) OR (e.cdcooper = 1	AND e.nrdconta = 3845770	AND e.nrctremp = 3845770) OR
(e.cdcooper = 1	AND e.nrdconta = 3845850	AND e.nrctremp = 198868) OR (e.cdcooper = 1	AND e.nrdconta = 3848035	AND e.nrctremp = 447232) OR
(e.cdcooper = 1	AND e.nrdconta = 3848167	AND e.nrctremp = 781649) OR (e.cdcooper = 1	AND e.nrdconta = 3849228	AND e.nrctremp = 584884) OR
(e.cdcooper = 1	AND e.nrdconta = 3849350	AND e.nrctremp = 616559) OR (e.cdcooper = 1	AND e.nrdconta = 3849732	AND e.nrctremp = 761539) OR
(e.cdcooper = 1	AND e.nrdconta = 3850102	AND e.nrctremp = 344215) OR (e.cdcooper = 1	AND e.nrdconta = 3853080	AND e.nrctremp = 412293) OR
(e.cdcooper = 1	AND e.nrdconta = 3853276	AND e.nrctremp = 3853276) OR (e.cdcooper = 1	AND e.nrdconta = 3857093	AND e.nrctremp = 867418) OR
(e.cdcooper = 1	AND e.nrdconta = 3862038	AND e.nrctremp = 417811) OR (e.cdcooper = 1	AND e.nrdconta = 3863590	AND e.nrctremp = 785398) OR
(e.cdcooper = 1	AND e.nrdconta = 3864260	AND e.nrctremp = 859914) OR (e.cdcooper = 1	AND e.nrdconta = 3864561	AND e.nrctremp = 1044278) OR
(e.cdcooper = 1	AND e.nrdconta = 3867366	AND e.nrctremp = 3867366) OR (e.cdcooper = 1	AND e.nrdconta = 3869989	AND e.nrctremp = 1040322) OR
(e.cdcooper = 1	AND e.nrdconta = 3870073	AND e.nrctremp = 145277) OR (e.cdcooper = 1	AND e.nrdconta = 3871665	AND e.nrctremp = 1099973) OR
(e.cdcooper = 1	AND e.nrdconta = 3874435	AND e.nrctremp = 595398) OR (e.cdcooper = 1	AND e.nrdconta = 3875180	AND e.nrctremp = 646560) OR
(e.cdcooper = 1	AND e.nrdconta = 3876527	AND e.nrctremp = 144473) OR (e.cdcooper = 1	AND e.nrdconta = 3877205	AND e.nrctremp = 34785) OR
(e.cdcooper = 1	AND e.nrdconta = 3877922	AND e.nrctremp = 485283) OR (e.cdcooper = 1	AND e.nrdconta = 3878236	AND e.nrctremp = 3878236) OR
(e.cdcooper = 1	AND e.nrdconta = 3879194	AND e.nrctremp = 3879194) OR (e.cdcooper = 1	AND e.nrdconta = 3881776	AND e.nrctremp = 478768) OR
(e.cdcooper = 1	AND e.nrdconta = 3881865	AND e.nrctremp = 439870) OR (e.cdcooper = 1	AND e.nrdconta = 3884546	AND e.nrctremp = 111032) OR
(e.cdcooper = 1	AND e.nrdconta = 3884635	AND e.nrctremp = 658240) OR (e.cdcooper = 1	AND e.nrdconta = 3884635	AND e.nrctremp = 678051) OR
(e.cdcooper = 1	AND e.nrdconta = 3886301	AND e.nrctremp = 668187) OR (e.cdcooper = 1	AND e.nrdconta = 3886301	AND e.nrctremp = 806716) OR
(e.cdcooper = 1	AND e.nrdconta = 3886310	AND e.nrctremp = 644120) OR (e.cdcooper = 1	AND e.nrdconta = 3886506	AND e.nrctremp = 1111275) OR
(e.cdcooper = 1	AND e.nrdconta = 3886514	AND e.nrctremp = 1013059) OR (e.cdcooper = 1	AND e.nrdconta = 3888800	AND e.nrctremp = 1450564) OR
(e.cdcooper = 1	AND e.nrdconta = 3888967	AND e.nrctremp = 340298) OR (e.cdcooper = 1	AND e.nrdconta = 3889114	AND e.nrctremp = 131527) OR
(e.cdcooper = 1	AND e.nrdconta = 3891046	AND e.nrctremp = 3891046) OR (e.cdcooper = 1	AND e.nrdconta = 3894533	AND e.nrctremp = 615466) OR
(e.cdcooper = 1	AND e.nrdconta = 3895017	AND e.nrctremp = 678161) OR (e.cdcooper = 1	AND e.nrdconta = 3895041	AND e.nrctremp = 3895041) OR
(e.cdcooper = 1	AND e.nrdconta = 3895181	AND e.nrctremp = 654240) OR (e.cdcooper = 1	AND e.nrdconta = 3895610	AND e.nrctremp = 1586908) OR
(e.cdcooper = 1	AND e.nrdconta = 3897141	AND e.nrctremp = 43197) OR (e.cdcooper = 1	AND e.nrdconta = 3904857	AND e.nrctremp = 105525) OR
(e.cdcooper = 1	AND e.nrdconta = 3905110	AND e.nrctremp = 902740) OR (e.cdcooper = 1	AND e.nrdconta = 3906230	AND e.nrctremp = 3906230) OR
(e.cdcooper = 1	AND e.nrdconta = 3907279	AND e.nrctremp = 110928) OR (e.cdcooper = 1	AND e.nrdconta = 3910164	AND e.nrctremp = 3910164) OR
(e.cdcooper = 1	AND e.nrdconta = 3910946	AND e.nrctremp = 3910946) OR (e.cdcooper = 1	AND e.nrdconta = 3913058	AND e.nrctremp = 693455) OR
(e.cdcooper = 1	AND e.nrdconta = 3915964	AND e.nrctremp = 3915964) OR (e.cdcooper = 1	AND e.nrdconta = 3916600	AND e.nrctremp = 384442) OR
(e.cdcooper = 1	AND e.nrdconta = 3916642	AND e.nrctremp = 1164582) OR (e.cdcooper = 1	AND e.nrdconta = 3917436	AND e.nrctremp = 922841) OR
(e.cdcooper = 1	AND e.nrdconta = 3918467	AND e.nrctremp = 1082448) OR (e.cdcooper = 1	AND e.nrdconta = 3920518	AND e.nrctremp = 1852991) OR
(e.cdcooper = 1	AND e.nrdconta = 3921670	AND e.nrctremp = 1131573) OR (e.cdcooper = 1	AND e.nrdconta = 3923053	AND e.nrctremp = 1112826) OR
(e.cdcooper = 1	AND e.nrdconta = 3924394	AND e.nrctremp = 720603) OR (e.cdcooper = 1	AND e.nrdconta = 3924580	AND e.nrctremp = 3924580) OR
(e.cdcooper = 1	AND e.nrdconta = 3925277	AND e.nrctremp = 991081) OR (e.cdcooper = 1	AND e.nrdconta = 3925307	AND e.nrctremp = 1196304) OR
(e.cdcooper = 1	AND e.nrdconta = 3925552	AND e.nrctremp = 71229) OR (e.cdcooper = 1	AND e.nrdconta = 3925552	AND e.nrctremp = 121151) OR
(e.cdcooper = 1	AND e.nrdconta = 3925854	AND e.nrctremp = 951909) OR (e.cdcooper = 1	AND e.nrdconta = 3926052	AND e.nrctremp = 799142) OR
(e.cdcooper = 1	AND e.nrdconta = 3927440	AND e.nrctremp = 1596490) OR (e.cdcooper = 1	AND e.nrdconta = 3927814	AND e.nrctremp = 1513506) OR
(e.cdcooper = 1	AND e.nrdconta = 3928071	AND e.nrctremp = 3928071) OR (e.cdcooper = 1	AND e.nrdconta = 3928675	AND e.nrctremp = 3928675) OR
(e.cdcooper = 1	AND e.nrdconta = 3928756	AND e.nrctremp = 3928756) OR (e.cdcooper = 1	AND e.nrdconta = 3929973	AND e.nrctremp = 1415414) OR
(e.cdcooper = 1	AND e.nrdconta = 3930955	AND e.nrctremp = 3930955) OR (e.cdcooper = 1	AND e.nrdconta = 3932800	AND e.nrctremp = 644655) OR
(e.cdcooper = 1	AND e.nrdconta = 3933083	AND e.nrctremp = 1470573) OR (e.cdcooper = 1	AND e.nrdconta = 3933342	AND e.nrctremp = 1230347) OR
(e.cdcooper = 1	AND e.nrdconta = 3933369	AND e.nrctremp = 3933369) OR (e.cdcooper = 1	AND e.nrdconta = 3934780	AND e.nrctremp = 1088531) OR
(e.cdcooper = 1	AND e.nrdconta = 3934799	AND e.nrctremp = 910472) OR (e.cdcooper = 1	AND e.nrdconta = 3934810	AND e.nrctremp = 8622) OR
(e.cdcooper = 1	AND e.nrdconta = 3935892	AND e.nrctremp = 3935892) OR (e.cdcooper = 1	AND e.nrdconta = 3936007	AND e.nrctremp = 1326574) OR
(e.cdcooper = 1	AND e.nrdconta = 3936562	AND e.nrctremp = 428334) OR (e.cdcooper = 1	AND e.nrdconta = 3936562	AND e.nrctremp = 428335) OR
(e.cdcooper = 1	AND e.nrdconta = 3937798	AND e.nrctremp = 745944) OR (e.cdcooper = 1	AND e.nrdconta = 3939359	AND e.nrctremp = 1387145) OR
(e.cdcooper = 1	AND e.nrdconta = 3940683	AND e.nrctremp = 1049570) OR (e.cdcooper = 1	AND e.nrdconta = 3940896	AND e.nrctremp = 1272972) OR
(e.cdcooper = 1	AND e.nrdconta = 3941655	AND e.nrctremp = 3941655) OR (e.cdcooper = 1	AND e.nrdconta = 3942171	AND e.nrctremp = 1413052) OR
(e.cdcooper = 1	AND e.nrdconta = 3942341	AND e.nrctremp = 125065) OR (e.cdcooper = 1	AND e.nrdconta = 3944603	AND e.nrctremp = 864254) OR
(e.cdcooper = 1	AND e.nrdconta = 3944905	AND e.nrctremp = 306258) OR (e.cdcooper = 1	AND e.nrdconta = 3945596	AND e.nrctremp = 3945596) OR
(e.cdcooper = 1	AND e.nrdconta = 3945740	AND e.nrctremp = 890876) OR (e.cdcooper = 1	AND e.nrdconta = 3946673	AND e.nrctremp = 739797) OR
(e.cdcooper = 1	AND e.nrdconta = 3947505	AND e.nrctremp = 1475387) OR (e.cdcooper = 1	AND e.nrdconta = 3949265	AND e.nrctremp = 146603) OR
(e.cdcooper = 1	AND e.nrdconta = 3950921	AND e.nrctremp = 1224066) OR (e.cdcooper = 1	AND e.nrdconta = 3951820	AND e.nrctremp = 11056) OR
(e.cdcooper = 1	AND e.nrdconta = 3951936	AND e.nrctremp = 495176) OR (e.cdcooper = 1	AND e.nrdconta = 3952983	AND e.nrctremp = 69992) OR
(e.cdcooper = 1	AND e.nrdconta = 3954463	AND e.nrctremp = 3954463) OR (e.cdcooper = 1	AND e.nrdconta = 3956059	AND e.nrctremp = 1049049) OR
(e.cdcooper = 1	AND e.nrdconta = 3957489	AND e.nrctremp = 1041994) OR (e.cdcooper = 1	AND e.nrdconta = 3957799	AND e.nrctremp = 3957799) OR
(e.cdcooper = 1	AND e.nrdconta = 3957977	AND e.nrctremp = 171316) OR (e.cdcooper = 1	AND e.nrdconta = 3958213	AND e.nrctremp = 113422) OR
(e.cdcooper = 1	AND e.nrdconta = 3958280	AND e.nrctremp = 64950) OR (e.cdcooper = 1	AND e.nrdconta = 3958515	AND e.nrctremp = 1330998) OR
(e.cdcooper = 1	AND e.nrdconta = 3958736	AND e.nrctremp = 1520359) OR (e.cdcooper = 1	AND e.nrdconta = 3960269	AND e.nrctremp = 11803) OR
(e.cdcooper = 1	AND e.nrdconta = 3960889	AND e.nrctremp = 457785) OR (e.cdcooper = 1	AND e.nrdconta = 3964230	AND e.nrctremp = 95296) OR
(e.cdcooper = 1	AND e.nrdconta = 3965023	AND e.nrctremp = 639122) OR (e.cdcooper = 1	AND e.nrdconta = 3965686	AND e.nrctremp = 3965686) OR
(e.cdcooper = 1	AND e.nrdconta = 3966860	AND e.nrctremp = 1076088) OR (e.cdcooper = 1	AND e.nrdconta = 3973956	AND e.nrctremp = 822834) OR
(e.cdcooper = 1	AND e.nrdconta = 3974251	AND e.nrctremp = 519992) OR (e.cdcooper = 1	AND e.nrdconta = 3975231	AND e.nrctremp = 703495) OR
(e.cdcooper = 1	AND e.nrdconta = 3977595	AND e.nrctremp = 776319) OR (e.cdcooper = 1	AND e.nrdconta = 3977994	AND e.nrctremp = 804740) OR
(e.cdcooper = 1	AND e.nrdconta = 3979776	AND e.nrctremp = 1146820) OR (e.cdcooper = 1	AND e.nrdconta = 3981789	AND e.nrctremp = 551591) OR
(e.cdcooper = 1	AND e.nrdconta = 3982050	AND e.nrctremp = 1155828) OR (e.cdcooper = 1	AND e.nrdconta = 3983153	AND e.nrctremp = 747091) OR
(e.cdcooper = 1	AND e.nrdconta = 3984400	AND e.nrctremp = 1157434) OR (e.cdcooper = 1	AND e.nrdconta = 3985121	AND e.nrctremp = 127295) OR
(e.cdcooper = 1	AND e.nrdconta = 3989798	AND e.nrctremp = 489261) OR (e.cdcooper = 1	AND e.nrdconta = 3990044	AND e.nrctremp = 1596278) OR
(e.cdcooper = 1	AND e.nrdconta = 3991318	AND e.nrctremp = 3991318) OR (e.cdcooper = 1	AND e.nrdconta = 3991865	AND e.nrctremp = 459201) OR
(e.cdcooper = 1	AND e.nrdconta = 3992063	AND e.nrctremp = 100056) OR (e.cdcooper = 1	AND e.nrdconta = 3993469	AND e.nrctremp = 785802) OR
(e.cdcooper = 1	AND e.nrdconta = 3994392	AND e.nrctremp = 534583) OR (e.cdcooper = 1	AND e.nrdconta = 3997324	AND e.nrctremp = 3997324) OR
(e.cdcooper = 1	AND e.nrdconta = 3998967	AND e.nrctremp = 747412) OR (e.cdcooper = 1	AND e.nrdconta = 4000269	AND e.nrctremp = 908956) OR
(e.cdcooper = 1	AND e.nrdconta = 4001001	AND e.nrctremp = 4001001) OR (e.cdcooper = 1	AND e.nrdconta = 4001818	AND e.nrctremp = 1835393) OR
(e.cdcooper = 1	AND e.nrdconta = 4001893	AND e.nrctremp = 1037553) OR (e.cdcooper = 1	AND e.nrdconta = 4001966	AND e.nrctremp = 166182) OR
(e.cdcooper = 1	AND e.nrdconta = 4002164	AND e.nrctremp = 1161230) OR (e.cdcooper = 1	AND e.nrdconta = 4004523	AND e.nrctremp = 1029747) OR
(e.cdcooper = 1	AND e.nrdconta = 4004817	AND e.nrctremp = 909009) OR (e.cdcooper = 1	AND e.nrdconta = 4005457	AND e.nrctremp = 1252698) OR
(e.cdcooper = 1	AND e.nrdconta = 4005953	AND e.nrctremp = 719057) OR (e.cdcooper = 1	AND e.nrdconta = 4007280	AND e.nrctremp = 1125349) OR
(e.cdcooper = 1	AND e.nrdconta = 4008898	AND e.nrctremp = 704262) OR (e.cdcooper = 1	AND e.nrdconta = 4011678	AND e.nrctremp = 1852998) OR
(e.cdcooper = 1	AND e.nrdconta = 4012070	AND e.nrctremp = 1251146) OR (e.cdcooper = 1	AND e.nrdconta = 4012364	AND e.nrctremp = 4012364) OR
(e.cdcooper = 1	AND e.nrdconta = 4012470	AND e.nrctremp = 604757) OR (e.cdcooper = 1	AND e.nrdconta = 4014189	AND e.nrctremp = 1126154) OR
(e.cdcooper = 1	AND e.nrdconta = 4014367	AND e.nrctremp = 532881) OR (e.cdcooper = 1	AND e.nrdconta = 4016106	AND e.nrctremp = 1031862) OR
(e.cdcooper = 1	AND e.nrdconta = 4016602	AND e.nrctremp = 1619433) OR (e.cdcooper = 1	AND e.nrdconta = 4017668	AND e.nrctremp = 1435220) OR
(e.cdcooper = 1	AND e.nrdconta = 4017870	AND e.nrctremp = 1017950) OR (e.cdcooper = 1	AND e.nrdconta = 4017870	AND e.nrctremp = 1916406) OR
(e.cdcooper = 1	AND e.nrdconta = 4018532	AND e.nrctremp = 788036) OR (e.cdcooper = 1	AND e.nrdconta = 4018672	AND e.nrctremp = 965028) OR
(e.cdcooper = 1	AND e.nrdconta = 4019733	AND e.nrctremp = 1045675) OR (e.cdcooper = 1	AND e.nrdconta = 4019849	AND e.nrctremp = 1109972) OR
(e.cdcooper = 1	AND e.nrdconta = 4021380	AND e.nrctremp = 1610687) OR (e.cdcooper = 1	AND e.nrdconta = 4023404	AND e.nrctremp = 4023404) OR
(e.cdcooper = 1	AND e.nrdconta = 4024060	AND e.nrctremp = 1243879) OR (e.cdcooper = 1	AND e.nrdconta = 4025431	AND e.nrctremp = 1184101) OR
(e.cdcooper = 1	AND e.nrdconta = 4025989	AND e.nrctremp = 4025989) OR (e.cdcooper = 1	AND e.nrdconta = 4027230	AND e.nrctremp = 1049541) OR
(e.cdcooper = 1	AND e.nrdconta = 4028520	AND e.nrctremp = 548381) OR (e.cdcooper = 1	AND e.nrdconta = 4028929	AND e.nrctremp = 731604) OR
(e.cdcooper = 1	AND e.nrdconta = 4029372	AND e.nrctremp = 1226468) OR (e.cdcooper = 1	AND e.nrdconta = 4030176	AND e.nrctremp = 4030176) OR
(e.cdcooper = 1	AND e.nrdconta = 4030508	AND e.nrctremp = 4030508) OR (e.cdcooper = 1	AND e.nrdconta = 4033612	AND e.nrctremp = 700703) OR
(e.cdcooper = 1	AND e.nrdconta = 4033612	AND e.nrctremp = 4033612) OR (e.cdcooper = 1	AND e.nrdconta = 4034139	AND e.nrctremp = 763827) OR
(e.cdcooper = 1	AND e.nrdconta = 4035089	AND e.nrctremp = 695545) OR (e.cdcooper = 1	AND e.nrdconta = 4035135	AND e.nrctremp = 1408029) OR
(e.cdcooper = 1	AND e.nrdconta = 4036387	AND e.nrctremp = 908415) OR (e.cdcooper = 1	AND e.nrdconta = 4036557	AND e.nrctremp = 4036557) OR
(e.cdcooper = 1	AND e.nrdconta = 4037766	AND e.nrctremp = 798482) OR (e.cdcooper = 1	AND e.nrdconta = 4039939	AND e.nrctremp = 979938) OR
(e.cdcooper = 1	AND e.nrdconta = 4042204	AND e.nrctremp = 4042204) OR (e.cdcooper = 1	AND e.nrdconta = 4045289	AND e.nrctremp = 728372) OR
(e.cdcooper = 1	AND e.nrdconta = 4045440	AND e.nrctremp = 888198) OR (e.cdcooper = 1	AND e.nrdconta = 4045521	AND e.nrctremp = 1287109) OR
(e.cdcooper = 1	AND e.nrdconta = 4045955	AND e.nrctremp = 718535) OR (e.cdcooper = 1	AND e.nrdconta = 4046390	AND e.nrctremp = 961629) OR
(e.cdcooper = 1	AND e.nrdconta = 4047222	AND e.nrctremp = 653996) OR (e.cdcooper = 1	AND e.nrdconta = 4049810	AND e.nrctremp = 1596369) OR
(e.cdcooper = 1	AND e.nrdconta = 4050479	AND e.nrctremp = 4050479) OR (e.cdcooper = 1	AND e.nrdconta = 4051726	AND e.nrctremp = 4051726) OR
(e.cdcooper = 1	AND e.nrdconta = 4053320	AND e.nrctremp = 4053320) OR (e.cdcooper = 1	AND e.nrdconta = 4053656	AND e.nrctremp = 2145219) OR
(e.cdcooper = 1	AND e.nrdconta = 4053915	AND e.nrctremp = 4053915) OR (e.cdcooper = 1	AND e.nrdconta = 4055284	AND e.nrctremp = 899454) OR
(e.cdcooper = 1	AND e.nrdconta = 4055616	AND e.nrctremp = 1949609) OR (e.cdcooper = 1	AND e.nrdconta = 4056477	AND e.nrctremp = 4056477) OR
(e.cdcooper = 1	AND e.nrdconta = 4056868	AND e.nrctremp = 1267174) OR (e.cdcooper = 1	AND e.nrdconta = 4058666	AND e.nrctremp = 4058666) OR
(e.cdcooper = 1	AND e.nrdconta = 4062655	AND e.nrctremp = 734743) OR (e.cdcooper = 1	AND e.nrdconta = 4062655	AND e.nrctremp = 4062655) OR
(e.cdcooper = 1	AND e.nrdconta = 4063368	AND e.nrctremp = 4063368) OR (e.cdcooper = 1	AND e.nrdconta = 4063384	AND e.nrctremp = 1629948) OR
(e.cdcooper = 1	AND e.nrdconta = 4063724	AND e.nrctremp = 4063724) OR (e.cdcooper = 1	AND e.nrdconta = 4066065	AND e.nrctremp = 4066065) OR
(e.cdcooper = 1	AND e.nrdconta = 4069285	AND e.nrctremp = 1480576) OR (e.cdcooper = 1	AND e.nrdconta = 4069366	AND e.nrctremp = 712240) OR
(e.cdcooper = 1	AND e.nrdconta = 4069838	AND e.nrctremp = 900929) OR (e.cdcooper = 1	AND e.nrdconta = 4070135	AND e.nrctremp = 4070135) OR
(e.cdcooper = 1	AND e.nrdconta = 4071450	AND e.nrctremp = 1640517) OR (e.cdcooper = 1	AND e.nrdconta = 4071590	AND e.nrctremp = 1040008) OR
(e.cdcooper = 1	AND e.nrdconta = 4072189	AND e.nrctremp = 4072189) OR (e.cdcooper = 1	AND e.nrdconta = 4072677	AND e.nrctremp = 1920811) OR
(e.cdcooper = 1	AND e.nrdconta = 4073304	AND e.nrctremp = 4073304) OR (e.cdcooper = 1	AND e.nrdconta = 4074238	AND e.nrctremp = 714770) OR
(e.cdcooper = 1	AND e.nrdconta = 4074688	AND e.nrctremp = 1343409) OR (e.cdcooper = 1	AND e.nrdconta = 4075021	AND e.nrctremp = 4075021) OR
(e.cdcooper = 1	AND e.nrdconta = 4075854	AND e.nrctremp = 650227) OR (e.cdcooper = 1	AND e.nrdconta = 4077083	AND e.nrctremp = 802407) OR
(e.cdcooper = 1	AND e.nrdconta = 4077490	AND e.nrctremp = 944717) OR (e.cdcooper = 1	AND e.nrdconta = 4077733	AND e.nrctremp = 1724145) OR
(e.cdcooper = 1	AND e.nrdconta = 4078055	AND e.nrctremp = 706273) OR (e.cdcooper = 1	AND e.nrdconta = 4078314	AND e.nrctremp = 814432) OR
(e.cdcooper = 1	AND e.nrdconta = 4078969	AND e.nrctremp = 4078969) OR (e.cdcooper = 1	AND e.nrdconta = 4079000	AND e.nrctremp = 848513) OR
(e.cdcooper = 1	AND e.nrdconta = 4081293	AND e.nrctremp = 4081293) OR (e.cdcooper = 1	AND e.nrdconta = 4082710	AND e.nrctremp = 4082710) OR
(e.cdcooper = 1	AND e.nrdconta = 4083229	AND e.nrctremp = 1072043) OR (e.cdcooper = 1	AND e.nrdconta = 4084144	AND e.nrctremp = 1587106) OR
(e.cdcooper = 1	AND e.nrdconta = 4085078	AND e.nrctremp = 1619158) OR (e.cdcooper = 1	AND e.nrdconta = 4085450	AND e.nrctremp = 4085450) OR
(e.cdcooper = 1	AND e.nrdconta = 4085825	AND e.nrctremp = 4085825) OR (e.cdcooper = 1	AND e.nrdconta = 4087259	AND e.nrctremp = 1916407) OR
(e.cdcooper = 1	AND e.nrdconta = 4088107	AND e.nrctremp = 1144726) OR (e.cdcooper = 1	AND e.nrdconta = 4088662	AND e.nrctremp = 676147) OR
(e.cdcooper = 1	AND e.nrdconta = 4091370	AND e.nrctremp = 644649) OR (e.cdcooper = 1	AND e.nrdconta = 4373901	AND e.nrctremp = 1144004) OR
(e.cdcooper = 1	AND e.nrdconta = 4394984	AND e.nrctremp = 873552) OR (e.cdcooper = 1	AND e.nrdconta = 4397258	AND e.nrctremp = 507126) OR
(e.cdcooper = 1	AND e.nrdconta = 4399315	AND e.nrctremp = 904574) OR (e.cdcooper = 1	AND e.nrdconta = 4996259	AND e.nrctremp = 964350) OR
(e.cdcooper = 1	AND e.nrdconta = 5533120	AND e.nrctremp = 1227004) OR (e.cdcooper = 1	AND e.nrdconta = 6000789	AND e.nrctremp = 924444) OR
(e.cdcooper = 1	AND e.nrdconta = 6004148	AND e.nrctremp = 387852) OR (e.cdcooper = 1	AND e.nrdconta = 6004369	AND e.nrctremp = 1227497) OR
(e.cdcooper = 1	AND e.nrdconta = 6004415	AND e.nrctremp = 6004415) OR (e.cdcooper = 1	AND e.nrdconta = 6005268	AND e.nrctremp = 461955) OR
(e.cdcooper = 1	AND e.nrdconta = 6008836	AND e.nrctremp = 820408) OR (e.cdcooper = 1	AND e.nrdconta = 6010679	AND e.nrctremp = 6010679) OR
(e.cdcooper = 1	AND e.nrdconta = 6010687	AND e.nrctremp = 121658) OR (e.cdcooper = 1	AND e.nrdconta = 6010687	AND e.nrctremp = 469742) OR
(e.cdcooper = 1	AND e.nrdconta = 6010687	AND e.nrctremp = 469765) OR (e.cdcooper = 1	AND e.nrdconta = 6010784	AND e.nrctremp = 6010784) OR
(e.cdcooper = 1	AND e.nrdconta = 6011764	AND e.nrctremp = 1358299) OR (e.cdcooper = 1	AND e.nrdconta = 6016545	AND e.nrctremp = 1477501) OR
(e.cdcooper = 1	AND e.nrdconta = 6020305	AND e.nrctremp = 1302393) OR (e.cdcooper = 1	AND e.nrdconta = 6020780	AND e.nrctremp = 6020780) OR
(e.cdcooper = 1	AND e.nrdconta = 6022030	AND e.nrctremp = 95200) OR (e.cdcooper = 1	AND e.nrdconta = 6022596	AND e.nrctremp = 29646) OR
(e.cdcooper = 1	AND e.nrdconta = 6025390	AND e.nrctremp = 1120023) OR (e.cdcooper = 1	AND e.nrdconta = 6026249	AND e.nrctremp = 1156884) OR
(e.cdcooper = 1	AND e.nrdconta = 6029221	AND e.nrctremp = 570260) OR (e.cdcooper = 1	AND e.nrdconta = 6029493	AND e.nrctremp = 953657) OR
(e.cdcooper = 1	AND e.nrdconta = 6034438	AND e.nrctremp = 1289318) OR (e.cdcooper = 1	AND e.nrdconta = 6034640	AND e.nrctremp = 1006524) OR
(e.cdcooper = 1	AND e.nrdconta = 6036228	AND e.nrctremp = 6036228) OR (e.cdcooper = 1	AND e.nrdconta = 6037712	AND e.nrctremp = 727749) OR
(e.cdcooper = 1	AND e.nrdconta = 6038085	AND e.nrctremp = 121120) OR (e.cdcooper = 1	AND e.nrdconta = 6039081	AND e.nrctremp = 1168749) OR
(e.cdcooper = 1	AND e.nrdconta = 6039839	AND e.nrctremp = 844874) OR (e.cdcooper = 1	AND e.nrdconta = 6042848	AND e.nrctremp = 642682) OR
(e.cdcooper = 1	AND e.nrdconta = 6046622	AND e.nrctremp = 43099) OR (e.cdcooper = 1	AND e.nrdconta = 6046622	AND e.nrctremp = 174339) OR
(e.cdcooper = 1	AND e.nrdconta = 6049940	AND e.nrctremp = 477385) OR (e.cdcooper = 1	AND e.nrdconta = 6052711	AND e.nrctremp = 1379255) OR
(e.cdcooper = 1	AND e.nrdconta = 6053319	AND e.nrctremp = 1445634) OR (e.cdcooper = 1	AND e.nrdconta = 6055230	AND e.nrctremp = 1421344) OR
(e.cdcooper = 1	AND e.nrdconta = 6057365	AND e.nrctremp = 655792) OR (e.cdcooper = 1	AND e.nrdconta = 6058272	AND e.nrctremp = 482983) OR
(e.cdcooper = 1	AND e.nrdconta = 6065724	AND e.nrctremp = 550982) OR (e.cdcooper = 1	AND e.nrdconta = 6066690	AND e.nrctremp = 6066690) OR
(e.cdcooper = 1	AND e.nrdconta = 6068146	AND e.nrctremp = 778018) OR (e.cdcooper = 1	AND e.nrdconta = 6070876	AND e.nrctremp = 638859) OR
(e.cdcooper = 1	AND e.nrdconta = 6072127	AND e.nrctremp = 40969) OR (e.cdcooper = 1	AND e.nrdconta = 6073646	AND e.nrctremp = 455914) OR
(e.cdcooper = 1	AND e.nrdconta = 6073751	AND e.nrctremp = 1183709) OR (e.cdcooper = 1	AND e.nrdconta = 6074707	AND e.nrctremp = 729585) OR
(e.cdcooper = 1	AND e.nrdconta = 6079156	AND e.nrctremp = 108325) OR (e.cdcooper = 1	AND e.nrdconta = 6079229	AND e.nrctremp = 797492) OR
(e.cdcooper = 1	AND e.nrdconta = 6079474	AND e.nrctremp = 962488) OR (e.cdcooper = 1	AND e.nrdconta = 6079938	AND e.nrctremp = 795783) OR
(e.cdcooper = 1	AND e.nrdconta = 6083455	AND e.nrctremp = 689697) OR (e.cdcooper = 1	AND e.nrdconta = 6084761	AND e.nrctremp = 943599) OR
(e.cdcooper = 1	AND e.nrdconta = 6087825	AND e.nrctremp = 1139185) OR (e.cdcooper = 1	AND e.nrdconta = 6087876	AND e.nrctremp = 175270) OR
(e.cdcooper = 1	AND e.nrdconta = 6089100	AND e.nrctremp = 842742) OR (e.cdcooper = 1	AND e.nrdconta = 6090214	AND e.nrctremp = 669857) OR
(e.cdcooper = 1	AND e.nrdconta = 6090249	AND e.nrctremp = 6090249) OR (e.cdcooper = 1	AND e.nrdconta = 6090427	AND e.nrctremp = 324782) OR
(e.cdcooper = 1	AND e.nrdconta = 6091750	AND e.nrctremp = 1095979) OR (e.cdcooper = 1	AND e.nrdconta = 6092900	AND e.nrctremp = 603533) OR
(e.cdcooper = 1	AND e.nrdconta = 6095135	AND e.nrctremp = 1006380) OR (e.cdcooper = 1	AND e.nrdconta = 6121110	AND e.nrctremp = 590171) OR
(e.cdcooper = 1	AND e.nrdconta = 6121578	AND e.nrctremp = 894111) OR (e.cdcooper = 1	AND e.nrdconta = 6121730	AND e.nrctremp = 434688) OR
(e.cdcooper = 1	AND e.nrdconta = 6121837	AND e.nrctremp = 6121837) OR (e.cdcooper = 1	AND e.nrdconta = 6128335	AND e.nrctremp = 1157961) OR
(e.cdcooper = 1	AND e.nrdconta = 6128920	AND e.nrctremp = 621014) OR (e.cdcooper = 1	AND e.nrdconta = 6129013	AND e.nrctremp = 383419) OR
(e.cdcooper = 1	AND e.nrdconta = 6131182	AND e.nrctremp = 6131182) OR (e.cdcooper = 1	AND e.nrdconta = 6131727	AND e.nrctremp = 545928) OR
(e.cdcooper = 1	AND e.nrdconta = 6133479	AND e.nrctremp = 337393) OR (e.cdcooper = 1	AND e.nrdconta = 6134416	AND e.nrctremp = 392436) OR
(e.cdcooper = 1	AND e.nrdconta = 6134416	AND e.nrctremp = 1165336) OR (e.cdcooper = 1	AND e.nrdconta = 6134815	AND e.nrctremp = 1027137) OR
(e.cdcooper = 1	AND e.nrdconta = 6137385	AND e.nrctremp = 6137385) OR (e.cdcooper = 1	AND e.nrdconta = 6137857	AND e.nrctremp = 120751) OR
(e.cdcooper = 1	AND e.nrdconta = 6138942	AND e.nrctremp = 849604) OR (e.cdcooper = 1	AND e.nrdconta = 6139655	AND e.nrctremp = 542039) OR
(e.cdcooper = 1	AND e.nrdconta = 6146279	AND e.nrctremp = 1264389) OR (e.cdcooper = 1	AND e.nrdconta = 6148093	AND e.nrctremp = 340073) OR
(e.cdcooper = 1	AND e.nrdconta = 6153887	AND e.nrctremp = 935601) OR (e.cdcooper = 1	AND e.nrdconta = 6155219	AND e.nrctremp = 110439) OR
(e.cdcooper = 1	AND e.nrdconta = 6155391	AND e.nrctremp = 765677) OR (e.cdcooper = 1	AND e.nrdconta = 6159060	AND e.nrctremp = 1144465) OR
(e.cdcooper = 1	AND e.nrdconta = 6164846	AND e.nrctremp = 460590) OR (e.cdcooper = 1	AND e.nrdconta = 6170102	AND e.nrctremp = 1457747) OR
(e.cdcooper = 1	AND e.nrdconta = 6170110	AND e.nrctremp = 21558) OR (e.cdcooper = 1	AND e.nrdconta = 6170471	AND e.nrctremp = 1647104) OR
(e.cdcooper = 1	AND e.nrdconta = 6171192	AND e.nrctremp = 444268) OR (e.cdcooper = 1	AND e.nrdconta = 6171281	AND e.nrctremp = 89359) OR
(e.cdcooper = 1	AND e.nrdconta = 6171478	AND e.nrctremp = 6171478) OR (e.cdcooper = 1	AND e.nrdconta = 6171710	AND e.nrctremp = 1124142) OR
(e.cdcooper = 1	AND e.nrdconta = 6174310	AND e.nrctremp = 6174310) OR (e.cdcooper = 1	AND e.nrdconta = 6175198	AND e.nrctremp = 196519) OR
(e.cdcooper = 1	AND e.nrdconta = 6176518	AND e.nrctremp = 166161) OR (e.cdcooper = 1	AND e.nrdconta = 6177336	AND e.nrctremp = 682228) OR
(e.cdcooper = 1	AND e.nrdconta = 6178472	AND e.nrctremp = 114984) OR (e.cdcooper = 1	AND e.nrdconta = 6180787	AND e.nrctremp = 585867) OR
(e.cdcooper = 1	AND e.nrdconta = 6181872	AND e.nrctremp = 1625884) OR (e.cdcooper = 1	AND e.nrdconta = 6182844	AND e.nrctremp = 964546) OR
(e.cdcooper = 1	AND e.nrdconta = 6183425	AND e.nrctremp = 941746) OR (e.cdcooper = 1	AND e.nrdconta = 6184570	AND e.nrctremp = 1920853) OR
(e.cdcooper = 1	AND e.nrdconta = 6187374	AND e.nrctremp = 6187374) OR (e.cdcooper = 1	AND e.nrdconta = 6187404	AND e.nrctremp = 768892) OR
(e.cdcooper = 1	AND e.nrdconta = 6187617	AND e.nrctremp = 119927) OR (e.cdcooper = 1	AND e.nrdconta = 6187617	AND e.nrctremp = 524068) OR
(e.cdcooper = 1	AND e.nrdconta = 6188125	AND e.nrctremp = 41911) OR (e.cdcooper = 1	AND e.nrdconta = 6188974	AND e.nrctremp = 466868) OR
(e.cdcooper = 1	AND e.nrdconta = 6189369	AND e.nrctremp = 576410) OR (e.cdcooper = 1	AND e.nrdconta = 6190324	AND e.nrctremp = 6190324) OR
(e.cdcooper = 1	AND e.nrdconta = 6193560	AND e.nrctremp = 1053759) OR (e.cdcooper = 1	AND e.nrdconta = 6193560	AND e.nrctremp = 1536505) OR
(e.cdcooper = 1	AND e.nrdconta = 6193846	AND e.nrctremp = 138499) OR (e.cdcooper = 1	AND e.nrdconta = 6193943	AND e.nrctremp = 1428350) OR
(e.cdcooper = 1	AND e.nrdconta = 6194818	AND e.nrctremp = 1219228) OR (e.cdcooper = 1	AND e.nrdconta = 6197590	AND e.nrctremp = 1111515) OR
(e.cdcooper = 1	AND e.nrdconta = 6197728	AND e.nrctremp = 691023) OR (e.cdcooper = 1	AND e.nrdconta = 6199399	AND e.nrctremp = 1375361) OR
(e.cdcooper = 1	AND e.nrdconta = 6199631	AND e.nrctremp = 1911376) OR (e.cdcooper = 1	AND e.nrdconta = 6200222	AND e.nrctremp = 55664) OR
(e.cdcooper = 1	AND e.nrdconta = 6201083	AND e.nrctremp = 6201083) OR (e.cdcooper = 1	AND e.nrdconta = 6201342	AND e.nrctremp = 819364) OR
(e.cdcooper = 1	AND e.nrdconta = 6201482	AND e.nrctremp = 915461) OR (e.cdcooper = 1	AND e.nrdconta = 6202276	AND e.nrctremp = 1474476) OR
(e.cdcooper = 1	AND e.nrdconta = 6202845	AND e.nrctremp = 932627) OR (e.cdcooper = 1	AND e.nrdconta = 6203671	AND e.nrctremp = 1146833) OR
(e.cdcooper = 1	AND e.nrdconta = 6204597	AND e.nrctremp = 577539) OR (e.cdcooper = 1	AND e.nrdconta = 6206000	AND e.nrctremp = 1433003) OR
(e.cdcooper = 1	AND e.nrdconta = 6207219	AND e.nrctremp = 249051) OR (e.cdcooper = 1	AND e.nrdconta = 6207855	AND e.nrctremp = 600814) OR
(e.cdcooper = 1	AND e.nrdconta = 6207987	AND e.nrctremp = 786231) OR (e.cdcooper = 1	AND e.nrdconta = 6208657	AND e.nrctremp = 1114078) OR
(e.cdcooper = 1	AND e.nrdconta = 6208819	AND e.nrctremp = 803106) OR (e.cdcooper = 1	AND e.nrdconta = 6208894	AND e.nrctremp = 55393) OR
(e.cdcooper = 1	AND e.nrdconta = 6211089	AND e.nrctremp = 6211089) OR (e.cdcooper = 1	AND e.nrdconta = 6211127	AND e.nrctremp = 6211127) OR
(e.cdcooper = 1	AND e.nrdconta = 6213731	AND e.nrctremp = 1208669) OR (e.cdcooper = 1	AND e.nrdconta = 6217141	AND e.nrctremp = 1382293) OR
(e.cdcooper = 1	AND e.nrdconta = 6220495	AND e.nrctremp = 117631) OR (e.cdcooper = 1	AND e.nrdconta = 6222366	AND e.nrctremp = 127365) OR
(e.cdcooper = 1	AND e.nrdconta = 6223940	AND e.nrctremp = 298903) OR (e.cdcooper = 1	AND e.nrdconta = 6224458	AND e.nrctremp = 892836) OR
(e.cdcooper = 1	AND e.nrdconta = 6225926	AND e.nrctremp = 748371) OR (e.cdcooper = 1	AND e.nrdconta = 6226981	AND e.nrctremp = 769151) OR
(e.cdcooper = 1	AND e.nrdconta = 6228003	AND e.nrctremp = 769683) OR (e.cdcooper = 1	AND e.nrdconta = 6230490	AND e.nrctremp = 985752) OR
(e.cdcooper = 1	AND e.nrdconta = 6230814	AND e.nrctremp = 98962) OR (e.cdcooper = 1	AND e.nrdconta = 6231080	AND e.nrctremp = 21049) OR
(e.cdcooper = 1	AND e.nrdconta = 6231101	AND e.nrctremp = 647337) OR (e.cdcooper = 1	AND e.nrdconta = 6231195	AND e.nrctremp = 27854) OR
(e.cdcooper = 1	AND e.nrdconta = 6232779	AND e.nrctremp = 121609) OR (e.cdcooper = 1	AND e.nrdconta = 6236901	AND e.nrctremp = 870350) OR
(e.cdcooper = 1	AND e.nrdconta = 6237312	AND e.nrctremp = 6237312) OR (e.cdcooper = 1	AND e.nrdconta = 6237320	AND e.nrctremp = 959015) OR
(e.cdcooper = 1	AND e.nrdconta = 6238572	AND e.nrctremp = 674278) OR (e.cdcooper = 1	AND e.nrdconta = 6240356	AND e.nrctremp = 6240356) OR
(e.cdcooper = 1	AND e.nrdconta = 6240682	AND e.nrctremp = 527211) OR (e.cdcooper = 1	AND e.nrdconta = 6243738	AND e.nrctremp = 999874) OR
(e.cdcooper = 1	AND e.nrdconta = 6243860	AND e.nrctremp = 757522) OR (e.cdcooper = 1	AND e.nrdconta = 6243940	AND e.nrctremp = 634539) OR
(e.cdcooper = 1	AND e.nrdconta = 6248233	AND e.nrctremp = 646651) OR (e.cdcooper = 1	AND e.nrdconta = 6248322	AND e.nrctremp = 740640) OR
(e.cdcooper = 1	AND e.nrdconta = 6248780	AND e.nrctremp = 824780) OR (e.cdcooper = 1	AND e.nrdconta = 6250653	AND e.nrctremp = 127982) OR
(e.cdcooper = 1	AND e.nrdconta = 6251218	AND e.nrctremp = 1285788) OR (e.cdcooper = 1	AND e.nrdconta = 6251668	AND e.nrctremp = 1377015) OR
(e.cdcooper = 1	AND e.nrdconta = 6252656	AND e.nrctremp = 1182547) OR (e.cdcooper = 1	AND e.nrdconta = 6252850	AND e.nrctremp = 8940) OR
(e.cdcooper = 1	AND e.nrdconta = 6253164	AND e.nrctremp = 798529) OR (e.cdcooper = 1	AND e.nrdconta = 6253482	AND e.nrctremp = 993659) OR
(e.cdcooper = 1	AND e.nrdconta = 6253539	AND e.nrctremp = 765136) OR (e.cdcooper = 1	AND e.nrdconta = 6255833	AND e.nrctremp = 1284706) OR
(e.cdcooper = 1	AND e.nrdconta = 6256449	AND e.nrctremp = 548241) OR (e.cdcooper = 1	AND e.nrdconta = 6257062	AND e.nrctremp = 1218591) OR
(e.cdcooper = 1	AND e.nrdconta = 6257550	AND e.nrctremp = 6257550) OR (e.cdcooper = 1	AND e.nrdconta = 6258328	AND e.nrctremp = 121744) OR
(e.cdcooper = 1	AND e.nrdconta = 6259014	AND e.nrctremp = 6259014) OR (e.cdcooper = 1	AND e.nrdconta = 6259057	AND e.nrctremp = 415913) OR
(e.cdcooper = 1	AND e.nrdconta = 6259103	AND e.nrctremp = 6259103) OR (e.cdcooper = 1	AND e.nrdconta = 6259529	AND e.nrctremp = 19772) OR
(e.cdcooper = 1	AND e.nrdconta = 6260543	AND e.nrctremp = 1260100) OR (e.cdcooper = 1	AND e.nrdconta = 6260977	AND e.nrctremp = 1541897) OR
(e.cdcooper = 1	AND e.nrdconta = 6261396	AND e.nrctremp = 142938) OR (e.cdcooper = 1	AND e.nrdconta = 6263470	AND e.nrctremp = 1153110) OR
(e.cdcooper = 1	AND e.nrdconta = 6263470	AND e.nrctremp = 1921371) OR (e.cdcooper = 1	AND e.nrdconta = 6263836	AND e.nrctremp = 95136) OR
(e.cdcooper = 1	AND e.nrdconta = 6263925	AND e.nrctremp = 698037) OR (e.cdcooper = 1	AND e.nrdconta = 6264476	AND e.nrctremp = 508651) OR
(e.cdcooper = 1	AND e.nrdconta = 6264476	AND e.nrctremp = 559744) OR (e.cdcooper = 1	AND e.nrdconta = 6265677	AND e.nrctremp = 174344) OR
(e.cdcooper = 1	AND e.nrdconta = 6266096	AND e.nrctremp = 1586729) OR (e.cdcooper = 1	AND e.nrdconta = 6270530	AND e.nrctremp = 941999) OR
(e.cdcooper = 1	AND e.nrdconta = 6271081	AND e.nrctremp = 1177445) OR (e.cdcooper = 1	AND e.nrdconta = 6271340	AND e.nrctremp = 700413) OR
(e.cdcooper = 1	AND e.nrdconta = 6271456	AND e.nrctremp = 6271456) OR (e.cdcooper = 1	AND e.nrdconta = 6273890	AND e.nrctremp = 384466) OR
(e.cdcooper = 1	AND e.nrdconta = 6274234	AND e.nrctremp = 31352) OR (e.cdcooper = 1	AND e.nrdconta = 6274277	AND e.nrctremp = 31185) OR
(e.cdcooper = 1	AND e.nrdconta = 6279015	AND e.nrctremp = 1150485) OR (e.cdcooper = 1	AND e.nrdconta = 6280560	AND e.nrctremp = 364554) OR
(e.cdcooper = 1	AND e.nrdconta = 6280749	AND e.nrctremp = 1453349) OR (e.cdcooper = 1	AND e.nrdconta = 6281710	AND e.nrctremp = 1347362) OR
(e.cdcooper = 1	AND e.nrdconta = 6282580	AND e.nrctremp = 1151664) OR (e.cdcooper = 1	AND e.nrdconta = 6284620	AND e.nrctremp = 1476988) OR
(e.cdcooper = 1	AND e.nrdconta = 6284710	AND e.nrctremp = 968956) OR (e.cdcooper = 1	AND e.nrdconta = 6285414	AND e.nrctremp = 6285414) OR
(e.cdcooper = 1	AND e.nrdconta = 6285490	AND e.nrctremp = 333006) OR (e.cdcooper = 1	AND e.nrdconta = 6285490	AND e.nrctremp = 648671) OR
(e.cdcooper = 1	AND e.nrdconta = 6286720	AND e.nrctremp = 1345931) OR (e.cdcooper = 1	AND e.nrdconta = 6286909	AND e.nrctremp = 706258) OR
(e.cdcooper = 1	AND e.nrdconta = 6287506	AND e.nrctremp = 6287506) OR (e.cdcooper = 1	AND e.nrdconta = 6287514	AND e.nrctremp = 617535) OR
(e.cdcooper = 1	AND e.nrdconta = 6292135	AND e.nrctremp = 727345) OR (e.cdcooper = 1	AND e.nrdconta = 6293751	AND e.nrctremp = 1191503) OR
(e.cdcooper = 1	AND e.nrdconta = 6294600	AND e.nrctremp = 11442) OR (e.cdcooper = 1	AND e.nrdconta = 6295240	AND e.nrctremp = 920994) OR
(e.cdcooper = 1	AND e.nrdconta = 6297889	AND e.nrctremp = 547232) OR (e.cdcooper = 1	AND e.nrdconta = 6297960	AND e.nrctremp = 648147) OR
(e.cdcooper = 1	AND e.nrdconta = 6299156	AND e.nrctremp = 6299156) OR (e.cdcooper = 1	AND e.nrdconta = 6299350	AND e.nrctremp = 349796) OR
(e.cdcooper = 1	AND e.nrdconta = 6299938	AND e.nrctremp = 966580) OR (e.cdcooper = 1	AND e.nrdconta = 6302319	AND e.nrctremp = 735991) OR
(e.cdcooper = 1	AND e.nrdconta = 6307710	AND e.nrctremp = 1241628) OR (e.cdcooper = 1	AND e.nrdconta = 6309607	AND e.nrctremp = 390240) OR
(e.cdcooper = 1	AND e.nrdconta = 6312179	AND e.nrctremp = 1026039) OR (e.cdcooper = 1	AND e.nrdconta = 6315119	AND e.nrctremp = 322673) OR
(e.cdcooper = 1	AND e.nrdconta = 6315445	AND e.nrctremp = 1417294) OR (e.cdcooper = 1	AND e.nrdconta = 6322336	AND e.nrctremp = 146995) OR
(e.cdcooper = 1	AND e.nrdconta = 6325440	AND e.nrctremp = 927796) OR (e.cdcooper = 1	AND e.nrdconta = 6326374	AND e.nrctremp = 1231953) OR
(e.cdcooper = 1	AND e.nrdconta = 6328113	AND e.nrctremp = 11627) OR (e.cdcooper = 1	AND e.nrdconta = 6329535	AND e.nrctremp = 1587415) OR
(e.cdcooper = 1	AND e.nrdconta = 6331629	AND e.nrctremp = 181544) OR (e.cdcooper = 1	AND e.nrdconta = 6335217	AND e.nrctremp = 1105247) OR
(e.cdcooper = 1	AND e.nrdconta = 6338844	AND e.nrctremp = 497042) OR (e.cdcooper = 1	AND e.nrdconta = 6341314	AND e.nrctremp = 1551281) OR
(e.cdcooper = 1	AND e.nrdconta = 6342370	AND e.nrctremp = 37447) OR (e.cdcooper = 1	AND e.nrdconta = 6344070	AND e.nrctremp = 773687) OR
(e.cdcooper = 1	AND e.nrdconta = 6345174	AND e.nrctremp = 1715835) OR (e.cdcooper = 1	AND e.nrdconta = 6345670	AND e.nrctremp = 826164) OR
(e.cdcooper = 1	AND e.nrdconta = 6347380	AND e.nrctremp = 248921) OR (e.cdcooper = 1	AND e.nrdconta = 6349919	AND e.nrctremp = 495762) OR
(e.cdcooper = 1	AND e.nrdconta = 6349951	AND e.nrctremp = 145012) OR (e.cdcooper = 1	AND e.nrdconta = 6350836	AND e.nrctremp = 655870) OR
(e.cdcooper = 1	AND e.nrdconta = 6350968	AND e.nrctremp = 1402693) OR (e.cdcooper = 1	AND e.nrdconta = 6358217	AND e.nrctremp = 834081) OR
(e.cdcooper = 1	AND e.nrdconta = 6360602	AND e.nrctremp = 1583792) OR (e.cdcooper = 1	AND e.nrdconta = 6361447	AND e.nrctremp = 1336825) OR
(e.cdcooper = 1	AND e.nrdconta = 6362583	AND e.nrctremp = 838321) OR (e.cdcooper = 1	AND e.nrdconta = 6362583	AND e.nrctremp = 2194852) OR
(e.cdcooper = 1	AND e.nrdconta = 6363830	AND e.nrctremp = 760429) OR (e.cdcooper = 1	AND e.nrdconta = 6363962	AND e.nrctremp = 720126) OR
(e.cdcooper = 1	AND e.nrdconta = 6364802	AND e.nrctremp = 576270) OR (e.cdcooper = 1	AND e.nrdconta = 6365213	AND e.nrctremp = 974515) OR
(e.cdcooper = 1	AND e.nrdconta = 6366457	AND e.nrctremp = 828912) OR (e.cdcooper = 1	AND e.nrdconta = 6372350	AND e.nrctremp = 774621) OR
(e.cdcooper = 1	AND e.nrdconta = 6373917	AND e.nrctremp = 467741) OR (e.cdcooper = 1	AND e.nrdconta = 6374840	AND e.nrctremp = 630589) OR
(e.cdcooper = 1	AND e.nrdconta = 6377483	AND e.nrctremp = 639063) OR (e.cdcooper = 1	AND e.nrdconta = 6379222	AND e.nrctremp = 387005) OR
(e.cdcooper = 1	AND e.nrdconta = 6380107	AND e.nrctremp = 564356) OR (e.cdcooper = 1	AND e.nrdconta = 6380417	AND e.nrctremp = 748436) OR
(e.cdcooper = 1	AND e.nrdconta = 6380921	AND e.nrctremp = 780423) OR (e.cdcooper = 1	AND e.nrdconta = 6381286	AND e.nrctremp = 805671) OR
(e.cdcooper = 1	AND e.nrdconta = 6383033	AND e.nrctremp = 1219057) OR (e.cdcooper = 1	AND e.nrdconta = 6384315	AND e.nrctremp = 6384315) OR
(e.cdcooper = 1	AND e.nrdconta = 6386890	AND e.nrctremp = 11310) OR (e.cdcooper = 1	AND e.nrdconta = 6387810	AND e.nrctremp = 6387810) OR
(e.cdcooper = 1	AND e.nrdconta = 6387985	AND e.nrctremp = 979859) OR (e.cdcooper = 1	AND e.nrdconta = 6388485	AND e.nrctremp = 762787) OR
(e.cdcooper = 1	AND e.nrdconta = 6388914	AND e.nrctremp = 1080429) OR (e.cdcooper = 1	AND e.nrdconta = 6389759	AND e.nrctremp = 643425) OR
(e.cdcooper = 1	AND e.nrdconta = 6394892	AND e.nrctremp = 958271) OR (e.cdcooper = 1	AND e.nrdconta = 6395040	AND e.nrctremp = 483188) OR
(e.cdcooper = 1	AND e.nrdconta = 6395376	AND e.nrctremp = 718467) OR (e.cdcooper = 1	AND e.nrdconta = 6395988	AND e.nrctremp = 506570) OR
(e.cdcooper = 1	AND e.nrdconta = 6396542	AND e.nrctremp = 922636) OR (e.cdcooper = 1	AND e.nrdconta = 6397980	AND e.nrctremp = 308145) OR
(e.cdcooper = 1	AND e.nrdconta = 6398588	AND e.nrctremp = 884392) OR (e.cdcooper = 1	AND e.nrdconta = 6400388	AND e.nrctremp = 586582) OR
(e.cdcooper = 1	AND e.nrdconta = 6401651	AND e.nrctremp = 817496) OR (e.cdcooper = 1	AND e.nrdconta = 6402054	AND e.nrctremp = 96782) OR
(e.cdcooper = 1	AND e.nrdconta = 6405541	AND e.nrctremp = 1336230) OR (e.cdcooper = 1	AND e.nrdconta = 6405550	AND e.nrctremp = 1296810) OR
(e.cdcooper = 1	AND e.nrdconta = 6408621	AND e.nrctremp = 67734) OR (e.cdcooper = 1	AND e.nrdconta = 6410561	AND e.nrctremp = 622971) OR
(e.cdcooper = 1	AND e.nrdconta = 6410642	AND e.nrctremp = 109474) OR (e.cdcooper = 1	AND e.nrdconta = 6410758	AND e.nrctremp = 686519) OR
(e.cdcooper = 1	AND e.nrdconta = 6411088	AND e.nrctremp = 1131756) OR (e.cdcooper = 1	AND e.nrdconta = 6416063	AND e.nrctremp = 6416063) OR
(e.cdcooper = 1	AND e.nrdconta = 6416462	AND e.nrctremp = 538091) OR (e.cdcooper = 1	AND e.nrdconta = 6416519	AND e.nrctremp = 1696352) OR
(e.cdcooper = 1	AND e.nrdconta = 6420389	AND e.nrctremp = 932373) OR (e.cdcooper = 1	AND e.nrdconta = 6421172	AND e.nrctremp = 710452) OR
(e.cdcooper = 1	AND e.nrdconta = 6422152	AND e.nrctremp = 6422152) OR (e.cdcooper = 1	AND e.nrdconta = 6422969	AND e.nrctremp = 6422969) OR
(e.cdcooper = 1	AND e.nrdconta = 6423396	AND e.nrctremp = 6423396) OR (e.cdcooper = 1	AND e.nrdconta = 6424058	AND e.nrctremp = 619942) OR
(e.cdcooper = 1	AND e.nrdconta = 6425887	AND e.nrctremp = 697242) OR (e.cdcooper = 1	AND e.nrdconta = 6426646	AND e.nrctremp = 185193) OR
(e.cdcooper = 1	AND e.nrdconta = 6427014	AND e.nrctremp = 673394) OR (e.cdcooper = 1	AND e.nrdconta = 6427952	AND e.nrctremp = 982105) OR
(e.cdcooper = 1	AND e.nrdconta = 6428592	AND e.nrctremp = 353399) OR (e.cdcooper = 1	AND e.nrdconta = 6428606	AND e.nrctremp = 114003) OR
(e.cdcooper = 1	AND e.nrdconta = 6428606	AND e.nrctremp = 691341) OR (e.cdcooper = 1	AND e.nrdconta = 6429904	AND e.nrctremp = 764019) OR
(e.cdcooper = 1	AND e.nrdconta = 6430473	AND e.nrctremp = 1033589) OR (e.cdcooper = 1	AND e.nrdconta = 6430589	AND e.nrctremp = 1171408) OR
(e.cdcooper = 1	AND e.nrdconta = 6430627	AND e.nrctremp = 6430627) OR (e.cdcooper = 1	AND e.nrdconta = 6430945	AND e.nrctremp = 1378022) OR
(e.cdcooper = 1	AND e.nrdconta = 6439802	AND e.nrctremp = 134500) OR (e.cdcooper = 1	AND e.nrdconta = 6441602	AND e.nrctremp = 890411) OR
(e.cdcooper = 1	AND e.nrdconta = 6444032	AND e.nrctremp = 685225) OR (e.cdcooper = 1	AND e.nrdconta = 6444415	AND e.nrctremp = 70307) OR
(e.cdcooper = 1	AND e.nrdconta = 6444849	AND e.nrctremp = 1794648) OR (e.cdcooper = 1	AND e.nrdconta = 6445730	AND e.nrctremp = 654160) OR
(e.cdcooper = 1	AND e.nrdconta = 6446841	AND e.nrctremp = 6446841) OR (e.cdcooper = 1	AND e.nrdconta = 6448801	AND e.nrctremp = 143952) OR
(e.cdcooper = 1	AND e.nrdconta = 6450075	AND e.nrctremp = 1440351) OR (e.cdcooper = 1	AND e.nrdconta = 6451780	AND e.nrctremp = 169794) OR
(e.cdcooper = 1	AND e.nrdconta = 6452779	AND e.nrctremp = 840604) OR (e.cdcooper = 1	AND e.nrdconta = 6457207	AND e.nrctremp = 875900) OR
(e.cdcooper = 1	AND e.nrdconta = 6462782	AND e.nrctremp = 510724) OR (e.cdcooper = 1	AND e.nrdconta = 6464173	AND e.nrctremp = 1538098) OR
(e.cdcooper = 1	AND e.nrdconta = 6464505	AND e.nrctremp = 6464505) OR (e.cdcooper = 1	AND e.nrdconta = 6464971	AND e.nrctremp = 842823) OR
(e.cdcooper = 1	AND e.nrdconta = 6465560	AND e.nrctremp = 137159) OR (e.cdcooper = 1	AND e.nrdconta = 6470289	AND e.nrctremp = 194329) OR
(e.cdcooper = 1	AND e.nrdconta = 6470823	AND e.nrctremp = 1251155) OR (e.cdcooper = 1	AND e.nrdconta = 6471048	AND e.nrctremp = 6471048) OR
(e.cdcooper = 1	AND e.nrdconta = 6472532	AND e.nrctremp = 83114) OR (e.cdcooper = 1	AND e.nrdconta = 6472761	AND e.nrctremp = 606647) OR
(e.cdcooper = 1	AND e.nrdconta = 6473873	AND e.nrctremp = 493161) OR (e.cdcooper = 1	AND e.nrdconta = 6474802	AND e.nrctremp = 340873) OR
(e.cdcooper = 1	AND e.nrdconta = 6475752	AND e.nrctremp = 1047315) OR (e.cdcooper = 1	AND e.nrdconta = 6476830	AND e.nrctremp = 291551) OR
(e.cdcooper = 1	AND e.nrdconta = 6480934	AND e.nrctremp = 1271931) OR (e.cdcooper = 1	AND e.nrdconta = 6481612	AND e.nrctremp = 1309207) OR
(e.cdcooper = 1	AND e.nrdconta = 6482295	AND e.nrctremp = 983798) OR (e.cdcooper = 1	AND e.nrdconta = 6483666	AND e.nrctremp = 796746) OR
(e.cdcooper = 1	AND e.nrdconta = 6483682	AND e.nrctremp = 132668) OR (e.cdcooper = 1	AND e.nrdconta = 6486096	AND e.nrctremp = 45658) OR
(e.cdcooper = 1	AND e.nrdconta = 6487670	AND e.nrctremp = 333311) OR (e.cdcooper = 1	AND e.nrdconta = 6488137	AND e.nrctremp = 466835) OR
(e.cdcooper = 1	AND e.nrdconta = 6488137	AND e.nrctremp = 496914) OR (e.cdcooper = 1	AND e.nrdconta = 6493289	AND e.nrctremp = 6493289) OR
(e.cdcooper = 1	AND e.nrdconta = 6493700	AND e.nrctremp = 1627961) OR (e.cdcooper = 1	AND e.nrdconta = 6494129	AND e.nrctremp = 1450405) OR
(e.cdcooper = 1	AND e.nrdconta = 6494749	AND e.nrctremp = 6494749) OR (e.cdcooper = 1	AND e.nrdconta = 6494773	AND e.nrctremp = 6494773) OR
(e.cdcooper = 1	AND e.nrdconta = 6495796	AND e.nrctremp = 887254) OR (e.cdcooper = 1	AND e.nrdconta = 6495834	AND e.nrctremp = 757473) OR
(e.cdcooper = 1	AND e.nrdconta = 6496997	AND e.nrctremp = 913599) OR (e.cdcooper = 1	AND e.nrdconta = 6497152	AND e.nrctremp = 491438) OR
(e.cdcooper = 1	AND e.nrdconta = 6497519	AND e.nrctremp = 11050) OR (e.cdcooper = 1	AND e.nrdconta = 6498957	AND e.nrctremp = 887151) OR
(e.cdcooper = 1	AND e.nrdconta = 6498990	AND e.nrctremp = 675444) OR (e.cdcooper = 1	AND e.nrdconta = 6499430	AND e.nrctremp = 400205) OR
(e.cdcooper = 1	AND e.nrdconta = 6499635	AND e.nrctremp = 1599867) OR (e.cdcooper = 1	AND e.nrdconta = 6501532	AND e.nrctremp = 14422) OR
(e.cdcooper = 1	AND e.nrdconta = 6501532	AND e.nrctremp = 131899) OR (e.cdcooper = 1	AND e.nrdconta = 6504337	AND e.nrctremp = 597008) OR
(e.cdcooper = 1	AND e.nrdconta = 6506186	AND e.nrctremp = 1587289) OR (e.cdcooper = 1	AND e.nrdconta = 6506364	AND e.nrctremp = 511686) OR
(e.cdcooper = 1	AND e.nrdconta = 6506550	AND e.nrctremp = 766683) OR (e.cdcooper = 1	AND e.nrdconta = 6506852	AND e.nrctremp = 470260) OR
(e.cdcooper = 1	AND e.nrdconta = 6506950	AND e.nrctremp = 327171) OR (e.cdcooper = 1	AND e.nrdconta = 6507557	AND e.nrctremp = 575206) OR
(e.cdcooper = 1	AND e.nrdconta = 6507611	AND e.nrctremp = 408449) OR (e.cdcooper = 1	AND e.nrdconta = 6508618	AND e.nrctremp = 1398209) OR
(e.cdcooper = 1	AND e.nrdconta = 6511775	AND e.nrctremp = 6511775) OR (e.cdcooper = 1	AND e.nrdconta = 6511864	AND e.nrctremp = 139691) OR
(e.cdcooper = 1	AND e.nrdconta = 6512054	AND e.nrctremp = 1099) OR (e.cdcooper = 1	AND e.nrdconta = 6512143	AND e.nrctremp = 889017) OR
(e.cdcooper = 1	AND e.nrdconta = 6512496	AND e.nrctremp = 174674) OR (e.cdcooper = 1	AND e.nrdconta = 6513891	AND e.nrctremp = 108315) OR
(e.cdcooper = 1	AND e.nrdconta = 6514332	AND e.nrctremp = 1389442) OR (e.cdcooper = 1	AND e.nrdconta = 6515410	AND e.nrctremp = 6515410) OR
(e.cdcooper = 1	AND e.nrdconta = 6516572	AND e.nrctremp = 643845) OR (e.cdcooper = 1	AND e.nrdconta = 6517137	AND e.nrctremp = 638707) OR
(e.cdcooper = 1	AND e.nrdconta = 6519008	AND e.nrctremp = 1034054) OR (e.cdcooper = 1	AND e.nrdconta = 6519806	AND e.nrctremp = 112885) OR
(e.cdcooper = 1	AND e.nrdconta = 6522335	AND e.nrctremp = 1560725) OR (e.cdcooper = 1	AND e.nrdconta = 6523072	AND e.nrctremp = 836597) OR
(e.cdcooper = 1	AND e.nrdconta = 6523072	AND e.nrctremp = 838675) OR (e.cdcooper = 1	AND e.nrdconta = 6523951	AND e.nrctremp = 766020) OR
(e.cdcooper = 1	AND e.nrdconta = 6524869	AND e.nrctremp = 350247) OR (e.cdcooper = 1	AND e.nrdconta = 6525814	AND e.nrctremp = 880516) OR
(e.cdcooper = 1	AND e.nrdconta = 6527060	AND e.nrctremp = 723193) OR (e.cdcooper = 1	AND e.nrdconta = 6527477	AND e.nrctremp = 859549) OR
(e.cdcooper = 1	AND e.nrdconta = 6527523	AND e.nrctremp = 31034) OR (e.cdcooper = 1	AND e.nrdconta = 6527523	AND e.nrctremp = 31035) OR
(e.cdcooper = 1	AND e.nrdconta = 6528309	AND e.nrctremp = 6528309) OR (e.cdcooper = 1	AND e.nrdconta = 6529313	AND e.nrctremp = 37787) OR
(e.cdcooper = 1	AND e.nrdconta = 6529577	AND e.nrctremp = 453204) OR (e.cdcooper = 1	AND e.nrdconta = 6530028	AND e.nrctremp = 311761) OR
(e.cdcooper = 1	AND e.nrdconta = 6532420	AND e.nrctremp = 470718) OR (e.cdcooper = 1	AND e.nrdconta = 6532420	AND e.nrctremp = 509483) OR
(e.cdcooper = 1	AND e.nrdconta = 6534791	AND e.nrctremp = 766380) OR (e.cdcooper = 1	AND e.nrdconta = 6537006	AND e.nrctremp = 6537006) OR
(e.cdcooper = 1	AND e.nrdconta = 6537464	AND e.nrctremp = 6537464) OR (e.cdcooper = 1	AND e.nrdconta = 6537847	AND e.nrctremp = 316202) OR
(e.cdcooper = 1	AND e.nrdconta = 6538185	AND e.nrctremp = 900874) OR (e.cdcooper = 1	AND e.nrdconta = 6538568	AND e.nrctremp = 1055451) OR
(e.cdcooper = 1	AND e.nrdconta = 6538991	AND e.nrctremp = 121846) OR (e.cdcooper = 1	AND e.nrdconta = 6538991	AND e.nrctremp = 124511) OR
(e.cdcooper = 1	AND e.nrdconta = 6539572	AND e.nrctremp = 6539572) OR (e.cdcooper = 1	AND e.nrdconta = 6543529	AND e.nrctremp = 6543529) OR
(e.cdcooper = 1	AND e.nrdconta = 6543812	AND e.nrctremp = 299557) OR (e.cdcooper = 1	AND e.nrdconta = 6545181	AND e.nrctremp = 6545181) OR
(e.cdcooper = 1	AND e.nrdconta = 6547524	AND e.nrctremp = 518493) OR (e.cdcooper = 1	AND e.nrdconta = 6549012	AND e.nrctremp = 982502) OR
(e.cdcooper = 1	AND e.nrdconta = 6549276	AND e.nrctremp = 38580) OR (e.cdcooper = 1	AND e.nrdconta = 6555136	AND e.nrctremp = 495170) OR
(e.cdcooper = 1	AND e.nrdconta = 6556221	AND e.nrctremp = 59894) OR (e.cdcooper = 1	AND e.nrdconta = 6557562	AND e.nrctremp = 427508) OR
(e.cdcooper = 1	AND e.nrdconta = 6557929	AND e.nrctremp = 468071) OR (e.cdcooper = 1	AND e.nrdconta = 6558917	AND e.nrctremp = 432578) OR
(e.cdcooper = 1	AND e.nrdconta = 6559891	AND e.nrctremp = 83355) OR (e.cdcooper = 1	AND e.nrdconta = 6560032	AND e.nrctremp = 1262253) OR
(e.cdcooper = 1	AND e.nrdconta = 6560547	AND e.nrctremp = 1136980) OR (e.cdcooper = 1	AND e.nrdconta = 6560580	AND e.nrctremp = 1527915) OR
(e.cdcooper = 1	AND e.nrdconta = 6560687	AND e.nrctremp = 6560687) OR (e.cdcooper = 1	AND e.nrdconta = 6562744	AND e.nrctremp = 610858) OR
(e.cdcooper = 1	AND e.nrdconta = 6564089	AND e.nrctremp = 6564089) OR (e.cdcooper = 1	AND e.nrdconta = 6564666	AND e.nrctremp = 1528728) OR
(e.cdcooper = 1	AND e.nrdconta = 6564828	AND e.nrctremp = 568538) OR (e.cdcooper = 1	AND e.nrdconta = 6568246	AND e.nrctremp = 859114) OR
(e.cdcooper = 1	AND e.nrdconta = 6571107	AND e.nrctremp = 603687) OR (e.cdcooper = 1	AND e.nrdconta = 6571140	AND e.nrctremp = 6571140) OR
(e.cdcooper = 1	AND e.nrdconta = 6573037	AND e.nrctremp = 635785) OR (e.cdcooper = 1	AND e.nrdconta = 6578411	AND e.nrctremp = 417080) OR
(e.cdcooper = 1	AND e.nrdconta = 6580173	AND e.nrctremp = 6580173) OR (e.cdcooper = 1	AND e.nrdconta = 6580920	AND e.nrctremp = 878279) OR
(e.cdcooper = 1	AND e.nrdconta = 6581935	AND e.nrctremp = 960582) OR (e.cdcooper = 1	AND e.nrdconta = 6582583	AND e.nrctremp = 526309) OR
(e.cdcooper = 1	AND e.nrdconta = 6587143	AND e.nrctremp = 518588) OR (e.cdcooper = 1	AND e.nrdconta = 6588328	AND e.nrctremp = 583178) OR
(e.cdcooper = 1	AND e.nrdconta = 6591108	AND e.nrctremp = 43324) OR (e.cdcooper = 1	AND e.nrdconta = 6591825	AND e.nrctremp = 1113058) OR
(e.cdcooper = 1	AND e.nrdconta = 6591990	AND e.nrctremp = 391672) OR (e.cdcooper = 1	AND e.nrdconta = 6594530	AND e.nrctremp = 131525) OR
(e.cdcooper = 1	AND e.nrdconta = 6595138	AND e.nrctremp = 347073) OR (e.cdcooper = 1	AND e.nrdconta = 6595871	AND e.nrctremp = 1542399) OR
(e.cdcooper = 1	AND e.nrdconta = 6598250	AND e.nrctremp = 1534164) OR (e.cdcooper = 1	AND e.nrdconta = 6599206	AND e.nrctremp = 1069133) OR
(e.cdcooper = 1	AND e.nrdconta = 6600417	AND e.nrctremp = 1266079) OR (e.cdcooper = 1	AND e.nrdconta = 6600654	AND e.nrctremp = 53867) OR
(e.cdcooper = 1	AND e.nrdconta = 6601235	AND e.nrctremp = 1517112) OR (e.cdcooper = 1	AND e.nrdconta = 6601847	AND e.nrctremp = 1195294) OR
(e.cdcooper = 1	AND e.nrdconta = 6602762	AND e.nrctremp = 157211) OR (e.cdcooper = 1	AND e.nrdconta = 6603327	AND e.nrctremp = 668852) OR
(e.cdcooper = 1	AND e.nrdconta = 6604390	AND e.nrctremp = 174236) OR (e.cdcooper = 1	AND e.nrdconta = 6607039	AND e.nrctremp = 1102726) OR
(e.cdcooper = 1	AND e.nrdconta = 6607039	AND e.nrctremp = 1682913) OR (e.cdcooper = 1	AND e.nrdconta = 6608485	AND e.nrctremp = 782760) OR
(e.cdcooper = 1	AND e.nrdconta = 6614531	AND e.nrctremp = 522541) OR (e.cdcooper = 1	AND e.nrdconta = 6614884	AND e.nrctremp = 1921275) OR
(e.cdcooper = 1	AND e.nrdconta = 6617263	AND e.nrctremp = 404213) OR (e.cdcooper = 1	AND e.nrdconta = 6617760	AND e.nrctremp = 338913) OR
(e.cdcooper = 1	AND e.nrdconta = 6618219	AND e.nrctremp = 6618219) OR (e.cdcooper = 1	AND e.nrdconta = 6618472	AND e.nrctremp = 6618472) OR
(e.cdcooper = 1	AND e.nrdconta = 6618529	AND e.nrctremp = 493820) OR (e.cdcooper = 1	AND e.nrdconta = 6618529	AND e.nrctremp = 521888) OR
(e.cdcooper = 1	AND e.nrdconta = 6618545	AND e.nrctremp = 6618545) OR (e.cdcooper = 1	AND e.nrdconta = 6618901	AND e.nrctremp = 462568) OR
(e.cdcooper = 1	AND e.nrdconta = 6620167	AND e.nrctremp = 6620167) OR (e.cdcooper = 1	AND e.nrdconta = 6620469	AND e.nrctremp = 1404304) OR
(e.cdcooper = 1	AND e.nrdconta = 6620655	AND e.nrctremp = 14003) OR (e.cdcooper = 1	AND e.nrdconta = 6620957	AND e.nrctremp = 1853013) OR
(e.cdcooper = 1	AND e.nrdconta = 6621252	AND e.nrctremp = 379444) OR (e.cdcooper = 1	AND e.nrdconta = 6623905	AND e.nrctremp = 882138) OR
(e.cdcooper = 1	AND e.nrdconta = 6625150	AND e.nrctremp = 699998) OR (e.cdcooper = 1	AND e.nrdconta = 6625460	AND e.nrctremp = 988718) OR
(e.cdcooper = 1	AND e.nrdconta = 6625525	AND e.nrctremp = 827544) OR (e.cdcooper = 1	AND e.nrdconta = 6626157	AND e.nrctremp = 32658) OR
(e.cdcooper = 1	AND e.nrdconta = 6626270	AND e.nrctremp = 51027) OR (e.cdcooper = 1	AND e.nrdconta = 6626840	AND e.nrctremp = 188975) OR
(e.cdcooper = 1	AND e.nrdconta = 6627323	AND e.nrctremp = 788185) OR (e.cdcooper = 1	AND e.nrdconta = 6627749	AND e.nrctremp = 114603) OR
(e.cdcooper = 1	AND e.nrdconta = 6628842	AND e.nrctremp = 6628842) OR (e.cdcooper = 1	AND e.nrdconta = 6630740	AND e.nrctremp = 1108936) OR
(e.cdcooper = 1	AND e.nrdconta = 6633498	AND e.nrctremp = 431691) OR (e.cdcooper = 1	AND e.nrdconta = 6636640	AND e.nrctremp = 1041868) OR
(e.cdcooper = 1	AND e.nrdconta = 6636683	AND e.nrctremp = 6636683) OR (e.cdcooper = 1	AND e.nrdconta = 6636721	AND e.nrctremp = 6636721) OR
(e.cdcooper = 1	AND e.nrdconta = 6637442	AND e.nrctremp = 1949537) OR (e.cdcooper = 1	AND e.nrdconta = 6643221	AND e.nrctremp = 994536) OR
(e.cdcooper = 1	AND e.nrdconta = 6643515	AND e.nrctremp = 6643515) OR (e.cdcooper = 1	AND e.nrdconta = 6643523	AND e.nrctremp = 11557) OR
(e.cdcooper = 1	AND e.nrdconta = 6643566	AND e.nrctremp = 101744) OR (e.cdcooper = 1	AND e.nrdconta = 6644554	AND e.nrctremp = 557479) OR
(e.cdcooper = 1	AND e.nrdconta = 6646204	AND e.nrctremp = 871076) OR (e.cdcooper = 1	AND e.nrdconta = 6649025	AND e.nrctremp = 1094836) OR
(e.cdcooper = 1	AND e.nrdconta = 6649700	AND e.nrctremp = 204511) OR (e.cdcooper = 1	AND e.nrdconta = 6649742	AND e.nrctremp = 1214518) OR
(e.cdcooper = 1	AND e.nrdconta = 6650031	AND e.nrctremp = 671417) OR (e.cdcooper = 1	AND e.nrdconta = 6650864	AND e.nrctremp = 1599779) OR
(e.cdcooper = 1	AND e.nrdconta = 6654142	AND e.nrctremp = 86298) OR (e.cdcooper = 1	AND e.nrdconta = 6654665	AND e.nrctremp = 104066) OR
(e.cdcooper = 1	AND e.nrdconta = 6658237	AND e.nrctremp = 1166613) OR (e.cdcooper = 1	AND e.nrdconta = 6658300	AND e.nrctremp = 1534562) OR
(e.cdcooper = 1	AND e.nrdconta = 6658512	AND e.nrctremp = 24751) OR (e.cdcooper = 1	AND e.nrdconta = 6658750	AND e.nrctremp = 995127) OR
(e.cdcooper = 1	AND e.nrdconta = 6659357	AND e.nrctremp = 1534601) OR (e.cdcooper = 1	AND e.nrdconta = 6660398	AND e.nrctremp = 133168) OR
(e.cdcooper = 1	AND e.nrdconta = 6661092	AND e.nrctremp = 760390) OR (e.cdcooper = 1	AND e.nrdconta = 6662242	AND e.nrctremp = 1350857) OR
(e.cdcooper = 1	AND e.nrdconta = 6662706	AND e.nrctremp = 575397) OR (e.cdcooper = 1	AND e.nrdconta = 6662781	AND e.nrctremp = 1102413) OR
(e.cdcooper = 1	AND e.nrdconta = 6663567	AND e.nrctremp = 443447) OR (e.cdcooper = 1	AND e.nrdconta = 6663648	AND e.nrctremp = 1487425) OR
(e.cdcooper = 1	AND e.nrdconta = 6665039	AND e.nrctremp = 461541) OR (e.cdcooper = 1	AND e.nrdconta = 6665071	AND e.nrctremp = 326171) OR
(e.cdcooper = 1	AND e.nrdconta = 6665810	AND e.nrctremp = 1696608) OR (e.cdcooper = 1	AND e.nrdconta = 6665977	AND e.nrctremp = 782752) OR
(e.cdcooper = 1	AND e.nrdconta = 6669077	AND e.nrctremp = 491436) OR (e.cdcooper = 1	AND e.nrdconta = 6669239	AND e.nrctremp = 2144951) OR
(e.cdcooper = 1	AND e.nrdconta = 6669662	AND e.nrctremp = 336772) OR (e.cdcooper = 1	AND e.nrdconta = 6669891	AND e.nrctremp = 1194934) OR
(e.cdcooper = 1	AND e.nrdconta = 6670172	AND e.nrctremp = 407621) OR (e.cdcooper = 1	AND e.nrdconta = 6672981	AND e.nrctremp = 573268) OR
(e.cdcooper = 1	AND e.nrdconta = 6673678	AND e.nrctremp = 384773) OR (e.cdcooper = 1	AND e.nrdconta = 6673759	AND e.nrctremp = 6673759) OR
(e.cdcooper = 1	AND e.nrdconta = 6673961	AND e.nrctremp = 175317) OR (e.cdcooper = 1	AND e.nrdconta = 6674100	AND e.nrctremp = 371064) OR
(e.cdcooper = 1	AND e.nrdconta = 6674330	AND e.nrctremp = 564673) OR (e.cdcooper = 1	AND e.nrdconta = 6674666	AND e.nrctremp = 6674666) OR
(e.cdcooper = 1	AND e.nrdconta = 6676219	AND e.nrctremp = 1480693) OR (e.cdcooper = 1	AND e.nrdconta = 6676367	AND e.nrctremp = 863495) OR
(e.cdcooper = 1	AND e.nrdconta = 6676669	AND e.nrctremp = 1204088) OR (e.cdcooper = 1	AND e.nrdconta = 6677134	AND e.nrctremp = 964217) OR
(e.cdcooper = 1	AND e.nrdconta = 6677320	AND e.nrctremp = 6677320) OR (e.cdcooper = 1	AND e.nrdconta = 6677479	AND e.nrctremp = 748079) OR
(e.cdcooper = 1	AND e.nrdconta = 6677525	AND e.nrctremp = 173790) OR (e.cdcooper = 1	AND e.nrdconta = 6677525	AND e.nrctremp = 669552) OR
(e.cdcooper = 1	AND e.nrdconta = 6677649	AND e.nrctremp = 668429) OR (e.cdcooper = 1	AND e.nrdconta = 6678289	AND e.nrctremp = 526675) OR
(e.cdcooper = 1	AND e.nrdconta = 6678360	AND e.nrctremp = 591672) OR (e.cdcooper = 1	AND e.nrdconta = 6678424	AND e.nrctremp = 690898) OR
(e.cdcooper = 1	AND e.nrdconta = 6680526	AND e.nrctremp = 6680526) OR (e.cdcooper = 1	AND e.nrdconta = 6681026	AND e.nrctremp = 65447) OR
(e.cdcooper = 1	AND e.nrdconta = 6682812	AND e.nrctremp = 860023) OR (e.cdcooper = 1	AND e.nrdconta = 6685757	AND e.nrctremp = 816194) OR
(e.cdcooper = 1	AND e.nrdconta = 6686486	AND e.nrctremp = 6686486) OR (e.cdcooper = 1	AND e.nrdconta = 6686605	AND e.nrctremp = 1100104) OR
(e.cdcooper = 1	AND e.nrdconta = 6690564	AND e.nrctremp = 389039) OR (e.cdcooper = 1	AND e.nrdconta = 6691692	AND e.nrctremp = 1587160) OR
(e.cdcooper = 1	AND e.nrdconta = 6691943	AND e.nrctremp = 397718) OR (e.cdcooper = 1	AND e.nrdconta = 6693415	AND e.nrctremp = 918564) OR
(e.cdcooper = 1	AND e.nrdconta = 6693920	AND e.nrctremp = 2104643) OR (e.cdcooper = 1	AND e.nrdconta = 6694748	AND e.nrctremp = 334505) OR
(e.cdcooper = 1	AND e.nrdconta = 6695680	AND e.nrctremp = 349605) OR (e.cdcooper = 1	AND e.nrdconta = 6697089	AND e.nrctremp = 1813683) OR
(e.cdcooper = 1	AND e.nrdconta = 6697160	AND e.nrctremp = 539491) OR (e.cdcooper = 1	AND e.nrdconta = 6697631	AND e.nrctremp = 642965) OR
(e.cdcooper = 1	AND e.nrdconta = 6698794	AND e.nrctremp = 179027) OR (e.cdcooper = 1	AND e.nrdconta = 6702708	AND e.nrctremp = 1921298) OR
(e.cdcooper = 1	AND e.nrdconta = 6704603	AND e.nrctremp = 320503) OR (e.cdcooper = 1	AND e.nrdconta = 6704697	AND e.nrctremp = 873679) OR
(e.cdcooper = 1	AND e.nrdconta = 6704743	AND e.nrctremp = 766662) OR (e.cdcooper = 1	AND e.nrdconta = 6705979	AND e.nrctremp = 1290020) OR
(e.cdcooper = 1	AND e.nrdconta = 6706088	AND e.nrctremp = 1853805) OR (e.cdcooper = 1	AND e.nrdconta = 6706851	AND e.nrctremp = 493864) OR
(e.cdcooper = 1	AND e.nrdconta = 6706851	AND e.nrctremp = 493868) OR (e.cdcooper = 1	AND e.nrdconta = 6707270	AND e.nrctremp = 1159042) OR
(e.cdcooper = 1	AND e.nrdconta = 6707610	AND e.nrctremp = 6707610) OR (e.cdcooper = 1	AND e.nrdconta = 6708170	AND e.nrctremp = 6708170) OR
(e.cdcooper = 1	AND e.nrdconta = 6709265	AND e.nrctremp = 1551236) OR (e.cdcooper = 1	AND e.nrdconta = 6715818	AND e.nrctremp = 148617) OR
(e.cdcooper = 1	AND e.nrdconta = 6716687	AND e.nrctremp = 447748) OR (e.cdcooper = 1	AND e.nrdconta = 6717292	AND e.nrctremp = 148627) OR
(e.cdcooper = 1	AND e.nrdconta = 6717462	AND e.nrctremp = 675398) OR (e.cdcooper = 1	AND e.nrdconta = 6719821	AND e.nrctremp = 608587) OR
(e.cdcooper = 1	AND e.nrdconta = 6719880	AND e.nrctremp = 660896) OR (e.cdcooper = 1	AND e.nrdconta = 6720412	AND e.nrctremp = 123908) OR
(e.cdcooper = 1	AND e.nrdconta = 6721486	AND e.nrctremp = 366175) OR (e.cdcooper = 1	AND e.nrdconta = 6722490	AND e.nrctremp = 146494) OR
(e.cdcooper = 1	AND e.nrdconta = 6722547	AND e.nrctremp = 678213) OR (e.cdcooper = 1	AND e.nrdconta = 6724485	AND e.nrctremp = 177376) OR
(e.cdcooper = 1	AND e.nrdconta = 6724990	AND e.nrctremp = 1921001) OR (e.cdcooper = 1	AND e.nrdconta = 6725031	AND e.nrctremp = 34297) OR
(e.cdcooper = 1	AND e.nrdconta = 6725309	AND e.nrctremp = 1440635) OR (e.cdcooper = 1	AND e.nrdconta = 6726917	AND e.nrctremp = 143088) OR
(e.cdcooper = 1	AND e.nrdconta = 6727050	AND e.nrctremp = 1126539) OR (e.cdcooper = 1	AND e.nrdconta = 6729576	AND e.nrctremp = 467860) OR
(e.cdcooper = 1	AND e.nrdconta = 6730906	AND e.nrctremp = 453726) OR (e.cdcooper = 1	AND e.nrdconta = 6731740	AND e.nrctremp = 541973) OR
(e.cdcooper = 1	AND e.nrdconta = 6731740	AND e.nrctremp = 568167) OR (e.cdcooper = 1	AND e.nrdconta = 6732151	AND e.nrctremp = 419533) OR
(e.cdcooper = 1	AND e.nrdconta = 6733549	AND e.nrctremp = 6733549) OR (e.cdcooper = 1	AND e.nrdconta = 6735762	AND e.nrctremp = 530348) OR
(e.cdcooper = 1	AND e.nrdconta = 6735894	AND e.nrctremp = 6735894) OR (e.cdcooper = 1	AND e.nrdconta = 6736211	AND e.nrctremp = 1283579) OR
(e.cdcooper = 1	AND e.nrdconta = 6736211	AND e.nrctremp = 1488770) OR (e.cdcooper = 1	AND e.nrdconta = 6736882	AND e.nrctremp = 455000) OR
(e.cdcooper = 1	AND e.nrdconta = 6738168	AND e.nrctremp = 481222) OR (e.cdcooper = 1	AND e.nrdconta = 6741070	AND e.nrctremp = 1046495) OR
(e.cdcooper = 1	AND e.nrdconta = 6743161	AND e.nrctremp = 426808) OR (e.cdcooper = 1	AND e.nrdconta = 6744087	AND e.nrctremp = 585817) OR
(e.cdcooper = 1	AND e.nrdconta = 6746713	AND e.nrctremp = 1350923) OR (e.cdcooper = 1	AND e.nrdconta = 6748651	AND e.nrctremp = 901723) OR
(e.cdcooper = 1	AND e.nrdconta = 6750826	AND e.nrctremp = 920006) OR (e.cdcooper = 1	AND e.nrdconta = 6751784	AND e.nrctremp = 817549) OR
(e.cdcooper = 1	AND e.nrdconta = 6753205	AND e.nrctremp = 1726090) OR (e.cdcooper = 1	AND e.nrdconta = 6754716	AND e.nrctremp = 603698) OR
(e.cdcooper = 1	AND e.nrdconta = 6754848	AND e.nrctremp = 603691) OR (e.cdcooper = 1	AND e.nrdconta = 6755305	AND e.nrctremp = 6755305) OR
(e.cdcooper = 1	AND e.nrdconta = 6755690	AND e.nrctremp = 498325) OR (e.cdcooper = 1	AND e.nrdconta = 6755933	AND e.nrctremp = 1082042) OR
(e.cdcooper = 1	AND e.nrdconta = 6756395	AND e.nrctremp = 121163) OR (e.cdcooper = 1	AND e.nrdconta = 6756700	AND e.nrctremp = 1622295) OR
(e.cdcooper = 1	AND e.nrdconta = 6756700	AND e.nrctremp = 2012496) OR (e.cdcooper = 1	AND e.nrdconta = 6756794	AND e.nrctremp = 6756794) OR
(e.cdcooper = 1	AND e.nrdconta = 6756840	AND e.nrctremp = 550712) OR (e.cdcooper = 1	AND e.nrdconta = 6756875	AND e.nrctremp = 193436) OR
(e.cdcooper = 1	AND e.nrdconta = 6758339	AND e.nrctremp = 498706) OR (e.cdcooper = 1	AND e.nrdconta = 6759211	AND e.nrctremp = 29885) OR
(e.cdcooper = 1	AND e.nrdconta = 6760538	AND e.nrctremp = 11518) OR (e.cdcooper = 1	AND e.nrdconta = 6760970	AND e.nrctremp = 1853345) OR
(e.cdcooper = 1	AND e.nrdconta = 6761585	AND e.nrctremp = 1021499) OR (e.cdcooper = 1	AND e.nrdconta = 6761607	AND e.nrctremp = 855611) OR
(e.cdcooper = 1	AND e.nrdconta = 6762620	AND e.nrctremp = 6762620) OR (e.cdcooper = 1	AND e.nrdconta = 6765408	AND e.nrctremp = 1727644) OR
(e.cdcooper = 1	AND e.nrdconta = 6768369	AND e.nrctremp = 752233) OR (e.cdcooper = 1	AND e.nrdconta = 6768636	AND e.nrctremp = 355111) OR
(e.cdcooper = 1	AND e.nrdconta = 6769934	AND e.nrctremp = 1853003) OR (e.cdcooper = 1	AND e.nrdconta = 6770100	AND e.nrctremp = 6770100) OR
(e.cdcooper = 1	AND e.nrdconta = 6770215	AND e.nrctremp = 850514) OR (e.cdcooper = 1	AND e.nrdconta = 6770720	AND e.nrctremp = 930290) OR
(e.cdcooper = 1	AND e.nrdconta = 6771173	AND e.nrctremp = 1063172) OR (e.cdcooper = 1	AND e.nrdconta = 6771173	AND e.nrctremp = 1374273) OR
(e.cdcooper = 1	AND e.nrdconta = 6771203	AND e.nrctremp = 6771203) OR (e.cdcooper = 1	AND e.nrdconta = 6771602	AND e.nrctremp = 422908) OR
(e.cdcooper = 1	AND e.nrdconta = 6772145	AND e.nrctremp = 147244) OR (e.cdcooper = 1	AND e.nrdconta = 6772145	AND e.nrctremp = 2004960) OR
(e.cdcooper = 1	AND e.nrdconta = 6772234	AND e.nrctremp = 422199) OR (e.cdcooper = 1	AND e.nrdconta = 6776140	AND e.nrctremp = 618089) OR
(e.cdcooper = 1	AND e.nrdconta = 6776981	AND e.nrctremp = 677457) OR (e.cdcooper = 1	AND e.nrdconta = 6777597	AND e.nrctremp = 983215) OR
(e.cdcooper = 1	AND e.nrdconta = 6777716	AND e.nrctremp = 6777716) OR (e.cdcooper = 1	AND e.nrdconta = 6778003	AND e.nrctremp = 1172102) OR
(e.cdcooper = 1	AND e.nrdconta = 6783465	AND e.nrctremp = 714544) OR (e.cdcooper = 1	AND e.nrdconta = 6783830	AND e.nrctremp = 1224607) OR
(e.cdcooper = 1	AND e.nrdconta = 6784607	AND e.nrctremp = 792206) OR (e.cdcooper = 1	AND e.nrdconta = 6785719	AND e.nrctremp = 1155450) OR
(e.cdcooper = 1	AND e.nrdconta = 6787541	AND e.nrctremp = 6787541) OR (e.cdcooper = 1	AND e.nrdconta = 6791107	AND e.nrctremp = 6791107) OR
(e.cdcooper = 1	AND e.nrdconta = 6797431	AND e.nrctremp = 1160618) OR (e.cdcooper = 1	AND e.nrdconta = 6799205	AND e.nrctremp = 11054) OR
(e.cdcooper = 1	AND e.nrdconta = 6802249	AND e.nrctremp = 1345063) OR (e.cdcooper = 1	AND e.nrdconta = 6802559	AND e.nrctremp = 1200247) OR
(e.cdcooper = 1	AND e.nrdconta = 6803261	AND e.nrctremp = 677180) OR (e.cdcooper = 1	AND e.nrdconta = 6804160	AND e.nrctremp = 569392) OR
(e.cdcooper = 1	AND e.nrdconta = 6806538	AND e.nrctremp = 6806538) OR (e.cdcooper = 1	AND e.nrdconta = 6808565	AND e.nrctremp = 804060) OR
(e.cdcooper = 1	AND e.nrdconta = 6809510	AND e.nrctremp = 425453) OR (e.cdcooper = 1	AND e.nrdconta = 6809510	AND e.nrctremp = 425464) OR
(e.cdcooper = 1	AND e.nrdconta = 6809774	AND e.nrctremp = 860176) OR (e.cdcooper = 1	AND e.nrdconta = 6810292	AND e.nrctremp = 1504327) OR
(e.cdcooper = 1	AND e.nrdconta = 6810802	AND e.nrctremp = 698937) OR (e.cdcooper = 1	AND e.nrdconta = 6811426	AND e.nrctremp = 157095) OR
(e.cdcooper = 1	AND e.nrdconta = 6812058	AND e.nrctremp = 6812058) OR (e.cdcooper = 1	AND e.nrdconta = 6812805	AND e.nrctremp = 963707) OR
(e.cdcooper = 1	AND e.nrdconta = 6814026	AND e.nrctremp = 1378805) OR (e.cdcooper = 1	AND e.nrdconta = 6814654	AND e.nrctremp = 822614) OR
(e.cdcooper = 1	AND e.nrdconta = 6817580	AND e.nrctremp = 1476846) OR (e.cdcooper = 1	AND e.nrdconta = 6818757	AND e.nrctremp = 1033407) OR
(e.cdcooper = 1	AND e.nrdconta = 6818978	AND e.nrctremp = 11629) OR (e.cdcooper = 1	AND e.nrdconta = 6819745	AND e.nrctremp = 142703) OR
(e.cdcooper = 1	AND e.nrdconta = 6819907	AND e.nrctremp = 1424809) OR (e.cdcooper = 1	AND e.nrdconta = 6821006	AND e.nrctremp = 6821006) OR
(e.cdcooper = 1	AND e.nrdconta = 6822002	AND e.nrctremp = 500361) OR (e.cdcooper = 1	AND e.nrdconta = 6822070	AND e.nrctremp = 1230979) OR
(e.cdcooper = 1	AND e.nrdconta = 6824013	AND e.nrctremp = 1443669) OR (e.cdcooper = 1	AND e.nrdconta = 6824471	AND e.nrctremp = 1056520) OR
(e.cdcooper = 1	AND e.nrdconta = 6827144	AND e.nrctremp = 2316) OR (e.cdcooper = 1	AND e.nrdconta = 6827934	AND e.nrctremp = 11111) OR
(e.cdcooper = 1	AND e.nrdconta = 6828574	AND e.nrctremp = 66193) OR (e.cdcooper = 1	AND e.nrdconta = 6828574	AND e.nrctremp = 316500) OR
(e.cdcooper = 1	AND e.nrdconta = 6828906	AND e.nrctremp = 816114) OR (e.cdcooper = 1	AND e.nrdconta = 6829465	AND e.nrctremp = 473119) OR
(e.cdcooper = 1	AND e.nrdconta = 6829643	AND e.nrctremp = 6829643) OR (e.cdcooper = 1	AND e.nrdconta = 6830455	AND e.nrctremp = 6830455) OR
(e.cdcooper = 1	AND e.nrdconta = 6830560	AND e.nrctremp = 1250864) OR (e.cdcooper = 1	AND e.nrdconta = 6831230	AND e.nrctremp = 846429) OR
(e.cdcooper = 1	AND e.nrdconta = 6831915	AND e.nrctremp = 1028035) OR (e.cdcooper = 1	AND e.nrdconta = 6832946	AND e.nrctremp = 652500) OR
(e.cdcooper = 1	AND e.nrdconta = 6832946	AND e.nrctremp = 6832946) OR (e.cdcooper = 1	AND e.nrdconta = 6833241	AND e.nrctremp = 121446) OR
(e.cdcooper = 1	AND e.nrdconta = 6834566	AND e.nrctremp = 1214353) OR (e.cdcooper = 1	AND e.nrdconta = 6834990	AND e.nrctremp = 311413) OR
(e.cdcooper = 1	AND e.nrdconta = 6834990	AND e.nrctremp = 644562) OR (e.cdcooper = 1	AND e.nrdconta = 6836496	AND e.nrctremp = 6836496) OR
(e.cdcooper = 1	AND e.nrdconta = 6837212	AND e.nrctremp = 6837212) OR (e.cdcooper = 1	AND e.nrdconta = 6837557	AND e.nrctremp = 582231) OR
(e.cdcooper = 1	AND e.nrdconta = 6839827	AND e.nrctremp = 574974) OR (e.cdcooper = 1	AND e.nrdconta = 6841902	AND e.nrctremp = 726009) OR
(e.cdcooper = 1	AND e.nrdconta = 6842542	AND e.nrctremp = 666310) OR (e.cdcooper = 1	AND e.nrdconta = 6843964	AND e.nrctremp = 1921086) OR
(e.cdcooper = 1	AND e.nrdconta = 6844502	AND e.nrctremp = 330955) OR (e.cdcooper = 1	AND e.nrdconta = 6845550	AND e.nrctremp = 6845550) OR
(e.cdcooper = 1	AND e.nrdconta = 6846041	AND e.nrctremp = 1853400) OR (e.cdcooper = 1	AND e.nrdconta = 6847927	AND e.nrctremp = 53883) OR
(e.cdcooper = 1	AND e.nrdconta = 6850553	AND e.nrctremp = 125409) OR (e.cdcooper = 1	AND e.nrdconta = 6851479	AND e.nrctremp = 917470) OR
(e.cdcooper = 1	AND e.nrdconta = 6852882	AND e.nrctremp = 511977) OR (e.cdcooper = 1	AND e.nrdconta = 6853013	AND e.nrctremp = 406290) OR
(e.cdcooper = 1	AND e.nrdconta = 6854656	AND e.nrctremp = 1013159) OR (e.cdcooper = 1	AND e.nrdconta = 6854826	AND e.nrctremp = 150050) OR
(e.cdcooper = 1	AND e.nrdconta = 6855563	AND e.nrctremp = 104816) OR (e.cdcooper = 1	AND e.nrdconta = 6855873	AND e.nrctremp = 730192) OR
(e.cdcooper = 1	AND e.nrdconta = 6856497	AND e.nrctremp = 829170) OR (e.cdcooper = 1	AND e.nrdconta = 6857043	AND e.nrctremp = 1621915) OR
(e.cdcooper = 1	AND e.nrdconta = 6857159	AND e.nrctremp = 970457) OR (e.cdcooper = 1	AND e.nrdconta = 6857620	AND e.nrctremp = 343020) OR
(e.cdcooper = 1	AND e.nrdconta = 6859968	AND e.nrctremp = 465835) OR (e.cdcooper = 1	AND e.nrdconta = 6860010	AND e.nrctremp = 1637732) OR
(e.cdcooper = 1	AND e.nrdconta = 6860087	AND e.nrctremp = 1696571) OR (e.cdcooper = 1	AND e.nrdconta = 6860338	AND e.nrctremp = 6860338) OR
(e.cdcooper = 1	AND e.nrdconta = 6860869	AND e.nrctremp = 180285) OR (e.cdcooper = 1	AND e.nrdconta = 6861148	AND e.nrctremp = 973068) OR
(e.cdcooper = 1	AND e.nrdconta = 6862608	AND e.nrctremp = 1064201) OR (e.cdcooper = 1	AND e.nrdconta = 6862608	AND e.nrctremp = 1389666) OR
(e.cdcooper = 1	AND e.nrdconta = 6862705	AND e.nrctremp = 6862705) OR (e.cdcooper = 1	AND e.nrdconta = 6864040	AND e.nrctremp = 6864040) OR
(e.cdcooper = 1	AND e.nrdconta = 6865941	AND e.nrctremp = 1223439) OR (e.cdcooper = 1	AND e.nrdconta = 6866387	AND e.nrctremp = 1436155) OR
(e.cdcooper = 1	AND e.nrdconta = 6869602	AND e.nrctremp = 486659) OR (e.cdcooper = 1	AND e.nrdconta = 6870490	AND e.nrctremp = 666298) OR
(e.cdcooper = 1	AND e.nrdconta = 6872042	AND e.nrctremp = 670220) OR (e.cdcooper = 1	AND e.nrdconta = 6872344	AND e.nrctremp = 6872344) OR
(e.cdcooper = 1	AND e.nrdconta = 6872492	AND e.nrctremp = 700202) OR (e.cdcooper = 1	AND e.nrdconta = 6873367	AND e.nrctremp = 532761) OR
(e.cdcooper = 1	AND e.nrdconta = 6874274	AND e.nrctremp = 173957) OR (e.cdcooper = 1	AND e.nrdconta = 6876668	AND e.nrctremp = 1016204) OR
(e.cdcooper = 1	AND e.nrdconta = 6880932	AND e.nrctremp = 342513) OR (e.cdcooper = 1	AND e.nrdconta = 6883109	AND e.nrctremp = 317303) OR
(e.cdcooper = 1	AND e.nrdconta = 6883672	AND e.nrctremp = 692787) OR (e.cdcooper = 1	AND e.nrdconta = 6885233	AND e.nrctremp = 234837) OR
(e.cdcooper = 1	AND e.nrdconta = 6885802	AND e.nrctremp = 1094337) OR (e.cdcooper = 1	AND e.nrdconta = 6886876	AND e.nrctremp = 623968) OR
(e.cdcooper = 1	AND e.nrdconta = 6888585	AND e.nrctremp = 1030570) OR (e.cdcooper = 1	AND e.nrdconta = 6888933	AND e.nrctremp = 6888933) OR
(e.cdcooper = 1	AND e.nrdconta = 6889956	AND e.nrctremp = 705513) OR (e.cdcooper = 1	AND e.nrdconta = 6890016	AND e.nrctremp = 1064564) OR
(e.cdcooper = 1	AND e.nrdconta = 6891039	AND e.nrctremp = 782450) OR (e.cdcooper = 1	AND e.nrdconta = 6891497	AND e.nrctremp = 556141) OR
(e.cdcooper = 1	AND e.nrdconta = 6892167	AND e.nrctremp = 349744) OR (e.cdcooper = 1	AND e.nrdconta = 6894607	AND e.nrctremp = 6894607) OR
(e.cdcooper = 1	AND e.nrdconta = 6897134	AND e.nrctremp = 1853825) OR (e.cdcooper = 1	AND e.nrdconta = 6900836	AND e.nrctremp = 1123058) OR
(e.cdcooper = 1	AND e.nrdconta = 6903002	AND e.nrctremp = 694348) OR (e.cdcooper = 1	AND e.nrdconta = 6905897	AND e.nrctremp = 95122) OR
(e.cdcooper = 1	AND e.nrdconta = 6905986	AND e.nrctremp = 6905986) OR (e.cdcooper = 1	AND e.nrdconta = 6906397	AND e.nrctremp = 1440325) OR
(e.cdcooper = 1	AND e.nrdconta = 6906613	AND e.nrctremp = 813046) OR (e.cdcooper = 1	AND e.nrdconta = 6906729	AND e.nrctremp = 120178) OR
(e.cdcooper = 1	AND e.nrdconta = 6908209	AND e.nrctremp = 6908209) OR (e.cdcooper = 1	AND e.nrdconta = 6908756	AND e.nrctremp = 907511) OR
(e.cdcooper = 1	AND e.nrdconta = 6908870	AND e.nrctremp = 1137842) OR (e.cdcooper = 1	AND e.nrdconta = 6909108	AND e.nrctremp = 1551375) OR
(e.cdcooper = 1	AND e.nrdconta = 6911064	AND e.nrctremp = 2012666) OR (e.cdcooper = 1	AND e.nrdconta = 6913890	AND e.nrctremp = 1625693) OR
(e.cdcooper = 1	AND e.nrdconta = 6914519	AND e.nrctremp = 6914519) OR (e.cdcooper = 1	AND e.nrdconta = 6917305	AND e.nrctremp = 379566) OR
(e.cdcooper = 1	AND e.nrdconta = 6917305	AND e.nrctremp = 477784) OR (e.cdcooper = 1	AND e.nrdconta = 6917950	AND e.nrctremp = 2325973) OR
(e.cdcooper = 1	AND e.nrdconta = 6918921	AND e.nrctremp = 805953) OR (e.cdcooper = 1	AND e.nrdconta = 6922406	AND e.nrctremp = 845156) OR
(e.cdcooper = 1	AND e.nrdconta = 6927246	AND e.nrctremp = 1853101) OR (e.cdcooper = 1	AND e.nrdconta = 6928200	AND e.nrctremp = 21441) OR
(e.cdcooper = 1	AND e.nrdconta = 6928617	AND e.nrctremp = 1325040) OR (e.cdcooper = 1	AND e.nrdconta = 6928633	AND e.nrctremp = 6928633) OR
(e.cdcooper = 1	AND e.nrdconta = 6928803	AND e.nrctremp = 1157729) OR (e.cdcooper = 1	AND e.nrdconta = 6929419	AND e.nrctremp = 750034) OR
(e.cdcooper = 1	AND e.nrdconta = 6930018	AND e.nrctremp = 750331) OR (e.cdcooper = 1	AND e.nrdconta = 6930387	AND e.nrctremp = 184517) OR
(e.cdcooper = 1	AND e.nrdconta = 6931316	AND e.nrctremp = 554787) OR (e.cdcooper = 1	AND e.nrdconta = 6934960	AND e.nrctremp = 6934960) OR
(e.cdcooper = 1	AND e.nrdconta = 6935630	AND e.nrctremp = 394641) OR (e.cdcooper = 1	AND e.nrdconta = 6935664	AND e.nrctremp = 1307575) OR
(e.cdcooper = 1	AND e.nrdconta = 6935702	AND e.nrctremp = 57100) OR (e.cdcooper = 1	AND e.nrdconta = 6935702	AND e.nrctremp = 436235) OR
(e.cdcooper = 1	AND e.nrdconta = 6935869	AND e.nrctremp = 1007279) OR (e.cdcooper = 1	AND e.nrdconta = 6935940	AND e.nrctremp = 2104469) OR
(e.cdcooper = 1	AND e.nrdconta = 6936083	AND e.nrctremp = 6936083) OR (e.cdcooper = 1	AND e.nrdconta = 6936768	AND e.nrctremp = 332342) OR
(e.cdcooper = 1	AND e.nrdconta = 6937039	AND e.nrctremp = 1341132) OR (e.cdcooper = 1	AND e.nrdconta = 6937047	AND e.nrctremp = 444291) OR
(e.cdcooper = 1	AND e.nrdconta = 6937225	AND e.nrctremp = 1079698) OR (e.cdcooper = 1	AND e.nrdconta = 6937926	AND e.nrctremp = 564396) OR
(e.cdcooper = 1	AND e.nrdconta = 6938647	AND e.nrctremp = 630381) OR (e.cdcooper = 1	AND e.nrdconta = 6940765	AND e.nrctremp = 878429) OR
(e.cdcooper = 1	AND e.nrdconta = 6940986	AND e.nrctremp = 986655) OR (e.cdcooper = 1	AND e.nrdconta = 6941826	AND e.nrctremp = 468112) OR
(e.cdcooper = 1	AND e.nrdconta = 6944736	AND e.nrctremp = 913899) OR (e.cdcooper = 1	AND e.nrdconta = 6946259	AND e.nrctremp = 6946259) OR
(e.cdcooper = 1	AND e.nrdconta = 6946658	AND e.nrctremp = 425946) OR (e.cdcooper = 1	AND e.nrdconta = 6946780	AND e.nrctremp = 360791) OR
(e.cdcooper = 1	AND e.nrdconta = 6947441	AND e.nrctremp = 1523886) OR (e.cdcooper = 1	AND e.nrdconta = 6947727	AND e.nrctremp = 105343) OR
(e.cdcooper = 1	AND e.nrdconta = 6949436	AND e.nrctremp = 6949436) OR (e.cdcooper = 1	AND e.nrdconta = 6949509	AND e.nrctremp = 682846) OR
(e.cdcooper = 1	AND e.nrdconta = 6949878	AND e.nrctremp = 6949878) OR (e.cdcooper = 1	AND e.nrdconta = 6951740	AND e.nrctremp = 737194) OR
(e.cdcooper = 1	AND e.nrdconta = 6951740	AND e.nrctremp = 912262) OR (e.cdcooper = 1	AND e.nrdconta = 6953239	AND e.nrctremp = 1917644) OR
(e.cdcooper = 1	AND e.nrdconta = 6954316	AND e.nrctremp = 698683) OR (e.cdcooper = 1	AND e.nrdconta = 6954677	AND e.nrctremp = 464855) OR
(e.cdcooper = 1	AND e.nrdconta = 6955045	AND e.nrctremp = 121129) OR (e.cdcooper = 1	AND e.nrdconta = 6955150	AND e.nrctremp = 178308) OR
(e.cdcooper = 1	AND e.nrdconta = 6955967	AND e.nrctremp = 6955967) OR (e.cdcooper = 1	AND e.nrdconta = 6957064	AND e.nrctremp = 881771) OR
(e.cdcooper = 1	AND e.nrdconta = 6957870	AND e.nrctremp = 1268187) OR (e.cdcooper = 1	AND e.nrdconta = 6960286	AND e.nrctremp = 1089164) OR
(e.cdcooper = 1	AND e.nrdconta = 6960421	AND e.nrctremp = 6960421) OR (e.cdcooper = 1	AND e.nrdconta = 6960430	AND e.nrctremp = 679651) OR
(e.cdcooper = 1	AND e.nrdconta = 6961380	AND e.nrctremp = 6961380) OR (e.cdcooper = 1	AND e.nrdconta = 6962440	AND e.nrctremp = 840212) OR
(e.cdcooper = 1	AND e.nrdconta = 6962823	AND e.nrctremp = 70853) OR (e.cdcooper = 1	AND e.nrdconta = 6963323	AND e.nrctremp = 554600) OR
(e.cdcooper = 1	AND e.nrdconta = 6963641	AND e.nrctremp = 653425) OR (e.cdcooper = 1	AND e.nrdconta = 6963722	AND e.nrctremp = 6963722) OR
(e.cdcooper = 1	AND e.nrdconta = 6963854	AND e.nrctremp = 417410) OR (e.cdcooper = 1	AND e.nrdconta = 6966527	AND e.nrctremp = 6966527) OR
(e.cdcooper = 1	AND e.nrdconta = 6968791	AND e.nrctremp = 206987) OR (e.cdcooper = 1	AND e.nrdconta = 6969402	AND e.nrctremp = 6969402) OR
(e.cdcooper = 1	AND e.nrdconta = 6970397	AND e.nrctremp = 333016) OR (e.cdcooper = 1	AND e.nrdconta = 6971156	AND e.nrctremp = 890914) OR
(e.cdcooper = 1	AND e.nrdconta = 6971180	AND e.nrctremp = 6971180) OR (e.cdcooper = 1	AND e.nrdconta = 6971873	AND e.nrctremp = 548577) OR
(e.cdcooper = 1	AND e.nrdconta = 6974368	AND e.nrctremp = 399098) OR (e.cdcooper = 1	AND e.nrdconta = 6976492	AND e.nrctremp = 345232) OR
(e.cdcooper = 1	AND e.nrdconta = 6976492	AND e.nrctremp = 954469) OR (e.cdcooper = 1	AND e.nrdconta = 6977472	AND e.nrctremp = 1281824) OR
(e.cdcooper = 1	AND e.nrdconta = 6977634	AND e.nrctremp = 613853) OR (e.cdcooper = 1	AND e.nrdconta = 6979190	AND e.nrctremp = 445840) OR
(e.cdcooper = 1	AND e.nrdconta = 6979750	AND e.nrctremp = 713627) OR (e.cdcooper = 1	AND e.nrdconta = 6980414	AND e.nrctremp = 551745) OR
(e.cdcooper = 1	AND e.nrdconta = 6981488	AND e.nrctremp = 1104827) OR (e.cdcooper = 1	AND e.nrdconta = 6983375	AND e.nrctremp = 645930) OR
(e.cdcooper = 1	AND e.nrdconta = 6983391	AND e.nrctremp = 128778) OR (e.cdcooper = 1	AND e.nrdconta = 6983766	AND e.nrctremp = 740793) OR
(e.cdcooper = 1	AND e.nrdconta = 6983928	AND e.nrctremp = 685685) OR (e.cdcooper = 1	AND e.nrdconta = 6984053	AND e.nrctremp = 988194) OR
(e.cdcooper = 1	AND e.nrdconta = 6985440	AND e.nrctremp = 6985440) OR (e.cdcooper = 1	AND e.nrdconta = 6985912	AND e.nrctremp = 6985912) OR
(e.cdcooper = 1	AND e.nrdconta = 6986129	AND e.nrctremp = 1556363) OR (e.cdcooper = 1	AND e.nrdconta = 6986358	AND e.nrctremp = 1761186) OR
(e.cdcooper = 1	AND e.nrdconta = 6986455	AND e.nrctremp = 6986455) OR (e.cdcooper = 1	AND e.nrdconta = 6986480	AND e.nrctremp = 713294) OR
(e.cdcooper = 1	AND e.nrdconta = 6986790	AND e.nrctremp = 662879) OR (e.cdcooper = 1	AND e.nrdconta = 6986919	AND e.nrctremp = 511566) OR
(e.cdcooper = 1	AND e.nrdconta = 6988865	AND e.nrctremp = 1097580) OR (e.cdcooper = 1	AND e.nrdconta = 6989390	AND e.nrctremp = 163199) OR
(e.cdcooper = 1	AND e.nrdconta = 6990223	AND e.nrctremp = 557091) OR (e.cdcooper = 1	AND e.nrdconta = 6990550	AND e.nrctremp = 618506) OR
(e.cdcooper = 1	AND e.nrdconta = 6990568	AND e.nrctremp = 1180297) OR (e.cdcooper = 1	AND e.nrdconta = 6992293	AND e.nrctremp = 1478236) OR
(e.cdcooper = 1	AND e.nrdconta = 6992714	AND e.nrctremp = 1308375) OR (e.cdcooper = 1	AND e.nrdconta = 6992889	AND e.nrctremp = 607773) OR
(e.cdcooper = 1	AND e.nrdconta = 6992943	AND e.nrctremp = 11895) OR (e.cdcooper = 1	AND e.nrdconta = 6995004	AND e.nrctremp = 6995004) OR
(e.cdcooper = 1	AND e.nrdconta = 6996515	AND e.nrctremp = 1096400) OR (e.cdcooper = 1	AND e.nrdconta = 6996655	AND e.nrctremp = 457666) OR
(e.cdcooper = 1	AND e.nrdconta = 6998186	AND e.nrctremp = 935606) OR (e.cdcooper = 1	AND e.nrdconta = 6998690	AND e.nrctremp = 1454607) OR
(e.cdcooper = 1	AND e.nrdconta = 6998720	AND e.nrctremp = 2104153) OR (e.cdcooper = 1	AND e.nrdconta = 6999310	AND e.nrctremp = 673512) OR
(e.cdcooper = 1	AND e.nrdconta = 6999620	AND e.nrctremp = 1352296) OR (e.cdcooper = 1	AND e.nrdconta = 7000472	AND e.nrctremp = 1294663) OR
(e.cdcooper = 1	AND e.nrdconta = 7002548	AND e.nrctremp = 818059) OR (e.cdcooper = 1	AND e.nrdconta = 7002904	AND e.nrctremp = 557065) OR
(e.cdcooper = 1	AND e.nrdconta = 7004028	AND e.nrctremp = 732068) OR (e.cdcooper = 1	AND e.nrdconta = 7004850	AND e.nrctremp = 1028591) OR
(e.cdcooper = 1	AND e.nrdconta = 7005059	AND e.nrctremp = 1388996) OR (e.cdcooper = 1	AND e.nrdconta = 7005237	AND e.nrctremp = 7005237) OR
(e.cdcooper = 1	AND e.nrdconta = 7007841	AND e.nrctremp = 578247) OR (e.cdcooper = 1	AND e.nrdconta = 7008376	AND e.nrctremp = 191128) OR
(e.cdcooper = 1	AND e.nrdconta = 7009488	AND e.nrctremp = 824754) OR (e.cdcooper = 1	AND e.nrdconta = 7010150	AND e.nrctremp = 7010150) OR
(e.cdcooper = 1	AND e.nrdconta = 7011040	AND e.nrctremp = 1569052) OR (e.cdcooper = 1	AND e.nrdconta = 7013329	AND e.nrctremp = 869621) OR
(e.cdcooper = 1	AND e.nrdconta = 7015305	AND e.nrctremp = 1555420) OR (e.cdcooper = 1	AND e.nrdconta = 7015453	AND e.nrctremp = 368677) OR
(e.cdcooper = 1	AND e.nrdconta = 7016085	AND e.nrctremp = 427890) OR (e.cdcooper = 1	AND e.nrdconta = 7016182	AND e.nrctremp = 889752) OR
(e.cdcooper = 1	AND e.nrdconta = 7017553	AND e.nrctremp = 1536943) OR (e.cdcooper = 1	AND e.nrdconta = 7019530	AND e.nrctremp = 888559) OR
(e.cdcooper = 1	AND e.nrdconta = 7020341	AND e.nrctremp = 7020341) OR (e.cdcooper = 1	AND e.nrdconta = 7021259	AND e.nrctremp = 1853608) OR
(e.cdcooper = 1	AND e.nrdconta = 7021623	AND e.nrctremp = 1432079) OR (e.cdcooper = 1	AND e.nrdconta = 7021623	AND e.nrctremp = 1547391) OR
(e.cdcooper = 1	AND e.nrdconta = 7021984	AND e.nrctremp = 687862) OR (e.cdcooper = 1	AND e.nrdconta = 7023316	AND e.nrctremp = 1422536) OR
(e.cdcooper = 1	AND e.nrdconta = 7023731	AND e.nrctremp = 1120297) OR (e.cdcooper = 1	AND e.nrdconta = 7024347	AND e.nrctremp = 121447) OR
(e.cdcooper = 1	AND e.nrdconta = 7024614	AND e.nrctremp = 1042106) OR (e.cdcooper = 1	AND e.nrdconta = 7025521	AND e.nrctremp = 7025521) OR
(e.cdcooper = 1	AND e.nrdconta = 7027087	AND e.nrctremp = 742971) OR (e.cdcooper = 1	AND e.nrdconta = 7028458	AND e.nrctremp = 169305) OR
(e.cdcooper = 1	AND e.nrdconta = 7028547	AND e.nrctremp = 114602) OR (e.cdcooper = 1	AND e.nrdconta = 7029080	AND e.nrctremp = 990749) OR
(e.cdcooper = 1	AND e.nrdconta = 7029500	AND e.nrctremp = 203020) OR (e.cdcooper = 1	AND e.nrdconta = 7031203	AND e.nrctremp = 1570000) OR
(e.cdcooper = 1	AND e.nrdconta = 7031467	AND e.nrctremp = 1619067) OR (e.cdcooper = 1	AND e.nrdconta = 7031653	AND e.nrctremp = 1296878) OR
(e.cdcooper = 1	AND e.nrdconta = 7032196	AND e.nrctremp = 762130) OR (e.cdcooper = 1	AND e.nrdconta = 7034601	AND e.nrctremp = 1157501) OR
(e.cdcooper = 1	AND e.nrdconta = 7035128	AND e.nrctremp = 631642) OR (e.cdcooper = 1	AND e.nrdconta = 7035802	AND e.nrctremp = 941565) OR
(e.cdcooper = 1	AND e.nrdconta = 7036027	AND e.nrctremp = 1090414) OR (e.cdcooper = 1	AND e.nrdconta = 7036760	AND e.nrctremp = 7036760) OR
(e.cdcooper = 1	AND e.nrdconta = 7037465	AND e.nrctremp = 685072) OR (e.cdcooper = 1	AND e.nrdconta = 7038070	AND e.nrctremp = 532880) OR
(e.cdcooper = 1	AND e.nrdconta = 7038496	AND e.nrctremp = 1463397) OR (e.cdcooper = 1	AND e.nrdconta = 7039824	AND e.nrctremp = 1349574) OR
(e.cdcooper = 1	AND e.nrdconta = 7040393	AND e.nrctremp = 1364469) OR (e.cdcooper = 1	AND e.nrdconta = 7041381	AND e.nrctremp = 427510) OR
(e.cdcooper = 1	AND e.nrdconta = 7042264	AND e.nrctremp = 28742) OR (e.cdcooper = 1	AND e.nrdconta = 7043457	AND e.nrctremp = 1523961) OR
(e.cdcooper = 1	AND e.nrdconta = 7045565	AND e.nrctremp = 661326) OR (e.cdcooper = 1	AND e.nrdconta = 7047053	AND e.nrctremp = 14134) OR
(e.cdcooper = 1	AND e.nrdconta = 7047703	AND e.nrctremp = 112675) OR (e.cdcooper = 1	AND e.nrdconta = 7047878	AND e.nrctremp = 806244) OR
(e.cdcooper = 1	AND e.nrdconta = 7048505	AND e.nrctremp = 1043986) OR (e.cdcooper = 1	AND e.nrdconta = 7048793	AND e.nrctremp = 581198) OR
(e.cdcooper = 1	AND e.nrdconta = 7049196	AND e.nrctremp = 775588) OR (e.cdcooper = 1	AND e.nrdconta = 7050143	AND e.nrctremp = 153996) OR
(e.cdcooper = 1	AND e.nrdconta = 7051131	AND e.nrctremp = 922581) OR (e.cdcooper = 1	AND e.nrdconta = 7051263	AND e.nrctremp = 66891) OR
(e.cdcooper = 1	AND e.nrdconta = 7051794	AND e.nrctremp = 7051794) OR (e.cdcooper = 1	AND e.nrdconta = 7051972	AND e.nrctremp = 384895) OR
(e.cdcooper = 1	AND e.nrdconta = 7055803	AND e.nrctremp = 7055803) OR (e.cdcooper = 1	AND e.nrdconta = 7056230	AND e.nrctremp = 1147825) OR
(e.cdcooper = 1	AND e.nrdconta = 7057326	AND e.nrctremp = 101840) OR (e.cdcooper = 1	AND e.nrdconta = 7057644	AND e.nrctremp = 1221955) OR
(e.cdcooper = 1	AND e.nrdconta = 7057717	AND e.nrctremp = 494243) OR (e.cdcooper = 1	AND e.nrdconta = 7058004	AND e.nrctremp = 1394603) OR
(e.cdcooper = 1	AND e.nrdconta = 7058268	AND e.nrctremp = 11534) OR (e.cdcooper = 1	AND e.nrdconta = 7058608	AND e.nrctremp = 516200) OR
(e.cdcooper = 1	AND e.nrdconta = 7060300	AND e.nrctremp = 1655146) OR (e.cdcooper = 1	AND e.nrdconta = 7061366	AND e.nrctremp = 7061366) OR
(e.cdcooper = 1	AND e.nrdconta = 7062150	AND e.nrctremp = 713452) OR (e.cdcooper = 1	AND e.nrdconta = 7063075	AND e.nrctremp = 110854) OR
(e.cdcooper = 1	AND e.nrdconta = 7065590	AND e.nrctremp = 7065590) OR (e.cdcooper = 1	AND e.nrdconta = 7068077	AND e.nrctremp = 1412330) OR
(e.cdcooper = 1	AND e.nrdconta = 7068506	AND e.nrctremp = 7068506) OR (e.cdcooper = 1	AND e.nrdconta = 7068913	AND e.nrctremp = 7068913) OR
(e.cdcooper = 1	AND e.nrdconta = 7071159	AND e.nrctremp = 610509) OR (e.cdcooper = 1	AND e.nrdconta = 7071183	AND e.nrctremp = 548925) OR
(e.cdcooper = 1	AND e.nrdconta = 7073909	AND e.nrctremp = 7073909) OR (e.cdcooper = 1	AND e.nrdconta = 7075510	AND e.nrctremp = 361787) OR
(e.cdcooper = 1	AND e.nrdconta = 7076339	AND e.nrctremp = 949592) OR (e.cdcooper = 1	AND e.nrdconta = 7076487	AND e.nrctremp = 730614) OR
(e.cdcooper = 1	AND e.nrdconta = 7076967	AND e.nrctremp = 1163079) OR (e.cdcooper = 1	AND e.nrdconta = 7077050	AND e.nrctremp = 624026) OR
(e.cdcooper = 1	AND e.nrdconta = 7077785	AND e.nrctremp = 364352) OR (e.cdcooper = 1	AND e.nrdconta = 7077823	AND e.nrctremp = 1949393) OR
(e.cdcooper = 1	AND e.nrdconta = 7078978	AND e.nrctremp = 436698) OR (e.cdcooper = 1	AND e.nrdconta = 7078986	AND e.nrctremp = 327722) OR
(e.cdcooper = 1	AND e.nrdconta = 7079052	AND e.nrctremp = 542647) OR (e.cdcooper = 1	AND e.nrdconta = 7080115	AND e.nrctremp = 757253) OR
(e.cdcooper = 1	AND e.nrdconta = 7080131	AND e.nrctremp = 101240) OR (e.cdcooper = 1	AND e.nrdconta = 7083165	AND e.nrctremp = 943992) OR
(e.cdcooper = 1	AND e.nrdconta = 7083599	AND e.nrctremp = 1852999) OR (e.cdcooper = 1	AND e.nrdconta = 7084242	AND e.nrctremp = 1249087) OR
(e.cdcooper = 1	AND e.nrdconta = 7084242	AND e.nrctremp = 1463162) OR (e.cdcooper = 1	AND e.nrdconta = 7084587	AND e.nrctremp = 33978) OR
(e.cdcooper = 1	AND e.nrdconta = 7085583	AND e.nrctremp = 7085583) OR (e.cdcooper = 1	AND e.nrdconta = 7085834	AND e.nrctremp = 438485) OR
(e.cdcooper = 1	AND e.nrdconta = 7086229	AND e.nrctremp = 607369) OR (e.cdcooper = 1	AND e.nrdconta = 7088582	AND e.nrctremp = 7088582) OR
(e.cdcooper = 1	AND e.nrdconta = 7089171	AND e.nrctremp = 1500263) OR (e.cdcooper = 1	AND e.nrdconta = 7089562	AND e.nrctremp = 1043176) OR
(e.cdcooper = 1	AND e.nrdconta = 7089961	AND e.nrctremp = 797237) OR (e.cdcooper = 1	AND e.nrdconta = 7091583	AND e.nrctremp = 121130) OR
(e.cdcooper = 1	AND e.nrdconta = 7091648	AND e.nrctremp = 7091648) OR (e.cdcooper = 1	AND e.nrdconta = 7091770	AND e.nrctremp = 691716) OR
(e.cdcooper = 1	AND e.nrdconta = 7095155	AND e.nrctremp = 7095155) OR (e.cdcooper = 1	AND e.nrdconta = 7095198	AND e.nrctremp = 1272926) OR
(e.cdcooper = 1	AND e.nrdconta = 7095406	AND e.nrctremp = 7095406) OR (e.cdcooper = 1	AND e.nrdconta = 7095660	AND e.nrctremp = 778647) OR
(e.cdcooper = 1	AND e.nrdconta = 7096330	AND e.nrctremp = 1484855) OR (e.cdcooper = 1	AND e.nrdconta = 7096410	AND e.nrctremp = 7096410) OR
(e.cdcooper = 1	AND e.nrdconta = 7097638	AND e.nrctremp = 1265996) OR (e.cdcooper = 1	AND e.nrdconta = 7097964	AND e.nrctremp = 7097964) OR
(e.cdcooper = 1	AND e.nrdconta = 7098049	AND e.nrctremp = 1139184) OR (e.cdcooper = 1	AND e.nrdconta = 7098049	AND e.nrctremp = 1387392) OR
(e.cdcooper = 1	AND e.nrdconta = 7099096	AND e.nrctremp = 1040079) OR (e.cdcooper = 1	AND e.nrdconta = 7099266	AND e.nrctremp = 1094564) OR
(e.cdcooper = 1	AND e.nrdconta = 7099886	AND e.nrctremp = 1012761) OR (e.cdcooper = 1	AND e.nrdconta = 7100388	AND e.nrctremp = 135894) OR
(e.cdcooper = 1	AND e.nrdconta = 7100396	AND e.nrctremp = 1164118) OR (e.cdcooper = 1	AND e.nrdconta = 7100868	AND e.nrctremp = 739690) OR
(e.cdcooper = 1	AND e.nrdconta = 7101058	AND e.nrctremp = 968837) OR (e.cdcooper = 1	AND e.nrdconta = 7101155	AND e.nrctremp = 1356266) OR
(e.cdcooper = 1	AND e.nrdconta = 7101805	AND e.nrctremp = 123347) OR (e.cdcooper = 1	AND e.nrdconta = 7101821	AND e.nrctremp = 7101821) OR
(e.cdcooper = 1	AND e.nrdconta = 7102097	AND e.nrctremp = 639145) OR (e.cdcooper = 1	AND e.nrdconta = 7102879	AND e.nrctremp = 1586907) OR
(e.cdcooper = 1	AND e.nrdconta = 7104405	AND e.nrctremp = 509553) OR (e.cdcooper = 1	AND e.nrdconta = 7104570	AND e.nrctremp = 1114628) OR
(e.cdcooper = 1	AND e.nrdconta = 7105924	AND e.nrctremp = 802667) OR (e.cdcooper = 1	AND e.nrdconta = 7106173	AND e.nrctremp = 1947018) OR
(e.cdcooper = 1	AND e.nrdconta = 7106840	AND e.nrctremp = 1086416) OR (e.cdcooper = 1	AND e.nrdconta = 7107609	AND e.nrctremp = 7107609) OR
(e.cdcooper = 1	AND e.nrdconta = 7108923	AND e.nrctremp = 562223) OR (e.cdcooper = 1	AND e.nrdconta = 7112483	AND e.nrctremp = 7112483) OR
(e.cdcooper = 1	AND e.nrdconta = 7113480	AND e.nrctremp = 2366977) OR (e.cdcooper = 1	AND e.nrdconta = 7114745	AND e.nrctremp = 652275) OR
(e.cdcooper = 1	AND e.nrdconta = 7114966	AND e.nrctremp = 7114966) OR (e.cdcooper = 1	AND e.nrdconta = 7115164	AND e.nrctremp = 215165) OR
(e.cdcooper = 1	AND e.nrdconta = 7121660	AND e.nrctremp = 126756) OR (e.cdcooper = 1	AND e.nrdconta = 7121741	AND e.nrctremp = 1424375) OR
(e.cdcooper = 1	AND e.nrdconta = 7122551	AND e.nrctremp = 7122551) OR (e.cdcooper = 1	AND e.nrdconta = 7122845	AND e.nrctremp = 2004918) OR
(e.cdcooper = 1	AND e.nrdconta = 7125950	AND e.nrctremp = 22449) OR (e.cdcooper = 1	AND e.nrdconta = 7126026	AND e.nrctremp = 38423) OR
(e.cdcooper = 1	AND e.nrdconta = 7126611	AND e.nrctremp = 7126611) OR (e.cdcooper = 1	AND e.nrdconta = 7126786	AND e.nrctremp = 506725) OR
(e.cdcooper = 1	AND e.nrdconta = 7127731	AND e.nrctremp = 905458) OR (e.cdcooper = 1	AND e.nrdconta = 7128053	AND e.nrctremp = 7128053) OR
(e.cdcooper = 1	AND e.nrdconta = 7128240	AND e.nrctremp = 2012934) OR (e.cdcooper = 1	AND e.nrdconta = 7128550	AND e.nrctremp = 1232697) OR
(e.cdcooper = 1	AND e.nrdconta = 7129335	AND e.nrctremp = 650520) OR (e.cdcooper = 1	AND e.nrdconta = 7129491	AND e.nrctremp = 462401) OR
(e.cdcooper = 1	AND e.nrdconta = 7130473	AND e.nrctremp = 763069) OR (e.cdcooper = 1	AND e.nrdconta = 7130953	AND e.nrctremp = 7130953) OR
(e.cdcooper = 1	AND e.nrdconta = 7133251	AND e.nrctremp = 768666) OR (e.cdcooper = 1	AND e.nrdconta = 7133804	AND e.nrctremp = 672073) OR
(e.cdcooper = 1	AND e.nrdconta = 7134118	AND e.nrctremp = 857878) OR (e.cdcooper = 1	AND e.nrdconta = 7134851	AND e.nrctremp = 614111) OR
(e.cdcooper = 1	AND e.nrdconta = 7135734	AND e.nrctremp = 477600) OR (e.cdcooper = 1	AND e.nrdconta = 7136803	AND e.nrctremp = 1277883) OR
(e.cdcooper = 1	AND e.nrdconta = 7137621	AND e.nrctremp = 894294) OR (e.cdcooper = 1	AND e.nrdconta = 7139020	AND e.nrctremp = 1259373) OR
(e.cdcooper = 1	AND e.nrdconta = 7139187	AND e.nrctremp = 1329852) OR (e.cdcooper = 1	AND e.nrdconta = 7139187	AND e.nrctremp = 1586698) OR
(e.cdcooper = 1	AND e.nrdconta = 7139691	AND e.nrctremp = 1513452) OR (e.cdcooper = 1	AND e.nrdconta = 7139896	AND e.nrctremp = 701768) OR
(e.cdcooper = 1	AND e.nrdconta = 7140096	AND e.nrctremp = 987521) OR (e.cdcooper = 1	AND e.nrdconta = 7140487	AND e.nrctremp = 94320) OR
(e.cdcooper = 1	AND e.nrdconta = 7140568	AND e.nrctremp = 617984) OR (e.cdcooper = 1	AND e.nrdconta = 7141521	AND e.nrctremp = 1436291) OR
(e.cdcooper = 1	AND e.nrdconta = 7143141	AND e.nrctremp = 7143141) OR (e.cdcooper = 1	AND e.nrdconta = 7143346	AND e.nrctremp = 1513699) OR
(e.cdcooper = 1	AND e.nrdconta = 7143443	AND e.nrctremp = 7143443) OR (e.cdcooper = 1	AND e.nrdconta = 7146884	AND e.nrctremp = 982631) OR
(e.cdcooper = 1	AND e.nrdconta = 7147279	AND e.nrctremp = 1388145) OR (e.cdcooper = 1	AND e.nrdconta = 7149336	AND e.nrctremp = 33325) OR
(e.cdcooper = 1	AND e.nrdconta = 7149689	AND e.nrctremp = 7149689) OR (e.cdcooper = 1	AND e.nrdconta = 7150245	AND e.nrctremp = 602930) OR
(e.cdcooper = 1	AND e.nrdconta = 7150369	AND e.nrctremp = 831975) OR (e.cdcooper = 1	AND e.nrdconta = 7152345	AND e.nrctremp = 7152345) OR
(e.cdcooper = 1	AND e.nrdconta = 7153384	AND e.nrctremp = 1666819) OR (e.cdcooper = 1	AND e.nrdconta = 7153791	AND e.nrctremp = 1469333) OR
(e.cdcooper = 1	AND e.nrdconta = 7154216	AND e.nrctremp = 617864) OR (e.cdcooper = 1	AND e.nrdconta = 7154941	AND e.nrctremp = 1532308) OR
(e.cdcooper = 1	AND e.nrdconta = 7155280	AND e.nrctremp = 861876) OR (e.cdcooper = 1	AND e.nrdconta = 7155875	AND e.nrctremp = 647124) OR
(e.cdcooper = 1	AND e.nrdconta = 7156421	AND e.nrctremp = 60997) OR (e.cdcooper = 1	AND e.nrdconta = 7156464	AND e.nrctremp = 1103861) OR
(e.cdcooper = 1	AND e.nrdconta = 7156910	AND e.nrctremp = 7156910) OR (e.cdcooper = 1	AND e.nrdconta = 7157061	AND e.nrctremp = 1587515) OR
(e.cdcooper = 1	AND e.nrdconta = 7158130	AND e.nrctremp = 553026) OR (e.cdcooper = 1	AND e.nrdconta = 7158866	AND e.nrctremp = 339057) OR
(e.cdcooper = 1	AND e.nrdconta = 7159242	AND e.nrctremp = 666239) OR (e.cdcooper = 1	AND e.nrdconta = 7159765	AND e.nrctremp = 7159765) OR
(e.cdcooper = 1	AND e.nrdconta = 7160097	AND e.nrctremp = 7160097) OR (e.cdcooper = 1	AND e.nrdconta = 7160224	AND e.nrctremp = 1076112) OR
(e.cdcooper = 1	AND e.nrdconta = 7160909	AND e.nrctremp = 7160909) OR (e.cdcooper = 1	AND e.nrdconta = 7162634	AND e.nrctremp = 1889495) OR
(e.cdcooper = 1	AND e.nrdconta = 7163037	AND e.nrctremp = 7163037) OR (e.cdcooper = 1	AND e.nrdconta = 7163436	AND e.nrctremp = 7163436) OR
(e.cdcooper = 1	AND e.nrdconta = 7163770	AND e.nrctremp = 7163770) OR (e.cdcooper = 1	AND e.nrdconta = 7163959	AND e.nrctremp = 45636) OR
(e.cdcooper = 1	AND e.nrdconta = 7164190	AND e.nrctremp = 117834) OR (e.cdcooper = 1	AND e.nrdconta = 7165030	AND e.nrctremp = 742159) OR
(e.cdcooper = 1	AND e.nrdconta = 7165480	AND e.nrctremp = 1208144) OR (e.cdcooper = 1	AND e.nrdconta = 7166281	AND e.nrctremp = 668369) OR
(e.cdcooper = 1	AND e.nrdconta = 7167296	AND e.nrctremp = 818891) OR (e.cdcooper = 1	AND e.nrdconta = 7167326	AND e.nrctremp = 510059) OR
(e.cdcooper = 1	AND e.nrdconta = 7168098	AND e.nrctremp = 1046663) OR (e.cdcooper = 1	AND e.nrdconta = 7168837	AND e.nrctremp = 7168837) OR
(e.cdcooper = 1	AND e.nrdconta = 7169400	AND e.nrctremp = 920498) OR (e.cdcooper = 1	AND e.nrdconta = 7169469	AND e.nrctremp = 7169469) OR
(e.cdcooper = 1	AND e.nrdconta = 7171129	AND e.nrctremp = 499911) OR (e.cdcooper = 1	AND e.nrdconta = 7171129	AND e.nrctremp = 7171129) OR
(e.cdcooper = 1	AND e.nrdconta = 7172036	AND e.nrctremp = 1036072) OR (e.cdcooper = 1	AND e.nrdconta = 7173350	AND e.nrctremp = 572935) OR
(e.cdcooper = 1	AND e.nrdconta = 7175051	AND e.nrctremp = 7175051) OR (e.cdcooper = 1	AND e.nrdconta = 7176015	AND e.nrctremp = 7176015) OR
(e.cdcooper = 1	AND e.nrdconta = 7176023	AND e.nrctremp = 7176023) OR (e.cdcooper = 1	AND e.nrdconta = 7176481	AND e.nrctremp = 1300108) OR
(e.cdcooper = 1	AND e.nrdconta = 7178786	AND e.nrctremp = 804565) OR (e.cdcooper = 1	AND e.nrdconta = 7179138	AND e.nrctremp = 771600) OR
(e.cdcooper = 1	AND e.nrdconta = 7179138	AND e.nrctremp = 1270069) OR (e.cdcooper = 1	AND e.nrdconta = 7179502	AND e.nrctremp = 1304919) OR
(e.cdcooper = 1	AND e.nrdconta = 7179707	AND e.nrctremp = 848894) OR (e.cdcooper = 1	AND e.nrdconta = 7180519	AND e.nrctremp = 1221779) OR
(e.cdcooper = 1	AND e.nrdconta = 7182180	AND e.nrctremp = 835433) OR (e.cdcooper = 1	AND e.nrdconta = 7183119	AND e.nrctremp = 7183119) OR
(e.cdcooper = 1	AND e.nrdconta = 7185430	AND e.nrctremp = 860062) OR (e.cdcooper = 1	AND e.nrdconta = 7185570	AND e.nrctremp = 283362) OR
(e.cdcooper = 1	AND e.nrdconta = 7186142	AND e.nrctremp = 547085) OR (e.cdcooper = 1	AND e.nrdconta = 7186487	AND e.nrctremp = 536553) OR
(e.cdcooper = 1	AND e.nrdconta = 7186487	AND e.nrctremp = 898872) OR (e.cdcooper = 1	AND e.nrdconta = 7186606	AND e.nrctremp = 7186606) OR
(e.cdcooper = 1	AND e.nrdconta = 7186860	AND e.nrctremp = 7186860) OR (e.cdcooper = 1	AND e.nrdconta = 7189192	AND e.nrctremp = 133124) OR
(e.cdcooper = 1	AND e.nrdconta = 7189354	AND e.nrctremp = 955255) OR (e.cdcooper = 1	AND e.nrdconta = 7190484	AND e.nrctremp = 561760) OR
(e.cdcooper = 1	AND e.nrdconta = 7191251	AND e.nrctremp = 338753) OR (e.cdcooper = 1	AND e.nrdconta = 7191561	AND e.nrctremp = 836125) OR
(e.cdcooper = 1	AND e.nrdconta = 7192495	AND e.nrctremp = 821346) OR (e.cdcooper = 1	AND e.nrdconta = 7192606	AND e.nrctremp = 751062) OR
(e.cdcooper = 1	AND e.nrdconta = 7192819	AND e.nrctremp = 148353) OR (e.cdcooper = 1	AND e.nrdconta = 7193181	AND e.nrctremp = 317894) OR
(e.cdcooper = 1	AND e.nrdconta = 7193645	AND e.nrctremp = 7193645) OR (e.cdcooper = 1	AND e.nrdconta = 7194340	AND e.nrctremp = 1168745) OR
(e.cdcooper = 1	AND e.nrdconta = 7194684	AND e.nrctremp = 1596308) OR (e.cdcooper = 1	AND e.nrdconta = 7195109	AND e.nrctremp = 1083966) OR
(e.cdcooper = 1	AND e.nrdconta = 7195265	AND e.nrctremp = 713713) OR (e.cdcooper = 1	AND e.nrdconta = 7195508	AND e.nrctremp = 1261543) OR
(e.cdcooper = 1	AND e.nrdconta = 7196059	AND e.nrctremp = 531381) OR (e.cdcooper = 1	AND e.nrdconta = 7199325	AND e.nrctremp = 1619285) OR
(e.cdcooper = 1	AND e.nrdconta = 7199511	AND e.nrctremp = 1014794) OR (e.cdcooper = 1	AND e.nrdconta = 7199635	AND e.nrctremp = 718366) OR
(e.cdcooper = 1	AND e.nrdconta = 7199996	AND e.nrctremp = 1654416) OR (e.cdcooper = 1	AND e.nrdconta = 7200145	AND e.nrctremp = 7200145) OR
(e.cdcooper = 1	AND e.nrdconta = 7200544	AND e.nrctremp = 682688) OR (e.cdcooper = 1	AND e.nrdconta = 7201494	AND e.nrctremp = 1066239) OR
(e.cdcooper = 1	AND e.nrdconta = 7201800	AND e.nrctremp = 7201800) OR (e.cdcooper = 1	AND e.nrdconta = 7202296	AND e.nrctremp = 1467444) OR
(e.cdcooper = 1	AND e.nrdconta = 7202903	AND e.nrctremp = 127288) OR (e.cdcooper = 1	AND e.nrdconta = 7203543	AND e.nrctremp = 198267) OR
(e.cdcooper = 1	AND e.nrdconta = 7204515	AND e.nrctremp = 7204515) OR (e.cdcooper = 1	AND e.nrdconta = 7205317	AND e.nrctremp = 441524) OR
(e.cdcooper = 1	AND e.nrdconta = 7205961	AND e.nrctremp = 1048880) OR (e.cdcooper = 1	AND e.nrdconta = 7210647	AND e.nrctremp = 1297512) OR
(e.cdcooper = 1	AND e.nrdconta = 7210817	AND e.nrctremp = 751974) OR (e.cdcooper = 1	AND e.nrdconta = 7210973	AND e.nrctremp = 743132) OR
(e.cdcooper = 1	AND e.nrdconta = 7211201	AND e.nrctremp = 1201295) OR (e.cdcooper = 1	AND e.nrdconta = 7211562	AND e.nrctremp = 525545) OR
(e.cdcooper = 1	AND e.nrdconta = 7212259	AND e.nrctremp = 685525) OR (e.cdcooper = 1	AND e.nrdconta = 7212674	AND e.nrctremp = 1853671) OR
(e.cdcooper = 1	AND e.nrdconta = 7212755	AND e.nrctremp = 934086) OR (e.cdcooper = 1	AND e.nrdconta = 7212879	AND e.nrctremp = 536009) OR
(e.cdcooper = 1	AND e.nrdconta = 7213182	AND e.nrctremp = 190009) OR (e.cdcooper = 1	AND e.nrdconta = 7213263	AND e.nrctremp = 123693) OR
(e.cdcooper = 1	AND e.nrdconta = 7213441	AND e.nrctremp = 1921173) OR (e.cdcooper = 1	AND e.nrdconta = 7213557	AND e.nrctremp = 663131) OR
(e.cdcooper = 1	AND e.nrdconta = 7214928	AND e.nrctremp = 976999) OR (e.cdcooper = 1	AND e.nrdconta = 7214952	AND e.nrctremp = 177326) OR
(e.cdcooper = 1	AND e.nrdconta = 7218079	AND e.nrctremp = 765121) OR (e.cdcooper = 1	AND e.nrdconta = 7220405	AND e.nrctremp = 675921) OR
(e.cdcooper = 1	AND e.nrdconta = 7221231	AND e.nrctremp = 468825) OR (e.cdcooper = 1	AND e.nrdconta = 7221428	AND e.nrctremp = 7221428) OR
(e.cdcooper = 1	AND e.nrdconta = 7222378	AND e.nrctremp = 7222378) OR (e.cdcooper = 1	AND e.nrdconta = 7223870	AND e.nrctremp = 7223870) OR
(e.cdcooper = 1	AND e.nrdconta = 7223943	AND e.nrctremp = 548834) OR (e.cdcooper = 1	AND e.nrdconta = 7223978	AND e.nrctremp = 624285) OR
(e.cdcooper = 1	AND e.nrdconta = 7223986	AND e.nrctremp = 549455) OR (e.cdcooper = 1	AND e.nrdconta = 7224494	AND e.nrctremp = 940181) OR
(e.cdcooper = 1	AND e.nrdconta = 7225172	AND e.nrctremp = 1597691) OR (e.cdcooper = 1	AND e.nrdconta = 7225300	AND e.nrctremp = 1141964) OR
(e.cdcooper = 1	AND e.nrdconta = 7227108	AND e.nrctremp = 7227108) OR (e.cdcooper = 1	AND e.nrdconta = 7227191	AND e.nrctremp = 316156) OR
(e.cdcooper = 1	AND e.nrdconta = 7227973	AND e.nrctremp = 7227973) OR (e.cdcooper = 1	AND e.nrdconta = 7230770	AND e.nrctremp = 527707) OR
(e.cdcooper = 1	AND e.nrdconta = 7231601	AND e.nrctremp = 516190) OR (e.cdcooper = 1	AND e.nrdconta = 7233990	AND e.nrctremp = 1526132) OR
(e.cdcooper = 1	AND e.nrdconta = 7234155	AND e.nrctremp = 455557) OR (e.cdcooper = 1	AND e.nrdconta = 7235690	AND e.nrctremp = 7235690) OR
(e.cdcooper = 1	AND e.nrdconta = 7237456	AND e.nrctremp = 1042053) OR (e.cdcooper = 1	AND e.nrdconta = 7237901	AND e.nrctremp = 7237901) OR
(e.cdcooper = 1	AND e.nrdconta = 7239378	AND e.nrctremp = 7239378) OR (e.cdcooper = 1	AND e.nrdconta = 7239971	AND e.nrctremp = 117305) OR
(e.cdcooper = 1	AND e.nrdconta = 7240201	AND e.nrctremp = 7240201) OR (e.cdcooper = 1	AND e.nrdconta = 7240520	AND e.nrctremp = 1116703) OR
(e.cdcooper = 1	AND e.nrdconta = 7240635	AND e.nrctremp = 323163) OR (e.cdcooper = 1	AND e.nrdconta = 7241399	AND e.nrctremp = 520088) OR
(e.cdcooper = 1	AND e.nrdconta = 7241801	AND e.nrctremp = 698721) OR (e.cdcooper = 1	AND e.nrdconta = 7242620	AND e.nrctremp = 21551) OR
(e.cdcooper = 1	AND e.nrdconta = 7242700	AND e.nrctremp = 37782) OR (e.cdcooper = 1	AND e.nrdconta = 7245351	AND e.nrctremp = 1157741) OR
(e.cdcooper = 1	AND e.nrdconta = 7245360	AND e.nrctremp = 1724020) OR (e.cdcooper = 1	AND e.nrdconta = 7245610	AND e.nrctremp = 7245610) OR
(e.cdcooper = 1	AND e.nrdconta = 7245734	AND e.nrctremp = 493548) OR (e.cdcooper = 1	AND e.nrdconta = 7245858	AND e.nrctremp = 7245858) OR
(e.cdcooper = 1	AND e.nrdconta = 7246510	AND e.nrctremp = 646755) OR (e.cdcooper = 1	AND e.nrdconta = 7246641	AND e.nrctremp = 7246641) OR
(e.cdcooper = 1	AND e.nrdconta = 7247729	AND e.nrctremp = 171271) OR (e.cdcooper = 1	AND e.nrdconta = 7248237	AND e.nrctremp = 1018097) OR
(e.cdcooper = 1	AND e.nrdconta = 7248318	AND e.nrctremp = 777227) OR (e.cdcooper = 1	AND e.nrdconta = 7248709	AND e.nrctremp = 1145617) OR
(e.cdcooper = 1	AND e.nrdconta = 7250002	AND e.nrctremp = 1100798) OR (e.cdcooper = 1	AND e.nrdconta = 7252960	AND e.nrctremp = 1172243) OR
(e.cdcooper = 1	AND e.nrdconta = 7254423	AND e.nrctremp = 1344637) OR (e.cdcooper = 1	AND e.nrdconta = 7254431	AND e.nrctremp = 674459) OR
(e.cdcooper = 1	AND e.nrdconta = 7255268	AND e.nrctremp = 139516) OR (e.cdcooper = 1	AND e.nrdconta = 7255586	AND e.nrctremp = 7255586) OR
(e.cdcooper = 1	AND e.nrdconta = 7255705	AND e.nrctremp = 1235658) OR (e.cdcooper = 1	AND e.nrdconta = 7256353	AND e.nrctremp = 321992) OR
(e.cdcooper = 1	AND e.nrdconta = 7256400	AND e.nrctremp = 403573) OR (e.cdcooper = 1	AND e.nrdconta = 7256680	AND e.nrctremp = 7256680) OR
(e.cdcooper = 1	AND e.nrdconta = 7257996	AND e.nrctremp = 7257996) OR (e.cdcooper = 1	AND e.nrdconta = 7258887	AND e.nrctremp = 886322) OR
(e.cdcooper = 1	AND e.nrdconta = 7258909	AND e.nrctremp = 7258909) OR (e.cdcooper = 1	AND e.nrdconta = 7258992	AND e.nrctremp = 7258992) OR
(e.cdcooper = 1	AND e.nrdconta = 7259042	AND e.nrctremp = 1053233) OR (e.cdcooper = 1	AND e.nrdconta = 7259140	AND e.nrctremp = 686894) OR
(e.cdcooper = 1	AND e.nrdconta = 7259565	AND e.nrctremp = 693732) OR (e.cdcooper = 1	AND e.nrdconta = 7260563	AND e.nrctremp = 636734) OR
(e.cdcooper = 1	AND e.nrdconta = 7260580	AND e.nrctremp = 96473) OR (e.cdcooper = 1	AND e.nrdconta = 7260598	AND e.nrctremp = 689420) OR
(e.cdcooper = 1	AND e.nrdconta = 7261241	AND e.nrctremp = 598641) OR (e.cdcooper = 1	AND e.nrdconta = 7261322	AND e.nrctremp = 351764) OR
(e.cdcooper = 1	AND e.nrdconta = 7261420	AND e.nrctremp = 829786) OR (e.cdcooper = 1	AND e.nrdconta = 7261829	AND e.nrctremp = 555172) OR
(e.cdcooper = 1	AND e.nrdconta = 7262450	AND e.nrctremp = 913063) OR (e.cdcooper = 1	AND e.nrdconta = 7262620	AND e.nrctremp = 448584) OR
(e.cdcooper = 1	AND e.nrdconta = 7263554	AND e.nrctremp = 686111) OR (e.cdcooper = 1	AND e.nrdconta = 7264160	AND e.nrctremp = 7264160) OR
(e.cdcooper = 1	AND e.nrdconta = 7265603	AND e.nrctremp = 1654948) OR (e.cdcooper = 1	AND e.nrdconta = 7266553	AND e.nrctremp = 146075) OR
(e.cdcooper = 1	AND e.nrdconta = 7266880	AND e.nrctremp = 7266880) OR (e.cdcooper = 1	AND e.nrdconta = 7266960	AND e.nrctremp = 488638) OR
(e.cdcooper = 1	AND e.nrdconta = 7266995	AND e.nrctremp = 146079) OR (e.cdcooper = 1	AND e.nrdconta = 7267657	AND e.nrctremp = 7267657) OR
(e.cdcooper = 1	AND e.nrdconta = 7267789	AND e.nrctremp = 143160) OR (e.cdcooper = 1	AND e.nrdconta = 7268289	AND e.nrctremp = 1139296) OR
(e.cdcooper = 1	AND e.nrdconta = 7268750	AND e.nrctremp = 7268750) OR (e.cdcooper = 1	AND e.nrdconta = 7268840	AND e.nrctremp = 1026489) OR
(e.cdcooper = 1	AND e.nrdconta = 7269080	AND e.nrctremp = 686432) OR (e.cdcooper = 1	AND e.nrdconta = 7271654	AND e.nrctremp = 590734) OR
(e.cdcooper = 1	AND e.nrdconta = 7272570	AND e.nrctremp = 7272570) OR (e.cdcooper = 1	AND e.nrdconta = 7272766	AND e.nrctremp = 7272766) OR
(e.cdcooper = 1	AND e.nrdconta = 7272995	AND e.nrctremp = 797123) OR (e.cdcooper = 1	AND e.nrdconta = 7277377	AND e.nrctremp = 7277377) OR
(e.cdcooper = 1	AND e.nrdconta = 7277881	AND e.nrctremp = 1404297) OR (e.cdcooper = 1	AND e.nrdconta = 7278527	AND e.nrctremp = 158742) OR
(e.cdcooper = 1	AND e.nrdconta = 7278926	AND e.nrctremp = 153176) OR (e.cdcooper = 1	AND e.nrdconta = 7279590	AND e.nrctremp = 656624) OR
(e.cdcooper = 1	AND e.nrdconta = 7280416	AND e.nrctremp = 1216459) OR (e.cdcooper = 1	AND e.nrdconta = 7282443	AND e.nrctremp = 7282443) OR
(e.cdcooper = 1	AND e.nrdconta = 7283768	AND e.nrctremp = 132881) OR (e.cdcooper = 1	AND e.nrdconta = 7283806	AND e.nrctremp = 190708) OR
(e.cdcooper = 1	AND e.nrdconta = 7283938	AND e.nrctremp = 132773) OR (e.cdcooper = 1	AND e.nrdconta = 7284543	AND e.nrctremp = 825770) OR
(e.cdcooper = 1	AND e.nrdconta = 7286260	AND e.nrctremp = 1587361) OR (e.cdcooper = 1	AND e.nrdconta = 7286481	AND e.nrctremp = 7286481) OR
(e.cdcooper = 1	AND e.nrdconta = 7287399	AND e.nrctremp = 1878891) OR (e.cdcooper = 1	AND e.nrdconta = 7287852	AND e.nrctremp = 603280) OR
(e.cdcooper = 1	AND e.nrdconta = 7288433	AND e.nrctremp = 1033352) OR (e.cdcooper = 1	AND e.nrdconta = 7288751	AND e.nrctremp = 7288751) OR
(e.cdcooper = 1	AND e.nrdconta = 7289871	AND e.nrctremp = 1224699) OR (e.cdcooper = 1	AND e.nrdconta = 7290357	AND e.nrctremp = 22813) OR
(e.cdcooper = 1	AND e.nrdconta = 7291485	AND e.nrctremp = 389879) OR (e.cdcooper = 1	AND e.nrdconta = 7291892	AND e.nrctremp = 76675) OR
(e.cdcooper = 1	AND e.nrdconta = 7294670	AND e.nrctremp = 49003) OR (e.cdcooper = 1	AND e.nrdconta = 7294867	AND e.nrctremp = 323989) OR
(e.cdcooper = 1	AND e.nrdconta = 7295049	AND e.nrctremp = 875642) OR (e.cdcooper = 1	AND e.nrdconta = 7298528	AND e.nrctremp = 563421) OR
(e.cdcooper = 1	AND e.nrdconta = 7300034	AND e.nrctremp = 7300034) OR (e.cdcooper = 1	AND e.nrdconta = 7300816	AND e.nrctremp = 129301) OR
(e.cdcooper = 1	AND e.nrdconta = 7301057	AND e.nrctremp = 988634) OR (e.cdcooper = 1	AND e.nrdconta = 7301405	AND e.nrctremp = 913568) OR
(e.cdcooper = 1	AND e.nrdconta = 7301820	AND e.nrctremp = 187730) OR (e.cdcooper = 1	AND e.nrdconta = 7302967	AND e.nrctremp = 979057) OR
(e.cdcooper = 1	AND e.nrdconta = 7303254	AND e.nrctremp = 488676) OR (e.cdcooper = 1	AND e.nrdconta = 7304714	AND e.nrctremp = 757923) OR
(e.cdcooper = 1	AND e.nrdconta = 7304846	AND e.nrctremp = 683070) OR (e.cdcooper = 1	AND e.nrdconta = 7304846	AND e.nrctremp = 701029) OR
(e.cdcooper = 1	AND e.nrdconta = 7304986	AND e.nrctremp = 1002189) OR (e.cdcooper = 1	AND e.nrdconta = 7305214	AND e.nrctremp = 551916) OR
(e.cdcooper = 1	AND e.nrdconta = 7305664	AND e.nrctremp = 7305664) OR (e.cdcooper = 1	AND e.nrdconta = 7306601	AND e.nrctremp = 1052099) OR
(e.cdcooper = 1	AND e.nrdconta = 7307438	AND e.nrctremp = 7307438) OR (e.cdcooper = 1	AND e.nrdconta = 7307896	AND e.nrctremp = 11339) OR
(e.cdcooper = 1	AND e.nrdconta = 7308957	AND e.nrctremp = 7308957) OR (e.cdcooper = 1	AND e.nrdconta = 7308973	AND e.nrctremp = 7308973) OR
(e.cdcooper = 1	AND e.nrdconta = 7313152	AND e.nrctremp = 7313152) OR (e.cdcooper = 1	AND e.nrdconta = 7313845	AND e.nrctremp = 7313845) OR
(e.cdcooper = 1	AND e.nrdconta = 7315198	AND e.nrctremp = 1036171) OR (e.cdcooper = 1	AND e.nrdconta = 7315791	AND e.nrctremp = 763284) OR
(e.cdcooper = 1	AND e.nrdconta = 7316410	AND e.nrctremp = 677331) OR (e.cdcooper = 1	AND e.nrdconta = 7316763	AND e.nrctremp = 423622) OR
(e.cdcooper = 1	AND e.nrdconta = 7317115	AND e.nrctremp = 21048) OR (e.cdcooper = 1	AND e.nrdconta = 7320540	AND e.nrctremp = 882828) OR
(e.cdcooper = 1	AND e.nrdconta = 7322330	AND e.nrctremp = 7322330) OR (e.cdcooper = 1	AND e.nrdconta = 7322550	AND e.nrctremp = 1704032) OR
(e.cdcooper = 1	AND e.nrdconta = 7323646	AND e.nrctremp = 1341007) OR (e.cdcooper = 1	AND e.nrdconta = 7331983	AND e.nrctremp = 7331983) OR
(e.cdcooper = 1	AND e.nrdconta = 7332467	AND e.nrctremp = 1920981) OR (e.cdcooper = 1	AND e.nrdconta = 7335040	AND e.nrctremp = 7335040) OR
(e.cdcooper = 1	AND e.nrdconta = 7335490	AND e.nrctremp = 898972) OR (e.cdcooper = 1	AND e.nrdconta = 7336888	AND e.nrctremp = 909819) OR
(e.cdcooper = 1	AND e.nrdconta = 7337019	AND e.nrctremp = 1112327) OR (e.cdcooper = 1	AND e.nrdconta = 7337361	AND e.nrctremp = 509745) OR
(e.cdcooper = 1	AND e.nrdconta = 7338287	AND e.nrctremp = 1120415) OR (e.cdcooper = 1	AND e.nrdconta = 7339321	AND e.nrctremp = 882185) OR
(e.cdcooper = 1	AND e.nrdconta = 7339780	AND e.nrctremp = 7339780) OR (e.cdcooper = 1	AND e.nrdconta = 7341555	AND e.nrctremp = 7341555) OR
(e.cdcooper = 1	AND e.nrdconta = 7341997	AND e.nrctremp = 758505) OR (e.cdcooper = 1	AND e.nrdconta = 7342691	AND e.nrctremp = 899028) OR
(e.cdcooper = 1	AND e.nrdconta = 7343019	AND e.nrctremp = 7343019) OR (e.cdcooper = 1	AND e.nrdconta = 7343310	AND e.nrctremp = 1385369) OR
(e.cdcooper = 1	AND e.nrdconta = 7343850	AND e.nrctremp = 298365) OR (e.cdcooper = 1	AND e.nrdconta = 7343850	AND e.nrctremp = 404859) OR
(e.cdcooper = 1	AND e.nrdconta = 7344015	AND e.nrctremp = 425437) OR (e.cdcooper = 1	AND e.nrdconta = 7344899	AND e.nrctremp = 187129) OR
(e.cdcooper = 1	AND e.nrdconta = 7346263	AND e.nrctremp = 1169363) OR (e.cdcooper = 1	AND e.nrdconta = 7346620	AND e.nrctremp = 404382) OR
(e.cdcooper = 1	AND e.nrdconta = 7346999	AND e.nrctremp = 448407) OR (e.cdcooper = 1	AND e.nrdconta = 7347650	AND e.nrctremp = 1532219) OR
(e.cdcooper = 1	AND e.nrdconta = 7348746	AND e.nrctremp = 1393681) OR (e.cdcooper = 1	AND e.nrdconta = 7349092	AND e.nrctremp = 7349092) OR
(e.cdcooper = 1	AND e.nrdconta = 7349416	AND e.nrctremp = 1047178) OR (e.cdcooper = 1	AND e.nrdconta = 7349521	AND e.nrctremp = 1535262) OR
(e.cdcooper = 1	AND e.nrdconta = 7349556	AND e.nrctremp = 353446) OR (e.cdcooper = 1	AND e.nrdconta = 7352450	AND e.nrctremp = 300758) OR
(e.cdcooper = 1	AND e.nrdconta = 7353049	AND e.nrctremp = 406839) OR (e.cdcooper = 1	AND e.nrdconta = 7354070	AND e.nrctremp = 1366736) OR
(e.cdcooper = 1	AND e.nrdconta = 7354886	AND e.nrctremp = 499579) OR (e.cdcooper = 1	AND e.nrdconta = 7354983	AND e.nrctremp = 156037) OR
(e.cdcooper = 1	AND e.nrdconta = 7355637	AND e.nrctremp = 144799) OR (e.cdcooper = 1	AND e.nrdconta = 7355661	AND e.nrctremp = 124682) OR
(e.cdcooper = 1	AND e.nrdconta = 7356145	AND e.nrctremp = 1462201) OR (e.cdcooper = 1	AND e.nrdconta = 7356781	AND e.nrctremp = 1074406) OR
(e.cdcooper = 1	AND e.nrdconta = 7357176	AND e.nrctremp = 525995) OR (e.cdcooper = 1	AND e.nrdconta = 7357214	AND e.nrctremp = 1202552) OR
(e.cdcooper = 1	AND e.nrdconta = 7357222	AND e.nrctremp = 624901) OR (e.cdcooper = 1	AND e.nrdconta = 7358458	AND e.nrctremp = 997475) OR
(e.cdcooper = 1	AND e.nrdconta = 7361483	AND e.nrctremp = 830164) OR (e.cdcooper = 1	AND e.nrdconta = 7361793	AND e.nrctremp = 747453) OR
(e.cdcooper = 1	AND e.nrdconta = 7362331	AND e.nrctremp = 710407) OR (e.cdcooper = 1	AND e.nrdconta = 7363168	AND e.nrctremp = 1405146) OR
(e.cdcooper = 1	AND e.nrdconta = 7364024	AND e.nrctremp = 7364024) OR (e.cdcooper = 1	AND e.nrdconta = 7364733	AND e.nrctremp = 11124) OR
(e.cdcooper = 1	AND e.nrdconta = 7365004	AND e.nrctremp = 1949518) OR (e.cdcooper = 1	AND e.nrdconta = 7365454	AND e.nrctremp = 683465) OR
(e.cdcooper = 1	AND e.nrdconta = 7365560	AND e.nrctremp = 1920903) OR (e.cdcooper = 1	AND e.nrdconta = 7365748	AND e.nrctremp = 7365748) OR
(e.cdcooper = 1	AND e.nrdconta = 7366485	AND e.nrctremp = 595938) OR (e.cdcooper = 1	AND e.nrdconta = 7366965	AND e.nrctremp = 576960) OR
(e.cdcooper = 1	AND e.nrdconta = 7367392	AND e.nrctremp = 1696220) OR (e.cdcooper = 1	AND e.nrdconta = 7368461	AND e.nrctremp = 1696440) OR
(e.cdcooper = 1	AND e.nrdconta = 7368909	AND e.nrctremp = 700522) OR (e.cdcooper = 1	AND e.nrdconta = 7370075	AND e.nrctremp = 821870) OR
(e.cdcooper = 1	AND e.nrdconta = 7370709	AND e.nrctremp = 1302233) OR (e.cdcooper = 1	AND e.nrdconta = 7372515	AND e.nrctremp = 1161682) OR
(e.cdcooper = 1	AND e.nrdconta = 7374011	AND e.nrctremp = 498150) OR (e.cdcooper = 1	AND e.nrdconta = 7374933	AND e.nrctremp = 7374933) OR
(e.cdcooper = 1	AND e.nrdconta = 7375638	AND e.nrctremp = 994979) OR (e.cdcooper = 1	AND e.nrdconta = 7377592	AND e.nrctremp = 660822) OR
(e.cdcooper = 1	AND e.nrdconta = 7378955	AND e.nrctremp = 537169) OR (e.cdcooper = 1	AND e.nrdconta = 7379013	AND e.nrctremp = 982405) OR
(e.cdcooper = 1	AND e.nrdconta = 7379277	AND e.nrctremp = 917628) OR (e.cdcooper = 1	AND e.nrdconta = 7379480	AND e.nrctremp = 196248) OR
(e.cdcooper = 1	AND e.nrdconta = 7380020	AND e.nrctremp = 692796) OR (e.cdcooper = 1	AND e.nrdconta = 7383150	AND e.nrctremp = 858978) OR
(e.cdcooper = 1	AND e.nrdconta = 7384378	AND e.nrctremp = 391461) OR (e.cdcooper = 1	AND e.nrdconta = 7388284	AND e.nrctremp = 156418) OR
(e.cdcooper = 1	AND e.nrdconta = 7389612	AND e.nrctremp = 76839) OR (e.cdcooper = 1	AND e.nrdconta = 7389809	AND e.nrctremp = 751048) OR
(e.cdcooper = 1	AND e.nrdconta = 7389949	AND e.nrctremp = 754158) OR (e.cdcooper = 1	AND e.nrdconta = 7390815	AND e.nrctremp = 7390815) OR
(e.cdcooper = 1	AND e.nrdconta = 7391358	AND e.nrctremp = 7391358) OR (e.cdcooper = 1	AND e.nrdconta = 7391544	AND e.nrctremp = 927602) OR
(e.cdcooper = 1	AND e.nrdconta = 7391951	AND e.nrctremp = 554470) OR (e.cdcooper = 1	AND e.nrdconta = 7392796	AND e.nrctremp = 7392796) OR
(e.cdcooper = 1	AND e.nrdconta = 7393172	AND e.nrctremp = 1452695) OR (e.cdcooper = 1	AND e.nrdconta = 7393385	AND e.nrctremp = 708422) OR
(e.cdcooper = 1	AND e.nrdconta = 7393547	AND e.nrctremp = 595176) OR (e.cdcooper = 1	AND e.nrdconta = 7393768	AND e.nrctremp = 558475) OR
(e.cdcooper = 1	AND e.nrdconta = 7394403	AND e.nrctremp = 848522) OR (e.cdcooper = 1	AND e.nrdconta = 7395116	AND e.nrctremp = 7395116) OR
(e.cdcooper = 1	AND e.nrdconta = 7395647	AND e.nrctremp = 883199) OR (e.cdcooper = 1	AND e.nrdconta = 7398999	AND e.nrctremp = 786971) OR
(e.cdcooper = 1	AND e.nrdconta = 7399090	AND e.nrctremp = 7399090) OR (e.cdcooper = 1	AND e.nrdconta = 7399120	AND e.nrctremp = 7399120) OR
(e.cdcooper = 1	AND e.nrdconta = 7400144	AND e.nrctremp = 367052) OR (e.cdcooper = 1	AND e.nrdconta = 7403267	AND e.nrctremp = 724455) OR
(e.cdcooper = 1	AND e.nrdconta = 7403445	AND e.nrctremp = 7403445) OR (e.cdcooper = 1	AND e.nrdconta = 7404158	AND e.nrctremp = 1103511) OR
(e.cdcooper = 1	AND e.nrdconta = 7404530	AND e.nrctremp = 1320871) OR (e.cdcooper = 1	AND e.nrdconta = 7405820	AND e.nrctremp = 1541736) OR
(e.cdcooper = 1	AND e.nrdconta = 7405871	AND e.nrctremp = 676832) OR (e.cdcooper = 1	AND e.nrdconta = 7406622	AND e.nrctremp = 7406622) OR
(e.cdcooper = 1	AND e.nrdconta = 7407920	AND e.nrctremp = 1360474) OR (e.cdcooper = 1	AND e.nrdconta = 7408056	AND e.nrctremp = 1540519) OR
(e.cdcooper = 1	AND e.nrdconta = 7408587	AND e.nrctremp = 850417) OR (e.cdcooper = 1	AND e.nrdconta = 7408846	AND e.nrctremp = 1177953) OR
(e.cdcooper = 1	AND e.nrdconta = 7408900	AND e.nrctremp = 1928186) OR (e.cdcooper = 1	AND e.nrdconta = 7409125	AND e.nrctremp = 389439) OR
(e.cdcooper = 1	AND e.nrdconta = 7410123	AND e.nrctremp = 7410123) OR (e.cdcooper = 1	AND e.nrdconta = 7410786	AND e.nrctremp = 131747) OR
(e.cdcooper = 1	AND e.nrdconta = 7411430	AND e.nrctremp = 1551803) OR (e.cdcooper = 1	AND e.nrdconta = 7411731	AND e.nrctremp = 969299) OR
(e.cdcooper = 1	AND e.nrdconta = 7412185	AND e.nrctremp = 677377) OR (e.cdcooper = 1	AND e.nrdconta = 7413076	AND e.nrctremp = 557284) OR
(e.cdcooper = 1	AND e.nrdconta = 7413459	AND e.nrctremp = 7413459) OR (e.cdcooper = 1	AND e.nrdconta = 7413831	AND e.nrctremp = 1119976) OR
(e.cdcooper = 1	AND e.nrdconta = 7413963	AND e.nrctremp = 7413963) OR (e.cdcooper = 1	AND e.nrdconta = 7414242	AND e.nrctremp = 7414242) OR
(e.cdcooper = 1	AND e.nrdconta = 7414900	AND e.nrctremp = 750690) OR (e.cdcooper = 1	AND e.nrdconta = 7414900	AND e.nrctremp = 843446) OR
(e.cdcooper = 1	AND e.nrdconta = 7416318	AND e.nrctremp = 569242) OR (e.cdcooper = 1	AND e.nrdconta = 7417179	AND e.nrctremp = 642907) OR
(e.cdcooper = 1	AND e.nrdconta = 7417179	AND e.nrctremp = 731069) OR (e.cdcooper = 1	AND e.nrdconta = 7418698	AND e.nrctremp = 1306765) OR
(e.cdcooper = 1	AND e.nrdconta = 7420358	AND e.nrctremp = 7420358) OR (e.cdcooper = 1	AND e.nrdconta = 7421915	AND e.nrctremp = 796130) OR
(e.cdcooper = 1	AND e.nrdconta = 7422229	AND e.nrctremp = 7422229) OR (e.cdcooper = 1	AND e.nrdconta = 7422997	AND e.nrctremp = 7422997) OR
(e.cdcooper = 1	AND e.nrdconta = 7424272	AND e.nrctremp = 7424272) OR (e.cdcooper = 1	AND e.nrdconta = 7424604	AND e.nrctremp = 627759) OR
(e.cdcooper = 1	AND e.nrdconta = 7424841	AND e.nrctremp = 682256) OR (e.cdcooper = 1	AND e.nrdconta = 7425465	AND e.nrctremp = 146486) OR
(e.cdcooper = 1	AND e.nrdconta = 7425902	AND e.nrctremp = 7425902) OR (e.cdcooper = 1	AND e.nrdconta = 7427166	AND e.nrctremp = 1027321) OR
(e.cdcooper = 1	AND e.nrdconta = 7427670	AND e.nrctremp = 1092827) OR (e.cdcooper = 1	AND e.nrdconta = 7428235	AND e.nrctremp = 656135) OR
(e.cdcooper = 1	AND e.nrdconta = 7428642	AND e.nrctremp = 1277517) OR (e.cdcooper = 1	AND e.nrdconta = 7429312	AND e.nrctremp = 1383872) OR
(e.cdcooper = 1	AND e.nrdconta = 7434006	AND e.nrctremp = 1293783) OR (e.cdcooper = 1	AND e.nrdconta = 7434260	AND e.nrctremp = 225280) OR
(e.cdcooper = 1	AND e.nrdconta = 7434880	AND e.nrctremp = 1957361) OR (e.cdcooper = 1	AND e.nrdconta = 7435800	AND e.nrctremp = 1059370) OR
(e.cdcooper = 1	AND e.nrdconta = 7437420	AND e.nrctremp = 900325) OR (e.cdcooper = 1	AND e.nrdconta = 7437668	AND e.nrctremp = 772458) OR
(e.cdcooper = 1	AND e.nrdconta = 7437986	AND e.nrctremp = 7437986) OR (e.cdcooper = 1	AND e.nrdconta = 7438699	AND e.nrctremp = 678380) OR
(e.cdcooper = 1	AND e.nrdconta = 7438842	AND e.nrctremp = 412503) OR (e.cdcooper = 1	AND e.nrdconta = 7438915	AND e.nrctremp = 7438915) OR
(e.cdcooper = 1	AND e.nrdconta = 7439075	AND e.nrctremp = 7439075) OR (e.cdcooper = 1	AND e.nrdconta = 7439903	AND e.nrctremp = 7439903) OR
(e.cdcooper = 1	AND e.nrdconta = 7440812	AND e.nrctremp = 1504254) OR (e.cdcooper = 1	AND e.nrdconta = 7441894	AND e.nrctremp = 475034) OR
(e.cdcooper = 1	AND e.nrdconta = 7442190	AND e.nrctremp = 874837) OR (e.cdcooper = 1	AND e.nrdconta = 7442432	AND e.nrctremp = 1153682) OR
(e.cdcooper = 1	AND e.nrdconta = 7443277	AND e.nrctremp = 7443277) OR (e.cdcooper = 1	AND e.nrdconta = 7444532	AND e.nrctremp = 7444532) OR
(e.cdcooper = 1	AND e.nrdconta = 7445075	AND e.nrctremp = 468143) OR (e.cdcooper = 1	AND e.nrdconta = 7445229	AND e.nrctremp = 541593) OR
(e.cdcooper = 1	AND e.nrdconta = 7445601	AND e.nrctremp = 845359) OR (e.cdcooper = 1	AND e.nrdconta = 7446586	AND e.nrctremp = 1138761) OR
(e.cdcooper = 1	AND e.nrdconta = 7447345	AND e.nrctremp = 7447345) OR (e.cdcooper = 1	AND e.nrdconta = 7447540	AND e.nrctremp = 1180207) OR
(e.cdcooper = 1	AND e.nrdconta = 7447728	AND e.nrctremp = 512573) OR (e.cdcooper = 1	AND e.nrdconta = 7449488	AND e.nrctremp = 511911) OR
(e.cdcooper = 1	AND e.nrdconta = 7451920	AND e.nrctremp = 7451920) OR (e.cdcooper = 1	AND e.nrdconta = 7452730	AND e.nrctremp = 1263894) OR
(e.cdcooper = 1	AND e.nrdconta = 7453752	AND e.nrctremp = 735240) OR (e.cdcooper = 1	AND e.nrdconta = 7453892	AND e.nrctremp = 847281) OR
(e.cdcooper = 1	AND e.nrdconta = 7455224	AND e.nrctremp = 1013119) OR (e.cdcooper = 1	AND e.nrdconta = 7456417	AND e.nrctremp = 62914) OR
(e.cdcooper = 1	AND e.nrdconta = 7458320	AND e.nrctremp = 1260422) OR (e.cdcooper = 1	AND e.nrdconta = 7458401	AND e.nrctremp = 1051314) OR
(e.cdcooper = 1	AND e.nrdconta = 7460481	AND e.nrctremp = 21039) OR (e.cdcooper = 1	AND e.nrdconta = 7460481	AND e.nrctremp = 7460481) OR
(e.cdcooper = 1	AND e.nrdconta = 7460562	AND e.nrctremp = 1369330) OR (e.cdcooper = 1	AND e.nrdconta = 7461739	AND e.nrctremp = 1072862) OR
(e.cdcooper = 1	AND e.nrdconta = 7462239	AND e.nrctremp = 7462239) OR (e.cdcooper = 1	AND e.nrdconta = 7464959	AND e.nrctremp = 1654584) OR
(e.cdcooper = 1	AND e.nrdconta = 7465181	AND e.nrctremp = 524218) OR (e.cdcooper = 1	AND e.nrdconta = 7465688	AND e.nrctremp = 7465688) OR
(e.cdcooper = 1	AND e.nrdconta = 7468857	AND e.nrctremp = 7468857) OR (e.cdcooper = 1	AND e.nrdconta = 7469640	AND e.nrctremp = 1083308) OR
(e.cdcooper = 1	AND e.nrdconta = 7471696	AND e.nrctremp = 725755) OR (e.cdcooper = 1	AND e.nrdconta = 7472390	AND e.nrctremp = 7472390) OR
(e.cdcooper = 1	AND e.nrdconta = 7473486	AND e.nrctremp = 1079703) OR (e.cdcooper = 1	AND e.nrdconta = 7473664	AND e.nrctremp = 500062) OR
(e.cdcooper = 1	AND e.nrdconta = 7474741	AND e.nrctremp = 1478229) OR (e.cdcooper = 1	AND e.nrdconta = 7475136	AND e.nrctremp = 46200) OR
(e.cdcooper = 1	AND e.nrdconta = 7476620	AND e.nrctremp = 741644) OR (e.cdcooper = 1	AND e.nrdconta = 7476620	AND e.nrctremp = 741653) OR
(e.cdcooper = 1	AND e.nrdconta = 7476949	AND e.nrctremp = 500433) OR (e.cdcooper = 1	AND e.nrdconta = 7477341	AND e.nrctremp = 81744) OR
(e.cdcooper = 1	AND e.nrdconta = 7477465	AND e.nrctremp = 378073) OR (e.cdcooper = 1	AND e.nrdconta = 7478208	AND e.nrctremp = 1949475) OR
(e.cdcooper = 1	AND e.nrdconta = 7479700	AND e.nrctremp = 800669) OR (e.cdcooper = 1	AND e.nrdconta = 7479905	AND e.nrctremp = 7479905) OR
(e.cdcooper = 1	AND e.nrdconta = 7480288	AND e.nrctremp = 913813) OR (e.cdcooper = 1	AND e.nrdconta = 7482388	AND e.nrctremp = 1109742) OR
(e.cdcooper = 1	AND e.nrdconta = 7483678	AND e.nrctremp = 121448) OR (e.cdcooper = 1	AND e.nrdconta = 7483694	AND e.nrctremp = 1599832) OR
(e.cdcooper = 1	AND e.nrdconta = 7484909	AND e.nrctremp = 641300) OR (e.cdcooper = 1	AND e.nrdconta = 7485620	AND e.nrctremp = 607801) OR
(e.cdcooper = 1	AND e.nrdconta = 7486448	AND e.nrctremp = 1787856) OR (e.cdcooper = 1	AND e.nrdconta = 7486731	AND e.nrctremp = 1517705) OR
(e.cdcooper = 1	AND e.nrdconta = 7488360	AND e.nrctremp = 1130189) OR (e.cdcooper = 1	AND e.nrdconta = 7488661	AND e.nrctremp = 607423) OR
(e.cdcooper = 1	AND e.nrdconta = 7489803	AND e.nrctremp = 1016031) OR (e.cdcooper = 1	AND e.nrdconta = 7490054	AND e.nrctremp = 735313) OR
(e.cdcooper = 1	AND e.nrdconta = 7491085	AND e.nrctremp = 422152) OR (e.cdcooper = 1	AND e.nrdconta = 7493932	AND e.nrctremp = 797830) OR
(e.cdcooper = 1	AND e.nrdconta = 7494068	AND e.nrctremp = 825861) OR (e.cdcooper = 1	AND e.nrdconta = 7494165	AND e.nrctremp = 1094383) OR
(e.cdcooper = 1	AND e.nrdconta = 7494297	AND e.nrctremp = 693625) OR (e.cdcooper = 1	AND e.nrdconta = 7494793	AND e.nrctremp = 759258) OR
(e.cdcooper = 1	AND e.nrdconta = 7496397	AND e.nrctremp = 7496397) OR (e.cdcooper = 1	AND e.nrdconta = 7497016	AND e.nrctremp = 787271) OR
(e.cdcooper = 1	AND e.nrdconta = 7497300	AND e.nrctremp = 7497300) OR (e.cdcooper = 1	AND e.nrdconta = 7497474	AND e.nrctremp = 534144) OR
(e.cdcooper = 1	AND e.nrdconta = 7497750	AND e.nrctremp = 7497750) OR (e.cdcooper = 1	AND e.nrdconta = 7498012	AND e.nrctremp = 153536) OR
(e.cdcooper = 1	AND e.nrdconta = 7498098	AND e.nrctremp = 592511) OR (e.cdcooper = 1	AND e.nrdconta = 7498306	AND e.nrctremp = 747835) OR
(e.cdcooper = 1	AND e.nrdconta = 7498608	AND e.nrctremp = 559572) OR (e.cdcooper = 1	AND e.nrdconta = 7499639	AND e.nrctremp = 138456) OR
(e.cdcooper = 1	AND e.nrdconta = 7499949	AND e.nrctremp = 633035) OR (e.cdcooper = 1	AND e.nrdconta = 7500530	AND e.nrctremp = 83234) OR
(e.cdcooper = 1	AND e.nrdconta = 7500777	AND e.nrctremp = 690232) OR (e.cdcooper = 1	AND e.nrdconta = 7501340	AND e.nrctremp = 485933) OR
(e.cdcooper = 1	AND e.nrdconta = 7501676	AND e.nrctremp = 491421) OR (e.cdcooper = 1	AND e.nrdconta = 7501960	AND e.nrctremp = 7501960) OR
(e.cdcooper = 1	AND e.nrdconta = 7502028	AND e.nrctremp = 7502028) OR (e.cdcooper = 1	AND e.nrdconta = 7502478	AND e.nrctremp = 1132449) OR
(e.cdcooper = 1	AND e.nrdconta = 7503865	AND e.nrctremp = 953168) OR (e.cdcooper = 1	AND e.nrdconta = 7506023	AND e.nrctremp = 1005900) OR
(e.cdcooper = 1	AND e.nrdconta = 7506368	AND e.nrctremp = 126570) OR (e.cdcooper = 1	AND e.nrdconta = 7506490	AND e.nrctremp = 7506490) OR
(e.cdcooper = 1	AND e.nrdconta = 7506570	AND e.nrctremp = 626772) OR (e.cdcooper = 1	AND e.nrdconta = 7506961	AND e.nrctremp = 7506961) OR
(e.cdcooper = 1	AND e.nrdconta = 7508220	AND e.nrctremp = 705023) OR (e.cdcooper = 1	AND e.nrdconta = 7508620	AND e.nrctremp = 1775220) OR
(e.cdcooper = 1	AND e.nrdconta = 7510055	AND e.nrctremp = 1551309) OR (e.cdcooper = 1	AND e.nrdconta = 7511167	AND e.nrctremp = 7511167) OR
(e.cdcooper = 1	AND e.nrdconta = 7511426	AND e.nrctremp = 1058539) OR (e.cdcooper = 1	AND e.nrdconta = 7514700	AND e.nrctremp = 142061) OR
(e.cdcooper = 1	AND e.nrdconta = 7514875	AND e.nrctremp = 748082) OR (e.cdcooper = 1	AND e.nrdconta = 7515154	AND e.nrctremp = 1606164) OR
(e.cdcooper = 1	AND e.nrdconta = 7515383	AND e.nrctremp = 1055408) OR (e.cdcooper = 1	AND e.nrdconta = 7515499	AND e.nrctremp = 1169140) OR
(e.cdcooper = 1	AND e.nrdconta = 7515928	AND e.nrctremp = 631670) OR (e.cdcooper = 1	AND e.nrdconta = 7516550	AND e.nrctremp = 519924) OR
(e.cdcooper = 1	AND e.nrdconta = 7517076	AND e.nrctremp = 892800) OR (e.cdcooper = 1	AND e.nrdconta = 7518811	AND e.nrctremp = 1587112) OR
(e.cdcooper = 1	AND e.nrdconta = 7521006	AND e.nrctremp = 780060) OR (e.cdcooper = 1	AND e.nrdconta = 7525877	AND e.nrctremp = 520240) OR
(e.cdcooper = 1	AND e.nrdconta = 7526385	AND e.nrctremp = 631281) OR (e.cdcooper = 1	AND e.nrdconta = 7526911	AND e.nrctremp = 994208) OR
(e.cdcooper = 1	AND e.nrdconta = 7527586	AND e.nrctremp = 1276074) OR (e.cdcooper = 1	AND e.nrdconta = 7527608	AND e.nrctremp = 321929) OR
(e.cdcooper = 1	AND e.nrdconta = 7527659	AND e.nrctremp = 7527659) OR (e.cdcooper = 1	AND e.nrdconta = 7528590	AND e.nrctremp = 994857) OR
(e.cdcooper = 1	AND e.nrdconta = 7529023	AND e.nrctremp = 7529023) OR (e.cdcooper = 1	AND e.nrdconta = 7529511	AND e.nrctremp = 188207) OR
(e.cdcooper = 1	AND e.nrdconta = 7530447	AND e.nrctremp = 1350871) OR (e.cdcooper = 1	AND e.nrdconta = 7531931	AND e.nrctremp = 1920809) OR
(e.cdcooper = 1	AND e.nrdconta = 7532954	AND e.nrctremp = 1096933) OR (e.cdcooper = 1	AND e.nrdconta = 7533098	AND e.nrctremp = 68752) OR
(e.cdcooper = 1	AND e.nrdconta = 7533233	AND e.nrctremp = 937012) OR (e.cdcooper = 1	AND e.nrdconta = 7533268	AND e.nrctremp = 1214031) OR
(e.cdcooper = 1	AND e.nrdconta = 7534329	AND e.nrctremp = 733465) OR (e.cdcooper = 1	AND e.nrdconta = 7534426	AND e.nrctremp = 1278920) OR
(e.cdcooper = 1	AND e.nrdconta = 7534426	AND e.nrctremp = 1920919) OR (e.cdcooper = 1	AND e.nrdconta = 7534884	AND e.nrctremp = 424151) OR
(e.cdcooper = 1	AND e.nrdconta = 7536267	AND e.nrctremp = 955708) OR (e.cdcooper = 1	AND e.nrdconta = 7537018	AND e.nrctremp = 136379) OR
(e.cdcooper = 1	AND e.nrdconta = 7537069	AND e.nrctremp = 112669) OR (e.cdcooper = 1	AND e.nrdconta = 7537689	AND e.nrctremp = 782326) OR
(e.cdcooper = 1	AND e.nrdconta = 7539002	AND e.nrctremp = 413135) OR (e.cdcooper = 1	AND e.nrdconta = 7539002	AND e.nrctremp = 7539002) OR
(e.cdcooper = 1	AND e.nrdconta = 7540051	AND e.nrctremp = 345150) OR (e.cdcooper = 1	AND e.nrdconta = 7541023	AND e.nrctremp = 130994) OR
(e.cdcooper = 1	AND e.nrdconta = 7541201	AND e.nrctremp = 1466048) OR (e.cdcooper = 1	AND e.nrdconta = 7543034	AND e.nrctremp = 1088822) OR
(e.cdcooper = 1	AND e.nrdconta = 7543077	AND e.nrctremp = 802383) OR (e.cdcooper = 1	AND e.nrdconta = 7544154	AND e.nrctremp = 450813) OR
(e.cdcooper = 1	AND e.nrdconta = 7545983	AND e.nrctremp = 964280) OR (e.cdcooper = 1	AND e.nrdconta = 7548281	AND e.nrctremp = 1400787) OR
(e.cdcooper = 1	AND e.nrdconta = 7549482	AND e.nrctremp = 666740) OR (e.cdcooper = 1	AND e.nrdconta = 7549601	AND e.nrctremp = 1440379) OR
(e.cdcooper = 1	AND e.nrdconta = 7549865	AND e.nrctremp = 773520) OR (e.cdcooper = 1	AND e.nrdconta = 7550693	AND e.nrctremp = 139836) OR
(e.cdcooper = 1	AND e.nrdconta = 7551290	AND e.nrctremp = 894074) OR (e.cdcooper = 1	AND e.nrdconta = 7551886	AND e.nrctremp = 1006207) OR
(e.cdcooper = 1	AND e.nrdconta = 7552084	AND e.nrctremp = 627607) OR (e.cdcooper = 1	AND e.nrdconta = 7552980	AND e.nrctremp = 780424) OR
(e.cdcooper = 1	AND e.nrdconta = 7556365	AND e.nrctremp = 1125427) OR (e.cdcooper = 1	AND e.nrdconta = 7556365	AND e.nrctremp = 1333999) OR
(e.cdcooper = 1	AND e.nrdconta = 7556543	AND e.nrctremp = 1055559) OR (e.cdcooper = 1	AND e.nrdconta = 7556870	AND e.nrctremp = 1159664) OR
(e.cdcooper = 1	AND e.nrdconta = 7557507	AND e.nrctremp = 885174) OR (e.cdcooper = 1	AND e.nrdconta = 7559127	AND e.nrctremp = 1654356) OR
(e.cdcooper = 1	AND e.nrdconta = 7559275	AND e.nrctremp = 1068910) OR (e.cdcooper = 1	AND e.nrdconta = 7559674	AND e.nrctremp = 21656) OR
(e.cdcooper = 1	AND e.nrdconta = 7559720	AND e.nrctremp = 479443) OR (e.cdcooper = 1	AND e.nrdconta = 7560036	AND e.nrctremp = 1126906) OR
(e.cdcooper = 1	AND e.nrdconta = 7560826	AND e.nrctremp = 936452) OR (e.cdcooper = 1	AND e.nrdconta = 7560842	AND e.nrctremp = 702620) OR
(e.cdcooper = 1	AND e.nrdconta = 7564074	AND e.nrctremp = 166214) OR (e.cdcooper = 1	AND e.nrdconta = 7564147	AND e.nrctremp = 111643) OR
(e.cdcooper = 1	AND e.nrdconta = 7564848	AND e.nrctremp = 7564848) OR (e.cdcooper = 1	AND e.nrdconta = 7565313	AND e.nrctremp = 1084033) OR
(e.cdcooper = 1	AND e.nrdconta = 7566140	AND e.nrctremp = 427075) OR (e.cdcooper = 1	AND e.nrdconta = 7567502	AND e.nrctremp = 7567502) OR
(e.cdcooper = 1	AND e.nrdconta = 7567561	AND e.nrctremp = 524283) OR (e.cdcooper = 1	AND e.nrdconta = 7568029	AND e.nrctremp = 7568029) OR
(e.cdcooper = 1	AND e.nrdconta = 7569580	AND e.nrctremp = 1367339) OR (e.cdcooper = 1	AND e.nrdconta = 7571038	AND e.nrctremp = 1596202) OR
(e.cdcooper = 1	AND e.nrdconta = 7573103	AND e.nrctremp = 944859) OR (e.cdcooper = 1	AND e.nrdconta = 7573618	AND e.nrctremp = 637262) OR
(e.cdcooper = 1	AND e.nrdconta = 7575785	AND e.nrctremp = 7575785) OR (e.cdcooper = 1	AND e.nrdconta = 7575831	AND e.nrctremp = 1099838) OR
(e.cdcooper = 1	AND e.nrdconta = 7577036	AND e.nrctremp = 601832) OR (e.cdcooper = 1	AND e.nrdconta = 7577990	AND e.nrctremp = 1384713) OR
(e.cdcooper = 1	AND e.nrdconta = 7578156	AND e.nrctremp = 7578156) OR (e.cdcooper = 1	AND e.nrdconta = 7578431	AND e.nrctremp = 148122) OR
(e.cdcooper = 1	AND e.nrdconta = 7580215	AND e.nrctremp = 1616785) OR (e.cdcooper = 1	AND e.nrdconta = 7580673	AND e.nrctremp = 1964436) OR
(e.cdcooper = 1	AND e.nrdconta = 7582412	AND e.nrctremp = 934782) OR (e.cdcooper = 1	AND e.nrdconta = 7582927	AND e.nrctremp = 95009) OR
(e.cdcooper = 1	AND e.nrdconta = 7584652	AND e.nrctremp = 768209) OR (e.cdcooper = 1	AND e.nrdconta = 7584962	AND e.nrctremp = 114660) OR
(e.cdcooper = 1	AND e.nrdconta = 7585578	AND e.nrctremp = 152083) OR (e.cdcooper = 1	AND e.nrdconta = 7586817	AND e.nrctremp = 1139538) OR
(e.cdcooper = 1	AND e.nrdconta = 7586876	AND e.nrctremp = 7586876) OR (e.cdcooper = 1	AND e.nrdconta = 7587651	AND e.nrctremp = 524441) OR
(e.cdcooper = 1	AND e.nrdconta = 7588160	AND e.nrctremp = 595026) OR (e.cdcooper = 1	AND e.nrdconta = 7591420	AND e.nrctremp = 7591420) OR
(e.cdcooper = 1	AND e.nrdconta = 7591616	AND e.nrctremp = 7591616) OR (e.cdcooper = 1	AND e.nrdconta = 7593422	AND e.nrctremp = 7593422) OR
(e.cdcooper = 1	AND e.nrdconta = 7594968	AND e.nrctremp = 969562) OR (e.cdcooper = 1	AND e.nrdconta = 7595654	AND e.nrctremp = 188013) OR
(e.cdcooper = 1	AND e.nrdconta = 7597835	AND e.nrctremp = 7597835) OR (e.cdcooper = 1	AND e.nrdconta = 7598033	AND e.nrctremp = 703016) OR
(e.cdcooper = 1	AND e.nrdconta = 7598629	AND e.nrctremp = 1235459) OR (e.cdcooper = 1	AND e.nrdconta = 7598700	AND e.nrctremp = 1298113) OR
(e.cdcooper = 1	AND e.nrdconta = 7599366	AND e.nrctremp = 1045135) OR (e.cdcooper = 1	AND e.nrdconta = 7600143	AND e.nrctremp = 7600143) OR
(e.cdcooper = 1	AND e.nrdconta = 7600771	AND e.nrctremp = 693351) OR (e.cdcooper = 1	AND e.nrdconta = 7600771	AND e.nrctremp = 847253) OR
(e.cdcooper = 1	AND e.nrdconta = 7601069	AND e.nrctremp = 754455) OR (e.cdcooper = 1	AND e.nrdconta = 7601093	AND e.nrctremp = 7601093) OR
(e.cdcooper = 1	AND e.nrdconta = 7602430	AND e.nrctremp = 752731) OR (e.cdcooper = 1	AND e.nrdconta = 7602901	AND e.nrctremp = 539776) OR
(e.cdcooper = 1	AND e.nrdconta = 7603029	AND e.nrctremp = 883587) OR (e.cdcooper = 1	AND e.nrdconta = 7603045	AND e.nrctremp = 923103) OR
(e.cdcooper = 1	AND e.nrdconta = 7603070	AND e.nrctremp = 7603070) OR (e.cdcooper = 1	AND e.nrdconta = 7604858	AND e.nrctremp = 101520) OR
(e.cdcooper = 1	AND e.nrdconta = 7605170	AND e.nrctremp = 634474) OR (e.cdcooper = 1	AND e.nrdconta = 7605170	AND e.nrctremp = 1042571) OR
(e.cdcooper = 1	AND e.nrdconta = 7607180	AND e.nrctremp = 7607180) OR (e.cdcooper = 1	AND e.nrdconta = 7607490	AND e.nrctremp = 7607490) OR
(e.cdcooper = 1	AND e.nrdconta = 7608020	AND e.nrctremp = 931667) OR (e.cdcooper = 1	AND e.nrdconta = 7608942	AND e.nrctremp = 7608942) OR
(e.cdcooper = 1	AND e.nrdconta = 7608950	AND e.nrctremp = 942512) OR (e.cdcooper = 1	AND e.nrdconta = 7609140	AND e.nrctremp = 2325650) OR
(e.cdcooper = 1	AND e.nrdconta = 7610157	AND e.nrctremp = 7610157) OR (e.cdcooper = 1	AND e.nrdconta = 7610165	AND e.nrctremp = 1199138) OR
(e.cdcooper = 1	AND e.nrdconta = 7610270	AND e.nrctremp = 696648) OR (e.cdcooper = 1	AND e.nrdconta = 7610602	AND e.nrctremp = 746816) OR
(e.cdcooper = 1	AND e.nrdconta = 7614365	AND e.nrctremp = 598114) OR (e.cdcooper = 1	AND e.nrdconta = 7617739	AND e.nrctremp = 1211641) OR
(e.cdcooper = 1	AND e.nrdconta = 7618964	AND e.nrctremp = 1099571) OR (e.cdcooper = 1	AND e.nrdconta = 7619456	AND e.nrctremp = 620586) OR
(e.cdcooper = 1	AND e.nrdconta = 7619715	AND e.nrctremp = 1136143) OR (e.cdcooper = 1	AND e.nrdconta = 7620128	AND e.nrctremp = 613966) OR
(e.cdcooper = 1	AND e.nrdconta = 7620667	AND e.nrctremp = 872421) OR (e.cdcooper = 1	AND e.nrdconta = 7621540	AND e.nrctremp = 1036249) OR
(e.cdcooper = 1	AND e.nrdconta = 7621949	AND e.nrctremp = 1619313) OR (e.cdcooper = 1	AND e.nrdconta = 7622309	AND e.nrctremp = 65042) OR
(e.cdcooper = 1	AND e.nrdconta = 7623178	AND e.nrctremp = 1230662) OR (e.cdcooper = 1	AND e.nrdconta = 7623453	AND e.nrctremp = 467076) OR
(e.cdcooper = 1	AND e.nrdconta = 7625030	AND e.nrctremp = 24407) OR (e.cdcooper = 1	AND e.nrdconta = 7626991	AND e.nrctremp = 475730) OR
(e.cdcooper = 1	AND e.nrdconta = 7627122	AND e.nrctremp = 7627122) OR (e.cdcooper = 1	AND e.nrdconta = 7628080	AND e.nrctremp = 1587060) OR
(e.cdcooper = 1	AND e.nrdconta = 7628269	AND e.nrctremp = 586671) OR (e.cdcooper = 1	AND e.nrdconta = 7629532	AND e.nrctremp = 7629532) OR
(e.cdcooper = 1	AND e.nrdconta = 7630077	AND e.nrctremp = 344405) OR (e.cdcooper = 1	AND e.nrdconta = 7630964	AND e.nrctremp = 82115) OR
(e.cdcooper = 1	AND e.nrdconta = 7631260	AND e.nrctremp = 1260377) OR (e.cdcooper = 1	AND e.nrdconta = 7632118	AND e.nrctremp = 778210) OR
(e.cdcooper = 1	AND e.nrdconta = 7634277	AND e.nrctremp = 1175106) OR (e.cdcooper = 1	AND e.nrdconta = 7636490	AND e.nrctremp = 530651) OR
(e.cdcooper = 1	AND e.nrdconta = 7636563	AND e.nrctremp = 7636563) OR (e.cdcooper = 1	AND e.nrdconta = 7637713	AND e.nrctremp = 1747096) OR
(e.cdcooper = 1	AND e.nrdconta = 7641575	AND e.nrctremp = 446058) OR (e.cdcooper = 1	AND e.nrdconta = 7641818	AND e.nrctremp = 1439931) OR
(e.cdcooper = 1	AND e.nrdconta = 7641940	AND e.nrctremp = 7641940) OR (e.cdcooper = 1	AND e.nrdconta = 7641990	AND e.nrctremp = 522670) OR
(e.cdcooper = 1	AND e.nrdconta = 7643330	AND e.nrctremp = 1086160) OR (e.cdcooper = 1	AND e.nrdconta = 7644370	AND e.nrctremp = 927126) OR
(e.cdcooper = 1	AND e.nrdconta = 7644531	AND e.nrctremp = 11942) OR (e.cdcooper = 1	AND e.nrdconta = 7644710	AND e.nrctremp = 1101888) OR
(e.cdcooper = 1	AND e.nrdconta = 7645457	AND e.nrctremp = 146023) OR (e.cdcooper = 1	AND e.nrdconta = 7646739	AND e.nrctremp = 7646739) OR
(e.cdcooper = 1	AND e.nrdconta = 7646836	AND e.nrctremp = 709578) OR (e.cdcooper = 1	AND e.nrdconta = 7648065	AND e.nrctremp = 487810) OR
(e.cdcooper = 1	AND e.nrdconta = 7649460	AND e.nrctremp = 421) OR (e.cdcooper = 1	AND e.nrdconta = 7649983	AND e.nrctremp = 541255) OR
(e.cdcooper = 1	AND e.nrdconta = 7650094	AND e.nrctremp = 1022159) OR (e.cdcooper = 1	AND e.nrdconta = 7650787	AND e.nrctremp = 743725) OR
(e.cdcooper = 1	AND e.nrdconta = 7651350	AND e.nrctremp = 7651350) OR (e.cdcooper = 1	AND e.nrdconta = 7653344	AND e.nrctremp = 1035923) OR
(e.cdcooper = 1	AND e.nrdconta = 7653964	AND e.nrctremp = 887089) OR (e.cdcooper = 1	AND e.nrdconta = 7654219	AND e.nrctremp = 1097967) OR
(e.cdcooper = 1	AND e.nrdconta = 7655401	AND e.nrctremp = 7655401) OR (e.cdcooper = 1	AND e.nrdconta = 7655703	AND e.nrctremp = 61458) OR
(e.cdcooper = 1	AND e.nrdconta = 7656645	AND e.nrctremp = 93170) OR (e.cdcooper = 1	AND e.nrdconta = 7658222	AND e.nrctremp = 1128714) OR
(e.cdcooper = 1	AND e.nrdconta = 7658303	AND e.nrctremp = 1419458) OR (e.cdcooper = 1	AND e.nrdconta = 7658427	AND e.nrctremp = 7658427) OR
(e.cdcooper = 1	AND e.nrdconta = 7658516	AND e.nrctremp = 540675) OR (e.cdcooper = 1	AND e.nrdconta = 7659180	AND e.nrctremp = 899630) OR
(e.cdcooper = 1	AND e.nrdconta = 7659563	AND e.nrctremp = 13153) OR (e.cdcooper = 1	AND e.nrdconta = 7660120	AND e.nrctremp = 970108) OR
(e.cdcooper = 1	AND e.nrdconta = 7660626	AND e.nrctremp = 478961) OR (e.cdcooper = 1	AND e.nrdconta = 7661762	AND e.nrctremp = 7661762) OR
(e.cdcooper = 1	AND e.nrdconta = 7662742	AND e.nrctremp = 1115576) OR (e.cdcooper = 1	AND e.nrdconta = 7663331	AND e.nrctremp = 679412) OR
(e.cdcooper = 1	AND e.nrdconta = 7663897	AND e.nrctremp = 7663897) OR (e.cdcooper = 1	AND e.nrdconta = 7664303	AND e.nrctremp = 632469) OR
(e.cdcooper = 1	AND e.nrdconta = 7664940	AND e.nrctremp = 514678) OR (e.cdcooper = 1	AND e.nrdconta = 7665474	AND e.nrctremp = 759220) OR
(e.cdcooper = 1	AND e.nrdconta = 7667248	AND e.nrctremp = 1104056) OR (e.cdcooper = 1	AND e.nrdconta = 7667370	AND e.nrctremp = 667224) OR
(e.cdcooper = 1	AND e.nrdconta = 7667370	AND e.nrctremp = 7667370) OR (e.cdcooper = 1	AND e.nrdconta = 7667604	AND e.nrctremp = 1921445) OR
(e.cdcooper = 1	AND e.nrdconta = 7667949	AND e.nrctremp = 802971) OR (e.cdcooper = 1	AND e.nrdconta = 7668490	AND e.nrctremp = 14674) OR
(e.cdcooper = 1	AND e.nrdconta = 7670389	AND e.nrctremp = 1072246) OR (e.cdcooper = 1	AND e.nrdconta = 7670753	AND e.nrctremp = 604067) OR
(e.cdcooper = 1	AND e.nrdconta = 7670800	AND e.nrctremp = 7670800) OR (e.cdcooper = 1	AND e.nrdconta = 7670974	AND e.nrctremp = 231221) OR
(e.cdcooper = 1	AND e.nrdconta = 7671792	AND e.nrctremp = 488945) OR (e.cdcooper = 1	AND e.nrdconta = 7671830	AND e.nrctremp = 1586884) OR
(e.cdcooper = 1	AND e.nrdconta = 7672101	AND e.nrctremp = 7672101) OR (e.cdcooper = 1	AND e.nrdconta = 7672241	AND e.nrctremp = 855474) OR
(e.cdcooper = 1	AND e.nrdconta = 7672446	AND e.nrctremp = 7672446) OR (e.cdcooper = 1	AND e.nrdconta = 7672535	AND e.nrctremp = 1325310) OR
(e.cdcooper = 1	AND e.nrdconta = 7675267	AND e.nrctremp = 7675267) OR (e.cdcooper = 1	AND e.nrdconta = 7675348	AND e.nrctremp = 825316) OR
(e.cdcooper = 1	AND e.nrdconta = 7675631	AND e.nrctremp = 172425) OR (e.cdcooper = 1	AND e.nrdconta = 7676883	AND e.nrctremp = 642101) OR
(e.cdcooper = 1	AND e.nrdconta = 7677073	AND e.nrctremp = 440198) OR (e.cdcooper = 1	AND e.nrdconta = 7677081	AND e.nrctremp = 477363) OR
(e.cdcooper = 1	AND e.nrdconta = 7677740	AND e.nrctremp = 1243307) OR (e.cdcooper = 1	AND e.nrdconta = 7678444	AND e.nrctremp = 711074) OR
(e.cdcooper = 1	AND e.nrdconta = 7678592	AND e.nrctremp = 1017790) OR (e.cdcooper = 1	AND e.nrdconta = 7679050	AND e.nrctremp = 842986) OR
(e.cdcooper = 1	AND e.nrdconta = 7679416	AND e.nrctremp = 414717) OR (e.cdcooper = 1	AND e.nrdconta = 7680058	AND e.nrctremp = 7680058) OR
(e.cdcooper = 1	AND e.nrdconta = 7681534	AND e.nrctremp = 7681534) OR (e.cdcooper = 1	AND e.nrdconta = 7681739	AND e.nrctremp = 725310) OR
(e.cdcooper = 1	AND e.nrdconta = 7682298	AND e.nrctremp = 629479) OR (e.cdcooper = 1	AND e.nrdconta = 7682484	AND e.nrctremp = 544402) OR
(e.cdcooper = 1	AND e.nrdconta = 7682719	AND e.nrctremp = 1619288) OR (e.cdcooper = 1	AND e.nrdconta = 7685572	AND e.nrctremp = 7685572) OR
(e.cdcooper = 1	AND e.nrdconta = 7687524	AND e.nrctremp = 812305) OR (e.cdcooper = 1	AND e.nrdconta = 7687540	AND e.nrctremp = 855000) OR
(e.cdcooper = 1	AND e.nrdconta = 7688032	AND e.nrctremp = 7688032) OR (e.cdcooper = 1	AND e.nrdconta = 7688458	AND e.nrctremp = 7688458) OR
(e.cdcooper = 1	AND e.nrdconta = 7688644	AND e.nrctremp = 1364064) OR (e.cdcooper = 1	AND e.nrdconta = 7689730	AND e.nrctremp = 398361) OR
(e.cdcooper = 1	AND e.nrdconta = 7689942	AND e.nrctremp = 7689942) OR (e.cdcooper = 1	AND e.nrdconta = 7690258	AND e.nrctremp = 805366) OR
(e.cdcooper = 1	AND e.nrdconta = 7690487	AND e.nrctremp = 1254958) OR (e.cdcooper = 1	AND e.nrdconta = 7693273	AND e.nrctremp = 1048488) OR
(e.cdcooper = 1	AND e.nrdconta = 7693885	AND e.nrctremp = 757180) OR (e.cdcooper = 1	AND e.nrdconta = 7695578	AND e.nrctremp = 7695578) OR
(e.cdcooper = 1	AND e.nrdconta = 7696108	AND e.nrctremp = 608754) OR (e.cdcooper = 1	AND e.nrdconta = 7696558	AND e.nrctremp = 931093) OR
(e.cdcooper = 1	AND e.nrdconta = 7698615	AND e.nrctremp = 1275555) OR (e.cdcooper = 1	AND e.nrdconta = 7698720	AND e.nrctremp = 837162) OR
(e.cdcooper = 1	AND e.nrdconta = 7701233	AND e.nrctremp = 543058) OR (e.cdcooper = 1	AND e.nrdconta = 7701276	AND e.nrctremp = 1057675) OR
(e.cdcooper = 1	AND e.nrdconta = 7702124	AND e.nrctremp = 7702124) OR (e.cdcooper = 1	AND e.nrdconta = 7702302	AND e.nrctremp = 360593) OR
(e.cdcooper = 1	AND e.nrdconta = 7702434	AND e.nrctremp = 475846) OR (e.cdcooper = 1	AND e.nrdconta = 7703856	AND e.nrctremp = 517356) OR
(e.cdcooper = 1	AND e.nrdconta = 7704399	AND e.nrctremp = 7704399) OR (e.cdcooper = 1	AND e.nrdconta = 7704720	AND e.nrctremp = 859706) OR
(e.cdcooper = 1	AND e.nrdconta = 7705107	AND e.nrctremp = 111627) OR (e.cdcooper = 1	AND e.nrdconta = 7705352	AND e.nrctremp = 827046) OR
(e.cdcooper = 1	AND e.nrdconta = 7707460	AND e.nrctremp = 7707460) OR (e.cdcooper = 1	AND e.nrdconta = 7707592	AND e.nrctremp = 7707592) OR
(e.cdcooper = 1	AND e.nrdconta = 7707738	AND e.nrctremp = 7707738) OR (e.cdcooper = 1	AND e.nrdconta = 7708548	AND e.nrctremp = 306857) OR
(e.cdcooper = 1	AND e.nrdconta = 7710240	AND e.nrctremp = 721700) OR (e.cdcooper = 1	AND e.nrdconta = 7710623	AND e.nrctremp = 549086) OR
(e.cdcooper = 1	AND e.nrdconta = 7710623	AND e.nrctremp = 549103) OR (e.cdcooper = 1	AND e.nrdconta = 7710810	AND e.nrctremp = 7710810) OR
(e.cdcooper = 1	AND e.nrdconta = 7711395	AND e.nrctremp = 1112554) OR (e.cdcooper = 1	AND e.nrdconta = 7713096	AND e.nrctremp = 713772) OR
(e.cdcooper = 1	AND e.nrdconta = 7713207	AND e.nrctremp = 1256424) OR (e.cdcooper = 1	AND e.nrdconta = 7714637	AND e.nrctremp = 7714637) OR
(e.cdcooper = 1	AND e.nrdconta = 7715838	AND e.nrctremp = 601537) OR (e.cdcooper = 1	AND e.nrdconta = 7716052	AND e.nrctremp = 7716052) OR
(e.cdcooper = 1	AND e.nrdconta = 7716109	AND e.nrctremp = 523256) OR (e.cdcooper = 1	AND e.nrdconta = 7716400	AND e.nrctremp = 1045752) OR
(e.cdcooper = 1	AND e.nrdconta = 7717040	AND e.nrctremp = 1067828) OR (e.cdcooper = 1	AND e.nrdconta = 7718683	AND e.nrctremp = 7718683) OR
(e.cdcooper = 1	AND e.nrdconta = 7718730	AND e.nrctremp = 802621) OR (e.cdcooper = 1	AND e.nrdconta = 7719264	AND e.nrctremp = 7719264) OR
(e.cdcooper = 1	AND e.nrdconta = 7720335	AND e.nrctremp = 1006739) OR (e.cdcooper = 1	AND e.nrdconta = 7720491	AND e.nrctremp = 153167) OR
(e.cdcooper = 1	AND e.nrdconta = 7721439	AND e.nrctremp = 58546) OR (e.cdcooper = 1	AND e.nrdconta = 7723571	AND e.nrctremp = 326668) OR
(e.cdcooper = 1	AND e.nrdconta = 7724101	AND e.nrctremp = 7724101) OR (e.cdcooper = 1	AND e.nrdconta = 7724497	AND e.nrctremp = 611116) OR
(e.cdcooper = 1	AND e.nrdconta = 7725507	AND e.nrctremp = 588998) OR (e.cdcooper = 1	AND e.nrdconta = 7726139	AND e.nrctremp = 486407) OR
(e.cdcooper = 1	AND e.nrdconta = 7726430	AND e.nrctremp = 1081745) OR (e.cdcooper = 1	AND e.nrdconta = 7726457	AND e.nrctremp = 388940) OR
(e.cdcooper = 1	AND e.nrdconta = 7727208	AND e.nrctremp = 141885) OR (e.cdcooper = 1	AND e.nrdconta = 7727720	AND e.nrctremp = 7727720) OR
(e.cdcooper = 1	AND e.nrdconta = 7728107	AND e.nrctremp = 1448877) OR (e.cdcooper = 1	AND e.nrdconta = 7728107	AND e.nrctremp = 1619308) OR
(e.cdcooper = 1	AND e.nrdconta = 7728239	AND e.nrctremp = 7728239) OR (e.cdcooper = 1	AND e.nrdconta = 7728425	AND e.nrctremp = 1154774) OR
(e.cdcooper = 1	AND e.nrdconta = 7728557	AND e.nrctremp = 293217) OR (e.cdcooper = 1	AND e.nrdconta = 7729189	AND e.nrctremp = 169225) OR
(e.cdcooper = 1	AND e.nrdconta = 7729456	AND e.nrctremp = 1551520) OR (e.cdcooper = 1	AND e.nrdconta = 7729960	AND e.nrctremp = 7729960) OR
(e.cdcooper = 1	AND e.nrdconta = 7729987	AND e.nrctremp = 723608) OR (e.cdcooper = 1	AND e.nrdconta = 7730489	AND e.nrctremp = 634885) OR
(e.cdcooper = 1	AND e.nrdconta = 7730500	AND e.nrctremp = 674496) OR (e.cdcooper = 1	AND e.nrdconta = 7730810	AND e.nrctremp = 1791989) OR
(e.cdcooper = 1	AND e.nrdconta = 7731973	AND e.nrctremp = 1595251) OR (e.cdcooper = 1	AND e.nrdconta = 7731973	AND e.nrctremp = 1595258) OR
(e.cdcooper = 1	AND e.nrdconta = 7731973	AND e.nrctremp = 2013042) OR (e.cdcooper = 1	AND e.nrdconta = 7733461	AND e.nrctremp = 126638) OR
(e.cdcooper = 1	AND e.nrdconta = 7734921	AND e.nrctremp = 801699) OR (e.cdcooper = 1	AND e.nrdconta = 7736304	AND e.nrctremp = 80389) OR
(e.cdcooper = 1	AND e.nrdconta = 7738846	AND e.nrctremp = 1276373) OR (e.cdcooper = 1	AND e.nrdconta = 7739281	AND e.nrctremp = 231218) OR
(e.cdcooper = 1	AND e.nrdconta = 7740166	AND e.nrctremp = 761958) OR (e.cdcooper = 1	AND e.nrdconta = 7740778	AND e.nrctremp = 1086772) OR
(e.cdcooper = 1	AND e.nrdconta = 7741510	AND e.nrctremp = 15327) OR (e.cdcooper = 1	AND e.nrdconta = 7741715	AND e.nrctremp = 698945) OR
(e.cdcooper = 1	AND e.nrdconta = 7741715	AND e.nrctremp = 1523950) OR (e.cdcooper = 1	AND e.nrdconta = 7742258	AND e.nrctremp = 414051) OR
(e.cdcooper = 1	AND e.nrdconta = 7742932	AND e.nrctremp = 1322184) OR (e.cdcooper = 1	AND e.nrdconta = 7744234	AND e.nrctremp = 7744234) OR
(e.cdcooper = 1	AND e.nrdconta = 7745311	AND e.nrctremp = 847504) OR (e.cdcooper = 1	AND e.nrdconta = 7745338	AND e.nrctremp = 1041747) OR
(e.cdcooper = 1	AND e.nrdconta = 7745893	AND e.nrctremp = 943975) OR (e.cdcooper = 1	AND e.nrdconta = 7746040	AND e.nrctremp = 7746040) OR
(e.cdcooper = 1	AND e.nrdconta = 7747306	AND e.nrctremp = 11632) OR (e.cdcooper = 1	AND e.nrdconta = 7747403	AND e.nrctremp = 1130830) OR
(e.cdcooper = 1	AND e.nrdconta = 7747578	AND e.nrctremp = 677493) OR (e.cdcooper = 1	AND e.nrdconta = 7748329	AND e.nrctremp = 7748329) OR
(e.cdcooper = 1	AND e.nrdconta = 7749350	AND e.nrctremp = 7749350) OR (e.cdcooper = 1	AND e.nrdconta = 7749546	AND e.nrctremp = 924165) OR
(e.cdcooper = 1	AND e.nrdconta = 7751036	AND e.nrctremp = 462764) OR (e.cdcooper = 1	AND e.nrdconta = 7753527	AND e.nrctremp = 7753527) OR
(e.cdcooper = 1	AND e.nrdconta = 7756500	AND e.nrctremp = 550745) OR (e.cdcooper = 1	AND e.nrdconta = 7758189	AND e.nrctremp = 608226) OR
(e.cdcooper = 1	AND e.nrdconta = 7758570	AND e.nrctremp = 1551143) OR (e.cdcooper = 1	AND e.nrdconta = 7760159	AND e.nrctremp = 1306929) OR
(e.cdcooper = 1	AND e.nrdconta = 7760906	AND e.nrctremp = 7760906) OR (e.cdcooper = 1	AND e.nrdconta = 7761279	AND e.nrctremp = 1254312) OR
(e.cdcooper = 1	AND e.nrdconta = 7761848	AND e.nrctremp = 7761848) OR (e.cdcooper = 1	AND e.nrdconta = 7761856	AND e.nrctremp = 1604001) OR
(e.cdcooper = 1	AND e.nrdconta = 7763123	AND e.nrctremp = 1059363) OR (e.cdcooper = 1	AND e.nrdconta = 7765541	AND e.nrctremp = 1396989) OR
(e.cdcooper = 1	AND e.nrdconta = 7768273	AND e.nrctremp = 1243290) OR (e.cdcooper = 1	AND e.nrdconta = 7768907	AND e.nrctremp = 728581) OR
(e.cdcooper = 1	AND e.nrdconta = 7768931	AND e.nrctremp = 7768931) OR (e.cdcooper = 1	AND e.nrdconta = 7769814	AND e.nrctremp = 926047) OR
(e.cdcooper = 1	AND e.nrdconta = 7769849	AND e.nrctremp = 7769849) OR (e.cdcooper = 1	AND e.nrdconta = 7773250	AND e.nrctremp = 549489) OR
(e.cdcooper = 1	AND e.nrdconta = 7773765	AND e.nrctremp = 477310) OR (e.cdcooper = 1	AND e.nrdconta = 7773820	AND e.nrctremp = 7773820) OR
(e.cdcooper = 1	AND e.nrdconta = 7774036	AND e.nrctremp = 1128817) OR (e.cdcooper = 1	AND e.nrdconta = 7775938	AND e.nrctremp = 7775938) OR
(e.cdcooper = 1	AND e.nrdconta = 7776586	AND e.nrctremp = 62976) OR (e.cdcooper = 1	AND e.nrdconta = 7777710	AND e.nrctremp = 21355) OR
(e.cdcooper = 1	AND e.nrdconta = 7779020	AND e.nrctremp = 1096965) OR (e.cdcooper = 1	AND e.nrdconta = 7780230	AND e.nrctremp = 952986) OR
(e.cdcooper = 1	AND e.nrdconta = 7782632	AND e.nrctremp = 528775) OR (e.cdcooper = 1	AND e.nrdconta = 7784023	AND e.nrctremp = 760439) OR
(e.cdcooper = 1	AND e.nrdconta = 7784058	AND e.nrctremp = 2012295) OR (e.cdcooper = 1	AND e.nrdconta = 7784988	AND e.nrctremp = 997394) OR
(e.cdcooper = 1	AND e.nrdconta = 7785038	AND e.nrctremp = 7785038) OR (e.cdcooper = 1	AND e.nrdconta = 7786832	AND e.nrctremp = 738146) OR
(e.cdcooper = 1	AND e.nrdconta = 7786875	AND e.nrctremp = 750430) OR (e.cdcooper = 1	AND e.nrdconta = 7786964	AND e.nrctremp = 3406) OR
(e.cdcooper = 1	AND e.nrdconta = 7788142	AND e.nrctremp = 7788142) OR (e.cdcooper = 1	AND e.nrdconta = 7788371	AND e.nrctremp = 367590) OR
(e.cdcooper = 1	AND e.nrdconta = 7791402	AND e.nrctremp = 351331) OR (e.cdcooper = 1	AND e.nrdconta = 7791429	AND e.nrctremp = 1309320) OR
(e.cdcooper = 1	AND e.nrdconta = 7793057	AND e.nrctremp = 868184) OR (e.cdcooper = 1	AND e.nrdconta = 7793553	AND e.nrctremp = 1528414) OR
(e.cdcooper = 1	AND e.nrdconta = 7793650	AND e.nrctremp = 1145045) OR (e.cdcooper = 1	AND e.nrdconta = 7796625	AND e.nrctremp = 880286) OR
(e.cdcooper = 1	AND e.nrdconta = 7796668	AND e.nrctremp = 1179668) OR (e.cdcooper = 1	AND e.nrdconta = 7797001	AND e.nrctremp = 554570) OR
(e.cdcooper = 1	AND e.nrdconta = 7798300	AND e.nrctremp = 7798300) OR (e.cdcooper = 1	AND e.nrdconta = 7798334	AND e.nrctremp = 829378) OR
(e.cdcooper = 1	AND e.nrdconta = 7798440	AND e.nrctremp = 7798440) OR (e.cdcooper = 1	AND e.nrdconta = 7798679	AND e.nrctremp = 7798679) OR
(e.cdcooper = 1	AND e.nrdconta = 7798784	AND e.nrctremp = 1056640) OR (e.cdcooper = 1	AND e.nrdconta = 7799071	AND e.nrctremp = 837145) OR
(e.cdcooper = 1	AND e.nrdconta = 7799187	AND e.nrctremp = 7799187) OR (e.cdcooper = 1	AND e.nrdconta = 7799276	AND e.nrctremp = 477711) OR
(e.cdcooper = 1	AND e.nrdconta = 7801769	AND e.nrctremp = 759952) OR (e.cdcooper = 1	AND e.nrdconta = 7801858	AND e.nrctremp = 7801858) OR
(e.cdcooper = 1	AND e.nrdconta = 7801874	AND e.nrctremp = 906326) OR (e.cdcooper = 1	AND e.nrdconta = 7801882	AND e.nrctremp = 7801882) OR
(e.cdcooper = 1	AND e.nrdconta = 7802293	AND e.nrctremp = 1488589) OR (e.cdcooper = 1	AND e.nrdconta = 7802404	AND e.nrctremp = 503067) OR
(e.cdcooper = 1	AND e.nrdconta = 7802471	AND e.nrctremp = 1596296) OR (e.cdcooper = 1	AND e.nrdconta = 7802749	AND e.nrctremp = 540029) OR
(e.cdcooper = 1	AND e.nrdconta = 7802749	AND e.nrctremp = 7802749) OR (e.cdcooper = 1	AND e.nrdconta = 7802757	AND e.nrctremp = 7802757) OR
(e.cdcooper = 1	AND e.nrdconta = 7802790	AND e.nrctremp = 943250) OR (e.cdcooper = 1	AND e.nrdconta = 7804571	AND e.nrctremp = 1697770) OR
(e.cdcooper = 1	AND e.nrdconta = 7805241	AND e.nrctremp = 551777) OR (e.cdcooper = 1	AND e.nrdconta = 7806868	AND e.nrctremp = 197116) OR
(e.cdcooper = 1	AND e.nrdconta = 7807040	AND e.nrctremp = 7807040) OR (e.cdcooper = 1	AND e.nrdconta = 7807201	AND e.nrctremp = 280764) OR
(e.cdcooper = 1	AND e.nrdconta = 7809069	AND e.nrctremp = 875926) OR (e.cdcooper = 1	AND e.nrdconta = 7810571	AND e.nrctremp = 1410577) OR
(e.cdcooper = 1	AND e.nrdconta = 7811535	AND e.nrctremp = 51510) OR (e.cdcooper = 1	AND e.nrdconta = 7811799	AND e.nrctremp = 1083796) OR
(e.cdcooper = 1	AND e.nrdconta = 7811934	AND e.nrctremp = 149326) OR (e.cdcooper = 1	AND e.nrdconta = 7812469	AND e.nrctremp = 7812469) OR
(e.cdcooper = 1	AND e.nrdconta = 7812515	AND e.nrctremp = 33686) OR (e.cdcooper = 1	AND e.nrdconta = 7812701	AND e.nrctremp = 956655) OR
(e.cdcooper = 1	AND e.nrdconta = 7812744	AND e.nrctremp = 567286) OR (e.cdcooper = 1	AND e.nrdconta = 7813813	AND e.nrctremp = 952765) OR
(e.cdcooper = 1	AND e.nrdconta = 7813813	AND e.nrctremp = 1054612) OR (e.cdcooper = 1	AND e.nrdconta = 7814038	AND e.nrctremp = 7814038) OR
(e.cdcooper = 1	AND e.nrdconta = 7814291	AND e.nrctremp = 7814291) OR (e.cdcooper = 1	AND e.nrdconta = 7814526	AND e.nrctremp = 1835402) OR
(e.cdcooper = 1	AND e.nrdconta = 7814615	AND e.nrctremp = 782544) OR (e.cdcooper = 1	AND e.nrdconta = 7814623	AND e.nrctremp = 801072) OR
(e.cdcooper = 1	AND e.nrdconta = 7814801	AND e.nrctremp = 697557) OR (e.cdcooper = 1	AND e.nrdconta = 7816685	AND e.nrctremp = 7816685) OR
(e.cdcooper = 1	AND e.nrdconta = 7816871	AND e.nrctremp = 7816871) OR (e.cdcooper = 1	AND e.nrdconta = 7818289	AND e.nrctremp = 324370) OR
(e.cdcooper = 1	AND e.nrdconta = 7821611	AND e.nrctremp = 1462633) OR (e.cdcooper = 1	AND e.nrdconta = 7822120	AND e.nrctremp = 1173242) OR
(e.cdcooper = 1	AND e.nrdconta = 7822936	AND e.nrctremp = 488264) OR (e.cdcooper = 1	AND e.nrdconta = 7822944	AND e.nrctremp = 898921) OR
(e.cdcooper = 1	AND e.nrdconta = 7825064	AND e.nrctremp = 659764) OR (e.cdcooper = 1	AND e.nrdconta = 7825935	AND e.nrctremp = 704711) OR
(e.cdcooper = 1	AND e.nrdconta = 7826508	AND e.nrctremp = 976474) OR (e.cdcooper = 1	AND e.nrdconta = 7827440	AND e.nrctremp = 1609230) OR
(e.cdcooper = 1	AND e.nrdconta = 7827628	AND e.nrctremp = 11628) OR (e.cdcooper = 1	AND e.nrdconta = 7828462	AND e.nrctremp = 7828462) OR
(e.cdcooper = 1	AND e.nrdconta = 7829078	AND e.nrctremp = 7829078) OR (e.cdcooper = 1	AND e.nrdconta = 7829183	AND e.nrctremp = 7829183) OR
(e.cdcooper = 1	AND e.nrdconta = 7829230	AND e.nrctremp = 605081) OR (e.cdcooper = 1	AND e.nrdconta = 7829647	AND e.nrctremp = 43292) OR
(e.cdcooper = 1	AND e.nrdconta = 7831080	AND e.nrctremp = 7831080) OR (e.cdcooper = 1	AND e.nrdconta = 7831404	AND e.nrctremp = 1035323) OR
(e.cdcooper = 1	AND e.nrdconta = 7831790	AND e.nrctremp = 133196) OR (e.cdcooper = 1	AND e.nrdconta = 7831820	AND e.nrctremp = 1775208) OR
(e.cdcooper = 1	AND e.nrdconta = 7832060	AND e.nrctremp = 876353) OR (e.cdcooper = 1	AND e.nrdconta = 7832931	AND e.nrctremp = 644690) OR
(e.cdcooper = 1	AND e.nrdconta = 7832990	AND e.nrctremp = 827202) OR (e.cdcooper = 1	AND e.nrdconta = 7834438	AND e.nrctremp = 7834438) OR
(e.cdcooper = 1	AND e.nrdconta = 7836112	AND e.nrctremp = 751108) OR (e.cdcooper = 1	AND e.nrdconta = 7836155	AND e.nrctremp = 762721) OR
(e.cdcooper = 1	AND e.nrdconta = 7836376	AND e.nrctremp = 207475) OR (e.cdcooper = 1	AND e.nrdconta = 7837348	AND e.nrctremp = 490478) OR
(e.cdcooper = 1	AND e.nrdconta = 7838662	AND e.nrctremp = 1274839) OR (e.cdcooper = 1	AND e.nrdconta = 7840055	AND e.nrctremp = 525889) OR
(e.cdcooper = 1	AND e.nrdconta = 7840853	AND e.nrctremp = 1596350) OR (e.cdcooper = 1	AND e.nrdconta = 7841108	AND e.nrctremp = 1057052) OR
(e.cdcooper = 1	AND e.nrdconta = 7842104	AND e.nrctremp = 552428) OR (e.cdcooper = 1	AND e.nrdconta = 7842635	AND e.nrctremp = 808895) OR
(e.cdcooper = 1	AND e.nrdconta = 7843160	AND e.nrctremp = 928261) OR (e.cdcooper = 1	AND e.nrdconta = 7843380	AND e.nrctremp = 7843380) OR
(e.cdcooper = 1	AND e.nrdconta = 7843593	AND e.nrctremp = 766721) OR (e.cdcooper = 1	AND e.nrdconta = 7843607	AND e.nrctremp = 7843607) OR
(e.cdcooper = 1	AND e.nrdconta = 7844565	AND e.nrctremp = 1224619) OR (e.cdcooper = 1	AND e.nrdconta = 7846657	AND e.nrctremp = 718196) OR
(e.cdcooper = 1	AND e.nrdconta = 7846916	AND e.nrctremp = 698755) OR (e.cdcooper = 1	AND e.nrdconta = 7846916	AND e.nrctremp = 735782) OR
(e.cdcooper = 1	AND e.nrdconta = 7847203	AND e.nrctremp = 409397) OR (e.cdcooper = 1	AND e.nrdconta = 7847742	AND e.nrctremp = 1149499) OR
(e.cdcooper = 1	AND e.nrdconta = 7847750	AND e.nrctremp = 440888) OR (e.cdcooper = 1	AND e.nrdconta = 7848218	AND e.nrctremp = 1044782) OR
(e.cdcooper = 1	AND e.nrdconta = 7848277	AND e.nrctremp = 7848277) OR (e.cdcooper = 1	AND e.nrdconta = 7849303	AND e.nrctremp = 1775043) OR
(e.cdcooper = 1	AND e.nrdconta = 7850565	AND e.nrctremp = 480139) OR (e.cdcooper = 1	AND e.nrdconta = 7852193	AND e.nrctremp = 1190029) OR
(e.cdcooper = 1	AND e.nrdconta = 7852541	AND e.nrctremp = 295692) OR (e.cdcooper = 1	AND e.nrdconta = 7853076	AND e.nrctremp = 985610) OR
(e.cdcooper = 1	AND e.nrdconta = 7853360	AND e.nrctremp = 605451) OR (e.cdcooper = 1	AND e.nrdconta = 7853866	AND e.nrctremp = 1199481) OR
(e.cdcooper = 1	AND e.nrdconta = 7854730	AND e.nrctremp = 176210) OR (e.cdcooper = 1	AND e.nrdconta = 7854943	AND e.nrctremp = 1492861) OR
(e.cdcooper = 1	AND e.nrdconta = 7855362	AND e.nrctremp = 7855362) OR (e.cdcooper = 1	AND e.nrdconta = 7857675	AND e.nrctremp = 752152) OR
(e.cdcooper = 1	AND e.nrdconta = 7859180	AND e.nrctremp = 683630) OR (e.cdcooper = 1	AND e.nrdconta = 7859325	AND e.nrctremp = 7859325) OR
(e.cdcooper = 1	AND e.nrdconta = 7859600	AND e.nrctremp = 456009) OR (e.cdcooper = 1	AND e.nrdconta = 7860137	AND e.nrctremp = 956042) OR
(e.cdcooper = 1	AND e.nrdconta = 7860161	AND e.nrctremp = 7860161) OR (e.cdcooper = 1	AND e.nrdconta = 7860196	AND e.nrctremp = 562608) OR
(e.cdcooper = 1	AND e.nrdconta = 7860935	AND e.nrctremp = 676180) OR (e.cdcooper = 1	AND e.nrdconta = 7861672	AND e.nrctremp = 605387) OR
(e.cdcooper = 1	AND e.nrdconta = 7862156	AND e.nrctremp = 656414) OR (e.cdcooper = 1	AND e.nrdconta = 7863063	AND e.nrctremp = 7863063) OR
(e.cdcooper = 1	AND e.nrdconta = 7863802	AND e.nrctremp = 1074809) OR (e.cdcooper = 1	AND e.nrdconta = 7866020	AND e.nrctremp = 674814) OR
(e.cdcooper = 1	AND e.nrdconta = 7866526	AND e.nrctremp = 55628) OR (e.cdcooper = 1	AND e.nrdconta = 7866585	AND e.nrctremp = 428172) OR
(e.cdcooper = 1	AND e.nrdconta = 7866771	AND e.nrctremp = 7866771) OR (e.cdcooper = 1	AND e.nrdconta = 7866895	AND e.nrctremp = 7866895) OR
(e.cdcooper = 1	AND e.nrdconta = 7869533	AND e.nrctremp = 1209122) OR (e.cdcooper = 1	AND e.nrdconta = 7870183	AND e.nrctremp = 829774) OR
(e.cdcooper = 1	AND e.nrdconta = 7870388	AND e.nrctremp = 7870388) OR (e.cdcooper = 1	AND e.nrdconta = 7871783	AND e.nrctremp = 7871783) OR
(e.cdcooper = 1	AND e.nrdconta = 7872054	AND e.nrctremp = 7872054) OR (e.cdcooper = 1	AND e.nrdconta = 7872399	AND e.nrctremp = 7872399) OR
(e.cdcooper = 1	AND e.nrdconta = 7872658	AND e.nrctremp = 645769) OR (e.cdcooper = 1	AND e.nrdconta = 7872828	AND e.nrctremp = 1245383) OR
(e.cdcooper = 1	AND e.nrdconta = 7872909	AND e.nrctremp = 381770) OR (e.cdcooper = 1	AND e.nrdconta = 7873034	AND e.nrctremp = 469666) OR
(e.cdcooper = 1	AND e.nrdconta = 7874103	AND e.nrctremp = 7874103) OR (e.cdcooper = 1	AND e.nrdconta = 7874456	AND e.nrctremp = 1800200) OR
(e.cdcooper = 1	AND e.nrdconta = 7874456	AND e.nrctremp = 1800241) OR (e.cdcooper = 1	AND e.nrdconta = 7874782	AND e.nrctremp = 638817) OR
(e.cdcooper = 1	AND e.nrdconta = 7874855	AND e.nrctremp = 902608) OR (e.cdcooper = 1	AND e.nrdconta = 7875185	AND e.nrctremp = 1194139) OR
(e.cdcooper = 1	AND e.nrdconta = 7875517	AND e.nrctremp = 632292) OR (e.cdcooper = 1	AND e.nrdconta = 7875541	AND e.nrctremp = 1024124) OR
(e.cdcooper = 1	AND e.nrdconta = 7875851	AND e.nrctremp = 1190728) OR (e.cdcooper = 1	AND e.nrdconta = 7875975	AND e.nrctremp = 943189) OR
(e.cdcooper = 1	AND e.nrdconta = 7877064	AND e.nrctremp = 328989) OR (e.cdcooper = 1	AND e.nrdconta = 7877064	AND e.nrctremp = 1005782) OR
(e.cdcooper = 1	AND e.nrdconta = 7877315	AND e.nrctremp = 948663) OR (e.cdcooper = 1	AND e.nrdconta = 7878036	AND e.nrctremp = 7878036) OR
(e.cdcooper = 1	AND e.nrdconta = 7878397	AND e.nrctremp = 942553) OR (e.cdcooper = 1	AND e.nrdconta = 7878907	AND e.nrctremp = 1570032) OR
(e.cdcooper = 1	AND e.nrdconta = 7879318	AND e.nrctremp = 7879318) OR (e.cdcooper = 1	AND e.nrdconta = 7879873	AND e.nrctremp = 496787) OR
(e.cdcooper = 1	AND e.nrdconta = 7880510	AND e.nrctremp = 748094) OR (e.cdcooper = 1	AND e.nrdconta = 7881304	AND e.nrctremp = 607205) OR
(e.cdcooper = 1	AND e.nrdconta = 7884761	AND e.nrctremp = 760749) OR (e.cdcooper = 1	AND e.nrdconta = 7885490	AND e.nrctremp = 615495) OR
(e.cdcooper = 1	AND e.nrdconta = 7885687	AND e.nrctremp = 45624) OR (e.cdcooper = 1	AND e.nrdconta = 7886608	AND e.nrctremp = 7886608) OR
(e.cdcooper = 1	AND e.nrdconta = 7887779	AND e.nrctremp = 85052) OR (e.cdcooper = 1	AND e.nrdconta = 7889321	AND e.nrctremp = 777567) OR
(e.cdcooper = 1	AND e.nrdconta = 7890613	AND e.nrctremp = 154707) OR (e.cdcooper = 1	AND e.nrdconta = 7890613	AND e.nrctremp = 692450) OR
(e.cdcooper = 1	AND e.nrdconta = 7890621	AND e.nrctremp = 977335) OR (e.cdcooper = 1	AND e.nrdconta = 7891130	AND e.nrctremp = 568562) OR
(e.cdcooper = 1	AND e.nrdconta = 7891644	AND e.nrctremp = 7891644) OR (e.cdcooper = 1	AND e.nrdconta = 7892446	AND e.nrctremp = 138404) OR
(e.cdcooper = 1	AND e.nrdconta = 7892861	AND e.nrctremp = 1203993) OR (e.cdcooper = 1	AND e.nrdconta = 7893094	AND e.nrctremp = 717664) OR
(e.cdcooper = 1	AND e.nrdconta = 7893175	AND e.nrctremp = 1170774) OR (e.cdcooper = 1	AND e.nrdconta = 7893744	AND e.nrctremp = 481910) OR
(e.cdcooper = 1	AND e.nrdconta = 7894007	AND e.nrctremp = 942233) OR (e.cdcooper = 1	AND e.nrdconta = 7897235	AND e.nrctremp = 114144) OR
(e.cdcooper = 1	AND e.nrdconta = 7897723	AND e.nrctremp = 1064454) OR (e.cdcooper = 1	AND e.nrdconta = 7897928	AND e.nrctremp = 1300056) OR
(e.cdcooper = 1	AND e.nrdconta = 7898223	AND e.nrctremp = 596178) OR (e.cdcooper = 1	AND e.nrdconta = 7898290	AND e.nrctremp = 888796) OR
(e.cdcooper = 1	AND e.nrdconta = 7898835	AND e.nrctremp = 1551332) OR (e.cdcooper = 1	AND e.nrdconta = 7899483	AND e.nrctremp = 718676) OR
(e.cdcooper = 1	AND e.nrdconta = 7900082	AND e.nrctremp = 7900082) OR (e.cdcooper = 1	AND e.nrdconta = 7901011	AND e.nrctremp = 935243) OR
(e.cdcooper = 1	AND e.nrdconta = 7901089	AND e.nrctremp = 7901089) OR (e.cdcooper = 1	AND e.nrdconta = 7901810	AND e.nrctremp = 605657) OR
(e.cdcooper = 1	AND e.nrdconta = 7901976	AND e.nrctremp = 3889) OR (e.cdcooper = 1	AND e.nrdconta = 7902255	AND e.nrctremp = 11436) OR
(e.cdcooper = 1	AND e.nrdconta = 7902891	AND e.nrctremp = 1619471) OR (e.cdcooper = 1	AND e.nrdconta = 7903545	AND e.nrctremp = 648382) OR
(e.cdcooper = 1	AND e.nrdconta = 7904479	AND e.nrctremp = 1156520) OR (e.cdcooper = 1	AND e.nrdconta = 7905351	AND e.nrctremp = 1039055) OR
(e.cdcooper = 1	AND e.nrdconta = 7905548	AND e.nrctremp = 462733) OR (e.cdcooper = 1	AND e.nrdconta = 7907141	AND e.nrctremp = 754546) OR
(e.cdcooper = 1	AND e.nrdconta = 7908970	AND e.nrctremp = 765591) OR (e.cdcooper = 1	AND e.nrdconta = 7910355	AND e.nrctremp = 424939) OR
(e.cdcooper = 1	AND e.nrdconta = 7911432	AND e.nrctremp = 195) OR (e.cdcooper = 1	AND e.nrdconta = 7911653	AND e.nrctremp = 7911653) OR
(e.cdcooper = 1	AND e.nrdconta = 7912021	AND e.nrctremp = 1267655) OR (e.cdcooper = 1	AND e.nrdconta = 7916035	AND e.nrctremp = 565029) OR
(e.cdcooper = 1	AND e.nrdconta = 7916973	AND e.nrctremp = 1596189) OR (e.cdcooper = 1	AND e.nrdconta = 7917236	AND e.nrctremp = 543057) OR
(e.cdcooper = 1	AND e.nrdconta = 7917287	AND e.nrctremp = 11258) OR (e.cdcooper = 1	AND e.nrdconta = 7917384	AND e.nrctremp = 1095389) OR
(e.cdcooper = 1	AND e.nrdconta = 7918020	AND e.nrctremp = 758164) OR (e.cdcooper = 1	AND e.nrdconta = 7918372	AND e.nrctremp = 449250) OR
(e.cdcooper = 1	AND e.nrdconta = 7918674	AND e.nrctremp = 806884) OR (e.cdcooper = 1	AND e.nrdconta = 7919360	AND e.nrctremp = 408996) OR
(e.cdcooper = 1	AND e.nrdconta = 7919972	AND e.nrctremp = 827140) OR (e.cdcooper = 1	AND e.nrdconta = 7920105	AND e.nrctremp = 502342) OR
(e.cdcooper = 1	AND e.nrdconta = 7920547	AND e.nrctremp = 752831) OR (e.cdcooper = 1	AND e.nrdconta = 7920857	AND e.nrctremp = 1992561) OR
(e.cdcooper = 1	AND e.nrdconta = 7920962	AND e.nrctremp = 1586799) OR (e.cdcooper = 1	AND e.nrdconta = 7921136	AND e.nrctremp = 7921136) OR
(e.cdcooper = 1	AND e.nrdconta = 7922159	AND e.nrctremp = 969185) OR (e.cdcooper = 1	AND e.nrdconta = 7922442	AND e.nrctremp = 1920934) OR
(e.cdcooper = 1	AND e.nrdconta = 7923112	AND e.nrctremp = 608024) OR (e.cdcooper = 1	AND e.nrdconta = 7925085	AND e.nrctremp = 7925085) OR
(e.cdcooper = 1	AND e.nrdconta = 7926839	AND e.nrctremp = 172579) OR (e.cdcooper = 1	AND e.nrdconta = 7926901	AND e.nrctremp = 111607) OR
(e.cdcooper = 1	AND e.nrdconta = 7927053	AND e.nrctremp = 419271) OR (e.cdcooper = 1	AND e.nrdconta = 7928114	AND e.nrctremp = 1192019) OR
(e.cdcooper = 1	AND e.nrdconta = 7928440	AND e.nrctremp = 1304215) OR (e.cdcooper = 1	AND e.nrdconta = 7928505	AND e.nrctremp = 693829) OR
(e.cdcooper = 1	AND e.nrdconta = 7928742	AND e.nrctremp = 738152) OR (e.cdcooper = 1	AND e.nrdconta = 7928866	AND e.nrctremp = 626246) OR
(e.cdcooper = 1	AND e.nrdconta = 7929110	AND e.nrctremp = 1032197) OR (e.cdcooper = 1	AND e.nrdconta = 7929480	AND e.nrctremp = 331585) OR
(e.cdcooper = 1	AND e.nrdconta = 7929790	AND e.nrctremp = 7929790) OR (e.cdcooper = 1	AND e.nrdconta = 7933169	AND e.nrctremp = 7933169) OR
(e.cdcooper = 1	AND e.nrdconta = 7933568	AND e.nrctremp = 7933568) OR (e.cdcooper = 1	AND e.nrdconta = 7934831	AND e.nrctremp = 7934831) OR
(e.cdcooper = 1	AND e.nrdconta = 7935188	AND e.nrctremp = 904803) OR (e.cdcooper = 1	AND e.nrdconta = 7935188	AND e.nrctremp = 1136072) OR
(e.cdcooper = 1	AND e.nrdconta = 7935846	AND e.nrctremp = 7935846) OR (e.cdcooper = 1	AND e.nrdconta = 7936222	AND e.nrctremp = 1192179) OR
(e.cdcooper = 1	AND e.nrdconta = 7936672	AND e.nrctremp = 516375) OR (e.cdcooper = 1	AND e.nrdconta = 7937440	AND e.nrctremp = 920544) OR
(e.cdcooper = 1	AND e.nrdconta = 7937920	AND e.nrctremp = 1468617) OR (e.cdcooper = 1	AND e.nrdconta = 7940793	AND e.nrctremp = 807144) OR
(e.cdcooper = 1	AND e.nrdconta = 7941650	AND e.nrctremp = 611979) OR (e.cdcooper = 1	AND e.nrdconta = 7941765	AND e.nrctremp = 7941765) OR
(e.cdcooper = 1	AND e.nrdconta = 7944039	AND e.nrctremp = 7944039) OR (e.cdcooper = 1	AND e.nrdconta = 7944683	AND e.nrctremp = 7944683) OR
(e.cdcooper = 1	AND e.nrdconta = 7944691	AND e.nrctremp = 899026) OR (e.cdcooper = 1	AND e.nrdconta = 7945035	AND e.nrctremp = 7945035) OR
(e.cdcooper = 1	AND e.nrdconta = 7945515	AND e.nrctremp = 10000) OR (e.cdcooper = 1	AND e.nrdconta = 7946228	AND e.nrctremp = 7946228) OR
(e.cdcooper = 1	AND e.nrdconta = 7946430	AND e.nrctremp = 1324462) OR (e.cdcooper = 1	AND e.nrdconta = 7948786	AND e.nrctremp = 7948786) OR
(e.cdcooper = 1	AND e.nrdconta = 7948832	AND e.nrctremp = 7948832) OR (e.cdcooper = 1	AND e.nrdconta = 7950322	AND e.nrctremp = 7950322) OR
(e.cdcooper = 1	AND e.nrdconta = 7950357	AND e.nrctremp = 507451) OR (e.cdcooper = 1	AND e.nrdconta = 7952031	AND e.nrctremp = 356838) OR
(e.cdcooper = 1	AND e.nrdconta = 7952090	AND e.nrctremp = 7952090) OR (e.cdcooper = 1	AND e.nrdconta = 7952503	AND e.nrctremp = 1354578) OR
(e.cdcooper = 1	AND e.nrdconta = 7953542	AND e.nrctremp = 585879) OR (e.cdcooper = 1	AND e.nrdconta = 7954271	AND e.nrctremp = 335230) OR
(e.cdcooper = 1	AND e.nrdconta = 7954760	AND e.nrctremp = 727878) OR (e.cdcooper = 1	AND e.nrdconta = 7955863	AND e.nrctremp = 225264) OR
(e.cdcooper = 1	AND e.nrdconta = 7956746	AND e.nrctremp = 596509) OR (e.cdcooper = 1	AND e.nrdconta = 7959362	AND e.nrctremp = 817963) OR
(e.cdcooper = 1	AND e.nrdconta = 7959699	AND e.nrctremp = 1379085) OR (e.cdcooper = 1	AND e.nrdconta = 7959940	AND e.nrctremp = 7959940) OR
(e.cdcooper = 1	AND e.nrdconta = 7960123	AND e.nrctremp = 1214109) OR (e.cdcooper = 1	AND e.nrdconta = 7960255	AND e.nrctremp = 726698) OR
(e.cdcooper = 1	AND e.nrdconta = 7961324	AND e.nrctremp = 366015) OR (e.cdcooper = 1	AND e.nrdconta = 7962851	AND e.nrctremp = 190007) OR
(e.cdcooper = 1	AND e.nrdconta = 7963106	AND e.nrctremp = 105340) OR (e.cdcooper = 1	AND e.nrdconta = 7963122	AND e.nrctremp = 674086) OR
(e.cdcooper = 1	AND e.nrdconta = 7963491	AND e.nrctremp = 7963491) OR (e.cdcooper = 1	AND e.nrdconta = 7963670	AND e.nrctremp = 7963670) OR
(e.cdcooper = 1	AND e.nrdconta = 7964765	AND e.nrctremp = 2012297) OR (e.cdcooper = 1	AND e.nrdconta = 7966482	AND e.nrctremp = 7966482) OR
(e.cdcooper = 1	AND e.nrdconta = 7966610	AND e.nrctremp = 7966610) OR (e.cdcooper = 1	AND e.nrdconta = 7966962	AND e.nrctremp = 773109) OR
(e.cdcooper = 1	AND e.nrdconta = 7967039	AND e.nrctremp = 1168615) OR (e.cdcooper = 1	AND e.nrdconta = 7967543	AND e.nrctremp = 7967543) OR
(e.cdcooper = 1	AND e.nrdconta = 7968639	AND e.nrctremp = 874697) OR (e.cdcooper = 1	AND e.nrdconta = 7971028	AND e.nrctremp = 685807) OR
(e.cdcooper = 1	AND e.nrdconta = 7971680	AND e.nrctremp = 690120) OR (e.cdcooper = 1	AND e.nrdconta = 7971699	AND e.nrctremp = 1103121) OR
(e.cdcooper = 1	AND e.nrdconta = 7971770	AND e.nrctremp = 7971770) OR (e.cdcooper = 1	AND e.nrdconta = 7972237	AND e.nrctremp = 7972237) OR
(e.cdcooper = 1	AND e.nrdconta = 7973268	AND e.nrctremp = 988926) OR (e.cdcooper = 1	AND e.nrdconta = 7973861	AND e.nrctremp = 611675) OR
(e.cdcooper = 1	AND e.nrdconta = 7974663	AND e.nrctremp = 7974663) OR (e.cdcooper = 1	AND e.nrdconta = 7975120	AND e.nrctremp = 1489018) OR
(e.cdcooper = 1	AND e.nrdconta = 7975988	AND e.nrctremp = 581432) OR (e.cdcooper = 1	AND e.nrdconta = 7977336	AND e.nrctremp = 1002517) OR
(e.cdcooper = 1	AND e.nrdconta = 7978618	AND e.nrctremp = 1354291) OR (e.cdcooper = 1	AND e.nrdconta = 7979380	AND e.nrctremp = 764012) OR
(e.cdcooper = 1	AND e.nrdconta = 7979509	AND e.nrctremp = 1006648) OR (e.cdcooper = 1	AND e.nrdconta = 7979673	AND e.nrctremp = 785745) OR
(e.cdcooper = 1	AND e.nrdconta = 7981317	AND e.nrctremp = 798396) OR (e.cdcooper = 1	AND e.nrdconta = 7981317	AND e.nrctremp = 907463) OR
(e.cdcooper = 1	AND e.nrdconta = 7981481	AND e.nrctremp = 1185498) OR (e.cdcooper = 1	AND e.nrdconta = 7982267	AND e.nrctremp = 7982267) OR
(e.cdcooper = 1	AND e.nrdconta = 7982364	AND e.nrctremp = 723046) OR (e.cdcooper = 1	AND e.nrdconta = 7982712	AND e.nrctremp = 87366) OR
(e.cdcooper = 1	AND e.nrdconta = 7982887	AND e.nrctremp = 614814) OR (e.cdcooper = 1	AND e.nrdconta = 7983522	AND e.nrctremp = 121416) OR
(e.cdcooper = 1	AND e.nrdconta = 7984634	AND e.nrctremp = 1090036) OR (e.cdcooper = 1	AND e.nrdconta = 7984634	AND e.nrctremp = 1949603) OR
(e.cdcooper = 1	AND e.nrdconta = 7985576	AND e.nrctremp = 7985576) OR (e.cdcooper = 1	AND e.nrdconta = 7985630	AND e.nrctremp = 870732) OR
(e.cdcooper = 1	AND e.nrdconta = 7986335	AND e.nrctremp = 7986335) OR (e.cdcooper = 1	AND e.nrdconta = 7986653	AND e.nrctremp = 7986653) OR
(e.cdcooper = 1	AND e.nrdconta = 7986661	AND e.nrctremp = 422324) OR (e.cdcooper = 1	AND e.nrdconta = 7986823	AND e.nrctremp = 968114) OR
(e.cdcooper = 1	AND e.nrdconta = 7987110	AND e.nrctremp = 136321) OR (e.cdcooper = 1	AND e.nrdconta = 7987471	AND e.nrctremp = 102112) OR
(e.cdcooper = 1	AND e.nrdconta = 7988249	AND e.nrctremp = 682651) OR (e.cdcooper = 1	AND e.nrdconta = 7990936	AND e.nrctremp = 7990936) OR
(e.cdcooper = 1	AND e.nrdconta = 7991487	AND e.nrctremp = 123021) OR (e.cdcooper = 1	AND e.nrdconta = 7991665	AND e.nrctremp = 1191482) OR
(e.cdcooper = 1	AND e.nrdconta = 7992874	AND e.nrctremp = 155241) OR (e.cdcooper = 1	AND e.nrdconta = 7993749	AND e.nrctremp = 935897) OR
(e.cdcooper = 1	AND e.nrdconta = 7994044	AND e.nrctremp = 836631) OR (e.cdcooper = 1	AND e.nrdconta = 7995466	AND e.nrctremp = 869935) OR
(e.cdcooper = 1	AND e.nrdconta = 7995830	AND e.nrctremp = 745492) OR (e.cdcooper = 1	AND e.nrdconta = 7996551	AND e.nrctremp = 1062260) OR
(e.cdcooper = 1	AND e.nrdconta = 7996667	AND e.nrctremp = 10843) OR (e.cdcooper = 1	AND e.nrdconta = 7996748	AND e.nrctremp = 1250521) OR
(e.cdcooper = 1	AND e.nrdconta = 7996870	AND e.nrctremp = 157104) OR (e.cdcooper = 1	AND e.nrdconta = 7997078	AND e.nrctremp = 7997078) OR
(e.cdcooper = 1	AND e.nrdconta = 7997159	AND e.nrctremp = 875523) OR (e.cdcooper = 1	AND e.nrdconta = 7999119	AND e.nrctremp = 887761) OR
(e.cdcooper = 1	AND e.nrdconta = 8000018	AND e.nrctremp = 547487) OR (e.cdcooper = 1	AND e.nrdconta = 8000832	AND e.nrctremp = 8000832) OR
(e.cdcooper = 1	AND e.nrdconta = 8001324	AND e.nrctremp = 740061) OR (e.cdcooper = 1	AND e.nrdconta = 8003696	AND e.nrctremp = 8003696) OR
(e.cdcooper = 1	AND e.nrdconta = 8004439	AND e.nrctremp = 8004439) OR (e.cdcooper = 1	AND e.nrdconta = 8005168	AND e.nrctremp = 8005168) OR
(e.cdcooper = 1	AND e.nrdconta = 8005311	AND e.nrctremp = 8005311) OR (e.cdcooper = 1	AND e.nrdconta = 8005567	AND e.nrctremp = 939117) OR
(e.cdcooper = 1	AND e.nrdconta = 8005974	AND e.nrctremp = 8005974) OR (e.cdcooper = 1	AND e.nrdconta = 8007500	AND e.nrctremp = 8007500) OR
(e.cdcooper = 1	AND e.nrdconta = 8008094	AND e.nrctremp = 570845) OR (e.cdcooper = 1	AND e.nrdconta = 8008744	AND e.nrctremp = 8008744) OR
(e.cdcooper = 1	AND e.nrdconta = 8009945	AND e.nrctremp = 8009945) OR (e.cdcooper = 1	AND e.nrdconta = 8010170	AND e.nrctremp = 1260472) OR
(e.cdcooper = 1	AND e.nrdconta = 8010250	AND e.nrctremp = 808048) OR (e.cdcooper = 1	AND e.nrdconta = 8010463	AND e.nrctremp = 8010463) OR
(e.cdcooper = 1	AND e.nrdconta = 8010927	AND e.nrctremp = 1586595) OR (e.cdcooper = 1	AND e.nrdconta = 8011915	AND e.nrctremp = 63199) OR
(e.cdcooper = 1	AND e.nrdconta = 8011974	AND e.nrctremp = 1550955) OR (e.cdcooper = 1	AND e.nrdconta = 8014353	AND e.nrctremp = 117131) OR
(e.cdcooper = 1	AND e.nrdconta = 8014574	AND e.nrctremp = 878056) OR (e.cdcooper = 1	AND e.nrdconta = 8015260	AND e.nrctremp = 534551) OR
(e.cdcooper = 1	AND e.nrdconta = 8015384	AND e.nrctremp = 8015384) OR (e.cdcooper = 1	AND e.nrdconta = 8015988	AND e.nrctremp = 1051156) OR
(e.cdcooper = 1	AND e.nrdconta = 8016810	AND e.nrctremp = 8016810) OR (e.cdcooper = 1	AND e.nrdconta = 8017662	AND e.nrctremp = 895668) OR
(e.cdcooper = 1	AND e.nrdconta = 8019312	AND e.nrctremp = 507809) OR (e.cdcooper = 1	AND e.nrdconta = 8019746	AND e.nrctremp = 1227712) OR
(e.cdcooper = 1	AND e.nrdconta = 8020000	AND e.nrctremp = 852586) OR (e.cdcooper = 1	AND e.nrdconta = 8021570	AND e.nrctremp = 831387) OR
(e.cdcooper = 1	AND e.nrdconta = 8022097	AND e.nrctremp = 8022097) OR (e.cdcooper = 1	AND e.nrdconta = 8023085	AND e.nrctremp = 8023085) OR
(e.cdcooper = 1	AND e.nrdconta = 8024294	AND e.nrctremp = 172363) OR (e.cdcooper = 1	AND e.nrdconta = 8024774	AND e.nrctremp = 1346552) OR
(e.cdcooper = 1	AND e.nrdconta = 8025045	AND e.nrctremp = 1100000) OR (e.cdcooper = 1	AND e.nrdconta = 8025045	AND e.nrctremp = 1291584) OR
(e.cdcooper = 1	AND e.nrdconta = 8025550	AND e.nrctremp = 8025550) OR (e.cdcooper = 1	AND e.nrdconta = 8026858	AND e.nrctremp = 499392) OR
(e.cdcooper = 1	AND e.nrdconta = 8027080	AND e.nrctremp = 8027080) OR (e.cdcooper = 1	AND e.nrdconta = 8027455	AND e.nrctremp = 8027455) OR
(e.cdcooper = 1	AND e.nrdconta = 8028419	AND e.nrctremp = 1617386) OR (e.cdcooper = 1	AND e.nrdconta = 8029156	AND e.nrctremp = 2012943) OR
(e.cdcooper = 1	AND e.nrdconta = 8029580	AND e.nrctremp = 1437888) OR (e.cdcooper = 1	AND e.nrdconta = 8029580	AND e.nrctremp = 1448017) OR
(e.cdcooper = 1	AND e.nrdconta = 8030308	AND e.nrctremp = 694991) OR (e.cdcooper = 1	AND e.nrdconta = 8031029	AND e.nrctremp = 8031029) OR
(e.cdcooper = 1	AND e.nrdconta = 8032408	AND e.nrctremp = 121319) OR (e.cdcooper = 1	AND e.nrdconta = 8032408	AND e.nrctremp = 8032408) OR
(e.cdcooper = 1	AND e.nrdconta = 8032858	AND e.nrctremp = 8032858) OR (e.cdcooper = 1	AND e.nrdconta = 8033390	AND e.nrctremp = 8033390) OR
(e.cdcooper = 1	AND e.nrdconta = 8034117	AND e.nrctremp = 521679) OR (e.cdcooper = 1	AND e.nrdconta = 8036314	AND e.nrctremp = 586196) OR
(e.cdcooper = 1	AND e.nrdconta = 8036624	AND e.nrctremp = 933455) OR (e.cdcooper = 1	AND e.nrdconta = 8037272	AND e.nrctremp = 1156799) OR
(e.cdcooper = 1	AND e.nrdconta = 8037302	AND e.nrctremp = 8037302) OR (e.cdcooper = 1	AND e.nrdconta = 8038325	AND e.nrctremp = 731974) OR
(e.cdcooper = 1	AND e.nrdconta = 8041369	AND e.nrctremp = 634288) OR (e.cdcooper = 1	AND e.nrdconta = 8041539	AND e.nrctremp = 1228264) OR
(e.cdcooper = 1	AND e.nrdconta = 8042292	AND e.nrctremp = 181398) OR (e.cdcooper = 1	AND e.nrdconta = 8042578	AND e.nrctremp = 1284779) OR
(e.cdcooper = 1	AND e.nrdconta = 8042799	AND e.nrctremp = 1051305) OR (e.cdcooper = 1	AND e.nrdconta = 8042985	AND e.nrctremp = 1517043) OR
(e.cdcooper = 1	AND e.nrdconta = 8045461	AND e.nrctremp = 771087) OR (e.cdcooper = 1	AND e.nrdconta = 8046603	AND e.nrctremp = 889273) OR
(e.cdcooper = 1	AND e.nrdconta = 8046646	AND e.nrctremp = 8046646) OR (e.cdcooper = 1	AND e.nrdconta = 8047103	AND e.nrctremp = 8047103) OR
(e.cdcooper = 1	AND e.nrdconta = 8047553	AND e.nrctremp = 785218) OR (e.cdcooper = 1	AND e.nrdconta = 8051062	AND e.nrctremp = 125872) OR
(e.cdcooper = 1	AND e.nrdconta = 8051771	AND e.nrctremp = 853477) OR (e.cdcooper = 1	AND e.nrdconta = 8053081	AND e.nrctremp = 8053081) OR
(e.cdcooper = 1	AND e.nrdconta = 8053162	AND e.nrctremp = 1128505) OR (e.cdcooper = 1	AND e.nrdconta = 8053324	AND e.nrctremp = 8053324) OR
(e.cdcooper = 1	AND e.nrdconta = 8053944	AND e.nrctremp = 483306) OR (e.cdcooper = 1	AND e.nrdconta = 8054924	AND e.nrctremp = 516294) OR
(e.cdcooper = 1	AND e.nrdconta = 8055084	AND e.nrctremp = 726217) OR (e.cdcooper = 1	AND e.nrdconta = 8055750	AND e.nrctremp = 8055750) OR
(e.cdcooper = 1	AND e.nrdconta = 8056382	AND e.nrctremp = 8056382) OR (e.cdcooper = 1	AND e.nrdconta = 8057842	AND e.nrctremp = 8057842) OR
(e.cdcooper = 1	AND e.nrdconta = 8057893	AND e.nrctremp = 1272197) OR (e.cdcooper = 1	AND e.nrdconta = 8058725	AND e.nrctremp = 8058725) OR
(e.cdcooper = 1	AND e.nrdconta = 8061270	AND e.nrctremp = 1852979) OR (e.cdcooper = 1	AND e.nrdconta = 8061297	AND e.nrctremp = 1161559) OR
(e.cdcooper = 1	AND e.nrdconta = 8061947	AND e.nrctremp = 900987) OR (e.cdcooper = 1	AND e.nrdconta = 8062412	AND e.nrctremp = 535391) OR
(e.cdcooper = 1	AND e.nrdconta = 8064326	AND e.nrctremp = 682849) OR (e.cdcooper = 1	AND e.nrdconta = 8065101	AND e.nrctremp = 1060582) OR
(e.cdcooper = 1	AND e.nrdconta = 8065551	AND e.nrctremp = 8065551) OR (e.cdcooper = 1	AND e.nrdconta = 8065942	AND e.nrctremp = 8065942) OR
(e.cdcooper = 1	AND e.nrdconta = 8066191	AND e.nrctremp = 605319) OR (e.cdcooper = 1	AND e.nrdconta = 8068844	AND e.nrctremp = 1091729) OR
(e.cdcooper = 1	AND e.nrdconta = 8068895	AND e.nrctremp = 8068895) OR (e.cdcooper = 1	AND e.nrdconta = 8069590	AND e.nrctremp = 521863) OR
(e.cdcooper = 1	AND e.nrdconta = 8069727	AND e.nrctremp = 8069727) OR (e.cdcooper = 1	AND e.nrdconta = 8070326	AND e.nrctremp = 944824) OR
(e.cdcooper = 1	AND e.nrdconta = 8071314	AND e.nrctremp = 8071314) OR (e.cdcooper = 1	AND e.nrdconta = 8071357	AND e.nrctremp = 8071357) OR
(e.cdcooper = 1	AND e.nrdconta = 8073279	AND e.nrctremp = 498544) OR (e.cdcooper = 1	AND e.nrdconta = 8074780	AND e.nrctremp = 8074780) OR
(e.cdcooper = 1	AND e.nrdconta = 8074968	AND e.nrctremp = 1561294) OR (e.cdcooper = 1	AND e.nrdconta = 8075557	AND e.nrctremp = 8075557) OR
(e.cdcooper = 1	AND e.nrdconta = 8076278	AND e.nrctremp = 1228772) OR (e.cdcooper = 1	AND e.nrdconta = 8076413	AND e.nrctremp = 708695) OR
(e.cdcooper = 1	AND e.nrdconta = 8078637	AND e.nrctremp = 479080) OR (e.cdcooper = 1	AND e.nrdconta = 8078742	AND e.nrctremp = 781888) OR
(e.cdcooper = 1	AND e.nrdconta = 8079021	AND e.nrctremp = 618466) OR (e.cdcooper = 1	AND e.nrdconta = 8079242	AND e.nrctremp = 95195) OR
(e.cdcooper = 1	AND e.nrdconta = 8079307	AND e.nrctremp = 744131) OR (e.cdcooper = 1	AND e.nrdconta = 8079480	AND e.nrctremp = 1214567) OR
(e.cdcooper = 1	AND e.nrdconta = 8080453	AND e.nrctremp = 8080453) OR (e.cdcooper = 1	AND e.nrdconta = 8080615	AND e.nrctremp = 8080615) OR
(e.cdcooper = 1	AND e.nrdconta = 8081921	AND e.nrctremp = 8081921) OR (e.cdcooper = 1	AND e.nrdconta = 8082693	AND e.nrctremp = 1363773) OR
(e.cdcooper = 1	AND e.nrdconta = 8083673	AND e.nrctremp = 403077) OR (e.cdcooper = 1	AND e.nrdconta = 8083800	AND e.nrctremp = 730382) OR
(e.cdcooper = 1	AND e.nrdconta = 8085641	AND e.nrctremp = 8085641) OR (e.cdcooper = 1	AND e.nrdconta = 8087571	AND e.nrctremp = 1105698) OR
(e.cdcooper = 1	AND e.nrdconta = 8088454	AND e.nrctremp = 2221464) OR (e.cdcooper = 1	AND e.nrdconta = 8088586	AND e.nrctremp = 8088586) OR
(e.cdcooper = 1	AND e.nrdconta = 8088764	AND e.nrctremp = 1055110) OR (e.cdcooper = 1	AND e.nrdconta = 8092958	AND e.nrctremp = 95584) OR
(e.cdcooper = 1	AND e.nrdconta = 8093008	AND e.nrctremp = 8093008) OR (e.cdcooper = 1	AND e.nrdconta = 8093164	AND e.nrctremp = 8093164) OR
(e.cdcooper = 1	AND e.nrdconta = 8093466	AND e.nrctremp = 1318517) OR (e.cdcooper = 1	AND e.nrdconta = 8093792	AND e.nrctremp = 683812) OR
(e.cdcooper = 1	AND e.nrdconta = 8094802	AND e.nrctremp = 1673724) OR (e.cdcooper = 1	AND e.nrdconta = 8095841	AND e.nrctremp = 748737) OR
(e.cdcooper = 1	AND e.nrdconta = 8096031	AND e.nrctremp = 8096031) OR (e.cdcooper = 1	AND e.nrdconta = 8096244	AND e.nrctremp = 961807) OR
(e.cdcooper = 1	AND e.nrdconta = 8099405	AND e.nrctremp = 501882) OR (e.cdcooper = 1	AND e.nrdconta = 8099715	AND e.nrctremp = 480405) OR
(e.cdcooper = 1	AND e.nrdconta = 8100128	AND e.nrctremp = 445954) OR (e.cdcooper = 1	AND e.nrdconta = 8100578	AND e.nrctremp = 1184246) OR
(e.cdcooper = 1	AND e.nrdconta = 8101620	AND e.nrctremp = 8101620) OR (e.cdcooper = 1	AND e.nrdconta = 8101825	AND e.nrctremp = 1920945) OR
(e.cdcooper = 1	AND e.nrdconta = 8103097	AND e.nrctremp = 8103097) OR (e.cdcooper = 1	AND e.nrdconta = 8103283	AND e.nrctremp = 650059) OR
(e.cdcooper = 1	AND e.nrdconta = 8103640	AND e.nrctremp = 1115410) OR (e.cdcooper = 1	AND e.nrdconta = 8105383	AND e.nrctremp = 2220564) OR
(e.cdcooper = 1	AND e.nrdconta = 8106800	AND e.nrctremp = 543720) OR (e.cdcooper = 1	AND e.nrdconta = 8109605	AND e.nrctremp = 1283778) OR
(e.cdcooper = 1	AND e.nrdconta = 8110786	AND e.nrctremp = 636658) OR (e.cdcooper = 1	AND e.nrdconta = 8112282	AND e.nrctremp = 718662) OR
(e.cdcooper = 1	AND e.nrdconta = 8112525	AND e.nrctremp = 811607) OR (e.cdcooper = 1	AND e.nrdconta = 8112851	AND e.nrctremp = 1138692) OR
(e.cdcooper = 1	AND e.nrdconta = 8113181	AND e.nrctremp = 765198) OR (e.cdcooper = 1	AND e.nrdconta = 8116407	AND e.nrctremp = 1016475) OR
(e.cdcooper = 1	AND e.nrdconta = 8116555	AND e.nrctremp = 107253) OR (e.cdcooper = 1	AND e.nrdconta = 8116725	AND e.nrctremp = 871597) OR
(e.cdcooper = 1	AND e.nrdconta = 8118639	AND e.nrctremp = 1210599) OR (e.cdcooper = 1	AND e.nrdconta = 8119163	AND e.nrctremp = 8119163) OR
(e.cdcooper = 1	AND e.nrdconta = 8122210	AND e.nrctremp = 810392) OR (e.cdcooper = 1	AND e.nrdconta = 8123071	AND e.nrctremp = 144877) OR
(e.cdcooper = 1	AND e.nrdconta = 8123489	AND e.nrctremp = 1172610) OR (e.cdcooper = 1	AND e.nrdconta = 8125295	AND e.nrctremp = 1297218) OR
(e.cdcooper = 1	AND e.nrdconta = 8125635	AND e.nrctremp = 578609) OR (e.cdcooper = 1	AND e.nrdconta = 8126550	AND e.nrctremp = 788758) OR
(e.cdcooper = 1	AND e.nrdconta = 8127557	AND e.nrctremp = 114133) OR (e.cdcooper = 1	AND e.nrdconta = 8128545	AND e.nrctremp = 8128545) OR
(e.cdcooper = 1	AND e.nrdconta = 8129649	AND e.nrctremp = 776430) OR (e.cdcooper = 1	AND e.nrdconta = 8129690	AND e.nrctremp = 960614) OR
(e.cdcooper = 1	AND e.nrdconta = 8131260	AND e.nrctremp = 8131260) OR (e.cdcooper = 1	AND e.nrdconta = 8131368	AND e.nrctremp = 8131368) OR
(e.cdcooper = 1	AND e.nrdconta = 8133220	AND e.nrctremp = 785951) OR (e.cdcooper = 1	AND e.nrdconta = 8133387	AND e.nrctremp = 818213) OR
(e.cdcooper = 1	AND e.nrdconta = 8134588	AND e.nrctremp = 571498) OR (e.cdcooper = 1	AND e.nrdconta = 8134669	AND e.nrctremp = 8134669) OR
(e.cdcooper = 1	AND e.nrdconta = 8136327	AND e.nrctremp = 1111243) OR (e.cdcooper = 1	AND e.nrdconta = 8138540	AND e.nrctremp = 8138540) OR
(e.cdcooper = 1	AND e.nrdconta = 8139016	AND e.nrctremp = 1326586) OR (e.cdcooper = 1	AND e.nrdconta = 8139024	AND e.nrctremp = 705661) OR
(e.cdcooper = 1	AND e.nrdconta = 8139334	AND e.nrctremp = 817833) OR (e.cdcooper = 1	AND e.nrdconta = 8139431	AND e.nrctremp = 382579) OR
(e.cdcooper = 1	AND e.nrdconta = 8140456	AND e.nrctremp = 897313) OR (e.cdcooper = 1	AND e.nrdconta = 8140740	AND e.nrctremp = 617969) OR
(e.cdcooper = 1	AND e.nrdconta = 8140910	AND e.nrctremp = 1643994) OR (e.cdcooper = 1	AND e.nrdconta = 8141401	AND e.nrctremp = 735357) OR
(e.cdcooper = 1	AND e.nrdconta = 8145059	AND e.nrctremp = 741476) OR (e.cdcooper = 1	AND e.nrdconta = 8145113	AND e.nrctremp = 8145113) OR
(e.cdcooper = 1	AND e.nrdconta = 8146241	AND e.nrctremp = 647061) OR (e.cdcooper = 1	AND e.nrdconta = 8146934	AND e.nrctremp = 973383) OR
(e.cdcooper = 1	AND e.nrdconta = 8147329	AND e.nrctremp = 162568) OR (e.cdcooper = 1	AND e.nrdconta = 8149194	AND e.nrctremp = 602769) OR
(e.cdcooper = 1	AND e.nrdconta = 8149194	AND e.nrctremp = 602774) OR (e.cdcooper = 1	AND e.nrdconta = 8149305	AND e.nrctremp = 1361985) OR
(e.cdcooper = 1	AND e.nrdconta = 8149704	AND e.nrctremp = 832316) OR (e.cdcooper = 1	AND e.nrdconta = 8150095	AND e.nrctremp = 1195157) OR
(e.cdcooper = 1	AND e.nrdconta = 8151407	AND e.nrctremp = 549095) OR (e.cdcooper = 1	AND e.nrdconta = 8151458	AND e.nrctremp = 192003) OR
(e.cdcooper = 1	AND e.nrdconta = 8153949	AND e.nrctremp = 1313820) OR (e.cdcooper = 1	AND e.nrdconta = 8155232	AND e.nrctremp = 1629770) OR
(e.cdcooper = 1	AND e.nrdconta = 8156034	AND e.nrctremp = 303918) OR (e.cdcooper = 1	AND e.nrdconta = 8157766	AND e.nrctremp = 173524) OR
(e.cdcooper = 1	AND e.nrdconta = 8157804	AND e.nrctremp = 1449785) OR (e.cdcooper = 1	AND e.nrdconta = 8157847	AND e.nrctremp = 820560) OR
(e.cdcooper = 1	AND e.nrdconta = 8157995	AND e.nrctremp = 8157995) OR (e.cdcooper = 1	AND e.nrdconta = 8158290	AND e.nrctremp = 1325020) OR
(e.cdcooper = 1	AND e.nrdconta = 8158479	AND e.nrctremp = 177124) OR (e.cdcooper = 1	AND e.nrdconta = 8158827	AND e.nrctremp = 557857) OR
(e.cdcooper = 1	AND e.nrdconta = 8159220	AND e.nrctremp = 144245) OR (e.cdcooper = 1	AND e.nrdconta = 8159572	AND e.nrctremp = 758066) OR
(e.cdcooper = 1	AND e.nrdconta = 8160341	AND e.nrctremp = 509636) OR (e.cdcooper = 1	AND e.nrdconta = 8160961	AND e.nrctremp = 524798) OR
(e.cdcooper = 1	AND e.nrdconta = 8161968	AND e.nrctremp = 1028470) OR (e.cdcooper = 1	AND e.nrdconta = 8164703	AND e.nrctremp = 707126) OR
(e.cdcooper = 1	AND e.nrdconta = 8165270	AND e.nrctremp = 919800) OR (e.cdcooper = 1	AND e.nrdconta = 8166463	AND e.nrctremp = 1571642) OR
(e.cdcooper = 1	AND e.nrdconta = 8166498	AND e.nrctremp = 670559) OR (e.cdcooper = 1	AND e.nrdconta = 8167672	AND e.nrctremp = 8167672) OR
(e.cdcooper = 1	AND e.nrdconta = 8167710	AND e.nrctremp = 1514963) OR (e.cdcooper = 1	AND e.nrdconta = 8167745	AND e.nrctremp = 750573) OR
(e.cdcooper = 1	AND e.nrdconta = 8169829	AND e.nrctremp = 549186) OR (e.cdcooper = 1	AND e.nrdconta = 8170576	AND e.nrctremp = 944109) OR
(e.cdcooper = 1	AND e.nrdconta = 8170657	AND e.nrctremp = 1073887) OR (e.cdcooper = 1	AND e.nrdconta = 8171599	AND e.nrctremp = 336633) OR
(e.cdcooper = 1	AND e.nrdconta = 8172153	AND e.nrctremp = 1490906) OR (e.cdcooper = 1	AND e.nrdconta = 8172919	AND e.nrctremp = 767686) OR
(e.cdcooper = 1	AND e.nrdconta = 8173150	AND e.nrctremp = 901875) OR (e.cdcooper = 1	AND e.nrdconta = 8174130	AND e.nrctremp = 815528) OR
(e.cdcooper = 1	AND e.nrdconta = 8176019	AND e.nrctremp = 898852) OR (e.cdcooper = 1	AND e.nrdconta = 8177929	AND e.nrctremp = 466182) OR
(e.cdcooper = 1	AND e.nrdconta = 8178283	AND e.nrctremp = 833241) OR (e.cdcooper = 1	AND e.nrdconta = 8178607	AND e.nrctremp = 1193798) OR
(e.cdcooper = 1	AND e.nrdconta = 8180415	AND e.nrctremp = 497017) OR (e.cdcooper = 1	AND e.nrdconta = 8180415	AND e.nrctremp = 8180415) OR
(e.cdcooper = 1	AND e.nrdconta = 8180423	AND e.nrctremp = 8180423) OR (e.cdcooper = 1	AND e.nrdconta = 8180776	AND e.nrctremp = 8180776) OR
(e.cdcooper = 1	AND e.nrdconta = 8181780	AND e.nrctremp = 1853740) OR (e.cdcooper = 1	AND e.nrdconta = 8183694	AND e.nrctremp = 795252) OR
(e.cdcooper = 1	AND e.nrdconta = 8184518	AND e.nrctremp = 406027) OR (e.cdcooper = 1	AND e.nrdconta = 8186197	AND e.nrctremp = 625972) OR
(e.cdcooper = 1	AND e.nrdconta = 8186936	AND e.nrctremp = 8186936) OR (e.cdcooper = 1	AND e.nrdconta = 8187118	AND e.nrctremp = 958517) OR
(e.cdcooper = 1	AND e.nrdconta = 8187681	AND e.nrctremp = 393978) OR (e.cdcooper = 1	AND e.nrdconta = 8187681	AND e.nrctremp = 505052) OR
(e.cdcooper = 1	AND e.nrdconta = 8188238	AND e.nrctremp = 1333538) OR (e.cdcooper = 1	AND e.nrdconta = 8188866	AND e.nrctremp = 695477) OR
(e.cdcooper = 1	AND e.nrdconta = 8188955	AND e.nrctremp = 1353969) OR (e.cdcooper = 1	AND e.nrdconta = 8189820	AND e.nrctremp = 747895) OR
(e.cdcooper = 1	AND e.nrdconta = 8190240	AND e.nrctremp = 770690) OR (e.cdcooper = 1	AND e.nrdconta = 8192219	AND e.nrctremp = 800092) OR
(e.cdcooper = 1	AND e.nrdconta = 8193746	AND e.nrctremp = 8193746) OR (e.cdcooper = 1	AND e.nrdconta = 8195803	AND e.nrctremp = 1073847) OR
(e.cdcooper = 1	AND e.nrdconta = 8196516	AND e.nrctremp = 158786) OR (e.cdcooper = 1	AND e.nrdconta = 8197580	AND e.nrctremp = 8197580) OR
(e.cdcooper = 1	AND e.nrdconta = 8197903	AND e.nrctremp = 8197903) OR (e.cdcooper = 1	AND e.nrdconta = 8199310	AND e.nrctremp = 728629) OR
(e.cdcooper = 1	AND e.nrdconta = 8200262	AND e.nrctremp = 1134307) OR (e.cdcooper = 1	AND e.nrdconta = 8200327	AND e.nrctremp = 728015) OR
(e.cdcooper = 1	AND e.nrdconta = 8201552	AND e.nrctremp = 745032) OR (e.cdcooper = 1	AND e.nrdconta = 8202540	AND e.nrctremp = 8202540) OR
(e.cdcooper = 1	AND e.nrdconta = 8202559	AND e.nrctremp = 8202559) OR (e.cdcooper = 1	AND e.nrdconta = 8203610	AND e.nrctremp = 1004968) OR
(e.cdcooper = 1	AND e.nrdconta = 8203962	AND e.nrctremp = 935697) OR (e.cdcooper = 1	AND e.nrdconta = 8204667	AND e.nrctremp = 771437) OR
(e.cdcooper = 1	AND e.nrdconta = 8205078	AND e.nrctremp = 427336) OR (e.cdcooper = 1	AND e.nrdconta = 8205809	AND e.nrctremp = 571942) OR
(e.cdcooper = 1	AND e.nrdconta = 8207321	AND e.nrctremp = 8207321) OR (e.cdcooper = 1	AND e.nrdconta = 8208069	AND e.nrctremp = 704553) OR
(e.cdcooper = 1	AND e.nrdconta = 8208999	AND e.nrctremp = 8208999) OR (e.cdcooper = 1	AND e.nrdconta = 8210284	AND e.nrctremp = 500226) OR
(e.cdcooper = 1	AND e.nrdconta = 8210799	AND e.nrctremp = 731424) OR (e.cdcooper = 1	AND e.nrdconta = 8210799	AND e.nrctremp = 731427) OR
(e.cdcooper = 1	AND e.nrdconta = 8211264	AND e.nrctremp = 620491) OR (e.cdcooper = 1	AND e.nrdconta = 8211299	AND e.nrctremp = 966581) OR
(e.cdcooper = 1	AND e.nrdconta = 8212120	AND e.nrctremp = 1089622) OR (e.cdcooper = 1	AND e.nrdconta = 8213984	AND e.nrctremp = 1135281) OR
(e.cdcooper = 1	AND e.nrdconta = 8214255	AND e.nrctremp = 502108) OR (e.cdcooper = 1	AND e.nrdconta = 8214379	AND e.nrctremp = 873612) OR
(e.cdcooper = 1	AND e.nrdconta = 8214557	AND e.nrctremp = 1178867) OR (e.cdcooper = 1	AND e.nrdconta = 8214670	AND e.nrctremp = 174607) OR
(e.cdcooper = 1	AND e.nrdconta = 8214875	AND e.nrctremp = 1074662) OR (e.cdcooper = 1	AND e.nrdconta = 8214883	AND e.nrctremp = 565724) OR
(e.cdcooper = 1	AND e.nrdconta = 8214972	AND e.nrctremp = 2012549) OR (e.cdcooper = 1	AND e.nrdconta = 8215472	AND e.nrctremp = 179877) OR
(e.cdcooper = 1	AND e.nrdconta = 8215715	AND e.nrctremp = 519826) OR (e.cdcooper = 1	AND e.nrdconta = 8215790	AND e.nrctremp = 762364) OR
(e.cdcooper = 1	AND e.nrdconta = 8217009	AND e.nrctremp = 757961) OR (e.cdcooper = 1	AND e.nrdconta = 8217114	AND e.nrctremp = 988040) OR
(e.cdcooper = 1	AND e.nrdconta = 8217572	AND e.nrctremp = 1393182) OR (e.cdcooper = 1	AND e.nrdconta = 8217769	AND e.nrctremp = 661597) OR
(e.cdcooper = 1	AND e.nrdconta = 8218560	AND e.nrctremp = 543033) OR (e.cdcooper = 1	AND e.nrdconta = 8219540	AND e.nrctremp = 1247459) OR
(e.cdcooper = 1	AND e.nrdconta = 8219796	AND e.nrctremp = 8219796) OR (e.cdcooper = 1	AND e.nrdconta = 8220450	AND e.nrctremp = 1252848) OR
(e.cdcooper = 1	AND e.nrdconta = 8220590	AND e.nrctremp = 627654) OR (e.cdcooper = 1	AND e.nrdconta = 8221340	AND e.nrctremp = 942194) OR
(e.cdcooper = 1	AND e.nrdconta = 8222207	AND e.nrctremp = 829304) OR (e.cdcooper = 1	AND e.nrdconta = 8223556	AND e.nrctremp = 336961) OR
(e.cdcooper = 1	AND e.nrdconta = 8224200	AND e.nrctremp = 8224200) OR (e.cdcooper = 1	AND e.nrdconta = 8224277	AND e.nrctremp = 907450) OR
(e.cdcooper = 1	AND e.nrdconta = 8225648	AND e.nrctremp = 901550) OR (e.cdcooper = 1	AND e.nrdconta = 8226040	AND e.nrctremp = 8226040) OR
(e.cdcooper = 1	AND e.nrdconta = 8226920	AND e.nrctremp = 861784) OR (e.cdcooper = 1	AND e.nrdconta = 8228493	AND e.nrctremp = 8228493) OR
(e.cdcooper = 1	AND e.nrdconta = 8230099	AND e.nrctremp = 1904111) OR (e.cdcooper = 1	AND e.nrdconta = 8230692	AND e.nrctremp = 8230692) OR
(e.cdcooper = 1	AND e.nrdconta = 8230765	AND e.nrctremp = 1283300) OR (e.cdcooper = 1	AND e.nrdconta = 8231079	AND e.nrctremp = 462696) OR
(e.cdcooper = 1	AND e.nrdconta = 8231796	AND e.nrctremp = 8231796) OR (e.cdcooper = 1	AND e.nrdconta = 8232571	AND e.nrctremp = 450042) OR
(e.cdcooper = 1	AND e.nrdconta = 8232776	AND e.nrctremp = 1794594) OR (e.cdcooper = 1	AND e.nrdconta = 8233446	AND e.nrctremp = 677099) OR
(e.cdcooper = 1	AND e.nrdconta = 8233748	AND e.nrctremp = 1775263) OR (e.cdcooper = 1	AND e.nrdconta = 8234361	AND e.nrctremp = 508706) OR
(e.cdcooper = 1	AND e.nrdconta = 8234850	AND e.nrctremp = 971419) OR (e.cdcooper = 1	AND e.nrdconta = 8235120	AND e.nrctremp = 667610) OR
(e.cdcooper = 1	AND e.nrdconta = 8236399	AND e.nrctremp = 8236399) OR (e.cdcooper = 1	AND e.nrdconta = 8237433	AND e.nrctremp = 8237433) OR
(e.cdcooper = 1	AND e.nrdconta = 8237450	AND e.nrctremp = 8237450) OR (e.cdcooper = 1	AND e.nrdconta = 8238995	AND e.nrctremp = 644343) OR
(e.cdcooper = 1	AND e.nrdconta = 8239169	AND e.nrctremp = 942596) OR (e.cdcooper = 1	AND e.nrdconta = 8239762	AND e.nrctremp = 925734) OR
(e.cdcooper = 1	AND e.nrdconta = 8241538	AND e.nrctremp = 1241732) OR (e.cdcooper = 1	AND e.nrdconta = 8242054	AND e.nrctremp = 8242054) OR
(e.cdcooper = 1	AND e.nrdconta = 8242062	AND e.nrctremp = 1494184) OR (e.cdcooper = 1	AND e.nrdconta = 8242631	AND e.nrctremp = 1022354) OR
(e.cdcooper = 1	AND e.nrdconta = 8244405	AND e.nrctremp = 622320) OR (e.cdcooper = 1	AND e.nrdconta = 8244405	AND e.nrctremp = 899829) OR
(e.cdcooper = 1	AND e.nrdconta = 8245010	AND e.nrctremp = 8245010) OR (e.cdcooper = 1	AND e.nrdconta = 8245053	AND e.nrctremp = 8245053) OR
(e.cdcooper = 1	AND e.nrdconta = 8245665	AND e.nrctremp = 8245665) OR (e.cdcooper = 1	AND e.nrdconta = 8246840	AND e.nrctremp = 642377) OR
(e.cdcooper = 1	AND e.nrdconta = 8246840	AND e.nrctremp = 1121120) OR (e.cdcooper = 1	AND e.nrdconta = 8247790	AND e.nrctremp = 8247790) OR
(e.cdcooper = 1	AND e.nrdconta = 8248770	AND e.nrctremp = 627809) OR (e.cdcooper = 1	AND e.nrdconta = 8248982	AND e.nrctremp = 8248982) OR
(e.cdcooper = 1	AND e.nrdconta = 8249997	AND e.nrctremp = 1134738) OR (e.cdcooper = 1	AND e.nrdconta = 8250707	AND e.nrctremp = 501338) OR
(e.cdcooper = 1	AND e.nrdconta = 8250871	AND e.nrctremp = 889286) OR (e.cdcooper = 1	AND e.nrdconta = 8250871	AND e.nrctremp = 1085337) OR
(e.cdcooper = 1	AND e.nrdconta = 8251258	AND e.nrctremp = 822039) OR (e.cdcooper = 1	AND e.nrdconta = 8251525	AND e.nrctremp = 846188) OR
(e.cdcooper = 1	AND e.nrdconta = 8252424	AND e.nrctremp = 478100) OR (e.cdcooper = 1	AND e.nrdconta = 8253528	AND e.nrctremp = 501653) OR
(e.cdcooper = 1	AND e.nrdconta = 8255555	AND e.nrctremp = 8255555) OR (e.cdcooper = 1	AND e.nrdconta = 8255687	AND e.nrctremp = 1470874) OR
(e.cdcooper = 1	AND e.nrdconta = 8256152	AND e.nrctremp = 977815) OR (e.cdcooper = 1	AND e.nrdconta = 8257035	AND e.nrctremp = 994171) OR
(e.cdcooper = 1	AND e.nrdconta = 8257213	AND e.nrctremp = 1073918) OR (e.cdcooper = 1	AND e.nrdconta = 8257841	AND e.nrctremp = 8257841) OR
(e.cdcooper = 1	AND e.nrdconta = 8258201	AND e.nrctremp = 8258201) OR (e.cdcooper = 1	AND e.nrdconta = 8258236	AND e.nrctremp = 820385) OR
(e.cdcooper = 1	AND e.nrdconta = 8258520	AND e.nrctremp = 833379) OR (e.cdcooper = 1	AND e.nrdconta = 8258546	AND e.nrctremp = 953981) OR
(e.cdcooper = 1	AND e.nrdconta = 8259259	AND e.nrctremp = 766192) OR (e.cdcooper = 1	AND e.nrdconta = 8259275	AND e.nrctremp = 773671) OR
(e.cdcooper = 1	AND e.nrdconta = 8259925	AND e.nrctremp = 1035263) OR (e.cdcooper = 1	AND e.nrdconta = 8260095	AND e.nrctremp = 1371838) OR
(e.cdcooper = 1	AND e.nrdconta = 8260125	AND e.nrctremp = 153131) OR (e.cdcooper = 1	AND e.nrdconta = 8260559	AND e.nrctremp = 8260559) OR
(e.cdcooper = 1	AND e.nrdconta = 8261490	AND e.nrctremp = 975957) OR (e.cdcooper = 1	AND e.nrdconta = 8263035	AND e.nrctremp = 935525) OR
(e.cdcooper = 1	AND e.nrdconta = 8263698	AND e.nrctremp = 345859) OR (e.cdcooper = 1	AND e.nrdconta = 8264104	AND e.nrctremp = 1284243) OR
(e.cdcooper = 1	AND e.nrdconta = 8264139	AND e.nrctremp = 1513464) OR (e.cdcooper = 1	AND e.nrdconta = 8267170	AND e.nrctremp = 1061000) OR
(e.cdcooper = 1	AND e.nrdconta = 8267561	AND e.nrctremp = 898734) OR (e.cdcooper = 1	AND e.nrdconta = 8268126	AND e.nrctremp = 1655135) OR
(e.cdcooper = 1	AND e.nrdconta = 8268304	AND e.nrctremp = 558101) OR (e.cdcooper = 1	AND e.nrdconta = 8269068	AND e.nrctremp = 1503684) OR
(e.cdcooper = 1	AND e.nrdconta = 8269645	AND e.nrctremp = 8269645) OR (e.cdcooper = 1	AND e.nrdconta = 8269688	AND e.nrctremp = 8269688) OR
(e.cdcooper = 1	AND e.nrdconta = 8270287	AND e.nrctremp = 679677) OR (e.cdcooper = 1	AND e.nrdconta = 8272328	AND e.nrctremp = 8272328) OR
(e.cdcooper = 1	AND e.nrdconta = 8272476	AND e.nrctremp = 674324) OR (e.cdcooper = 1	AND e.nrdconta = 8272697	AND e.nrctremp = 674945) OR
(e.cdcooper = 1	AND e.nrdconta = 8274258	AND e.nrctremp = 737869) OR (e.cdcooper = 1	AND e.nrdconta = 8274290	AND e.nrctremp = 8274290) OR
(e.cdcooper = 1	AND e.nrdconta = 8275130	AND e.nrctremp = 1419453) OR (e.cdcooper = 1	AND e.nrdconta = 8278334	AND e.nrctremp = 414951) OR
(e.cdcooper = 1	AND e.nrdconta = 8278652	AND e.nrctremp = 175345) OR (e.cdcooper = 1	AND e.nrdconta = 8279969	AND e.nrctremp = 8279969) OR
(e.cdcooper = 1	AND e.nrdconta = 8279977	AND e.nrctremp = 8279977) OR (e.cdcooper = 1	AND e.nrdconta = 8280576	AND e.nrctremp = 532330) OR
(e.cdcooper = 1	AND e.nrdconta = 8280703	AND e.nrctremp = 800159) OR (e.cdcooper = 1	AND e.nrdconta = 8280711	AND e.nrctremp = 8280711) OR
(e.cdcooper = 1	AND e.nrdconta = 8281149	AND e.nrctremp = 186044) OR (e.cdcooper = 1	AND e.nrdconta = 8281173	AND e.nrctremp = 395235) OR
(e.cdcooper = 1	AND e.nrdconta = 8281432	AND e.nrctremp = 8281432) OR (e.cdcooper = 1	AND e.nrdconta = 8282307	AND e.nrctremp = 8282307) OR
(e.cdcooper = 1	AND e.nrdconta = 8282706	AND e.nrctremp = 758609) OR (e.cdcooper = 1	AND e.nrdconta = 8284920	AND e.nrctremp = 8284920) OR
(e.cdcooper = 1	AND e.nrdconta = 8286248	AND e.nrctremp = 8286248) OR (e.cdcooper = 1	AND e.nrdconta = 8286388	AND e.nrctremp = 766540) OR
(e.cdcooper = 1	AND e.nrdconta = 8286418	AND e.nrctremp = 1366911) OR (e.cdcooper = 1	AND e.nrdconta = 8287856	AND e.nrctremp = 660396) OR
(e.cdcooper = 1	AND e.nrdconta = 8288461	AND e.nrctremp = 900525) OR (e.cdcooper = 1	AND e.nrdconta = 8288607	AND e.nrctremp = 8288607) OR
(e.cdcooper = 1	AND e.nrdconta = 8292124	AND e.nrctremp = 1040414) OR (e.cdcooper = 1	AND e.nrdconta = 8292566	AND e.nrctremp = 8292566) OR
(e.cdcooper = 1	AND e.nrdconta = 8293201	AND e.nrctremp = 383581) OR (e.cdcooper = 1	AND e.nrdconta = 8293201	AND e.nrctremp = 383644) OR
(e.cdcooper = 1	AND e.nrdconta = 8294259	AND e.nrctremp = 507318) OR (e.cdcooper = 1	AND e.nrdconta = 8294500	AND e.nrctremp = 932951) OR
(e.cdcooper = 1	AND e.nrdconta = 8295085	AND e.nrctremp = 8295085) OR (e.cdcooper = 1	AND e.nrdconta = 8295549	AND e.nrctremp = 589726) OR
(e.cdcooper = 1	AND e.nrdconta = 8296030	AND e.nrctremp = 1508395) OR (e.cdcooper = 1	AND e.nrdconta = 8300534	AND e.nrctremp = 8300534) OR
(e.cdcooper = 1	AND e.nrdconta = 8300771	AND e.nrctremp = 8300771) OR (e.cdcooper = 1	AND e.nrdconta = 8301646	AND e.nrctremp = 992641) OR
(e.cdcooper = 1	AND e.nrdconta = 8303347	AND e.nrctremp = 524527) OR (e.cdcooper = 1	AND e.nrdconta = 8304130	AND e.nrctremp = 8304130) OR
(e.cdcooper = 1	AND e.nrdconta = 8304173	AND e.nrctremp = 8304173) OR (e.cdcooper = 1	AND e.nrdconta = 8304246	AND e.nrctremp = 8304246) OR
(e.cdcooper = 1	AND e.nrdconta = 8304521	AND e.nrctremp = 846639) OR (e.cdcooper = 1	AND e.nrdconta = 8304645	AND e.nrctremp = 714070) OR
(e.cdcooper = 1	AND e.nrdconta = 8304920	AND e.nrctremp = 8304920) OR (e.cdcooper = 1	AND e.nrdconta = 8305102	AND e.nrctremp = 637379) OR
(e.cdcooper = 1	AND e.nrdconta = 8305439	AND e.nrctremp = 1379067) OR (e.cdcooper = 1	AND e.nrdconta = 8305811	AND e.nrctremp = 782266) OR
(e.cdcooper = 1	AND e.nrdconta = 8305927	AND e.nrctremp = 8305927) OR (e.cdcooper = 1	AND e.nrdconta = 8306060	AND e.nrctremp = 629461) OR
(e.cdcooper = 1	AND e.nrdconta = 8306095	AND e.nrctremp = 973949) OR (e.cdcooper = 1	AND e.nrdconta = 8306281	AND e.nrctremp = 8306281) OR
(e.cdcooper = 1	AND e.nrdconta = 8307458	AND e.nrctremp = 457724) OR (e.cdcooper = 1	AND e.nrdconta = 8307652	AND e.nrctremp = 387966) OR
(e.cdcooper = 1	AND e.nrdconta = 8308292	AND e.nrctremp = 1088935) OR (e.cdcooper = 1	AND e.nrdconta = 8308691	AND e.nrctremp = 424077) OR
(e.cdcooper = 1	AND e.nrdconta = 8308829	AND e.nrctremp = 947143) OR (e.cdcooper = 1	AND e.nrdconta = 8309353	AND e.nrctremp = 720550) OR
(e.cdcooper = 1	AND e.nrdconta = 8309930	AND e.nrctremp = 1060440) OR (e.cdcooper = 1	AND e.nrdconta = 8310440	AND e.nrctremp = 1000965) OR
(e.cdcooper = 1	AND e.nrdconta = 8310823	AND e.nrctremp = 522785) OR (e.cdcooper = 1	AND e.nrdconta = 8310823	AND e.nrctremp = 526238) OR
(e.cdcooper = 1	AND e.nrdconta = 8311137	AND e.nrctremp = 2012754) OR (e.cdcooper = 1	AND e.nrdconta = 8311790	AND e.nrctremp = 668283) OR
(e.cdcooper = 1	AND e.nrdconta = 8312931	AND e.nrctremp = 739637) OR (e.cdcooper = 1	AND e.nrdconta = 8312974	AND e.nrctremp = 781304) OR
(e.cdcooper = 1	AND e.nrdconta = 8313687	AND e.nrctremp = 993643) OR (e.cdcooper = 1	AND e.nrdconta = 8313822	AND e.nrctremp = 8313822) OR
(e.cdcooper = 1	AND e.nrdconta = 8314225	AND e.nrctremp = 1609116) OR (e.cdcooper = 1	AND e.nrdconta = 8314977	AND e.nrctremp = 8232903) OR
(e.cdcooper = 1	AND e.nrdconta = 8315442	AND e.nrctremp = 8315442) OR (e.cdcooper = 1	AND e.nrdconta = 8315671	AND e.nrctremp = 804680) OR
(e.cdcooper = 1	AND e.nrdconta = 8315914	AND e.nrctremp = 625113) OR (e.cdcooper = 1	AND e.nrdconta = 8315914	AND e.nrctremp = 907397) OR
(e.cdcooper = 1	AND e.nrdconta = 8316694	AND e.nrctremp = 572025) OR (e.cdcooper = 1	AND e.nrdconta = 8316759	AND e.nrctremp = 8316759) OR
(e.cdcooper = 1	AND e.nrdconta = 8317364	AND e.nrctremp = 8317364) OR (e.cdcooper = 1	AND e.nrdconta = 8318085	AND e.nrctremp = 8318085) OR
(e.cdcooper = 1	AND e.nrdconta = 8319405	AND e.nrctremp = 1596336) OR (e.cdcooper = 1	AND e.nrdconta = 8319707	AND e.nrctremp = 1118486) OR
(e.cdcooper = 1	AND e.nrdconta = 8320284	AND e.nrctremp = 8320284) OR (e.cdcooper = 1	AND e.nrdconta = 8320594	AND e.nrctremp = 8320594) OR
(e.cdcooper = 1	AND e.nrdconta = 8321345	AND e.nrctremp = 8321345) OR (e.cdcooper = 1	AND e.nrdconta = 8322406	AND e.nrctremp = 1105505) OR
(e.cdcooper = 1	AND e.nrdconta = 8322449	AND e.nrctremp = 769104) OR (e.cdcooper = 1	AND e.nrdconta = 8323585	AND e.nrctremp = 843659) OR
(e.cdcooper = 1	AND e.nrdconta = 8323682	AND e.nrctremp = 8323682) OR (e.cdcooper = 1	AND e.nrdconta = 8326126	AND e.nrctremp = 714047) OR
(e.cdcooper = 1	AND e.nrdconta = 8326282	AND e.nrctremp = 797296) OR (e.cdcooper = 1	AND e.nrdconta = 8327181	AND e.nrctremp = 24408) OR
(e.cdcooper = 1	AND e.nrdconta = 8327190	AND e.nrctremp = 806492) OR (e.cdcooper = 1	AND e.nrdconta = 8327815	AND e.nrctremp = 185244) OR
(e.cdcooper = 1	AND e.nrdconta = 8328307	AND e.nrctremp = 8328307) OR (e.cdcooper = 1	AND e.nrdconta = 8328420	AND e.nrctremp = 791528) OR
(e.cdcooper = 1	AND e.nrdconta = 8329745	AND e.nrctremp = 943833) OR (e.cdcooper = 1	AND e.nrdconta = 8330654	AND e.nrctremp = 734418) OR
(e.cdcooper = 1	AND e.nrdconta = 8331464	AND e.nrctremp = 8331464) OR (e.cdcooper = 1	AND e.nrdconta = 8332185	AND e.nrctremp = 8332185) OR
(e.cdcooper = 1	AND e.nrdconta = 8333149	AND e.nrctremp = 829977) OR (e.cdcooper = 1	AND e.nrdconta = 8333718	AND e.nrctremp = 778857) OR
(e.cdcooper = 1	AND e.nrdconta = 8334277	AND e.nrctremp = 792032) OR (e.cdcooper = 1	AND e.nrdconta = 8334536	AND e.nrctremp = 736965) OR
(e.cdcooper = 1	AND e.nrdconta = 8335419	AND e.nrctremp = 875540) OR (e.cdcooper = 1	AND e.nrdconta = 8335427	AND e.nrctremp = 1019355) OR
(e.cdcooper = 1	AND e.nrdconta = 8335567	AND e.nrctremp = 8335567) OR (e.cdcooper = 1	AND e.nrdconta = 8336113	AND e.nrctremp = 492989) OR
(e.cdcooper = 1	AND e.nrdconta = 8336431	AND e.nrctremp = 1085584) OR (e.cdcooper = 1	AND e.nrdconta = 8337233	AND e.nrctremp = 818077) OR
(e.cdcooper = 1	AND e.nrdconta = 8338116	AND e.nrctremp = 8338116) OR (e.cdcooper = 1	AND e.nrdconta = 8338442	AND e.nrctremp = 1182148) OR
(e.cdcooper = 1	AND e.nrdconta = 8339660	AND e.nrctremp = 973609) OR (e.cdcooper = 1	AND e.nrdconta = 8339732	AND e.nrctremp = 856931) OR
(e.cdcooper = 1	AND e.nrdconta = 8340005	AND e.nrctremp = 1258068) OR (e.cdcooper = 1	AND e.nrdconta = 8340145	AND e.nrctremp = 8340145) OR
(e.cdcooper = 1	AND e.nrdconta = 8341168	AND e.nrctremp = 787731) OR (e.cdcooper = 1	AND e.nrdconta = 8341826	AND e.nrctremp = 8341826) OR
(e.cdcooper = 1	AND e.nrdconta = 8341907	AND e.nrctremp = 21652) OR (e.cdcooper = 1	AND e.nrdconta = 8342245	AND e.nrctremp = 1775089) OR
(e.cdcooper = 1	AND e.nrdconta = 8343144	AND e.nrctremp = 1837450) OR (e.cdcooper = 1	AND e.nrdconta = 8344710	AND e.nrctremp = 738520) OR
(e.cdcooper = 1	AND e.nrdconta = 8344728	AND e.nrctremp = 1596464) OR (e.cdcooper = 1	AND e.nrdconta = 8345155	AND e.nrctremp = 644719) OR
(e.cdcooper = 1	AND e.nrdconta = 8347352	AND e.nrctremp = 8347352) OR (e.cdcooper = 1	AND e.nrdconta = 8348251	AND e.nrctremp = 1115392) OR
(e.cdcooper = 1	AND e.nrdconta = 8348316	AND e.nrctremp = 8348316) OR (e.cdcooper = 1	AND e.nrdconta = 8349223	AND e.nrctremp = 8349223) OR
(e.cdcooper = 1	AND e.nrdconta = 8349339	AND e.nrctremp = 1215700) OR (e.cdcooper = 1	AND e.nrdconta = 8349428	AND e.nrctremp = 890182) OR
(e.cdcooper = 1	AND e.nrdconta = 8350302	AND e.nrctremp = 909932) OR (e.cdcooper = 1	AND e.nrdconta = 8350949	AND e.nrctremp = 1853273) OR
(e.cdcooper = 1	AND e.nrdconta = 8351031	AND e.nrctremp = 661690) OR (e.cdcooper = 1	AND e.nrdconta = 8351520	AND e.nrctremp = 1079789) OR
(e.cdcooper = 1	AND e.nrdconta = 8352496	AND e.nrctremp = 930129) OR (e.cdcooper = 1	AND e.nrdconta = 8352496	AND e.nrctremp = 1444219) OR
(e.cdcooper = 1	AND e.nrdconta = 8354898	AND e.nrctremp = 1654700) OR (e.cdcooper = 1	AND e.nrdconta = 8355223	AND e.nrctremp = 863403) OR
(e.cdcooper = 1	AND e.nrdconta = 8355541	AND e.nrctremp = 782689) OR (e.cdcooper = 1	AND e.nrdconta = 8355975	AND e.nrctremp = 825873) OR
(e.cdcooper = 1	AND e.nrdconta = 8356530	AND e.nrctremp = 8356530) OR (e.cdcooper = 1	AND e.nrdconta = 8357080	AND e.nrctremp = 710182) OR
(e.cdcooper = 1	AND e.nrdconta = 8357471	AND e.nrctremp = 1518982) OR (e.cdcooper = 1	AND e.nrdconta = 8357552	AND e.nrctremp = 1323606) OR
(e.cdcooper = 1	AND e.nrdconta = 8358478	AND e.nrctremp = 1410252) OR (e.cdcooper = 1	AND e.nrdconta = 8361762	AND e.nrctremp = 8361762) OR
(e.cdcooper = 1	AND e.nrdconta = 8363692	AND e.nrctremp = 8363692) OR (e.cdcooper = 1	AND e.nrdconta = 8363781	AND e.nrctremp = 1147661) OR
(e.cdcooper = 1	AND e.nrdconta = 8366349	AND e.nrctremp = 854230) OR (e.cdcooper = 1	AND e.nrdconta = 8366705	AND e.nrctremp = 752228) OR
(e.cdcooper = 1	AND e.nrdconta = 8366993	AND e.nrctremp = 796548) OR (e.cdcooper = 1	AND e.nrdconta = 8367299	AND e.nrctremp = 581140) OR
(e.cdcooper = 1	AND e.nrdconta = 8367620	AND e.nrctremp = 8367620) OR (e.cdcooper = 1	AND e.nrdconta = 8368945	AND e.nrctremp = 153170) OR
(e.cdcooper = 1	AND e.nrdconta = 8369046	AND e.nrctremp = 109488) OR (e.cdcooper = 1	AND e.nrdconta = 8369291	AND e.nrctremp = 8369291) OR
(e.cdcooper = 1	AND e.nrdconta = 8369402	AND e.nrctremp = 425384) OR (e.cdcooper = 1	AND e.nrdconta = 8370028	AND e.nrctremp = 907486) OR
(e.cdcooper = 1	AND e.nrdconta = 8370885	AND e.nrctremp = 8370885) OR (e.cdcooper = 1	AND e.nrdconta = 8371121	AND e.nrctremp = 678210) OR
(e.cdcooper = 1	AND e.nrdconta = 8371938	AND e.nrctremp = 943708) OR (e.cdcooper = 1	AND e.nrdconta = 8373027	AND e.nrctremp = 1247398) OR
(e.cdcooper = 1	AND e.nrdconta = 8373965	AND e.nrctremp = 644443) OR (e.cdcooper = 1	AND e.nrdconta = 8375526	AND e.nrctremp = 606338) OR
(e.cdcooper = 1	AND e.nrdconta = 8376891	AND e.nrctremp = 8376891) OR (e.cdcooper = 1	AND e.nrdconta = 8377618	AND e.nrctremp = 944025) OR
(e.cdcooper = 1	AND e.nrdconta = 8377758	AND e.nrctremp = 1629969) OR (e.cdcooper = 1	AND e.nrdconta = 8379661	AND e.nrctremp = 812439) OR
(e.cdcooper = 1	AND e.nrdconta = 8380023	AND e.nrctremp = 581733) OR (e.cdcooper = 1	AND e.nrdconta = 8380937	AND e.nrctremp = 8380937) OR
(e.cdcooper = 1	AND e.nrdconta = 8381062	AND e.nrctremp = 768219) OR (e.cdcooper = 1	AND e.nrdconta = 8381240	AND e.nrctremp = 911795) OR
(e.cdcooper = 1	AND e.nrdconta = 8382069	AND e.nrctremp = 1341341) OR (e.cdcooper = 1	AND e.nrdconta = 8386072	AND e.nrctremp = 1979049) OR
(e.cdcooper = 1	AND e.nrdconta = 8387150	AND e.nrctremp = 734872) OR (e.cdcooper = 1	AND e.nrdconta = 8387524	AND e.nrctremp = 469620) OR
(e.cdcooper = 1	AND e.nrdconta = 8388148	AND e.nrctremp = 99802) OR (e.cdcooper = 1	AND e.nrdconta = 8388873	AND e.nrctremp = 8388873) OR
(e.cdcooper = 1	AND e.nrdconta = 8389160	AND e.nrctremp = 1334527) OR (e.cdcooper = 1	AND e.nrdconta = 8389179	AND e.nrctremp = 8389179) OR
(e.cdcooper = 1	AND e.nrdconta = 8390169	AND e.nrctremp = 8390169) OR (e.cdcooper = 1	AND e.nrdconta = 8390177	AND e.nrctremp = 8390177) OR
(e.cdcooper = 1	AND e.nrdconta = 8390185	AND e.nrctremp = 1326391) OR (e.cdcooper = 1	AND e.nrdconta = 8390240	AND e.nrctremp = 858904) OR
(e.cdcooper = 1	AND e.nrdconta = 8391270	AND e.nrctremp = 8391270) OR (e.cdcooper = 1	AND e.nrdconta = 8391645	AND e.nrctremp = 942957) OR
(e.cdcooper = 1	AND e.nrdconta = 8392676	AND e.nrctremp = 1024564) OR (e.cdcooper = 1	AND e.nrdconta = 8392900	AND e.nrctremp = 750974) OR
(e.cdcooper = 1	AND e.nrdconta = 8392978	AND e.nrctremp = 709883) OR (e.cdcooper = 1	AND e.nrdconta = 8393036	AND e.nrctremp = 1004402) OR
(e.cdcooper = 1	AND e.nrdconta = 8393176	AND e.nrctremp = 1803342) OR (e.cdcooper = 1	AND e.nrdconta = 8393281	AND e.nrctremp = 904198) OR
(e.cdcooper = 1	AND e.nrdconta = 8393710	AND e.nrctremp = 1222300) OR (e.cdcooper = 1	AND e.nrdconta = 8393850	AND e.nrctremp = 974606) OR
(e.cdcooper = 1	AND e.nrdconta = 8394016	AND e.nrctremp = 8394016) OR (e.cdcooper = 1	AND e.nrdconta = 8394458	AND e.nrctremp = 462079) OR
(e.cdcooper = 1	AND e.nrdconta = 8394458	AND e.nrctremp = 8394458) OR (e.cdcooper = 1	AND e.nrdconta = 8394857	AND e.nrctremp = 1406955) OR
(e.cdcooper = 1	AND e.nrdconta = 8396051	AND e.nrctremp = 8396051) OR (e.cdcooper = 1	AND e.nrdconta = 8396825	AND e.nrctremp = 8396825) OR
(e.cdcooper = 1	AND e.nrdconta = 8397376	AND e.nrctremp = 843964) OR (e.cdcooper = 1	AND e.nrdconta = 8397422	AND e.nrctremp = 682551) OR
(e.cdcooper = 1	AND e.nrdconta = 8398267	AND e.nrctremp = 924156) OR (e.cdcooper = 1	AND e.nrdconta = 8398410	AND e.nrctremp = 1056113) OR
(e.cdcooper = 1	AND e.nrdconta = 8399077	AND e.nrctremp = 8399077) OR (e.cdcooper = 1	AND e.nrdconta = 8400008	AND e.nrctremp = 1105638) OR
(e.cdcooper = 1	AND e.nrdconta = 8400601	AND e.nrctremp = 1289563) OR (e.cdcooper = 1	AND e.nrdconta = 8404615	AND e.nrctremp = 8404615) OR
(e.cdcooper = 1	AND e.nrdconta = 8404755	AND e.nrctremp = 8404755) OR (e.cdcooper = 1	AND e.nrdconta = 8405131	AND e.nrctremp = 8405131) OR
(e.cdcooper = 1	AND e.nrdconta = 8405190	AND e.nrctremp = 8405190) OR (e.cdcooper = 1	AND e.nrdconta = 8405239	AND e.nrctremp = 1203671) OR
(e.cdcooper = 1	AND e.nrdconta = 8406367	AND e.nrctremp = 1301489) OR (e.cdcooper = 1	AND e.nrdconta = 8406987	AND e.nrctremp = 769667) OR
(e.cdcooper = 1	AND e.nrdconta = 8407061	AND e.nrctremp = 8407061) OR (e.cdcooper = 1	AND e.nrdconta = 8407258	AND e.nrctremp = 844058) OR
(e.cdcooper = 1	AND e.nrdconta = 8408505	AND e.nrctremp = 8408505) OR (e.cdcooper = 1	AND e.nrdconta = 8408530	AND e.nrctremp = 562384) OR
(e.cdcooper = 1	AND e.nrdconta = 8409439	AND e.nrctremp = 1457521) OR (e.cdcooper = 1	AND e.nrdconta = 8409811	AND e.nrctremp = 815906) OR
(e.cdcooper = 1	AND e.nrdconta = 8410690	AND e.nrctremp = 8410690) OR (e.cdcooper = 1	AND e.nrdconta = 8411280	AND e.nrctremp = 834476) OR
(e.cdcooper = 1	AND e.nrdconta = 8412545	AND e.nrctremp = 8412545) OR (e.cdcooper = 1	AND e.nrdconta = 8413045	AND e.nrctremp = 1064274) OR
(e.cdcooper = 1	AND e.nrdconta = 8413819	AND e.nrctremp = 8413819) OR (e.cdcooper = 1	AND e.nrdconta = 8414157	AND e.nrctremp = 1069665) OR
(e.cdcooper = 1	AND e.nrdconta = 8414785	AND e.nrctremp = 734782) OR (e.cdcooper = 1	AND e.nrdconta = 8415536	AND e.nrctremp = 455796) OR
(e.cdcooper = 1	AND e.nrdconta = 8416095	AND e.nrctremp = 916580) OR (e.cdcooper = 1	AND e.nrdconta = 8416583	AND e.nrctremp = 8416583) OR
(e.cdcooper = 1	AND e.nrdconta = 8416745	AND e.nrctremp = 566969) OR (e.cdcooper = 1	AND e.nrdconta = 8417067	AND e.nrctremp = 1319082) OR
(e.cdcooper = 1	AND e.nrdconta = 8421960	AND e.nrctremp = 1315690) OR (e.cdcooper = 1	AND e.nrdconta = 8422559	AND e.nrctremp = 711255) OR
(e.cdcooper = 1	AND e.nrdconta = 8422575	AND e.nrctremp = 215129) OR (e.cdcooper = 1	AND e.nrdconta = 8422680	AND e.nrctremp = 599525) OR
(e.cdcooper = 1	AND e.nrdconta = 8422940	AND e.nrctremp = 792282) OR (e.cdcooper = 1	AND e.nrdconta = 8423245	AND e.nrctremp = 693211) OR
(e.cdcooper = 1	AND e.nrdconta = 8423636	AND e.nrctremp = 704913) OR (e.cdcooper = 1	AND e.nrdconta = 8424365	AND e.nrctremp = 1391972) OR
(e.cdcooper = 1	AND e.nrdconta = 8425620	AND e.nrctremp = 8425620) OR (e.cdcooper = 1	AND e.nrdconta = 8426163	AND e.nrctremp = 600604) OR
(e.cdcooper = 1	AND e.nrdconta = 8426473	AND e.nrctremp = 602820) OR (e.cdcooper = 1	AND e.nrdconta = 8427712	AND e.nrctremp = 1252507) OR
(e.cdcooper = 1	AND e.nrdconta = 8427941	AND e.nrctremp = 1400640) OR (e.cdcooper = 1	AND e.nrdconta = 8428590	AND e.nrctremp = 8428590) OR
(e.cdcooper = 1	AND e.nrdconta = 8429316	AND e.nrctremp = 621652) OR (e.cdcooper = 1	AND e.nrdconta = 8429600	AND e.nrctremp = 14237) OR
(e.cdcooper = 1	AND e.nrdconta = 8429995	AND e.nrctremp = 898400) OR (e.cdcooper = 1	AND e.nrdconta = 8430187	AND e.nrctremp = 1037358) OR
(e.cdcooper = 1	AND e.nrdconta = 8430381	AND e.nrctremp = 1647118) OR (e.cdcooper = 1	AND e.nrdconta = 8431370	AND e.nrctremp = 8431370) OR
(e.cdcooper = 1	AND e.nrdconta = 8432805	AND e.nrctremp = 1586871) OR (e.cdcooper = 1	AND e.nrdconta = 8432821	AND e.nrctremp = 8432821) OR
(e.cdcooper = 1	AND e.nrdconta = 8435405	AND e.nrctremp = 8435405) OR (e.cdcooper = 1	AND e.nrdconta = 8437157	AND e.nrctremp = 8437157) OR
(e.cdcooper = 1	AND e.nrdconta = 8437777	AND e.nrctremp = 746199) OR (e.cdcooper = 1	AND e.nrdconta = 8438005	AND e.nrctremp = 667253) OR
(e.cdcooper = 1	AND e.nrdconta = 8438315	AND e.nrctremp = 898874) OR (e.cdcooper = 1	AND e.nrdconta = 8439567	AND e.nrctremp = 804128) OR
(e.cdcooper = 1	AND e.nrdconta = 8440476	AND e.nrctremp = 8440476) OR (e.cdcooper = 1	AND e.nrdconta = 8441260	AND e.nrctremp = 1587058) OR
(e.cdcooper = 1	AND e.nrdconta = 8441561	AND e.nrctremp = 828763) OR (e.cdcooper = 1	AND e.nrdconta = 8443459	AND e.nrctremp = 1718856) OR
(e.cdcooper = 1	AND e.nrdconta = 8443980	AND e.nrctremp = 8443980) OR (e.cdcooper = 1	AND e.nrdconta = 8444781	AND e.nrctremp = 1568639) OR
(e.cdcooper = 1	AND e.nrdconta = 8445176	AND e.nrctremp = 8445176) OR (e.cdcooper = 1	AND e.nrdconta = 8445303	AND e.nrctremp = 8445303) OR
(e.cdcooper = 1	AND e.nrdconta = 8445516	AND e.nrctremp = 771552) OR (e.cdcooper = 1	AND e.nrdconta = 8445893	AND e.nrctremp = 8445893) OR
(e.cdcooper = 1	AND e.nrdconta = 8446695	AND e.nrctremp = 8446695) OR (e.cdcooper = 1	AND e.nrdconta = 8446911	AND e.nrctremp = 8446911) OR
(e.cdcooper = 1	AND e.nrdconta = 8447195	AND e.nrctremp = 788568) OR (e.cdcooper = 1	AND e.nrdconta = 8447454	AND e.nrctremp = 1490178) OR
(e.cdcooper = 1	AND e.nrdconta = 8447632	AND e.nrctremp = 8447632) OR (e.cdcooper = 1	AND e.nrdconta = 8448701	AND e.nrctremp = 8448701) OR
(e.cdcooper = 1	AND e.nrdconta = 8448760	AND e.nrctremp = 8448760) OR (e.cdcooper = 1	AND e.nrdconta = 8450250	AND e.nrctremp = 1113811) OR
(e.cdcooper = 1	AND e.nrdconta = 8450501	AND e.nrctremp = 769756) OR (e.cdcooper = 1	AND e.nrdconta = 8450862	AND e.nrctremp = 8450862) OR
(e.cdcooper = 1	AND e.nrdconta = 8450897	AND e.nrctremp = 829840) OR (e.cdcooper = 1	AND e.nrdconta = 8451214	AND e.nrctremp = 1275711) OR
(e.cdcooper = 1	AND e.nrdconta = 8451362	AND e.nrctremp = 522380) OR (e.cdcooper = 1	AND e.nrdconta = 8451478	AND e.nrctremp = 8451478) OR
(e.cdcooper = 1	AND e.nrdconta = 8451893	AND e.nrctremp = 8451893) OR (e.cdcooper = 1	AND e.nrdconta = 8452121	AND e.nrctremp = 8452121) OR
(e.cdcooper = 1	AND e.nrdconta = 8452466	AND e.nrctremp = 1175888) OR (e.cdcooper = 1	AND e.nrdconta = 8453381	AND e.nrctremp = 1593435) OR
(e.cdcooper = 1	AND e.nrdconta = 8454051	AND e.nrctremp = 8454051) OR (e.cdcooper = 1	AND e.nrdconta = 8454698	AND e.nrctremp = 855551) OR
(e.cdcooper = 1	AND e.nrdconta = 8455562	AND e.nrctremp = 951398) OR (e.cdcooper = 1	AND e.nrdconta = 8455945	AND e.nrctremp = 687603) OR
(e.cdcooper = 1	AND e.nrdconta = 8456810	AND e.nrctremp = 500998) OR (e.cdcooper = 1	AND e.nrdconta = 8457972	AND e.nrctremp = 715928) OR
(e.cdcooper = 1	AND e.nrdconta = 8458529	AND e.nrctremp = 8458529) OR (e.cdcooper = 1	AND e.nrdconta = 8458715	AND e.nrctremp = 1637866) OR
(e.cdcooper = 1	AND e.nrdconta = 8458995	AND e.nrctremp = 907264) OR (e.cdcooper = 1	AND e.nrdconta = 8460795	AND e.nrctremp = 797648) OR
(e.cdcooper = 1	AND e.nrdconta = 8461465	AND e.nrctremp = 1042805) OR (e.cdcooper = 1	AND e.nrdconta = 8461465	AND e.nrctremp = 1135985) OR
(e.cdcooper = 1	AND e.nrdconta = 8461554	AND e.nrctremp = 1157727) OR (e.cdcooper = 1	AND e.nrdconta = 8462178	AND e.nrctremp = 618645) OR
(e.cdcooper = 1	AND e.nrdconta = 8463034	AND e.nrctremp = 966602) OR (e.cdcooper = 1	AND e.nrdconta = 8463735	AND e.nrctremp = 1263145) OR
(e.cdcooper = 1	AND e.nrdconta = 8463964	AND e.nrctremp = 634030) OR (e.cdcooper = 1	AND e.nrdconta = 8464200	AND e.nrctremp = 595662) OR
(e.cdcooper = 1	AND e.nrdconta = 8464456	AND e.nrctremp = 478334) OR (e.cdcooper = 1	AND e.nrdconta = 8466629	AND e.nrctremp = 934360) OR
(e.cdcooper = 1	AND e.nrdconta = 8466947	AND e.nrctremp = 1294018) OR (e.cdcooper = 1	AND e.nrdconta = 8467064	AND e.nrctremp = 617541) OR
(e.cdcooper = 1	AND e.nrdconta = 8467161	AND e.nrctremp = 939476) OR (e.cdcooper = 1	AND e.nrdconta = 8468850	AND e.nrctremp = 548440) OR
(e.cdcooper = 1	AND e.nrdconta = 8468907	AND e.nrctremp = 1077080) OR (e.cdcooper = 1	AND e.nrdconta = 8468931	AND e.nrctremp = 622182) OR
(e.cdcooper = 1	AND e.nrdconta = 8468958	AND e.nrctremp = 8468958) OR (e.cdcooper = 1	AND e.nrdconta = 8469490	AND e.nrctremp = 924032) OR
(e.cdcooper = 1	AND e.nrdconta = 8469555	AND e.nrctremp = 8469555) OR (e.cdcooper = 1	AND e.nrdconta = 8469636	AND e.nrctremp = 746047) OR
(e.cdcooper = 1	AND e.nrdconta = 8470197	AND e.nrctremp = 632806) OR (e.cdcooper = 1	AND e.nrdconta = 8470383	AND e.nrctremp = 8470383) OR
(e.cdcooper = 1	AND e.nrdconta = 8470774	AND e.nrctremp = 1355204) OR (e.cdcooper = 1	AND e.nrdconta = 8471673	AND e.nrctremp = 1032954) OR
(e.cdcooper = 1	AND e.nrdconta = 8471789	AND e.nrctremp = 1031987) OR (e.cdcooper = 1	AND e.nrdconta = 8472009	AND e.nrctremp = 181509) OR
(e.cdcooper = 1	AND e.nrdconta = 8472823	AND e.nrctremp = 643155) OR (e.cdcooper = 1	AND e.nrdconta = 8474389	AND e.nrctremp = 561392) OR
(e.cdcooper = 1	AND e.nrdconta = 8474540	AND e.nrctremp = 1258825) OR (e.cdcooper = 1	AND e.nrdconta = 8475210	AND e.nrctremp = 834771) OR
(e.cdcooper = 1	AND e.nrdconta = 8476160	AND e.nrctremp = 8476160) OR (e.cdcooper = 1	AND e.nrdconta = 8477850	AND e.nrctremp = 637041) OR
(e.cdcooper = 1	AND e.nrdconta = 8480044	AND e.nrctremp = 8480044) OR (e.cdcooper = 1	AND e.nrdconta = 8480656	AND e.nrctremp = 470224) OR
(e.cdcooper = 1	AND e.nrdconta = 8480990	AND e.nrctremp = 8480990) OR (e.cdcooper = 1	AND e.nrdconta = 8483370	AND e.nrctremp = 1375037) OR
(e.cdcooper = 1	AND e.nrdconta = 8484155	AND e.nrctremp = 1101508) OR (e.cdcooper = 1	AND e.nrdconta = 8486352	AND e.nrctremp = 8486352) OR
(e.cdcooper = 1	AND e.nrdconta = 8488347	AND e.nrctremp = 8488347) OR (e.cdcooper = 1	AND e.nrdconta = 8488436	AND e.nrctremp = 635634) OR
(e.cdcooper = 1	AND e.nrdconta = 8488550	AND e.nrctremp = 1131438) OR (e.cdcooper = 1	AND e.nrdconta = 8488827	AND e.nrctremp = 8488827) OR
(e.cdcooper = 1	AND e.nrdconta = 8490090	AND e.nrctremp = 1353592) OR (e.cdcooper = 1	AND e.nrdconta = 8490546	AND e.nrctremp = 1794647) OR
(e.cdcooper = 1	AND e.nrdconta = 8490937	AND e.nrctremp = 970728) OR (e.cdcooper = 1	AND e.nrdconta = 8491550	AND e.nrctremp = 772526) OR
(e.cdcooper = 1	AND e.nrdconta = 8491780	AND e.nrctremp = 1120178) OR (e.cdcooper = 1	AND e.nrdconta = 8492620	AND e.nrctremp = 1576205) OR
(e.cdcooper = 1	AND e.nrdconta = 8493189	AND e.nrctremp = 1599776) OR (e.cdcooper = 1	AND e.nrdconta = 8494592	AND e.nrctremp = 8494592) OR
(e.cdcooper = 1	AND e.nrdconta = 8498776	AND e.nrctremp = 717157) OR (e.cdcooper = 1	AND e.nrdconta = 8498881	AND e.nrctremp = 8498881) OR
(e.cdcooper = 1	AND e.nrdconta = 8500037	AND e.nrctremp = 1051364) OR (e.cdcooper = 1	AND e.nrdconta = 8500290	AND e.nrctremp = 865919) OR
(e.cdcooper = 1	AND e.nrdconta = 8500568	AND e.nrctremp = 795639) OR (e.cdcooper = 1	AND e.nrdconta = 8500673	AND e.nrctremp = 761937) OR
(e.cdcooper = 1	AND e.nrdconta = 8500916	AND e.nrctremp = 455501) OR (e.cdcooper = 1	AND e.nrdconta = 8501734	AND e.nrctremp = 8501734) OR
(e.cdcooper = 1	AND e.nrdconta = 8501823	AND e.nrctremp = 956492) OR (e.cdcooper = 1	AND e.nrdconta = 8502692	AND e.nrctremp = 777818) OR
(e.cdcooper = 1	AND e.nrdconta = 8503451	AND e.nrctremp = 743989) OR (e.cdcooper = 1	AND e.nrdconta = 8503516	AND e.nrctremp = 827622) OR
(e.cdcooper = 1	AND e.nrdconta = 8503893	AND e.nrctremp = 591310) OR (e.cdcooper = 1	AND e.nrdconta = 8503893	AND e.nrctremp = 931280) OR
(e.cdcooper = 1	AND e.nrdconta = 8504261	AND e.nrctremp = 8504261) OR (e.cdcooper = 1	AND e.nrdconta = 8504717	AND e.nrctremp = 1107362) OR
(e.cdcooper = 1	AND e.nrdconta = 8506221	AND e.nrctremp = 8506221) OR (e.cdcooper = 1	AND e.nrdconta = 8507643	AND e.nrctremp = 993845) OR
(e.cdcooper = 1	AND e.nrdconta = 8507708	AND e.nrctremp = 819287) OR (e.cdcooper = 1	AND e.nrdconta = 8507929	AND e.nrctremp = 771993) OR
(e.cdcooper = 1	AND e.nrdconta = 8508194	AND e.nrctremp = 1238229) OR (e.cdcooper = 1	AND e.nrdconta = 8508321	AND e.nrctremp = 639212) OR
(e.cdcooper = 1	AND e.nrdconta = 8508950	AND e.nrctremp = 1003144) OR (e.cdcooper = 1	AND e.nrdconta = 8509948	AND e.nrctremp = 8509948) OR
(e.cdcooper = 1	AND e.nrdconta = 8510610	AND e.nrctremp = 1178056) OR (e.cdcooper = 1	AND e.nrdconta = 8510911	AND e.nrctremp = 8510911) OR
(e.cdcooper = 1	AND e.nrdconta = 8511063	AND e.nrctremp = 829615) OR (e.cdcooper = 1	AND e.nrdconta = 8511179	AND e.nrctremp = 670697) OR
(e.cdcooper = 1	AND e.nrdconta = 8511276	AND e.nrctremp = 924082) OR (e.cdcooper = 1	AND e.nrdconta = 8511837	AND e.nrctremp = 1342991) OR
(e.cdcooper = 1	AND e.nrdconta = 8511896	AND e.nrctremp = 718634) OR (e.cdcooper = 1	AND e.nrdconta = 8512655	AND e.nrctremp = 702787) OR
(e.cdcooper = 1	AND e.nrdconta = 8514097	AND e.nrctremp = 793466) OR (e.cdcooper = 1	AND e.nrdconta = 8514119	AND e.nrctremp = 1114904) OR
(e.cdcooper = 1	AND e.nrdconta = 8515158	AND e.nrctremp = 8515158) OR (e.cdcooper = 1	AND e.nrdconta = 8515344	AND e.nrctremp = 878614) OR
(e.cdcooper = 1	AND e.nrdconta = 8515751	AND e.nrctremp = 8515751) OR (e.cdcooper = 1	AND e.nrdconta = 8516111	AND e.nrctremp = 817942) OR
(e.cdcooper = 1	AND e.nrdconta = 8516294	AND e.nrctremp = 874275) OR (e.cdcooper = 1	AND e.nrdconta = 8516723	AND e.nrctremp = 1061335) OR
(e.cdcooper = 1	AND e.nrdconta = 8516740	AND e.nrctremp = 742982) OR (e.cdcooper = 1	AND e.nrdconta = 8517207	AND e.nrctremp = 727245) OR
(e.cdcooper = 1	AND e.nrdconta = 8517606	AND e.nrctremp = 988253) OR (e.cdcooper = 1	AND e.nrdconta = 8517967	AND e.nrctremp = 641069) OR
(e.cdcooper = 1	AND e.nrdconta = 8517967	AND e.nrctremp = 1727664) OR (e.cdcooper = 1	AND e.nrdconta = 8519323	AND e.nrctremp = 8519323) OR
(e.cdcooper = 1	AND e.nrdconta = 8519544	AND e.nrctremp = 8519544) OR (e.cdcooper = 1	AND e.nrdconta = 8519986	AND e.nrctremp = 8519986) OR
(e.cdcooper = 1	AND e.nrdconta = 8521263	AND e.nrctremp = 8521263) OR (e.cdcooper = 1	AND e.nrdconta = 8522537	AND e.nrctremp = 546326) OR
(e.cdcooper = 1	AND e.nrdconta = 8522839	AND e.nrctremp = 985484) OR (e.cdcooper = 1	AND e.nrdconta = 8523088	AND e.nrctremp = 8523088) OR
(e.cdcooper = 1	AND e.nrdconta = 8524386	AND e.nrctremp = 8524386) OR (e.cdcooper = 1	AND e.nrdconta = 8524467	AND e.nrctremp = 744883) OR
(e.cdcooper = 1	AND e.nrdconta = 8526974	AND e.nrctremp = 774195) OR (e.cdcooper = 1	AND e.nrdconta = 8526974	AND e.nrctremp = 898597) OR
(e.cdcooper = 1	AND e.nrdconta = 8527504	AND e.nrctremp = 929214) OR (e.cdcooper = 1	AND e.nrdconta = 8528713	AND e.nrctremp = 696509) OR
(e.cdcooper = 1	AND e.nrdconta = 8529027	AND e.nrctremp = 952672) OR (e.cdcooper = 1	AND e.nrdconta = 8530947	AND e.nrctremp = 617633) OR
(e.cdcooper = 1	AND e.nrdconta = 8531005	AND e.nrctremp = 8531005) OR (e.cdcooper = 1	AND e.nrdconta = 8531013	AND e.nrctremp = 8531013) OR
(e.cdcooper = 1	AND e.nrdconta = 8531552	AND e.nrctremp = 732372) OR (e.cdcooper = 1	AND e.nrdconta = 8531625	AND e.nrctremp = 536216) OR
(e.cdcooper = 1	AND e.nrdconta = 8531838	AND e.nrctremp = 8531858) OR (e.cdcooper = 1	AND e.nrdconta = 8531951	AND e.nrctremp = 1297980) OR
(e.cdcooper = 1	AND e.nrdconta = 8533636	AND e.nrctremp = 895363) OR (e.cdcooper = 1	AND e.nrdconta = 8534969	AND e.nrctremp = 1363474) OR
(e.cdcooper = 1	AND e.nrdconta = 8534985	AND e.nrctremp = 644204) OR (e.cdcooper = 1	AND e.nrdconta = 8535965	AND e.nrctremp = 809254) OR
(e.cdcooper = 1	AND e.nrdconta = 8537127	AND e.nrctremp = 8537127) OR (e.cdcooper = 1	AND e.nrdconta = 8537429	AND e.nrctremp = 1029694) OR
(e.cdcooper = 1	AND e.nrdconta = 8537933	AND e.nrctremp = 1223689) OR (e.cdcooper = 1	AND e.nrdconta = 8538409	AND e.nrctremp = 8538409) OR
(e.cdcooper = 1	AND e.nrdconta = 8538506	AND e.nrctremp = 1291224) OR (e.cdcooper = 1	AND e.nrdconta = 8538662	AND e.nrctremp = 766034) OR
(e.cdcooper = 1	AND e.nrdconta = 8539499	AND e.nrctremp = 924230) OR (e.cdcooper = 1	AND e.nrdconta = 8539626	AND e.nrctremp = 1551311) OR
(e.cdcooper = 1	AND e.nrdconta = 8539847	AND e.nrctremp = 8539847) OR (e.cdcooper = 1	AND e.nrdconta = 8540012	AND e.nrctremp = 79549) OR
(e.cdcooper = 1	AND e.nrdconta = 8540012	AND e.nrctremp = 892876) OR (e.cdcooper = 1	AND e.nrdconta = 8540659	AND e.nrctremp = 940875) OR
(e.cdcooper = 1	AND e.nrdconta = 8542511	AND e.nrctremp = 830878) OR (e.cdcooper = 1	AND e.nrdconta = 8543194	AND e.nrctremp = 895176) OR
(e.cdcooper = 1	AND e.nrdconta = 8543208	AND e.nrctremp = 837561) OR (e.cdcooper = 1	AND e.nrdconta = 8544344	AND e.nrctremp = 1488472) OR
(e.cdcooper = 1	AND e.nrdconta = 8544360	AND e.nrctremp = 646554) OR (e.cdcooper = 1	AND e.nrdconta = 8544980	AND e.nrctremp = 8544980) OR
(e.cdcooper = 1	AND e.nrdconta = 8545367	AND e.nrctremp = 480452) OR (e.cdcooper = 1	AND e.nrdconta = 8546533	AND e.nrctremp = 1237399) OR
(e.cdcooper = 1	AND e.nrdconta = 8549052	AND e.nrctremp = 1061897) OR (e.cdcooper = 1	AND e.nrdconta = 8551634	AND e.nrctremp = 8551634) OR
(e.cdcooper = 1	AND e.nrdconta = 8555060	AND e.nrctremp = 8555060) OR (e.cdcooper = 1	AND e.nrdconta = 8556660	AND e.nrctremp = 800130) OR
(e.cdcooper = 1	AND e.nrdconta = 8557454	AND e.nrctremp = 1408482) OR (e.cdcooper = 1	AND e.nrdconta = 8558523	AND e.nrctremp = 161968) OR
(e.cdcooper = 1	AND e.nrdconta = 8559058	AND e.nrctremp = 997605) OR (e.cdcooper = 1	AND e.nrdconta = 8560137	AND e.nrctremp = 8560137) OR
(e.cdcooper = 1	AND e.nrdconta = 8561508	AND e.nrctremp = 8561508) OR (e.cdcooper = 1	AND e.nrdconta = 8561710	AND e.nrctremp = 973620) OR
(e.cdcooper = 1	AND e.nrdconta = 8561753	AND e.nrctremp = 1104224) OR (e.cdcooper = 1	AND e.nrdconta = 8565740	AND e.nrctremp = 8565740) OR
(e.cdcooper = 1	AND e.nrdconta = 8565767	AND e.nrctremp = 1551767) OR (e.cdcooper = 1	AND e.nrdconta = 8565945	AND e.nrctremp = 520977) OR
(e.cdcooper = 1	AND e.nrdconta = 8566780	AND e.nrctremp = 955881) OR (e.cdcooper = 1	AND e.nrdconta = 8567158	AND e.nrctremp = 776358) OR
(e.cdcooper = 1	AND e.nrdconta = 8568626	AND e.nrctremp = 1040223) OR (e.cdcooper = 1	AND e.nrdconta = 8569061	AND e.nrctremp = 735985) OR
(e.cdcooper = 1	AND e.nrdconta = 8570213	AND e.nrctremp = 8570213) OR (e.cdcooper = 1	AND e.nrdconta = 8570442	AND e.nrctremp = 1587217) OR
(e.cdcooper = 1	AND e.nrdconta = 8571082	AND e.nrctremp = 8571082) OR (e.cdcooper = 1	AND e.nrdconta = 8572089	AND e.nrctremp = 932480) OR
(e.cdcooper = 1	AND e.nrdconta = 8572089	AND e.nrctremp = 947466) OR (e.cdcooper = 1	AND e.nrdconta = 8572755	AND e.nrctremp = 1148646) OR
(e.cdcooper = 1	AND e.nrdconta = 8572801	AND e.nrctremp = 1447637) OR (e.cdcooper = 1	AND e.nrdconta = 8573034	AND e.nrctremp = 546506) OR
(e.cdcooper = 1	AND e.nrdconta = 8574588	AND e.nrctremp = 833293) OR (e.cdcooper = 1	AND e.nrdconta = 8575029	AND e.nrctremp = 1213645) OR
(e.cdcooper = 1	AND e.nrdconta = 8575274	AND e.nrctremp = 8575274) OR (e.cdcooper = 1	AND e.nrdconta = 8575843	AND e.nrctremp = 999108) OR
(e.cdcooper = 1	AND e.nrdconta = 8576254	AND e.nrctremp = 839427) OR (e.cdcooper = 1	AND e.nrdconta = 8577129	AND e.nrctremp = 1173561) OR
(e.cdcooper = 1	AND e.nrdconta = 8577641	AND e.nrctremp = 653576) OR (e.cdcooper = 1	AND e.nrdconta = 8579270	AND e.nrctremp = 1267439) OR
(e.cdcooper = 1	AND e.nrdconta = 8579806	AND e.nrctremp = 8579806) OR (e.cdcooper = 1	AND e.nrdconta = 8581053	AND e.nrctremp = 189714) OR
(e.cdcooper = 1	AND e.nrdconta = 8581053	AND e.nrctremp = 189715) OR (e.cdcooper = 1	AND e.nrdconta = 8581096	AND e.nrctremp = 1007639) OR
(e.cdcooper = 1	AND e.nrdconta = 8581169	AND e.nrctremp = 1028756) OR (e.cdcooper = 1	AND e.nrdconta = 8581380	AND e.nrctremp = 886404) OR
(e.cdcooper = 1	AND e.nrdconta = 8583323	AND e.nrctremp = 1296413) OR (e.cdcooper = 1	AND e.nrdconta = 8583439	AND e.nrctremp = 8583439) OR
(e.cdcooper = 1	AND e.nrdconta = 8583617	AND e.nrctremp = 1775132) OR (e.cdcooper = 1	AND e.nrdconta = 8584079	AND e.nrctremp = 8584079) OR
(e.cdcooper = 1	AND e.nrdconta = 8584982	AND e.nrctremp = 926998) OR (e.cdcooper = 1	AND e.nrdconta = 8585032	AND e.nrctremp = 917302) OR
(e.cdcooper = 1	AND e.nrdconta = 8585300	AND e.nrctremp = 73160) OR (e.cdcooper = 1	AND e.nrdconta = 8585377	AND e.nrctremp = 474216) OR
(e.cdcooper = 1	AND e.nrdconta = 8585741	AND e.nrctremp = 1072481) OR (e.cdcooper = 1	AND e.nrdconta = 8587000	AND e.nrctremp = 1724183) OR
(e.cdcooper = 1	AND e.nrdconta = 8588422	AND e.nrctremp = 2104702) OR (e.cdcooper = 1	AND e.nrdconta = 8591601	AND e.nrctremp = 8591601) OR
(e.cdcooper = 1	AND e.nrdconta = 8593302	AND e.nrctremp = 1569275) OR (e.cdcooper = 1	AND e.nrdconta = 8593574	AND e.nrctremp = 24414) OR
(e.cdcooper = 1	AND e.nrdconta = 8593612	AND e.nrctremp = 999156) OR (e.cdcooper = 1	AND e.nrdconta = 8595020	AND e.nrctremp = 8595020) OR
(e.cdcooper = 1	AND e.nrdconta = 8596069	AND e.nrctremp = 1100420) OR (e.cdcooper = 1	AND e.nrdconta = 8596573	AND e.nrctremp = 1266867) OR
(e.cdcooper = 1	AND e.nrdconta = 8597014	AND e.nrctremp = 8597014) OR (e.cdcooper = 1	AND e.nrdconta = 8597103	AND e.nrctremp = 8597103) OR
(e.cdcooper = 1	AND e.nrdconta = 8597219	AND e.nrctremp = 1108906) OR (e.cdcooper = 1	AND e.nrdconta = 8598363	AND e.nrctremp = 179745) OR
(e.cdcooper = 1	AND e.nrdconta = 8600058	AND e.nrctremp = 114132) OR (e.cdcooper = 1	AND e.nrdconta = 8600643	AND e.nrctremp = 8600643) OR
(e.cdcooper = 1	AND e.nrdconta = 8601488	AND e.nrctremp = 974710) OR (e.cdcooper = 1	AND e.nrdconta = 8602891	AND e.nrctremp = 1665185) OR
(e.cdcooper = 1	AND e.nrdconta = 8602964	AND e.nrctremp = 851482) OR (e.cdcooper = 1	AND e.nrdconta = 8603308	AND e.nrctremp = 8603308) OR
(e.cdcooper = 1	AND e.nrdconta = 8603421	AND e.nrctremp = 1442904) OR (e.cdcooper = 1	AND e.nrdconta = 8604126	AND e.nrctremp = 716404) OR
(e.cdcooper = 1	AND e.nrdconta = 8605351	AND e.nrctremp = 935801) OR (e.cdcooper = 1	AND e.nrdconta = 8606528	AND e.nrctremp = 1051153) OR
(e.cdcooper = 1	AND e.nrdconta = 8608083	AND e.nrctremp = 1660964) OR (e.cdcooper = 1	AND e.nrdconta = 8608652	AND e.nrctremp = 950000) OR
(e.cdcooper = 1	AND e.nrdconta = 8611750	AND e.nrctremp = 8611750) OR (e.cdcooper = 1	AND e.nrdconta = 8612170	AND e.nrctremp = 8612170) OR
(e.cdcooper = 1	AND e.nrdconta = 8613826	AND e.nrctremp = 770744) OR (e.cdcooper = 1	AND e.nrdconta = 8613842	AND e.nrctremp = 1551240) OR
(e.cdcooper = 1	AND e.nrdconta = 8615420	AND e.nrctremp = 756951) OR (e.cdcooper = 1	AND e.nrdconta = 8616396	AND e.nrctremp = 805028) OR
(e.cdcooper = 1	AND e.nrdconta = 8617031	AND e.nrctremp = 8617031) OR (e.cdcooper = 1	AND e.nrdconta = 8617171	AND e.nrctremp = 1794586) OR
(e.cdcooper = 1	AND e.nrdconta = 8617686	AND e.nrctremp = 8617686) OR (e.cdcooper = 1	AND e.nrdconta = 8620970	AND e.nrctremp = 1149339) OR
(e.cdcooper = 1	AND e.nrdconta = 8624712	AND e.nrctremp = 8624712) OR (e.cdcooper = 1	AND e.nrdconta = 8626200	AND e.nrctremp = 8626200) OR
(e.cdcooper = 1	AND e.nrdconta = 8629757	AND e.nrctremp = 8629757) OR (e.cdcooper = 1	AND e.nrdconta = 8630739	AND e.nrctremp = 1519132) OR
(e.cdcooper = 1	AND e.nrdconta = 8631093	AND e.nrctremp = 1655156) OR (e.cdcooper = 1	AND e.nrdconta = 8631484	AND e.nrctremp = 674789) OR
(e.cdcooper = 1	AND e.nrdconta = 8634220	AND e.nrctremp = 671322) OR (e.cdcooper = 1	AND e.nrdconta = 8634696	AND e.nrctremp = 1296316) OR
(e.cdcooper = 1	AND e.nrdconta = 8637822	AND e.nrctremp = 8637822) OR (e.cdcooper = 1	AND e.nrdconta = 8638594	AND e.nrctremp = 8638594) OR
(e.cdcooper = 1	AND e.nrdconta = 8639930	AND e.nrctremp = 1011802) OR (e.cdcooper = 1	AND e.nrdconta = 8640432	AND e.nrctremp = 1027756) OR
(e.cdcooper = 1	AND e.nrdconta = 8642060	AND e.nrctremp = 8642060) OR (e.cdcooper = 1	AND e.nrdconta = 8642508	AND e.nrctremp = 1154356) OR
(e.cdcooper = 1	AND e.nrdconta = 8644470	AND e.nrctremp = 1192793) OR (e.cdcooper = 1	AND e.nrdconta = 8644861	AND e.nrctremp = 742609) OR
(e.cdcooper = 1	AND e.nrdconta = 8645035	AND e.nrctremp = 1270514) OR (e.cdcooper = 1	AND e.nrdconta = 8645868	AND e.nrctremp = 1212872) OR
(e.cdcooper = 1	AND e.nrdconta = 8646252	AND e.nrctremp = 8646252) OR (e.cdcooper = 1	AND e.nrdconta = 8646660	AND e.nrctremp = 8646660) OR
(e.cdcooper = 1	AND e.nrdconta = 8647224	AND e.nrctremp = 8647224) OR (e.cdcooper = 1	AND e.nrdconta = 8647968	AND e.nrctremp = 2150939) OR
(e.cdcooper = 1	AND e.nrdconta = 8647992	AND e.nrctremp = 683723) OR (e.cdcooper = 1	AND e.nrdconta = 8648360	AND e.nrctremp = 1029498) OR
(e.cdcooper = 1	AND e.nrdconta = 8648379	AND e.nrctremp = 778710) OR (e.cdcooper = 1	AND e.nrdconta = 8649324	AND e.nrctremp = 817401) OR
(e.cdcooper = 1	AND e.nrdconta = 8649944	AND e.nrctremp = 1059547) OR (e.cdcooper = 1	AND e.nrdconta = 8650438	AND e.nrctremp = 1208043) OR
(e.cdcooper = 1	AND e.nrdconta = 8651922	AND e.nrctremp = 829968) OR (e.cdcooper = 1	AND e.nrdconta = 8652511	AND e.nrctremp = 686495) OR
(e.cdcooper = 1	AND e.nrdconta = 8653941	AND e.nrctremp = 680322) OR (e.cdcooper = 1	AND e.nrdconta = 8654646	AND e.nrctremp = 1582301) OR
(e.cdcooper = 1	AND e.nrdconta = 8654760	AND e.nrctremp = 1243193) OR (e.cdcooper = 1	AND e.nrdconta = 8655235	AND e.nrctremp = 679958) OR
(e.cdcooper = 1	AND e.nrdconta = 8656665	AND e.nrctremp = 1213203) OR (e.cdcooper = 1	AND e.nrdconta = 8659761	AND e.nrctremp = 1440395) OR
(e.cdcooper = 1	AND e.nrdconta = 8660921	AND e.nrctremp = 1179136) OR (e.cdcooper = 1	AND e.nrdconta = 8661146	AND e.nrctremp = 848261) OR
(e.cdcooper = 1	AND e.nrdconta = 8661880	AND e.nrctremp = 8661880) OR (e.cdcooper = 1	AND e.nrdconta = 8661952	AND e.nrctremp = 1478245) OR
(e.cdcooper = 1	AND e.nrdconta = 8667187	AND e.nrctremp = 928690) OR (e.cdcooper = 1	AND e.nrdconta = 8667489	AND e.nrctremp = 198470) OR
(e.cdcooper = 1	AND e.nrdconta = 8668299	AND e.nrctremp = 686099) OR (e.cdcooper = 1	AND e.nrdconta = 8668299	AND e.nrctremp = 8668299) OR
(e.cdcooper = 1	AND e.nrdconta = 8668434	AND e.nrctremp = 8668434) OR (e.cdcooper = 1	AND e.nrdconta = 8669414	AND e.nrctremp = 2104853) OR
(e.cdcooper = 1	AND e.nrdconta = 8669490	AND e.nrctremp = 782831) OR (e.cdcooper = 1	AND e.nrdconta = 8671087	AND e.nrctremp = 988140) OR
(e.cdcooper = 1	AND e.nrdconta = 8672180	AND e.nrctremp = 8672180) OR (e.cdcooper = 1	AND e.nrdconta = 8673560	AND e.nrctremp = 1422520) OR
(e.cdcooper = 1	AND e.nrdconta = 8673870	AND e.nrctremp = 1641167) OR (e.cdcooper = 1	AND e.nrdconta = 8678006	AND e.nrctremp = 1294615) OR
(e.cdcooper = 1	AND e.nrdconta = 8678600	AND e.nrctremp = 865714) OR (e.cdcooper = 1	AND e.nrdconta = 8679878	AND e.nrctremp = 1377338) OR
(e.cdcooper = 1	AND e.nrdconta = 8680078	AND e.nrctremp = 1221446) OR (e.cdcooper = 1	AND e.nrdconta = 8682020	AND e.nrctremp = 1226086) OR
(e.cdcooper = 1	AND e.nrdconta = 8682020	AND e.nrctremp = 1492068) OR (e.cdcooper = 1	AND e.nrdconta = 8683069	AND e.nrctremp = 1270355) OR
(e.cdcooper = 1	AND e.nrdconta = 8687790	AND e.nrctremp = 844684) OR (e.cdcooper = 1	AND e.nrdconta = 8688273	AND e.nrctremp = 1166035) OR
(e.cdcooper = 1	AND e.nrdconta = 8688702	AND e.nrctremp = 702200) OR (e.cdcooper = 1	AND e.nrdconta = 8690090	AND e.nrctremp = 1136533) OR
(e.cdcooper = 1	AND e.nrdconta = 8691029	AND e.nrctremp = 1593604) OR (e.cdcooper = 1	AND e.nrdconta = 8691088	AND e.nrctremp = 1002065) OR
(e.cdcooper = 1	AND e.nrdconta = 8691274	AND e.nrctremp = 8691274) OR (e.cdcooper = 1	AND e.nrdconta = 8691363	AND e.nrctremp = 1015073) OR
(e.cdcooper = 1	AND e.nrdconta = 8691711	AND e.nrctremp = 848895) OR (e.cdcooper = 1	AND e.nrdconta = 8692343	AND e.nrctremp = 8692343) OR
(e.cdcooper = 1	AND e.nrdconta = 8692840	AND e.nrctremp = 1243123) OR (e.cdcooper = 1	AND e.nrdconta = 8693021	AND e.nrctremp = 1044394) OR
(e.cdcooper = 1	AND e.nrdconta = 8693250	AND e.nrctremp = 979947) OR (e.cdcooper = 1	AND e.nrdconta = 8693706	AND e.nrctremp = 8693706) OR
(e.cdcooper = 1	AND e.nrdconta = 8693722	AND e.nrctremp = 1357709) OR (e.cdcooper = 1	AND e.nrdconta = 8695253	AND e.nrctremp = 735657) OR
(e.cdcooper = 1	AND e.nrdconta = 8695342	AND e.nrctremp = 1794773) OR (e.cdcooper = 1	AND e.nrdconta = 8695458	AND e.nrctremp = 719622) OR
(e.cdcooper = 1	AND e.nrdconta = 8696381	AND e.nrctremp = 8696381) OR (e.cdcooper = 1	AND e.nrdconta = 8696845	AND e.nrctremp = 8696845) OR
(e.cdcooper = 1	AND e.nrdconta = 8701261	AND e.nrctremp = 958998) OR (e.cdcooper = 1	AND e.nrdconta = 8701750	AND e.nrctremp = 1654409) OR
(e.cdcooper = 1	AND e.nrdconta = 8703892	AND e.nrctremp = 8703892) OR (e.cdcooper = 1	AND e.nrdconta = 8704716	AND e.nrctremp = 831475) OR
(e.cdcooper = 1	AND e.nrdconta = 8705828	AND e.nrctremp = 968437) OR (e.cdcooper = 1	AND e.nrdconta = 8706123	AND e.nrctremp = 1215379) OR
(e.cdcooper = 1	AND e.nrdconta = 8706140	AND e.nrctremp = 1046656) OR (e.cdcooper = 1	AND e.nrdconta = 8706310	AND e.nrctremp = 8706310) OR
(e.cdcooper = 1	AND e.nrdconta = 8706760	AND e.nrctremp = 873215) OR (e.cdcooper = 1	AND e.nrdconta = 8707146	AND e.nrctremp = 1253840) OR
(e.cdcooper = 1	AND e.nrdconta = 8707928	AND e.nrctremp = 1031619) OR (e.cdcooper = 1	AND e.nrdconta = 8707936	AND e.nrctremp = 8707936) OR
(e.cdcooper = 1	AND e.nrdconta = 8708240	AND e.nrctremp = 1309082) OR (e.cdcooper = 1	AND e.nrdconta = 8708355	AND e.nrctremp = 8708355) OR
(e.cdcooper = 1	AND e.nrdconta = 8708371	AND e.nrctremp = 8708371) OR (e.cdcooper = 1	AND e.nrdconta = 8709610	AND e.nrctremp = 8709610) OR
(e.cdcooper = 1	AND e.nrdconta = 8709726	AND e.nrctremp = 8709726) OR (e.cdcooper = 1	AND e.nrdconta = 8710511	AND e.nrctremp = 8710511) OR
(e.cdcooper = 1	AND e.nrdconta = 8710821	AND e.nrctremp = 1088716) OR (e.cdcooper = 1	AND e.nrdconta = 8712263	AND e.nrctremp = 1066709) OR
(e.cdcooper = 1	AND e.nrdconta = 8714061	AND e.nrctremp = 8714061) OR (e.cdcooper = 1	AND e.nrdconta = 8715254	AND e.nrctremp = 792339) OR
(e.cdcooper = 1	AND e.nrdconta = 8715823	AND e.nrctremp = 8715823) OR (e.cdcooper = 1	AND e.nrdconta = 8718580	AND e.nrctremp = 1051455) OR
(e.cdcooper = 1	AND e.nrdconta = 8718881	AND e.nrctremp = 961159) OR (e.cdcooper = 1	AND e.nrdconta = 8718911	AND e.nrctremp = 931847) OR
(e.cdcooper = 1	AND e.nrdconta = 8721220	AND e.nrctremp = 1654874) OR (e.cdcooper = 1	AND e.nrdconta = 8721360	AND e.nrctremp = 1051174) OR
(e.cdcooper = 1	AND e.nrdconta = 8721440	AND e.nrctremp = 1596479) OR (e.cdcooper = 1	AND e.nrdconta = 8722056	AND e.nrctremp = 8722056) OR
(e.cdcooper = 1	AND e.nrdconta = 8722781	AND e.nrctremp = 8722781) OR (e.cdcooper = 1	AND e.nrdconta = 8722960	AND e.nrctremp = 1286195) OR
(e.cdcooper = 1	AND e.nrdconta = 8723265	AND e.nrctremp = 8723265) OR (e.cdcooper = 1	AND e.nrdconta = 8723559	AND e.nrctremp = 1587159) OR
(e.cdcooper = 1	AND e.nrdconta = 8724091	AND e.nrctremp = 812722) OR (e.cdcooper = 1	AND e.nrdconta = 8724482	AND e.nrctremp = 8724482) OR
(e.cdcooper = 1	AND e.nrdconta = 8727376	AND e.nrctremp = 1423208) OR (e.cdcooper = 1	AND e.nrdconta = 8727562	AND e.nrctremp = 974533) OR
(e.cdcooper = 1	AND e.nrdconta = 8731721	AND e.nrctremp = 8731721) OR (e.cdcooper = 1	AND e.nrdconta = 8732523	AND e.nrctremp = 8732523) OR
(e.cdcooper = 1	AND e.nrdconta = 8733929	AND e.nrctremp = 8733929) OR (e.cdcooper = 1	AND e.nrdconta = 8734135	AND e.nrctremp = 1174404) OR
(e.cdcooper = 1	AND e.nrdconta = 8735476	AND e.nrctremp = 1196895) OR (e.cdcooper = 1	AND e.nrdconta = 8736308	AND e.nrctremp = 1532382) OR
(e.cdcooper = 1	AND e.nrdconta = 8737649	AND e.nrctremp = 717053) OR (e.cdcooper = 1	AND e.nrdconta = 8738009	AND e.nrctremp = 1053894) OR
(e.cdcooper = 1	AND e.nrdconta = 8738890	AND e.nrctremp = 1344065) OR (e.cdcooper = 1	AND e.nrdconta = 8740089	AND e.nrctremp = 1379261) OR
(e.cdcooper = 1	AND e.nrdconta = 8740925	AND e.nrctremp = 1332790) OR (e.cdcooper = 1	AND e.nrdconta = 8742049	AND e.nrctremp = 745482) OR
(e.cdcooper = 1	AND e.nrdconta = 8742049	AND e.nrctremp = 8742049) OR (e.cdcooper = 1	AND e.nrdconta = 8743983	AND e.nrctremp = 1160470) OR
(e.cdcooper = 1	AND e.nrdconta = 8744785	AND e.nrctremp = 1106879) OR (e.cdcooper = 1	AND e.nrdconta = 8745757	AND e.nrctremp = 8745757) OR
(e.cdcooper = 1	AND e.nrdconta = 8746729	AND e.nrctremp = 1167161) OR (e.cdcooper = 1	AND e.nrdconta = 8748926	AND e.nrctremp = 1223527) OR
(e.cdcooper = 1	AND e.nrdconta = 8751099	AND e.nrctremp = 973870) OR (e.cdcooper = 1	AND e.nrdconta = 8751781	AND e.nrctremp = 776810) OR
(e.cdcooper = 1	AND e.nrdconta = 8752290	AND e.nrctremp = 1775018) OR (e.cdcooper = 1	AND e.nrdconta = 8753776	AND e.nrctremp = 793863) OR
(e.cdcooper = 1	AND e.nrdconta = 8756368	AND e.nrctremp = 1100509) OR (e.cdcooper = 1	AND e.nrdconta = 8758972	AND e.nrctremp = 875266) OR
(e.cdcooper = 1	AND e.nrdconta = 8759588	AND e.nrctremp = 8759588) OR (e.cdcooper = 1	AND e.nrdconta = 8759880	AND e.nrctremp = 727334) OR
(e.cdcooper = 1	AND e.nrdconta = 8761019	AND e.nrctremp = 1164904) OR (e.cdcooper = 1	AND e.nrdconta = 8763143	AND e.nrctremp = 8763143) OR
(e.cdcooper = 1	AND e.nrdconta = 8763623	AND e.nrctremp = 728858) OR (e.cdcooper = 1	AND e.nrdconta = 8763887	AND e.nrctremp = 1596477) OR
(e.cdcooper = 1	AND e.nrdconta = 8765251	AND e.nrctremp = 1293586) OR (e.cdcooper = 1	AND e.nrdconta = 8765723	AND e.nrctremp = 729774) OR
(e.cdcooper = 1	AND e.nrdconta = 8766363	AND e.nrctremp = 1466755) OR (e.cdcooper = 1	AND e.nrdconta = 8767718	AND e.nrctremp = 784978) OR
(e.cdcooper = 1	AND e.nrdconta = 8769931	AND e.nrctremp = 1280290) OR (e.cdcooper = 1	AND e.nrdconta = 8770123	AND e.nrctremp = 8770123) OR
(e.cdcooper = 1	AND e.nrdconta = 8770239	AND e.nrctremp = 1586877) OR (e.cdcooper = 1	AND e.nrdconta = 8770310	AND e.nrctremp = 1297191) OR
(e.cdcooper = 1	AND e.nrdconta = 8771006	AND e.nrctremp = 2104041) OR (e.cdcooper = 1	AND e.nrdconta = 8771804	AND e.nrctremp = 2078568) OR
(e.cdcooper = 1	AND e.nrdconta = 8772371	AND e.nrctremp = 770792) OR (e.cdcooper = 1	AND e.nrdconta = 8772410	AND e.nrctremp = 840292) OR
(e.cdcooper = 1	AND e.nrdconta = 8772568	AND e.nrctremp = 8772568) OR (e.cdcooper = 1	AND e.nrdconta = 8772835	AND e.nrctremp = 1584257) OR
(e.cdcooper = 1	AND e.nrdconta = 8773190	AND e.nrctremp = 1775045) OR (e.cdcooper = 1	AND e.nrdconta = 8774072	AND e.nrctremp = 733059) OR
(e.cdcooper = 1	AND e.nrdconta = 8774650	AND e.nrctremp = 8774650) OR (e.cdcooper = 1	AND e.nrdconta = 8774820	AND e.nrctremp = 733450) OR
(e.cdcooper = 1	AND e.nrdconta = 8774820	AND e.nrctremp = 8774820) OR (e.cdcooper = 1	AND e.nrdconta = 8776032	AND e.nrctremp = 8776032) OR
(e.cdcooper = 1	AND e.nrdconta = 8777012	AND e.nrctremp = 1334905) OR (e.cdcooper = 1	AND e.nrdconta = 8777640	AND e.nrctremp = 8777640) OR
(e.cdcooper = 1	AND e.nrdconta = 8778000	AND e.nrctremp = 8778000) OR (e.cdcooper = 1	AND e.nrdconta = 8778396	AND e.nrctremp = 8778396) OR
(e.cdcooper = 1	AND e.nrdconta = 8781346	AND e.nrctremp = 1046344) OR (e.cdcooper = 1	AND e.nrdconta = 8782393	AND e.nrctremp = 1396378) OR
(e.cdcooper = 1	AND e.nrdconta = 8782873	AND e.nrctremp = 1051736) OR (e.cdcooper = 1	AND e.nrdconta = 8783950	AND e.nrctremp = 2104082) OR
(e.cdcooper = 1	AND e.nrdconta = 8784043	AND e.nrctremp = 1091188) OR (e.cdcooper = 1	AND e.nrdconta = 8785236	AND e.nrctremp = 1586887) OR
(e.cdcooper = 1	AND e.nrdconta = 8785279	AND e.nrctremp = 1563576) OR (e.cdcooper = 1	AND e.nrdconta = 8786151	AND e.nrctremp = 8786151) OR
(e.cdcooper = 1	AND e.nrdconta = 8786330	AND e.nrctremp = 1431132) OR (e.cdcooper = 1	AND e.nrdconta = 8786330	AND e.nrctremp = 1724273) OR
(e.cdcooper = 1	AND e.nrdconta = 8788138	AND e.nrctremp = 1161080) OR (e.cdcooper = 1	AND e.nrdconta = 8793522	AND e.nrctremp = 793138) OR
(e.cdcooper = 1	AND e.nrdconta = 8793816	AND e.nrctremp = 966213) OR (e.cdcooper = 1	AND e.nrdconta = 8794324	AND e.nrctremp = 1623568) OR
(e.cdcooper = 1	AND e.nrdconta = 8795738	AND e.nrctremp = 8795738) OR (e.cdcooper = 1	AND e.nrdconta = 8796661	AND e.nrctremp = 753309) OR
(e.cdcooper = 1	AND e.nrdconta = 8796840	AND e.nrctremp = 1111207) OR (e.cdcooper = 1	AND e.nrdconta = 8796912	AND e.nrctremp = 1269671) OR
(e.cdcooper = 1	AND e.nrdconta = 8797013	AND e.nrctremp = 763562) OR (e.cdcooper = 1	AND e.nrdconta = 8797307	AND e.nrctremp = 1070490) OR
(e.cdcooper = 1	AND e.nrdconta = 8798460	AND e.nrctremp = 1299489) OR (e.cdcooper = 1	AND e.nrdconta = 8799881	AND e.nrctremp = 1516321) OR
(e.cdcooper = 1	AND e.nrdconta = 8802858	AND e.nrctremp = 996828) OR (e.cdcooper = 1	AND e.nrdconta = 8802955	AND e.nrctremp = 1536216) OR
(e.cdcooper = 1	AND e.nrdconta = 8804591	AND e.nrctremp = 1379558) OR (e.cdcooper = 1	AND e.nrdconta = 8806357	AND e.nrctremp = 929411) OR
(e.cdcooper = 1	AND e.nrdconta = 8807108	AND e.nrctremp = 962872) OR (e.cdcooper = 1	AND e.nrdconta = 8807310	AND e.nrctremp = 8807310) OR
(e.cdcooper = 1	AND e.nrdconta = 8808830	AND e.nrctremp = 1655069) OR (e.cdcooper = 1	AND e.nrdconta = 8810150	AND e.nrctremp = 989973) OR
(e.cdcooper = 1	AND e.nrdconta = 8814473	AND e.nrctremp = 161317) OR (e.cdcooper = 1	AND e.nrdconta = 8815810	AND e.nrctremp = 1084278) OR
(e.cdcooper = 1	AND e.nrdconta = 8816522	AND e.nrctremp = 1524576) OR (e.cdcooper = 1	AND e.nrdconta = 8818070	AND e.nrctremp = 868074) OR
(e.cdcooper = 1	AND e.nrdconta = 8821445	AND e.nrctremp = 2101872) OR (e.cdcooper = 1	AND e.nrdconta = 8821534	AND e.nrctremp = 920634) OR
(e.cdcooper = 1	AND e.nrdconta = 8821682	AND e.nrctremp = 756062) OR (e.cdcooper = 1	AND e.nrdconta = 8823308	AND e.nrctremp = 1248176) OR
(e.cdcooper = 1	AND e.nrdconta = 8824975	AND e.nrctremp = 756309) OR (e.cdcooper = 1	AND e.nrdconta = 8826536	AND e.nrctremp = 2150947) OR
(e.cdcooper = 1	AND e.nrdconta = 8826668	AND e.nrctremp = 935200) OR (e.cdcooper = 1	AND e.nrdconta = 8827044	AND e.nrctremp = 1483399) OR
(e.cdcooper = 1	AND e.nrdconta = 8827290	AND e.nrctremp = 967437) OR (e.cdcooper = 1	AND e.nrdconta = 8831394	AND e.nrctremp = 1311357) OR
(e.cdcooper = 1	AND e.nrdconta = 8831726	AND e.nrctremp = 8831726) OR (e.cdcooper = 1	AND e.nrdconta = 8833001	AND e.nrctremp = 1870704) OR
(e.cdcooper = 1	AND e.nrdconta = 8835810	AND e.nrctremp = 1290157) OR (e.cdcooper = 1	AND e.nrdconta = 8836450	AND e.nrctremp = 1409127) OR
(e.cdcooper = 1	AND e.nrdconta = 8836604	AND e.nrctremp = 1039466) OR (e.cdcooper = 1	AND e.nrdconta = 8837988	AND e.nrctremp = 8837988) OR
(e.cdcooper = 1	AND e.nrdconta = 8840440	AND e.nrctremp = 1380835) OR (e.cdcooper = 1	AND e.nrdconta = 8840547	AND e.nrctremp = 838664) OR
(e.cdcooper = 1	AND e.nrdconta = 8840741	AND e.nrctremp = 8840741) OR (e.cdcooper = 1	AND e.nrdconta = 8842680	AND e.nrctremp = 2326450) OR
(e.cdcooper = 1	AND e.nrdconta = 8844925	AND e.nrctremp = 8844925) OR (e.cdcooper = 1	AND e.nrdconta = 8844941	AND e.nrctremp = 1775070) OR
(e.cdcooper = 1	AND e.nrdconta = 8845581	AND e.nrctremp = 1213781) OR (e.cdcooper = 1	AND e.nrdconta = 8846065	AND e.nrctremp = 8846065) OR
(e.cdcooper = 1	AND e.nrdconta = 8846359	AND e.nrctremp = 1390172) OR (e.cdcooper = 1	AND e.nrdconta = 8846510	AND e.nrctremp = 1414474) OR
(e.cdcooper = 1	AND e.nrdconta = 8847177	AND e.nrctremp = 967313) OR (e.cdcooper = 1	AND e.nrdconta = 8848084	AND e.nrctremp = 767130) OR
(e.cdcooper = 1	AND e.nrdconta = 8848114	AND e.nrctremp = 767138) OR (e.cdcooper = 1	AND e.nrdconta = 8850410	AND e.nrctremp = 1241780) OR
(e.cdcooper = 1	AND e.nrdconta = 8851050	AND e.nrctremp = 1724061) OR (e.cdcooper = 1	AND e.nrdconta = 8851751	AND e.nrctremp = 952896) OR
(e.cdcooper = 1	AND e.nrdconta = 8854025	AND e.nrctremp = 1103817) OR (e.cdcooper = 1	AND e.nrdconta = 8857580	AND e.nrctremp = 1144304) OR
(e.cdcooper = 1	AND e.nrdconta = 8858101	AND e.nrctremp = 835716) OR (e.cdcooper = 1	AND e.nrdconta = 8858756	AND e.nrctremp = 1478239) OR
(e.cdcooper = 1	AND e.nrdconta = 8859965	AND e.nrctremp = 1696374) OR (e.cdcooper = 1	AND e.nrdconta = 8860661	AND e.nrctremp = 8860661) OR
(e.cdcooper = 1	AND e.nrdconta = 8861404	AND e.nrctremp = 856768) OR (e.cdcooper = 1	AND e.nrdconta = 8865132	AND e.nrctremp = 1007387) OR
(e.cdcooper = 1	AND e.nrdconta = 8867224	AND e.nrctremp = 1083020) OR (e.cdcooper = 1	AND e.nrdconta = 8867356	AND e.nrctremp = 1441405) OR
(e.cdcooper = 1	AND e.nrdconta = 8867399	AND e.nrctremp = 1335660) OR (e.cdcooper = 1	AND e.nrdconta = 8868530	AND e.nrctremp = 891720) OR
(e.cdcooper = 1	AND e.nrdconta = 8869421	AND e.nrctremp = 1196512) OR (e.cdcooper = 1	AND e.nrdconta = 8870713	AND e.nrctremp = 1064568) OR
(e.cdcooper = 1	AND e.nrdconta = 8870942	AND e.nrctremp = 856990) OR (e.cdcooper = 1	AND e.nrdconta = 8871167	AND e.nrctremp = 8871167) OR
(e.cdcooper = 1	AND e.nrdconta = 8871540	AND e.nrctremp = 855839) OR (e.cdcooper = 1	AND e.nrdconta = 8871949	AND e.nrctremp = 813104) OR
(e.cdcooper = 1	AND e.nrdconta = 8872430	AND e.nrctremp = 1127875) OR (e.cdcooper = 1	AND e.nrdconta = 8876100	AND e.nrctremp = 891557) OR
(e.cdcooper = 1	AND e.nrdconta = 8876240	AND e.nrctremp = 849375) OR (e.cdcooper = 1	AND e.nrdconta = 8877378	AND e.nrctremp = 8877378) OR
(e.cdcooper = 1	AND e.nrdconta = 8877386	AND e.nrctremp = 1376573) OR (e.cdcooper = 1	AND e.nrdconta = 8877408	AND e.nrctremp = 8877408) OR
(e.cdcooper = 1	AND e.nrdconta = 8877467	AND e.nrctremp = 1063592) OR (e.cdcooper = 1	AND e.nrdconta = 8879621	AND e.nrctremp = 1434821) OR
(e.cdcooper = 1	AND e.nrdconta = 8879729	AND e.nrctremp = 840959) OR (e.cdcooper = 1	AND e.nrdconta = 8880280	AND e.nrctremp = 918343) OR
(e.cdcooper = 1	AND e.nrdconta = 8880549	AND e.nrctremp = 1053889) OR (e.cdcooper = 1	AND e.nrdconta = 8883971	AND e.nrctremp = 1806104) OR
(e.cdcooper = 1	AND e.nrdconta = 8884021	AND e.nrctremp = 1380216) OR (e.cdcooper = 1	AND e.nrdconta = 8887896	AND e.nrctremp = 1280221) OR
(e.cdcooper = 1	AND e.nrdconta = 8888264	AND e.nrctremp = 1016314) OR (e.cdcooper = 1	AND e.nrdconta = 8888477	AND e.nrctremp = 1364624) OR
(e.cdcooper = 1	AND e.nrdconta = 8889422	AND e.nrctremp = 1119200) OR (e.cdcooper = 1	AND e.nrdconta = 8890650	AND e.nrctremp = 873699) OR
(e.cdcooper = 1	AND e.nrdconta = 8890692	AND e.nrctremp = 2221065) OR (e.cdcooper = 1	AND e.nrdconta = 8891915	AND e.nrctremp = 1449690) OR
(e.cdcooper = 1	AND e.nrdconta = 8891982	AND e.nrctremp = 1133264) OR (e.cdcooper = 1	AND e.nrdconta = 8892857	AND e.nrctremp = 799266) OR
(e.cdcooper = 1	AND e.nrdconta = 8892857	AND e.nrctremp = 1054109) OR (e.cdcooper = 1	AND e.nrdconta = 8895350	AND e.nrctremp = 879351) OR
(e.cdcooper = 1	AND e.nrdconta = 8896976	AND e.nrctremp = 940449) OR (e.cdcooper = 1	AND e.nrdconta = 8898081	AND e.nrctremp = 1262312) OR
(e.cdcooper = 1	AND e.nrdconta = 8900221	AND e.nrctremp = 1445419) OR (e.cdcooper = 1	AND e.nrdconta = 8901350	AND e.nrctremp = 920359) OR
(e.cdcooper = 1	AND e.nrdconta = 8904405	AND e.nrctremp = 992492) OR (e.cdcooper = 1	AND e.nrdconta = 8906661	AND e.nrctremp = 1414597) OR
(e.cdcooper = 1	AND e.nrdconta = 8909997	AND e.nrctremp = 1020760) OR (e.cdcooper = 1	AND e.nrdconta = 8912009	AND e.nrctremp = 8912009) OR
(e.cdcooper = 1	AND e.nrdconta = 8912173	AND e.nrctremp = 1158954) OR (e.cdcooper = 1	AND e.nrdconta = 8912424	AND e.nrctremp = 1147758) OR
(e.cdcooper = 1	AND e.nrdconta = 8913960	AND e.nrctremp = 1562381) OR (e.cdcooper = 1	AND e.nrdconta = 8915636	AND e.nrctremp = 974193) OR
(e.cdcooper = 1	AND e.nrdconta = 8917710	AND e.nrctremp = 2194849) OR (e.cdcooper = 1	AND e.nrdconta = 8918082	AND e.nrctremp = 1775168) OR
(e.cdcooper = 1	AND e.nrdconta = 8918392	AND e.nrctremp = 1369861) OR (e.cdcooper = 1	AND e.nrdconta = 8920311	AND e.nrctremp = 8920311) OR
(e.cdcooper = 1	AND e.nrdconta = 8921032	AND e.nrctremp = 1094313) OR (e.cdcooper = 1	AND e.nrdconta = 8921431	AND e.nrctremp = 1008800) OR
(e.cdcooper = 1	AND e.nrdconta = 8921490	AND e.nrctremp = 1295474) OR (e.cdcooper = 1	AND e.nrdconta = 8921989	AND e.nrctremp = 1114700) OR
(e.cdcooper = 1	AND e.nrdconta = 8924490	AND e.nrctremp = 806494) OR (e.cdcooper = 1	AND e.nrdconta = 8924589	AND e.nrctremp = 1214902) OR
(e.cdcooper = 1	AND e.nrdconta = 8924589	AND e.nrctremp = 1586869) OR (e.cdcooper = 1	AND e.nrdconta = 8924678	AND e.nrctremp = 1138529) OR
(e.cdcooper = 1	AND e.nrdconta = 8926360	AND e.nrctremp = 921696) OR (e.cdcooper = 1	AND e.nrdconta = 8926719	AND e.nrctremp = 924433) OR
(e.cdcooper = 1	AND e.nrdconta = 8927650	AND e.nrctremp = 948497) OR (e.cdcooper = 1	AND e.nrdconta = 8928444	AND e.nrctremp = 893761) OR
(e.cdcooper = 1	AND e.nrdconta = 8930007	AND e.nrctremp = 955041) OR (e.cdcooper = 1	AND e.nrdconta = 8931445	AND e.nrctremp = 966471) OR
(e.cdcooper = 1	AND e.nrdconta = 8931488	AND e.nrctremp = 948688) OR (e.cdcooper = 1	AND e.nrdconta = 8931569	AND e.nrctremp = 1144876) OR
(e.cdcooper = 1	AND e.nrdconta = 8931640	AND e.nrctremp = 982400) OR (e.cdcooper = 1	AND e.nrdconta = 8932450	AND e.nrctremp = 869912) OR
(e.cdcooper = 1	AND e.nrdconta = 8932972	AND e.nrctremp = 2104019) OR (e.cdcooper = 1	AND e.nrdconta = 8933596	AND e.nrctremp = 954965) OR
(e.cdcooper = 1	AND e.nrdconta = 8934584	AND e.nrctremp = 1177996) OR (e.cdcooper = 1	AND e.nrdconta = 8935394	AND e.nrctremp = 807260) OR
(e.cdcooper = 1	AND e.nrdconta = 8937184	AND e.nrctremp = 1098010) OR (e.cdcooper = 1	AND e.nrdconta = 8938334	AND e.nrctremp = 1101981) OR
(e.cdcooper = 1	AND e.nrdconta = 8938989	AND e.nrctremp = 808600) OR (e.cdcooper = 1	AND e.nrdconta = 8939829	AND e.nrctremp = 1885001) OR
(e.cdcooper = 1	AND e.nrdconta = 8941025	AND e.nrctremp = 1061146) OR (e.cdcooper = 1	AND e.nrdconta = 8941084	AND e.nrctremp = 1109829) OR
(e.cdcooper = 1	AND e.nrdconta = 8941351	AND e.nrctremp = 1215816) OR (e.cdcooper = 1	AND e.nrdconta = 8941939	AND e.nrctremp = 834315) OR
(e.cdcooper = 1	AND e.nrdconta = 8943168	AND e.nrctremp = 1397692) OR (e.cdcooper = 1	AND e.nrdconta = 8943613	AND e.nrctremp = 1660512) OR
(e.cdcooper = 1	AND e.nrdconta = 8944334	AND e.nrctremp = 1103574) OR (e.cdcooper = 1	AND e.nrdconta = 8944512	AND e.nrctremp = 956402) OR
(e.cdcooper = 1	AND e.nrdconta = 8945195	AND e.nrctremp = 1659678) OR (e.cdcooper = 1	AND e.nrdconta = 8945195	AND e.nrctremp = 1921370) OR
(e.cdcooper = 1	AND e.nrdconta = 8949077	AND e.nrctremp = 809813) OR (e.cdcooper = 1	AND e.nrdconta = 8949492	AND e.nrctremp = 827872) OR
(e.cdcooper = 1	AND e.nrdconta = 8950016	AND e.nrctremp = 972993) OR (e.cdcooper = 1	AND e.nrdconta = 8951950	AND e.nrctremp = 1551667) OR
(e.cdcooper = 1	AND e.nrdconta = 8951993	AND e.nrctremp = 1592623) OR (e.cdcooper = 1	AND e.nrdconta = 8952019	AND e.nrctremp = 1395327) OR
(e.cdcooper = 1	AND e.nrdconta = 8952019	AND e.nrctremp = 1637679) OR (e.cdcooper = 1	AND e.nrdconta = 8952027	AND e.nrctremp = 886932) OR
(e.cdcooper = 1	AND e.nrdconta = 8952450	AND e.nrctremp = 1339198) OR (e.cdcooper = 1	AND e.nrdconta = 8952590	AND e.nrctremp = 1280879) OR
(e.cdcooper = 1	AND e.nrdconta = 8954895	AND e.nrctremp = 1287884) OR (e.cdcooper = 1	AND e.nrdconta = 8956260	AND e.nrctremp = 817526) OR
(e.cdcooper = 1	AND e.nrdconta = 8956596	AND e.nrctremp = 8956596) OR (e.cdcooper = 1	AND e.nrdconta = 8957010	AND e.nrctremp = 815179) OR
(e.cdcooper = 1	AND e.nrdconta = 8957126	AND e.nrctremp = 924357) OR (e.cdcooper = 1	AND e.nrdconta = 8958505	AND e.nrctremp = 1409540) OR
(e.cdcooper = 1	AND e.nrdconta = 8960399	AND e.nrctremp = 1229243) OR (e.cdcooper = 1	AND e.nrdconta = 8961018	AND e.nrctremp = 1921099) OR
(e.cdcooper = 1	AND e.nrdconta = 8962464	AND e.nrctremp = 1634456) OR (e.cdcooper = 1	AND e.nrdconta = 8962723	AND e.nrctremp = 983330) OR
(e.cdcooper = 1	AND e.nrdconta = 8963037	AND e.nrctremp = 1603191) OR (e.cdcooper = 1	AND e.nrdconta = 8967474	AND e.nrctremp = 214222) OR
(e.cdcooper = 1	AND e.nrdconta = 8968934	AND e.nrctremp = 1014653) OR (e.cdcooper = 1	AND e.nrdconta = 8969825	AND e.nrctremp = 828747) OR
(e.cdcooper = 1	AND e.nrdconta = 8972117	AND e.nrctremp = 1054456) OR (e.cdcooper = 1	AND e.nrdconta = 8972591	AND e.nrctremp = 821420) OR
(e.cdcooper = 1	AND e.nrdconta = 8973032	AND e.nrctremp = 831011) OR (e.cdcooper = 1	AND e.nrdconta = 8975221	AND e.nrctremp = 1114769) OR
(e.cdcooper = 1	AND e.nrdconta = 8978433	AND e.nrctremp = 1586933) OR (e.cdcooper = 1	AND e.nrdconta = 8978956	AND e.nrctremp = 1096804) OR
(e.cdcooper = 1	AND e.nrdconta = 8979634	AND e.nrctremp = 1569978) OR (e.cdcooper = 1	AND e.nrdconta = 8987629	AND e.nrctremp = 844464) OR
(e.cdcooper = 1	AND e.nrdconta = 8987750	AND e.nrctremp = 1586932) OR (e.cdcooper = 1	AND e.nrdconta = 8992410	AND e.nrctremp = 1469345) OR
(e.cdcooper = 1	AND e.nrdconta = 8993882	AND e.nrctremp = 1316283) OR (e.cdcooper = 1	AND e.nrdconta = 8994560	AND e.nrctremp = 984724) OR
(e.cdcooper = 1	AND e.nrdconta = 8995567	AND e.nrctremp = 1596383) OR (e.cdcooper = 1	AND e.nrdconta = 8996393	AND e.nrctremp = 966278) OR
(e.cdcooper = 1	AND e.nrdconta = 8996474	AND e.nrctremp = 992136) OR (e.cdcooper = 1	AND e.nrdconta = 8996474	AND e.nrctremp = 2145138) OR
(e.cdcooper = 1	AND e.nrdconta = 8997462	AND e.nrctremp = 1031488) OR (e.cdcooper = 1	AND e.nrdconta = 8997470	AND e.nrctremp = 1128298) OR
(e.cdcooper = 1	AND e.nrdconta = 9001743	AND e.nrctremp = 1157900) OR (e.cdcooper = 1	AND e.nrdconta = 9002049	AND e.nrctremp = 9002049) OR
(e.cdcooper = 1	AND e.nrdconta = 9003355	AND e.nrctremp = 1436466) OR (e.cdcooper = 1	AND e.nrdconta = 9007890	AND e.nrctremp = 1261246) OR
(e.cdcooper = 1	AND e.nrdconta = 9008594	AND e.nrctremp = 1921043) OR (e.cdcooper = 1	AND e.nrdconta = 9008810	AND e.nrctremp = 1312551) OR
(e.cdcooper = 1	AND e.nrdconta = 9009850	AND e.nrctremp = 1373571) OR (e.cdcooper = 1	AND e.nrdconta = 9010777	AND e.nrctremp = 925124) OR
(e.cdcooper = 1	AND e.nrdconta = 9010807	AND e.nrctremp = 1395794) OR (e.cdcooper = 1	AND e.nrdconta = 9012834	AND e.nrctremp = 1076288) OR
(e.cdcooper = 1	AND e.nrdconta = 9013296	AND e.nrctremp = 941731) OR (e.cdcooper = 1	AND e.nrdconta = 9013997	AND e.nrctremp = 1277637) OR
(e.cdcooper = 1	AND e.nrdconta = 9016163	AND e.nrctremp = 1775435) OR (e.cdcooper = 1	AND e.nrdconta = 9017380	AND e.nrctremp = 1341739) OR
(e.cdcooper = 1	AND e.nrdconta = 9019413	AND e.nrctremp = 1127889) OR (e.cdcooper = 1	AND e.nrdconta = 9021701	AND e.nrctremp = 921125) OR
(e.cdcooper = 1	AND e.nrdconta = 9023682	AND e.nrctremp = 1082443) OR (e.cdcooper = 1	AND e.nrdconta = 9023950	AND e.nrctremp = 844899) OR
(e.cdcooper = 1	AND e.nrdconta = 9024786	AND e.nrctremp = 1504991) OR (e.cdcooper = 1	AND e.nrdconta = 9024972	AND e.nrctremp = 1130279) OR
(e.cdcooper = 1	AND e.nrdconta = 9025006	AND e.nrctremp = 1072631) OR (e.cdcooper = 1	AND e.nrdconta = 9025189	AND e.nrctremp = 844931) OR
(e.cdcooper = 1	AND e.nrdconta = 9027106	AND e.nrctremp = 906472) OR (e.cdcooper = 1	AND e.nrdconta = 9028773	AND e.nrctremp = 1273832) OR
(e.cdcooper = 1	AND e.nrdconta = 9031219	AND e.nrctremp = 1135747) OR (e.cdcooper = 1	AND e.nrdconta = 9031405	AND e.nrctremp = 2150952) OR
(e.cdcooper = 1	AND e.nrdconta = 9031596	AND e.nrctremp = 1030534) OR (e.cdcooper = 1	AND e.nrdconta = 9032541	AND e.nrctremp = 2012624) OR
(e.cdcooper = 1	AND e.nrdconta = 9032800	AND e.nrctremp = 1136139) OR (e.cdcooper = 1	AND e.nrdconta = 9034153	AND e.nrctremp = 979758) OR
(e.cdcooper = 1	AND e.nrdconta = 9034749	AND e.nrctremp = 1957441) OR (e.cdcooper = 1	AND e.nrdconta = 9035605	AND e.nrctremp = 941583) OR
(e.cdcooper = 1	AND e.nrdconta = 9035710	AND e.nrctremp = 1221749) OR (e.cdcooper = 1	AND e.nrdconta = 9035940	AND e.nrctremp = 1136109) OR
(e.cdcooper = 1	AND e.nrdconta = 9036415	AND e.nrctremp = 1227939) OR (e.cdcooper = 1	AND e.nrdconta = 9037420	AND e.nrctremp = 1029542) OR
(e.cdcooper = 1	AND e.nrdconta = 9037616	AND e.nrctremp = 1688680) OR (e.cdcooper = 1	AND e.nrdconta = 9038345	AND e.nrctremp = 1433791) OR
(e.cdcooper = 1	AND e.nrdconta = 9039902	AND e.nrctremp = 1949600) OR (e.cdcooper = 1	AND e.nrdconta = 9041818	AND e.nrctremp = 1367992) OR
(e.cdcooper = 1	AND e.nrdconta = 9042121	AND e.nrctremp = 977736) OR (e.cdcooper = 1	AND e.nrdconta = 9042539	AND e.nrctremp = 1171858) OR
(e.cdcooper = 1	AND e.nrdconta = 9042873	AND e.nrctremp = 9042873) OR (e.cdcooper = 1	AND e.nrdconta = 9043748	AND e.nrctremp = 864384) OR
(e.cdcooper = 1	AND e.nrdconta = 9044523	AND e.nrctremp = 1230517) OR (e.cdcooper = 1	AND e.nrdconta = 9044590	AND e.nrctremp = 885684) OR
(e.cdcooper = 1	AND e.nrdconta = 9045937	AND e.nrctremp = 994860) OR (e.cdcooper = 1	AND e.nrdconta = 9046046	AND e.nrctremp = 1098601) OR
(e.cdcooper = 1	AND e.nrdconta = 9047514	AND e.nrctremp = 856081) OR (e.cdcooper = 1	AND e.nrdconta = 9048731	AND e.nrctremp = 1224375) OR
(e.cdcooper = 1	AND e.nrdconta = 9048855	AND e.nrctremp = 1418997) OR (e.cdcooper = 1	AND e.nrdconta = 9050876	AND e.nrctremp = 1173397) OR
(e.cdcooper = 1	AND e.nrdconta = 9053654	AND e.nrctremp = 1696947) OR (e.cdcooper = 1	AND e.nrdconta = 9056483	AND e.nrctremp = 1682937) OR
(e.cdcooper = 1	AND e.nrdconta = 9056521	AND e.nrctremp = 1082157) OR (e.cdcooper = 1	AND e.nrdconta = 9057021	AND e.nrctremp = 1023325) OR
(e.cdcooper = 1	AND e.nrdconta = 9058427	AND e.nrctremp = 1220636) OR (e.cdcooper = 1	AND e.nrdconta = 9058842	AND e.nrctremp = 1021305) OR
(e.cdcooper = 1	AND e.nrdconta = 9061215	AND e.nrctremp = 2025457) OR (e.cdcooper = 1	AND e.nrdconta = 9061789	AND e.nrctremp = 1051652) OR
(e.cdcooper = 1	AND e.nrdconta = 9062181	AND e.nrctremp = 1254268) OR (e.cdcooper = 1	AND e.nrdconta = 9062432	AND e.nrctremp = 1221617) OR
(e.cdcooper = 1	AND e.nrdconta = 9063595	AND e.nrctremp = 1072653) OR (e.cdcooper = 1	AND e.nrdconta = 9063846	AND e.nrctremp = 1617376) OR
(e.cdcooper = 1	AND e.nrdconta = 9064087	AND e.nrctremp = 864063) OR (e.cdcooper = 1	AND e.nrdconta = 9065342	AND e.nrctremp = 1027171) OR
(e.cdcooper = 1	AND e.nrdconta = 9065350	AND e.nrctremp = 1009338) OR (e.cdcooper = 1	AND e.nrdconta = 9065890	AND e.nrctremp = 866846) OR
(e.cdcooper = 1	AND e.nrdconta = 9066845	AND e.nrctremp = 1019326) OR (e.cdcooper = 1	AND e.nrdconta = 9067124	AND e.nrctremp = 1162791) OR
(e.cdcooper = 1	AND e.nrdconta = 9068775	AND e.nrctremp = 1284441) OR (e.cdcooper = 1	AND e.nrdconta = 9069704	AND e.nrctremp = 1235365) OR
(e.cdcooper = 1	AND e.nrdconta = 9072063	AND e.nrctremp = 2101881) OR (e.cdcooper = 1	AND e.nrdconta = 9074279	AND e.nrctremp = 973446) OR
(e.cdcooper = 1	AND e.nrdconta = 9075968	AND e.nrctremp = 1264089) OR (e.cdcooper = 1	AND e.nrdconta = 9077154	AND e.nrctremp = 1092169) OR
(e.cdcooper = 1	AND e.nrdconta = 9077677	AND e.nrctremp = 1771563) OR (e.cdcooper = 1	AND e.nrdconta = 9078070	AND e.nrctremp = 1165011) OR
(e.cdcooper = 1	AND e.nrdconta = 9078290	AND e.nrctremp = 956849) OR (e.cdcooper = 1	AND e.nrdconta = 9079467	AND e.nrctremp = 1217879) OR
(e.cdcooper = 1	AND e.nrdconta = 9080660	AND e.nrctremp = 873492) OR (e.cdcooper = 1	AND e.nrdconta = 9082557	AND e.nrctremp = 939702) OR
(e.cdcooper = 1	AND e.nrdconta = 9083227	AND e.nrctremp = 986631) OR (e.cdcooper = 1	AND e.nrdconta = 9084738	AND e.nrctremp = 1391297) OR
(e.cdcooper = 1	AND e.nrdconta = 9085211	AND e.nrctremp = 1041918) OR (e.cdcooper = 1	AND e.nrdconta = 9085971	AND e.nrctremp = 1179777) OR
(e.cdcooper = 1	AND e.nrdconta = 9086056	AND e.nrctremp = 1398263) OR (e.cdcooper = 1	AND e.nrdconta = 9087567	AND e.nrctremp = 2145196) OR
(e.cdcooper = 1	AND e.nrdconta = 9089390	AND e.nrctremp = 1629923) OR (e.cdcooper = 1	AND e.nrdconta = 9090754	AND e.nrctremp = 1267060) OR
(e.cdcooper = 1	AND e.nrdconta = 9092021	AND e.nrctremp = 1031105) OR (e.cdcooper = 1	AND e.nrdconta = 9092218	AND e.nrctremp = 1612715) OR
(e.cdcooper = 1	AND e.nrdconta = 9092218	AND e.nrctremp = 1920940) OR (e.cdcooper = 1	AND e.nrdconta = 9092307	AND e.nrctremp = 1596263) OR
(e.cdcooper = 1	AND e.nrdconta = 9094687	AND e.nrctremp = 901223) OR (e.cdcooper = 1	AND e.nrdconta = 9096191	AND e.nrctremp = 1160129) OR
(e.cdcooper = 1	AND e.nrdconta = 9099107	AND e.nrctremp = 2104879) OR (e.cdcooper = 1	AND e.nrdconta = 9099646	AND e.nrctremp = 993203) OR
(e.cdcooper = 1	AND e.nrdconta = 9111719	AND e.nrctremp = 212831) OR (e.cdcooper = 1	AND e.nrdconta = 9119892	AND e.nrctremp = 9119892) OR
(e.cdcooper = 1	AND e.nrdconta = 9121560	AND e.nrctremp = 578682) OR (e.cdcooper = 1	AND e.nrdconta = 9121560	AND e.nrctremp = 702538) OR
(e.cdcooper = 1	AND e.nrdconta = 9122265	AND e.nrctremp = 706442) OR (e.cdcooper = 1	AND e.nrdconta = 9123784	AND e.nrctremp = 712539) OR
(e.cdcooper = 1	AND e.nrdconta = 9124187	AND e.nrctremp = 972013) OR (e.cdcooper = 1	AND e.nrdconta = 9128638	AND e.nrctremp = 450597) OR
(e.cdcooper = 1	AND e.nrdconta = 9129685	AND e.nrctremp = 1013097) OR (e.cdcooper = 1	AND e.nrdconta = 9132244	AND e.nrctremp = 337106) OR
(e.cdcooper = 1	AND e.nrdconta = 9132678	AND e.nrctremp = 934770) OR (e.cdcooper = 1	AND e.nrdconta = 9136401	AND e.nrctremp = 340212) OR
(e.cdcooper = 1	AND e.nrdconta = 9136401	AND e.nrctremp = 494156) OR (e.cdcooper = 1	AND e.nrdconta = 9137440	AND e.nrctremp = 924088) OR
(e.cdcooper = 1	AND e.nrdconta = 9139060	AND e.nrctremp = 531149) OR (e.cdcooper = 1	AND e.nrdconta = 9144803	AND e.nrctremp = 450004) OR
(e.cdcooper = 1	AND e.nrdconta = 9146202	AND e.nrctremp = 143654) OR (e.cdcooper = 1	AND e.nrdconta = 9147195	AND e.nrctremp = 1326780) OR
(e.cdcooper = 1	AND e.nrdconta = 9150633	AND e.nrctremp = 315506) OR (e.cdcooper = 1	AND e.nrdconta = 9155457	AND e.nrctremp = 1003041) OR
(e.cdcooper = 1	AND e.nrdconta = 9156607	AND e.nrctremp = 645246) OR (e.cdcooper = 1	AND e.nrdconta = 9156631	AND e.nrctremp = 177307) OR
(e.cdcooper = 1	AND e.nrdconta = 9158219	AND e.nrctremp = 1173923) OR (e.cdcooper = 1	AND e.nrdconta = 9160060	AND e.nrctremp = 988599) OR
(e.cdcooper = 1	AND e.nrdconta = 9160515	AND e.nrctremp = 1454788) OR (e.cdcooper = 1	AND e.nrdconta = 9160680	AND e.nrctremp = 1060734) OR
(e.cdcooper = 1	AND e.nrdconta = 9161287	AND e.nrctremp = 1101313) OR (e.cdcooper = 1	AND e.nrdconta = 9163913	AND e.nrctremp = 1327700) OR
(e.cdcooper = 1	AND e.nrdconta = 9164022	AND e.nrctremp = 1110180) OR (e.cdcooper = 1	AND e.nrdconta = 9165053	AND e.nrctremp = 886766) OR
(e.cdcooper = 1	AND e.nrdconta = 9172025	AND e.nrctremp = 1775319) OR (e.cdcooper = 1	AND e.nrdconta = 9173030	AND e.nrctremp = 1115770) OR
(e.cdcooper = 1	AND e.nrdconta = 9174214	AND e.nrctremp = 1186004) OR (e.cdcooper = 1	AND e.nrdconta = 9175466	AND e.nrctremp = 908776) OR
(e.cdcooper = 1	AND e.nrdconta = 9178945	AND e.nrctremp = 988510) OR (e.cdcooper = 1	AND e.nrdconta = 9180494	AND e.nrctremp = 1052048) OR
(e.cdcooper = 1	AND e.nrdconta = 9181393	AND e.nrctremp = 1103747) OR (e.cdcooper = 1	AND e.nrdconta = 9182578	AND e.nrctremp = 2145119) OR
(e.cdcooper = 1	AND e.nrdconta = 9183574	AND e.nrctremp = 929323) OR (e.cdcooper = 1	AND e.nrdconta = 9188266	AND e.nrctremp = 1097878) OR
(e.cdcooper = 1	AND e.nrdconta = 9189319	AND e.nrctremp = 1435299) OR (e.cdcooper = 1	AND e.nrdconta = 9189599	AND e.nrctremp = 1547638) OR
(e.cdcooper = 1	AND e.nrdconta = 9189734	AND e.nrctremp = 1096859) OR (e.cdcooper = 1	AND e.nrdconta = 9190180	AND e.nrctremp = 1149116) OR
(e.cdcooper = 1	AND e.nrdconta = 9191801	AND e.nrctremp = 1596449) OR (e.cdcooper = 1	AND e.nrdconta = 9193154	AND e.nrctremp = 1259902) OR
(e.cdcooper = 1	AND e.nrdconta = 9194339	AND e.nrctremp = 1547598) OR (e.cdcooper = 1	AND e.nrdconta = 9195122	AND e.nrctremp = 961201) OR
(e.cdcooper = 1	AND e.nrdconta = 9195980	AND e.nrctremp = 1379884) OR (e.cdcooper = 1	AND e.nrdconta = 9196935	AND e.nrctremp = 1599816) OR
(e.cdcooper = 1	AND e.nrdconta = 9197478	AND e.nrctremp = 1515023) OR (e.cdcooper = 1	AND e.nrdconta = 9197559	AND e.nrctremp = 1619032) OR
(e.cdcooper = 1	AND e.nrdconta = 9197931	AND e.nrctremp = 900659) OR (e.cdcooper = 1	AND e.nrdconta = 9202463	AND e.nrctremp = 1209300) OR
(e.cdcooper = 1	AND e.nrdconta = 9202790	AND e.nrctremp = 1199684) OR (e.cdcooper = 1	AND e.nrdconta = 9203575	AND e.nrctremp = 1380818) OR
(e.cdcooper = 1	AND e.nrdconta = 9205390	AND e.nrctremp = 1547581) OR (e.cdcooper = 1	AND e.nrdconta = 9205551	AND e.nrctremp = 1153465) OR
(e.cdcooper = 1	AND e.nrdconta = 9206043	AND e.nrctremp = 1921317) OR (e.cdcooper = 1	AND e.nrdconta = 9206345	AND e.nrctremp = 1586800) OR
(e.cdcooper = 1	AND e.nrdconta = 9206868	AND e.nrctremp = 1340732) OR (e.cdcooper = 1	AND e.nrdconta = 9207546	AND e.nrctremp = 906375) OR
(e.cdcooper = 1	AND e.nrdconta = 9208747	AND e.nrctremp = 1097648) OR (e.cdcooper = 1	AND e.nrdconta = 9210814	AND e.nrctremp = 1853651) OR
(e.cdcooper = 1	AND e.nrdconta = 9210946	AND e.nrctremp = 1003869) OR (e.cdcooper = 1	AND e.nrdconta = 9211241	AND e.nrctremp = 918821) OR
(e.cdcooper = 1	AND e.nrdconta = 9212523	AND e.nrctremp = 1885126) OR (e.cdcooper = 1	AND e.nrdconta = 9214828	AND e.nrctremp = 918536) OR
(e.cdcooper = 1	AND e.nrdconta = 9216715	AND e.nrctremp = 1179396) OR (e.cdcooper = 1	AND e.nrdconta = 9216995	AND e.nrctremp = 1014215) OR
(e.cdcooper = 1	AND e.nrdconta = 9219471	AND e.nrctremp = 1134731) OR (e.cdcooper = 1	AND e.nrdconta = 9219668	AND e.nrctremp = 2013045) OR
(e.cdcooper = 1	AND e.nrdconta = 9222430	AND e.nrctremp = 945629) OR (e.cdcooper = 1	AND e.nrdconta = 9223193	AND e.nrctremp = 1035088) OR
(e.cdcooper = 1	AND e.nrdconta = 9223495	AND e.nrctremp = 1096623) OR (e.cdcooper = 1	AND e.nrdconta = 9226125	AND e.nrctremp = 1619251) OR
(e.cdcooper = 1	AND e.nrdconta = 9226591	AND e.nrctremp = 1490357) OR (e.cdcooper = 1	AND e.nrdconta = 9226842	AND e.nrctremp = 1040171) OR
(e.cdcooper = 1	AND e.nrdconta = 9227261	AND e.nrctremp = 1190133) OR (e.cdcooper = 1	AND e.nrdconta = 9228489	AND e.nrctremp = 1036582) OR
(e.cdcooper = 1	AND e.nrdconta = 9229876	AND e.nrctremp = 2145057) OR (e.cdcooper = 1	AND e.nrdconta = 9229922	AND e.nrctremp = 1379695) OR
(e.cdcooper = 1	AND e.nrdconta = 9230777	AND e.nrctremp = 922304) OR (e.cdcooper = 1	AND e.nrdconta = 9234560	AND e.nrctremp = 1108980) OR
(e.cdcooper = 1	AND e.nrdconta = 9234810	AND e.nrctremp = 1048512) OR (e.cdcooper = 1	AND e.nrdconta = 9237410	AND e.nrctremp = 1096105) OR
(e.cdcooper = 1	AND e.nrdconta = 9239731	AND e.nrctremp = 1106175) OR (e.cdcooper = 1	AND e.nrdconta = 9239731	AND e.nrctremp = 1655071) OR
(e.cdcooper = 1	AND e.nrdconta = 9239936	AND e.nrctremp = 1599795) OR (e.cdcooper = 1	AND e.nrdconta = 9241540	AND e.nrctremp = 1267982) OR
(e.cdcooper = 1	AND e.nrdconta = 9245626	AND e.nrctremp = 1238739) OR (e.cdcooper = 1	AND e.nrdconta = 9245847	AND e.nrctremp = 1073749) OR
(e.cdcooper = 1	AND e.nrdconta = 9245847	AND e.nrctremp = 1269843) OR (e.cdcooper = 1	AND e.nrdconta = 9246940	AND e.nrctremp = 1386668) OR
(e.cdcooper = 1	AND e.nrdconta = 9249796	AND e.nrctremp = 1513983) OR (e.cdcooper = 1	AND e.nrdconta = 9254447	AND e.nrctremp = 927877) OR
(e.cdcooper = 1	AND e.nrdconta = 9254447	AND e.nrctremp = 1424162) OR (e.cdcooper = 1	AND e.nrdconta = 9255389	AND e.nrctremp = 1462027) OR
(e.cdcooper = 1	AND e.nrdconta = 9256466	AND e.nrctremp = 1733880) OR (e.cdcooper = 1	AND e.nrdconta = 9257012	AND e.nrctremp = 1070729) OR
(e.cdcooper = 1	AND e.nrdconta = 9258930	AND e.nrctremp = 1301760) OR (e.cdcooper = 1	AND e.nrdconta = 9259511	AND e.nrctremp = 1025765) OR
(e.cdcooper = 1	AND e.nrdconta = 9264310	AND e.nrctremp = 932874) OR (e.cdcooper = 1	AND e.nrdconta = 9264310	AND e.nrctremp = 1853643) OR
(e.cdcooper = 1	AND e.nrdconta = 9266259	AND e.nrctremp = 935414) OR (e.cdcooper = 1	AND e.nrdconta = 9266550	AND e.nrctremp = 1853655) OR
(e.cdcooper = 1	AND e.nrdconta = 9267220	AND e.nrctremp = 1724105) OR (e.cdcooper = 1	AND e.nrdconta = 9269835	AND e.nrctremp = 1007227) OR
(e.cdcooper = 1	AND e.nrdconta = 9270744	AND e.nrctremp = 1618989) OR (e.cdcooper = 1	AND e.nrdconta = 9270973	AND e.nrctremp = 1295725) OR
(e.cdcooper = 1	AND e.nrdconta = 9272267	AND e.nrctremp = 1105553) OR (e.cdcooper = 1	AND e.nrdconta = 9272739	AND e.nrctremp = 997025) OR
(e.cdcooper = 1	AND e.nrdconta = 9273328	AND e.nrctremp = 1222900) OR (e.cdcooper = 1	AND e.nrdconta = 9273743	AND e.nrctremp = 1853371) OR
(e.cdcooper = 1	AND e.nrdconta = 9274863	AND e.nrctremp = 991552) OR (e.cdcooper = 1	AND e.nrdconta = 9275304	AND e.nrctremp = 978736) OR
(e.cdcooper = 1	AND e.nrdconta = 9276645	AND e.nrctremp = 1588600) OR (e.cdcooper = 1	AND e.nrdconta = 9277668	AND e.nrctremp = 189509) OR
(e.cdcooper = 1	AND e.nrdconta = 9280073	AND e.nrctremp = 985302) OR (e.cdcooper = 1	AND e.nrdconta = 9283374	AND e.nrctremp = 1590773) OR
(e.cdcooper = 1	AND e.nrdconta = 9283374	AND e.nrctremp = 1727559) OR (e.cdcooper = 1	AND e.nrdconta = 9283986	AND e.nrctremp = 161340) OR
(e.cdcooper = 1	AND e.nrdconta = 9284419	AND e.nrctremp = 1491771) OR (e.cdcooper = 1	AND e.nrdconta = 9286888	AND e.nrctremp = 1540997) OR
(e.cdcooper = 1	AND e.nrdconta = 9286918	AND e.nrctremp = 1686256) OR (e.cdcooper = 1	AND e.nrdconta = 9288430	AND e.nrctremp = 1067407) OR
(e.cdcooper = 1	AND e.nrdconta = 9292250	AND e.nrctremp = 1429211) OR (e.cdcooper = 1	AND e.nrdconta = 9292713	AND e.nrctremp = 1181593) OR
(e.cdcooper = 1	AND e.nrdconta = 9294201	AND e.nrctremp = 2104306) OR (e.cdcooper = 1	AND e.nrdconta = 9295011	AND e.nrctremp = 1317486) OR
(e.cdcooper = 1	AND e.nrdconta = 9296530	AND e.nrctremp = 1151232) OR (e.cdcooper = 1	AND e.nrdconta = 9296530	AND e.nrctremp = 1250503) OR
(e.cdcooper = 1	AND e.nrdconta = 9297502	AND e.nrctremp = 1213818) OR (e.cdcooper = 1	AND e.nrdconta = 9298428	AND e.nrctremp = 2012693) OR
(e.cdcooper = 1	AND e.nrdconta = 9301593	AND e.nrctremp = 1780483) OR (e.cdcooper = 1	AND e.nrdconta = 9301780	AND e.nrctremp = 1005748) OR
(e.cdcooper = 1	AND e.nrdconta = 9303510	AND e.nrctremp = 1479590) OR (e.cdcooper = 1	AND e.nrdconta = 9305041	AND e.nrctremp = 1324856) OR
(e.cdcooper = 1	AND e.nrdconta = 9305645	AND e.nrctremp = 1053535) OR (e.cdcooper = 1	AND e.nrdconta = 9307443	AND e.nrctremp = 1203707) OR
(e.cdcooper = 1	AND e.nrdconta = 9307931	AND e.nrctremp = 1916417) OR (e.cdcooper = 1	AND e.nrdconta = 9308610	AND e.nrctremp = 998433) OR
(e.cdcooper = 1	AND e.nrdconta = 9308768	AND e.nrctremp = 1144156) OR (e.cdcooper = 1	AND e.nrdconta = 9309128	AND e.nrctremp = 1587389) OR
(e.cdcooper = 1	AND e.nrdconta = 9309748	AND e.nrctremp = 1143651) OR (e.cdcooper = 1	AND e.nrdconta = 9311025	AND e.nrctremp = 1596455) OR
(e.cdcooper = 1	AND e.nrdconta = 9313648	AND e.nrctremp = 1589422) OR (e.cdcooper = 1	AND e.nrdconta = 9314407	AND e.nrctremp = 1297277) OR
(e.cdcooper = 1	AND e.nrdconta = 9319115	AND e.nrctremp = 1665059) OR (e.cdcooper = 1	AND e.nrdconta = 9322736	AND e.nrctremp = 1350323) OR
(e.cdcooper = 1	AND e.nrdconta = 9324224	AND e.nrctremp = 1261338) OR (e.cdcooper = 1	AND e.nrdconta = 9325328	AND e.nrctremp = 1760292) OR
(e.cdcooper = 1	AND e.nrdconta = 9326804	AND e.nrctremp = 1377704) OR (e.cdcooper = 1	AND e.nrdconta = 9329331	AND e.nrctremp = 982843) OR
(e.cdcooper = 1	AND e.nrdconta = 9330496	AND e.nrctremp = 1493689) OR (e.cdcooper = 1	AND e.nrdconta = 9330534	AND e.nrctremp = 1292301) OR
(e.cdcooper = 1	AND e.nrdconta = 9330704	AND e.nrctremp = 1551478) OR (e.cdcooper = 1	AND e.nrdconta = 9332014	AND e.nrctremp = 978032) OR
(e.cdcooper = 1	AND e.nrdconta = 9333762	AND e.nrctremp = 2012910) OR (e.cdcooper = 1	AND e.nrdconta = 9337474	AND e.nrctremp = 1313863) OR
(e.cdcooper = 1	AND e.nrdconta = 9339094	AND e.nrctremp = 2104770) OR (e.cdcooper = 1	AND e.nrdconta = 9339310	AND e.nrctremp = 969146) OR
(e.cdcooper = 1	AND e.nrdconta = 9340114	AND e.nrctremp = 1478555) OR (e.cdcooper = 1	AND e.nrdconta = 9342583	AND e.nrctremp = 1513624) OR
(e.cdcooper = 1	AND e.nrdconta = 9342974	AND e.nrctremp = 1094736) OR (e.cdcooper = 1	AND e.nrdconta = 9343440	AND e.nrctremp = 971231) OR
(e.cdcooper = 1	AND e.nrdconta = 9345752	AND e.nrctremp = 1185534) OR (e.cdcooper = 1	AND e.nrdconta = 9345990	AND e.nrctremp = 972306) OR
(e.cdcooper = 1	AND e.nrdconta = 9346660	AND e.nrctremp = 1423187) OR (e.cdcooper = 1	AND e.nrdconta = 9347356	AND e.nrctremp = 973055) OR
(e.cdcooper = 1	AND e.nrdconta = 9348964	AND e.nrctremp = 1921033) OR (e.cdcooper = 1	AND e.nrdconta = 9349693	AND e.nrctremp = 1121880) OR
(e.cdcooper = 1	AND e.nrdconta = 9349901	AND e.nrctremp = 1053445) OR (e.cdcooper = 1	AND e.nrdconta = 9350870	AND e.nrctremp = 1135109) OR
(e.cdcooper = 1	AND e.nrdconta = 9352805	AND e.nrctremp = 1513692) OR (e.cdcooper = 1	AND e.nrdconta = 9354344	AND e.nrctremp = 977320) OR
(e.cdcooper = 1	AND e.nrdconta = 9355120	AND e.nrctremp = 1077783) OR (e.cdcooper = 1	AND e.nrdconta = 9355120	AND e.nrctremp = 1440575) OR
(e.cdcooper = 1	AND e.nrdconta = 9358137	AND e.nrctremp = 1125694) OR (e.cdcooper = 1	AND e.nrdconta = 9361618	AND e.nrctremp = 1125613) OR
(e.cdcooper = 1	AND e.nrdconta = 9361677	AND e.nrctremp = 980219) OR (e.cdcooper = 1	AND e.nrdconta = 9365087	AND e.nrctremp = 982432) OR
(e.cdcooper = 1	AND e.nrdconta = 9365680	AND e.nrctremp = 1948860) OR (e.cdcooper = 1	AND e.nrdconta = 9367977	AND e.nrctremp = 1478747) OR
(e.cdcooper = 1	AND e.nrdconta = 9369872	AND e.nrctremp = 1686189) OR (e.cdcooper = 1	AND e.nrdconta = 9370544	AND e.nrctremp = 1030161) OR
(e.cdcooper = 1	AND e.nrdconta = 9372474	AND e.nrctremp = 1669099) OR (e.cdcooper = 1	AND e.nrdconta = 9372938	AND e.nrctremp = 1490455) OR
(e.cdcooper = 1	AND e.nrdconta = 9374159	AND e.nrctremp = 1354152) OR (e.cdcooper = 1	AND e.nrdconta = 9375406	AND e.nrctremp = 1108550) OR
(e.cdcooper = 1	AND e.nrdconta = 9375864	AND e.nrctremp = 1353023) OR (e.cdcooper = 1	AND e.nrdconta = 9375899	AND e.nrctremp = 1074599) OR
(e.cdcooper = 1	AND e.nrdconta = 9376488	AND e.nrctremp = 1170692) OR (e.cdcooper = 1	AND e.nrdconta = 9377603	AND e.nrctremp = 1457251) OR
(e.cdcooper = 1	AND e.nrdconta = 9377930	AND e.nrctremp = 989149) OR (e.cdcooper = 1	AND e.nrdconta = 9378332	AND e.nrctremp = 1068420) OR
(e.cdcooper = 1	AND e.nrdconta = 9378618	AND e.nrctremp = 990219) OR (e.cdcooper = 1	AND e.nrdconta = 9380256	AND e.nrctremp = 1332048) OR
(e.cdcooper = 1	AND e.nrdconta = 9381783	AND e.nrctremp = 1596503) OR (e.cdcooper = 1	AND e.nrdconta = 9382321	AND e.nrctremp = 1542031) OR
(e.cdcooper = 1	AND e.nrdconta = 9383247	AND e.nrctremp = 1073818) OR (e.cdcooper = 1	AND e.nrdconta = 9384073	AND e.nrctremp = 1230449) OR
(e.cdcooper = 1	AND e.nrdconta = 9385177	AND e.nrctremp = 1030378) OR (e.cdcooper = 1	AND e.nrdconta = 9386246	AND e.nrctremp = 1849932) OR
(e.cdcooper = 1	AND e.nrdconta = 9386831	AND e.nrctremp = 2004952) OR (e.cdcooper = 1	AND e.nrdconta = 9387161	AND e.nrctremp = 1071739) OR
(e.cdcooper = 1	AND e.nrdconta = 9388915	AND e.nrctremp = 1551446) OR (e.cdcooper = 1	AND e.nrdconta = 9392254	AND e.nrctremp = 2104812) OR
(e.cdcooper = 1	AND e.nrdconta = 9393870	AND e.nrctremp = 1034265) OR (e.cdcooper = 1	AND e.nrdconta = 9394052	AND e.nrctremp = 1248686) OR
(e.cdcooper = 1	AND e.nrdconta = 9394230	AND e.nrctremp = 1056956) OR (e.cdcooper = 1	AND e.nrdconta = 9395210	AND e.nrctremp = 1409155) OR
(e.cdcooper = 1	AND e.nrdconta = 9395504	AND e.nrctremp = 1444014) OR (e.cdcooper = 1	AND e.nrdconta = 9395580	AND e.nrctremp = 1214486) OR
(e.cdcooper = 1	AND e.nrdconta = 9398457	AND e.nrctremp = 1100592) OR (e.cdcooper = 1	AND e.nrdconta = 9399607	AND e.nrctremp = 1031700) OR
(e.cdcooper = 1	AND e.nrdconta = 9399976	AND e.nrctremp = 1885089) OR (e.cdcooper = 1	AND e.nrdconta = 9399992	AND e.nrctremp = 1000258) OR
(e.cdcooper = 1	AND e.nrdconta = 9402071	AND e.nrctremp = 1165622) OR (e.cdcooper = 1	AND e.nrdconta = 9402675	AND e.nrctremp = 1006258) OR
(e.cdcooper = 1	AND e.nrdconta = 9404538	AND e.nrctremp = 1196905) OR (e.cdcooper = 1	AND e.nrdconta = 9405798	AND e.nrctremp = 1173084) OR
(e.cdcooper = 1	AND e.nrdconta = 9407774	AND e.nrctremp = 1599893) OR (e.cdcooper = 1	AND e.nrdconta = 9408614	AND e.nrctremp = 1350100) OR
(e.cdcooper = 1	AND e.nrdconta = 9408746	AND e.nrctremp = 1324769) OR (e.cdcooper = 1	AND e.nrdconta = 9408851	AND e.nrctremp = 1723172) OR
(e.cdcooper = 1	AND e.nrdconta = 9408940	AND e.nrctremp = 1599798) OR (e.cdcooper = 1	AND e.nrdconta = 9409564	AND e.nrctremp = 1336705) OR
(e.cdcooper = 1	AND e.nrdconta = 9410457	AND e.nrctremp = 1428829) OR (e.cdcooper = 1	AND e.nrdconta = 9412611	AND e.nrctremp = 1213777) OR
(e.cdcooper = 1	AND e.nrdconta = 9412760	AND e.nrctremp = 1957429) OR (e.cdcooper = 1	AND e.nrdconta = 9413383	AND e.nrctremp = 1202635) OR
(e.cdcooper = 1	AND e.nrdconta = 9413448	AND e.nrctremp = 1103507) OR (e.cdcooper = 1	AND e.nrdconta = 9413880	AND e.nrctremp = 1285605) OR
(e.cdcooper = 1	AND e.nrdconta = 9414983	AND e.nrctremp = 1007379) OR (e.cdcooper = 1	AND e.nrdconta = 9418091	AND e.nrctremp = 1425426) OR
(e.cdcooper = 1	AND e.nrdconta = 9418431	AND e.nrctremp = 1240164) OR (e.cdcooper = 1	AND e.nrdconta = 9418679	AND e.nrctremp = 1061195) OR
(e.cdcooper = 1	AND e.nrdconta = 9418733	AND e.nrctremp = 1057677) OR (e.cdcooper = 1	AND e.nrdconta = 9419900	AND e.nrctremp = 1027498) OR
(e.cdcooper = 1	AND e.nrdconta = 9420657	AND e.nrctremp = 1011708) OR (e.cdcooper = 1	AND e.nrdconta = 9421670	AND e.nrctremp = 1587418) OR
(e.cdcooper = 1	AND e.nrdconta = 9421963	AND e.nrctremp = 1340524) OR (e.cdcooper = 1	AND e.nrdconta = 9423915	AND e.nrctremp = 1587403) OR
(e.cdcooper = 1	AND e.nrdconta = 9424288	AND e.nrctremp = 1014412) OR (e.cdcooper = 1	AND e.nrdconta = 9432388	AND e.nrctremp = 1181698) OR
(e.cdcooper = 1	AND e.nrdconta = 9435409	AND e.nrctremp = 1527403) OR (e.cdcooper = 1	AND e.nrdconta = 9436286	AND e.nrctremp = 1587421) OR
(e.cdcooper = 1	AND e.nrdconta = 9436359	AND e.nrctremp = 1198372) OR (e.cdcooper = 1	AND e.nrdconta = 9436952	AND e.nrctremp = 1390597) OR
(e.cdcooper = 1	AND e.nrdconta = 9437967	AND e.nrctremp = 1083212) OR (e.cdcooper = 1	AND e.nrdconta = 9437991	AND e.nrctremp = 2013059) OR
(e.cdcooper = 1	AND e.nrdconta = 9438017	AND e.nrctremp = 1527742) OR (e.cdcooper = 1	AND e.nrdconta = 9439838	AND e.nrctremp = 1248584) OR
(e.cdcooper = 1	AND e.nrdconta = 9442332	AND e.nrctremp = 1021463) OR (e.cdcooper = 1	AND e.nrdconta = 9443053	AND e.nrctremp = 1513957) OR
(e.cdcooper = 1	AND e.nrdconta = 9444653	AND e.nrctremp = 1143534) OR (e.cdcooper = 1	AND e.nrdconta = 9445595	AND e.nrctremp = 1029221) OR
(e.cdcooper = 1	AND e.nrdconta = 9446079	AND e.nrctremp = 1551553) OR (e.cdcooper = 1	AND e.nrdconta = 9447610	AND e.nrctremp = 1166686) OR
(e.cdcooper = 1	AND e.nrdconta = 9448330	AND e.nrctremp = 1513943) OR (e.cdcooper = 1	AND e.nrdconta = 9449523	AND e.nrctremp = 1334203) OR
(e.cdcooper = 1	AND e.nrdconta = 9452060	AND e.nrctremp = 1047983) OR (e.cdcooper = 1	AND e.nrdconta = 9452109	AND e.nrctremp = 1492213) OR
(e.cdcooper = 1	AND e.nrdconta = 9452788	AND e.nrctremp = 1682642) OR (e.cdcooper = 1	AND e.nrdconta = 9453296	AND e.nrctremp = 1379003) OR
(e.cdcooper = 1	AND e.nrdconta = 9457364	AND e.nrctremp = 1348585) OR (e.cdcooper = 1	AND e.nrdconta = 9458018	AND e.nrctremp = 1262322) OR
(e.cdcooper = 1	AND e.nrdconta = 9458107	AND e.nrctremp = 1775762) OR (e.cdcooper = 1	AND e.nrdconta = 9459391	AND e.nrctremp = 1583829) OR
(e.cdcooper = 1	AND e.nrdconta = 9459553	AND e.nrctremp = 1531932) OR (e.cdcooper = 1	AND e.nrdconta = 9459871	AND e.nrctremp = 1437789) OR
(e.cdcooper = 1	AND e.nrdconta = 9459880	AND e.nrctremp = 2013014) OR (e.cdcooper = 1	AND e.nrdconta = 9460438	AND e.nrctremp = 1587532) OR
(e.cdcooper = 1	AND e.nrdconta = 9460624	AND e.nrctremp = 1071945) OR (e.cdcooper = 1	AND e.nrdconta = 9464247	AND e.nrctremp = 1257302) OR
(e.cdcooper = 1	AND e.nrdconta = 9465073	AND e.nrctremp = 2012999) OR (e.cdcooper = 1	AND e.nrdconta = 9466118	AND e.nrctremp = 1328457) OR
(e.cdcooper = 1	AND e.nrdconta = 9466290	AND e.nrctremp = 1719470) OR (e.cdcooper = 1	AND e.nrdconta = 9466959	AND e.nrctremp = 1044464) OR
(e.cdcooper = 1	AND e.nrdconta = 9468714	AND e.nrctremp = 1042420) OR (e.cdcooper = 1	AND e.nrdconta = 9469125	AND e.nrctremp = 1574356) OR
(e.cdcooper = 1	AND e.nrdconta = 9473530	AND e.nrctremp = 1583813) OR (e.cdcooper = 1	AND e.nrdconta = 9474242	AND e.nrctremp = 1849044) OR
(e.cdcooper = 1	AND e.nrdconta = 9474471	AND e.nrctremp = 1587534) OR (e.cdcooper = 1	AND e.nrdconta = 9474714	AND e.nrctremp = 1039189) OR
(e.cdcooper = 1	AND e.nrdconta = 9474870	AND e.nrctremp = 1042947) OR (e.cdcooper = 1	AND e.nrdconta = 9475656	AND e.nrctremp = 1041783) OR
(e.cdcooper = 1	AND e.nrdconta = 9475974	AND e.nrctremp = 1188565) OR (e.cdcooper = 1	AND e.nrdconta = 9476113	AND e.nrctremp = 1272771) OR
(e.cdcooper = 1	AND e.nrdconta = 9476628	AND e.nrctremp = 1688159) OR (e.cdcooper = 1	AND e.nrdconta = 9477187	AND e.nrctremp = 1126116) OR
(e.cdcooper = 1	AND e.nrdconta = 9479139	AND e.nrctremp = 1596452) OR (e.cdcooper = 1	AND e.nrdconta = 9479694	AND e.nrctremp = 1042192) OR
(e.cdcooper = 1	AND e.nrdconta = 9479902	AND e.nrctremp = 1853240) OR (e.cdcooper = 1	AND e.nrdconta = 9481842	AND e.nrctremp = 1313259) OR
(e.cdcooper = 1	AND e.nrdconta = 9483616	AND e.nrctremp = 1696675) OR (e.cdcooper = 1	AND e.nrdconta = 9484612	AND e.nrctremp = 1551797) OR
(e.cdcooper = 1	AND e.nrdconta = 9493620	AND e.nrctremp = 1724064) OR (e.cdcooper = 1	AND e.nrdconta = 9496955	AND e.nrctremp = 1049482) OR
(e.cdcooper = 1	AND e.nrdconta = 9497102	AND e.nrctremp = 1196794) OR (e.cdcooper = 1	AND e.nrdconta = 9499300	AND e.nrctremp = 1587430) OR
(e.cdcooper = 1	AND e.nrdconta = 9500308	AND e.nrctremp = 1051109) OR (e.cdcooper = 1	AND e.nrdconta = 9502009	AND e.nrctremp = 66791) OR
(e.cdcooper = 1	AND e.nrdconta = 9502106	AND e.nrctremp = 1596235) OR (e.cdcooper = 1	AND e.nrdconta = 9503170	AND e.nrctremp = 1340422) OR
(e.cdcooper = 1	AND e.nrdconta = 9513027	AND e.nrctremp = 1378874) OR (e.cdcooper = 1	AND e.nrdconta = 9513140	AND e.nrctremp = 1646355) OR
(e.cdcooper = 1	AND e.nrdconta = 9514376	AND e.nrctremp = 1211185) OR (e.cdcooper = 1	AND e.nrdconta = 9514376	AND e.nrctremp = 1921339) OR
(e.cdcooper = 1	AND e.nrdconta = 9514864	AND e.nrctremp = 1137326) OR (e.cdcooper = 1	AND e.nrdconta = 9515372	AND e.nrctremp = 1320242) OR
(e.cdcooper = 1	AND e.nrdconta = 9515623	AND e.nrctremp = 2104589) OR (e.cdcooper = 1	AND e.nrdconta = 9516182	AND e.nrctremp = 1396581) OR
(e.cdcooper = 1	AND e.nrdconta = 9516280	AND e.nrctremp = 1209711) OR (e.cdcooper = 1	AND e.nrdconta = 9516743	AND e.nrctremp = 1221608) OR
(e.cdcooper = 1	AND e.nrdconta = 9517081	AND e.nrctremp = 1177645) OR (e.cdcooper = 1	AND e.nrdconta = 9517642	AND e.nrctremp = 1485289) OR
(e.cdcooper = 1	AND e.nrdconta = 9519440	AND e.nrctremp = 1396675) OR (e.cdcooper = 1	AND e.nrdconta = 9521240	AND e.nrctremp = 1355715) OR
(e.cdcooper = 1	AND e.nrdconta = 9521828	AND e.nrctremp = 1269721) OR (e.cdcooper = 1	AND e.nrdconta = 9523685	AND e.nrctremp = 1577746) OR
(e.cdcooper = 1	AND e.nrdconta = 9527826	AND e.nrctremp = 1319695) OR (e.cdcooper = 1	AND e.nrdconta = 9528962	AND e.nrctremp = 1270871) OR
(e.cdcooper = 1	AND e.nrdconta = 9529624	AND e.nrctremp = 1138001) OR (e.cdcooper = 1	AND e.nrdconta = 9530711	AND e.nrctremp = 2040029) OR
(e.cdcooper = 1	AND e.nrdconta = 9532412	AND e.nrctremp = 1853737) OR (e.cdcooper = 1	AND e.nrdconta = 9533974	AND e.nrctremp = 1230180) OR
(e.cdcooper = 1	AND e.nrdconta = 9539000	AND e.nrctremp = 1374598) OR (e.cdcooper = 1	AND e.nrdconta = 9543643	AND e.nrctremp = 102639) OR
(e.cdcooper = 1	AND e.nrdconta = 9546553	AND e.nrctremp = 1530775) OR (e.cdcooper = 1	AND e.nrdconta = 9548033	AND e.nrctremp = 1378883) OR
(e.cdcooper = 1	AND e.nrdconta = 9549609	AND e.nrctremp = 1126041) OR (e.cdcooper = 1	AND e.nrdconta = 9554882	AND e.nrctremp = 1952830) OR
(e.cdcooper = 1	AND e.nrdconta = 9555056	AND e.nrctremp = 1366937) OR (e.cdcooper = 1	AND e.nrdconta = 9558829	AND e.nrctremp = 1586967) OR
(e.cdcooper = 1	AND e.nrdconta = 9558969	AND e.nrctremp = 1583817) OR (e.cdcooper = 1	AND e.nrdconta = 9560017	AND e.nrctremp = 2004954) OR
(e.cdcooper = 1	AND e.nrdconta = 9563652	AND e.nrctremp = 1655119) OR (e.cdcooper = 1	AND e.nrdconta = 9563741	AND e.nrctremp = 1696764) OR
(e.cdcooper = 1	AND e.nrdconta = 9563830	AND e.nrctremp = 1654789) OR (e.cdcooper = 1	AND e.nrdconta = 9564799	AND e.nrctremp = 1853254) OR
(e.cdcooper = 1	AND e.nrdconta = 9564810	AND e.nrctremp = 1268991) OR (e.cdcooper = 1	AND e.nrdconta = 9571477	AND e.nrctremp = 1086513) OR
(e.cdcooper = 1	AND e.nrdconta = 9573224	AND e.nrctremp = 1213319) OR (e.cdcooper = 1	AND e.nrdconta = 9575944	AND e.nrctremp = 1325007) OR
(e.cdcooper = 1	AND e.nrdconta = 9576347	AND e.nrctremp = 1177935) OR (e.cdcooper = 1	AND e.nrdconta = 9576525	AND e.nrctremp = 1089108) OR
(e.cdcooper = 1	AND e.nrdconta = 9578641	AND e.nrctremp = 1587372) OR (e.cdcooper = 1	AND e.nrdconta = 9580050	AND e.nrctremp = 1097986) OR
(e.cdcooper = 1	AND e.nrdconta = 9580700	AND e.nrctremp = 1583855) OR (e.cdcooper = 1	AND e.nrdconta = 9585303	AND e.nrctremp = 1696274) OR
(e.cdcooper = 1	AND e.nrdconta = 9586547	AND e.nrctremp = 1491778) OR (e.cdcooper = 1	AND e.nrdconta = 9586598	AND e.nrctremp = 1365626) OR
(e.cdcooper = 1	AND e.nrdconta = 9590153	AND e.nrctremp = 1429664) OR (e.cdcooper = 1	AND e.nrdconta = 9590277	AND e.nrctremp = 1248637) OR
(e.cdcooper = 1	AND e.nrdconta = 9590536	AND e.nrctremp = 1493740) OR (e.cdcooper = 1	AND e.nrdconta = 9590943	AND e.nrctremp = 1354145) OR
(e.cdcooper = 1	AND e.nrdconta = 9591338	AND e.nrctremp = 1098135) OR (e.cdcooper = 1	AND e.nrdconta = 9593101	AND e.nrctremp = 1885137) OR
(e.cdcooper = 1	AND e.nrdconta = 9593225	AND e.nrctremp = 1362778) OR (e.cdcooper = 1	AND e.nrdconta = 9594817	AND e.nrctremp = 1378984) OR
(e.cdcooper = 1	AND e.nrdconta = 9595872	AND e.nrctremp = 2040016) OR (e.cdcooper = 1	AND e.nrdconta = 9596038	AND e.nrctremp = 1587392) OR
(e.cdcooper = 1	AND e.nrdconta = 9598022	AND e.nrctremp = 1775434) OR (e.cdcooper = 1	AND e.nrdconta = 9598308	AND e.nrctremp = 1474523) OR
(e.cdcooper = 1	AND e.nrdconta = 9599061	AND e.nrctremp = 1619230) OR (e.cdcooper = 1	AND e.nrdconta = 9600264	AND e.nrctremp = 1198586) OR
(e.cdcooper = 1	AND e.nrdconta = 9601600	AND e.nrctremp = 1456062) OR (e.cdcooper = 1	AND e.nrdconta = 9602615	AND e.nrctremp = 1794828) OR
(e.cdcooper = 1	AND e.nrdconta = 9602739	AND e.nrctremp = 1103299) OR (e.cdcooper = 1	AND e.nrdconta = 9603832	AND e.nrctremp = 1409269) OR
(e.cdcooper = 1	AND e.nrdconta = 9604162	AND e.nrctremp = 1102445) OR (e.cdcooper = 1	AND e.nrdconta = 9605169	AND e.nrctremp = 1853236) OR
(e.cdcooper = 1	AND e.nrdconta = 9605541	AND e.nrctremp = 1219623) OR (e.cdcooper = 1	AND e.nrdconta = 9605622	AND e.nrctremp = 1103977) OR
(e.cdcooper = 1	AND e.nrdconta = 9606734	AND e.nrctremp = 1241336) OR (e.cdcooper = 1	AND e.nrdconta = 9614532	AND e.nrctremp = 1267810) OR
(e.cdcooper = 1	AND e.nrdconta = 9614966	AND e.nrctremp = 1619565) OR (e.cdcooper = 1	AND e.nrdconta = 9615954	AND e.nrctremp = 1879017) OR
(e.cdcooper = 1	AND e.nrdconta = 9616853	AND e.nrctremp = 2040046) OR (e.cdcooper = 1	AND e.nrdconta = 9618490	AND e.nrctremp = 1600346) OR
(e.cdcooper = 1	AND e.nrdconta = 9619798	AND e.nrctremp = 1393171) OR (e.cdcooper = 1	AND e.nrdconta = 9620184	AND e.nrctremp = 1629856) OR
(e.cdcooper = 1	AND e.nrdconta = 9621288	AND e.nrctremp = 1609498) OR (e.cdcooper = 1	AND e.nrdconta = 9622357	AND e.nrctremp = 1596509) OR
(e.cdcooper = 1	AND e.nrdconta = 9622543	AND e.nrctremp = 1125360) OR (e.cdcooper = 1	AND e.nrdconta = 9622900	AND e.nrctremp = 1133851) OR
(e.cdcooper = 1	AND e.nrdconta = 9624910	AND e.nrctremp = 2104288) OR (e.cdcooper = 1	AND e.nrdconta = 9625119	AND e.nrctremp = 1115260) OR
(e.cdcooper = 1	AND e.nrdconta = 9627332	AND e.nrctremp = 1437803) OR (e.cdcooper = 1	AND e.nrdconta = 9628029	AND e.nrctremp = 170944) OR
(e.cdcooper = 1	AND e.nrdconta = 9628614	AND e.nrctremp = 1294522) OR (e.cdcooper = 1	AND e.nrdconta = 9628630	AND e.nrctremp = 1655029) OR
(e.cdcooper = 1	AND e.nrdconta = 9630309	AND e.nrctremp = 1294746) OR (e.cdcooper = 1	AND e.nrdconta = 9632263	AND e.nrctremp = 1117417) OR
(e.cdcooper = 1	AND e.nrdconta = 9632999	AND e.nrctremp = 1369878) OR (e.cdcooper = 1	AND e.nrdconta = 9633154	AND e.nrctremp = 1587474) OR
(e.cdcooper = 1	AND e.nrdconta = 9634460	AND e.nrctremp = 1122934) OR (e.cdcooper = 1	AND e.nrdconta = 9636145	AND e.nrctremp = 1249356) OR
(e.cdcooper = 1	AND e.nrdconta = 9636145	AND e.nrctremp = 2104386) OR (e.cdcooper = 1	AND e.nrdconta = 9637559	AND e.nrctremp = 1587379) OR
(e.cdcooper = 1	AND e.nrdconta = 9638474	AND e.nrctremp = 1355716) OR (e.cdcooper = 1	AND e.nrdconta = 9641211	AND e.nrctremp = 1126542) OR
(e.cdcooper = 1	AND e.nrdconta = 9641777	AND e.nrctremp = 1324764) OR (e.cdcooper = 1	AND e.nrdconta = 9642919	AND e.nrctremp = 1174987) OR
(e.cdcooper = 1	AND e.nrdconta = 9644920	AND e.nrctremp = 1617364) OR (e.cdcooper = 1	AND e.nrdconta = 9647279	AND e.nrctremp = 2039794) OR
(e.cdcooper = 1	AND e.nrdconta = 9648372	AND e.nrctremp = 1775601) OR (e.cdcooper = 1	AND e.nrdconta = 9648860	AND e.nrctremp = 2432605) OR
(e.cdcooper = 1	AND e.nrdconta = 9652078	AND e.nrctremp = 1414600) OR (e.cdcooper = 1	AND e.nrdconta = 9653112	AND e.nrctremp = 1517250) OR
(e.cdcooper = 1	AND e.nrdconta = 9656634	AND e.nrctremp = 1231326) OR (e.cdcooper = 1	AND e.nrdconta = 9658220	AND e.nrctremp = 1140142) OR
(e.cdcooper = 1	AND e.nrdconta = 9659641	AND e.nrctremp = 1513619) OR (e.cdcooper = 1	AND e.nrdconta = 9660470	AND e.nrctremp = 1155134) OR
(e.cdcooper = 1	AND e.nrdconta = 9660470	AND e.nrctremp = 2194869) OR (e.cdcooper = 1	AND e.nrdconta = 9660810	AND e.nrctremp = 1587296) OR
(e.cdcooper = 1	AND e.nrdconta = 9662413	AND e.nrctremp = 1267813) OR (e.cdcooper = 1	AND e.nrdconta = 9667660	AND e.nrctremp = 1465415) OR
(e.cdcooper = 1	AND e.nrdconta = 9667814	AND e.nrctremp = 1467629) OR (e.cdcooper = 1	AND e.nrdconta = 9668870	AND e.nrctremp = 1283286) OR
(e.cdcooper = 1	AND e.nrdconta = 9673440	AND e.nrctremp = 1385146) OR (e.cdcooper = 1	AND e.nrdconta = 9673881	AND e.nrctremp = 1878985) OR
(e.cdcooper = 1	AND e.nrdconta = 9677461	AND e.nrctremp = 1324941) OR (e.cdcooper = 1	AND e.nrdconta = 9679723	AND e.nrctremp = 1147011) OR
(e.cdcooper = 1	AND e.nrdconta = 9680306	AND e.nrctremp = 1330089) OR (e.cdcooper = 1	AND e.nrdconta = 9680306	AND e.nrctremp = 1440711) OR
(e.cdcooper = 1	AND e.nrdconta = 9680306	AND e.nrctremp = 1587363) OR (e.cdcooper = 1	AND e.nrdconta = 9684468	AND e.nrctremp = 1348630) OR
(e.cdcooper = 1	AND e.nrdconta = 9687203	AND e.nrctremp = 1146282) OR (e.cdcooper = 1	AND e.nrdconta = 9690263	AND e.nrctremp = 1229304) OR
(e.cdcooper = 1	AND e.nrdconta = 9690581	AND e.nrctremp = 1331545) OR (e.cdcooper = 1	AND e.nrdconta = 9691863	AND e.nrctremp = 1614806) OR
(e.cdcooper = 1	AND e.nrdconta = 9692649	AND e.nrctremp = 1551848) OR (e.cdcooper = 1	AND e.nrdconta = 9695915	AND e.nrctremp = 1478065) OR
(e.cdcooper = 1	AND e.nrdconta = 9696326	AND e.nrctremp = 1409203) OR (e.cdcooper = 1	AND e.nrdconta = 9697896	AND e.nrctremp = 1152390) OR
(e.cdcooper = 1	AND e.nrdconta = 9700307	AND e.nrctremp = 1156139) OR (e.cdcooper = 1	AND e.nrdconta = 9702440	AND e.nrctremp = 1916370) OR
(e.cdcooper = 1	AND e.nrdconta = 9702474	AND e.nrctremp = 1677804) OR (e.cdcooper = 1	AND e.nrdconta = 9702903	AND e.nrctremp = 1551769) OR
(e.cdcooper = 1	AND e.nrdconta = 9703179	AND e.nrctremp = 1281480) OR (e.cdcooper = 1	AND e.nrdconta = 9704450	AND e.nrctremp = 1455310) OR
(e.cdcooper = 1	AND e.nrdconta = 9708030	AND e.nrctremp = 1634397) OR (e.cdcooper = 1	AND e.nrdconta = 9710930	AND e.nrctremp = 1413680) OR
(e.cdcooper = 1	AND e.nrdconta = 9714588	AND e.nrctremp = 1161704) OR (e.cdcooper = 1	AND e.nrdconta = 9714588	AND e.nrctremp = 1654642) OR
(e.cdcooper = 1	AND e.nrdconta = 9715444	AND e.nrctremp = 1201847) OR (e.cdcooper = 1	AND e.nrdconta = 9716815	AND e.nrctremp = 1587123) OR
(e.cdcooper = 1	AND e.nrdconta = 9718990	AND e.nrctremp = 2012696) OR (e.cdcooper = 1	AND e.nrdconta = 9719156	AND e.nrctremp = 1297643) OR
(e.cdcooper = 1	AND e.nrdconta = 9722335	AND e.nrctremp = 2012894) OR (e.cdcooper = 1	AND e.nrdconta = 9724486	AND e.nrctremp = 1166614) OR
(e.cdcooper = 1	AND e.nrdconta = 9725806	AND e.nrctremp = 1357940) OR (e.cdcooper = 1	AND e.nrdconta = 9725806	AND e.nrctremp = 1524384) OR
(e.cdcooper = 1	AND e.nrdconta = 9727493	AND e.nrctremp = 1853259) OR (e.cdcooper = 1	AND e.nrdconta = 9729437	AND e.nrctremp = 1389609) OR
(e.cdcooper = 1	AND e.nrdconta = 9729569	AND e.nrctremp = 1243187) OR (e.cdcooper = 1	AND e.nrdconta = 9729569	AND e.nrctremp = 1724099) OR
(e.cdcooper = 1	AND e.nrdconta = 9732268	AND e.nrctremp = 2145127) OR (e.cdcooper = 1	AND e.nrdconta = 9736573	AND e.nrctremp = 1591573) OR
(e.cdcooper = 1	AND e.nrdconta = 9740058	AND e.nrctremp = 2432601) OR (e.cdcooper = 1	AND e.nrdconta = 9742220	AND e.nrctremp = 1619331) OR
(e.cdcooper = 1	AND e.nrdconta = 9744576	AND e.nrctremp = 1408213) OR (e.cdcooper = 1	AND e.nrdconta = 9744894	AND e.nrctremp = 1849910) OR
(e.cdcooper = 1	AND e.nrdconta = 9746170	AND e.nrctremp = 1179610) OR (e.cdcooper = 1	AND e.nrdconta = 9746447	AND e.nrctremp = 1813672) OR
(e.cdcooper = 1	AND e.nrdconta = 9747699	AND e.nrctremp = 1179166) OR (e.cdcooper = 1	AND e.nrdconta = 9749195	AND e.nrctremp = 1180306) OR
(e.cdcooper = 1	AND e.nrdconta = 9749195	AND e.nrctremp = 1545731) OR (e.cdcooper = 1	AND e.nrdconta = 9755420	AND e.nrctremp = 1432633) OR
(e.cdcooper = 1	AND e.nrdconta = 9765301	AND e.nrctremp = 1225517) OR (e.cdcooper = 1	AND e.nrdconta = 9768815	AND e.nrctremp = 1583861) OR
(e.cdcooper = 1	AND e.nrdconta = 9769501	AND e.nrctremp = 1379621) OR (e.cdcooper = 1	AND e.nrdconta = 9769544	AND e.nrctremp = 1921206) OR
(e.cdcooper = 1	AND e.nrdconta = 9772103	AND e.nrctremp = 1505312) OR (e.cdcooper = 1	AND e.nrdconta = 9774750	AND e.nrctremp = 1209303) OR
(e.cdcooper = 1	AND e.nrdconta = 9775625	AND e.nrctremp = 1499909) OR (e.cdcooper = 1	AND e.nrdconta = 9775722	AND e.nrctremp = 1921304) OR
(e.cdcooper = 1	AND e.nrdconta = 9777431	AND e.nrctremp = 1587466) OR (e.cdcooper = 1	AND e.nrdconta = 9777890	AND e.nrctremp = 1195151) OR
(e.cdcooper = 1	AND e.nrdconta = 9778624	AND e.nrctremp = 1976991) OR (e.cdcooper = 1	AND e.nrdconta = 9779612	AND e.nrctremp = 1290610) OR
(e.cdcooper = 1	AND e.nrdconta = 9780718	AND e.nrctremp = 1835412) OR (e.cdcooper = 1	AND e.nrdconta = 9781382	AND e.nrctremp = 1531736) OR
(e.cdcooper = 1	AND e.nrdconta = 9785400	AND e.nrctremp = 1468553) OR (e.cdcooper = 1	AND e.nrdconta = 9788352	AND e.nrctremp = 1619327) OR
(e.cdcooper = 1	AND e.nrdconta = 9788611	AND e.nrctremp = 1259720) OR (e.cdcooper = 1	AND e.nrdconta = 9789510	AND e.nrctremp = 1351131) OR
(e.cdcooper = 1	AND e.nrdconta = 9789669	AND e.nrctremp = 1949341) OR (e.cdcooper = 1	AND e.nrdconta = 9794484	AND e.nrctremp = 1531873) OR
(e.cdcooper = 1	AND e.nrdconta = 9794743	AND e.nrctremp = 1255737) OR (e.cdcooper = 1	AND e.nrdconta = 9794913	AND e.nrctremp = 1205694) OR
(e.cdcooper = 1	AND e.nrdconta = 9795510	AND e.nrctremp = 1310189) OR (e.cdcooper = 1	AND e.nrdconta = 9796258	AND e.nrctremp = 1240141) OR
(e.cdcooper = 1	AND e.nrdconta = 9796495	AND e.nrctremp = 1247270) OR (e.cdcooper = 1	AND e.nrdconta = 9802762	AND e.nrctremp = 1656487) OR
(e.cdcooper = 1	AND e.nrdconta = 9808108	AND e.nrctremp = 1417455) OR (e.cdcooper = 1	AND e.nrdconta = 9812210	AND e.nrctremp = 1885124) OR
(e.cdcooper = 1	AND e.nrdconta = 9814051	AND e.nrctremp = 1225344) OR (e.cdcooper = 1	AND e.nrdconta = 9814175	AND e.nrctremp = 1727620) OR
(e.cdcooper = 1	AND e.nrdconta = 9815635	AND e.nrctremp = 1654653) OR (e.cdcooper = 1	AND e.nrdconta = 9817280	AND e.nrctremp = 1436673) OR
(e.cdcooper = 1	AND e.nrdconta = 9818030	AND e.nrctremp = 1218725) OR (e.cdcooper = 1	AND e.nrdconta = 9818405	AND e.nrctremp = 1274590) OR
(e.cdcooper = 1	AND e.nrdconta = 9820477	AND e.nrctremp = 1515551) OR (e.cdcooper = 1	AND e.nrdconta = 9821074	AND e.nrctremp = 1219622) OR
(e.cdcooper = 1	AND e.nrdconta = 9822070	AND e.nrctremp = 1527467) OR (e.cdcooper = 1	AND e.nrdconta = 9823840	AND e.nrctremp = 1617380) OR
(e.cdcooper = 1	AND e.nrdconta = 9826327	AND e.nrctremp = 1614851) OR (e.cdcooper = 1	AND e.nrdconta = 9828524	AND e.nrctremp = 1853638) OR
(e.cdcooper = 1	AND e.nrdconta = 9836403	AND e.nrctremp = 1523910) OR (e.cdcooper = 1	AND e.nrdconta = 9839844	AND e.nrctremp = 1775761) OR
(e.cdcooper = 1	AND e.nrdconta = 9842357	AND e.nrctremp = 1433563) OR (e.cdcooper = 1	AND e.nrdconta = 9842357	AND e.nrctremp = 1654999) OR
(e.cdcooper = 1	AND e.nrdconta = 9847782	AND e.nrctremp = 1230856) OR (e.cdcooper = 1	AND e.nrdconta = 9847782	AND e.nrctremp = 1478438) OR
(e.cdcooper = 1	AND e.nrdconta = 9849920	AND e.nrctremp = 1394408) OR (e.cdcooper = 1	AND e.nrdconta = 9856544	AND e.nrctremp = 1227584) OR
(e.cdcooper = 1	AND e.nrdconta = 9856609	AND e.nrctremp = 1879011) OR (e.cdcooper = 1	AND e.nrdconta = 9858679	AND e.nrctremp = 2104601) OR
(e.cdcooper = 1	AND e.nrdconta = 9863125	AND e.nrctremp = 1547946) OR (e.cdcooper = 1	AND e.nrdconta = 9863524	AND e.nrctremp = 1231651) OR
(e.cdcooper = 1	AND e.nrdconta = 9863680	AND e.nrctremp = 1262235) OR (e.cdcooper = 1	AND e.nrdconta = 9863729	AND e.nrctremp = 1654838) OR
(e.cdcooper = 1	AND e.nrdconta = 9865470	AND e.nrctremp = 1596463) OR (e.cdcooper = 1	AND e.nrdconta = 9869298	AND e.nrctremp = 1234505) OR
(e.cdcooper = 1	AND e.nrdconta = 9872426	AND e.nrctremp = 1355767) OR (e.cdcooper = 1	AND e.nrdconta = 9873465	AND e.nrctremp = 1361851) OR
(e.cdcooper = 1	AND e.nrdconta = 9876090	AND e.nrctremp = 1648492) OR (e.cdcooper = 1	AND e.nrdconta = 9879870	AND e.nrctremp = 1587509) OR
(e.cdcooper = 1	AND e.nrdconta = 9880313	AND e.nrctremp = 1794771) OR (e.cdcooper = 1	AND e.nrdconta = 9881042	AND e.nrctremp = 2012726) OR
(e.cdcooper = 1	AND e.nrdconta = 9882243	AND e.nrctremp = 1853617) OR (e.cdcooper = 1	AND e.nrdconta = 9891994	AND e.nrctremp = 1775292) OR
(e.cdcooper = 1	AND e.nrdconta = 9893288	AND e.nrctremp = 1547651) OR (e.cdcooper = 1	AND e.nrdconta = 9895027	AND e.nrctremp = 1394228) OR
(e.cdcooper = 1	AND e.nrdconta = 9895442	AND e.nrctremp = 1245907) OR (e.cdcooper = 1	AND e.nrdconta = 9897810	AND e.nrctremp = 1317814) OR
(e.cdcooper = 1	AND e.nrdconta = 9898190	AND e.nrctremp = 1247229) OR (e.cdcooper = 1	AND e.nrdconta = 9898247	AND e.nrctremp = 1596243) OR
(e.cdcooper = 1	AND e.nrdconta = 9898735	AND e.nrctremp = 1586611) OR (e.cdcooper = 1	AND e.nrdconta = 9900462	AND e.nrctremp = 1332312) OR
(e.cdcooper = 1	AND e.nrdconta = 9901647	AND e.nrctremp = 1587253) OR (e.cdcooper = 1	AND e.nrdconta = 9902651	AND e.nrctremp = 1587483) OR
(e.cdcooper = 1	AND e.nrdconta = 9908854	AND e.nrctremp = 1466261) OR (e.cdcooper = 1	AND e.nrdconta = 9911677	AND e.nrctremp = 1850008) OR
(e.cdcooper = 1	AND e.nrdconta = 9912940	AND e.nrctremp = 1596450) OR (e.cdcooper = 1	AND e.nrdconta = 9913700	AND e.nrctremp = 1324671) OR
(e.cdcooper = 1	AND e.nrdconta = 9920161	AND e.nrctremp = 1557611) OR (e.cdcooper = 1	AND e.nrdconta = 9921257	AND e.nrctremp = 2104497) OR
(e.cdcooper = 1	AND e.nrdconta = 9923284	AND e.nrctremp = 2039842) OR (e.cdcooper = 1	AND e.nrdconta = 9925104	AND e.nrctremp = 1480162) OR
(e.cdcooper = 1	AND e.nrdconta = 9928014	AND e.nrctremp = 1379020) OR (e.cdcooper = 1	AND e.nrdconta = 9930574	AND e.nrctremp = 1263475) OR
(e.cdcooper = 1	AND e.nrdconta = 9931511	AND e.nrctremp = 1339436) OR (e.cdcooper = 1	AND e.nrdconta = 9931686	AND e.nrctremp = 1879006) OR
(e.cdcooper = 1	AND e.nrdconta = 9933719	AND e.nrctremp = 2012708) OR (e.cdcooper = 1	AND e.nrdconta = 9936483	AND e.nrctremp = 1293829) OR
(e.cdcooper = 1	AND e.nrdconta = 9937617	AND e.nrctremp = 1372910) OR (e.cdcooper = 1	AND e.nrdconta = 9938311	AND e.nrctremp = 2585646) OR
(e.cdcooper = 1	AND e.nrdconta = 9941703	AND e.nrctremp = 2039854) OR (e.cdcooper = 1	AND e.nrdconta = 9947760	AND e.nrctremp = 1576671) OR
(e.cdcooper = 1	AND e.nrdconta = 9947990	AND e.nrctremp = 1595561) OR (e.cdcooper = 1	AND e.nrdconta = 9948945	AND e.nrctremp = 1630767) OR
(e.cdcooper = 1	AND e.nrdconta = 9949020	AND e.nrctremp = 1542668) OR (e.cdcooper = 1	AND e.nrdconta = 9956280	AND e.nrctremp = 1530551) OR
(e.cdcooper = 1	AND e.nrdconta = 9960821	AND e.nrctremp = 1569243) OR (e.cdcooper = 1	AND e.nrdconta = 9961674	AND e.nrctremp = 1655007) OR
(e.cdcooper = 1	AND e.nrdconta = 9964630	AND e.nrctremp = 1393002) OR (e.cdcooper = 1	AND e.nrdconta = 9967141	AND e.nrctremp = 1279619) OR
(e.cdcooper = 1	AND e.nrdconta = 9967494	AND e.nrctremp = 2012720) OR (e.cdcooper = 1	AND e.nrdconta = 9968539	AND e.nrctremp = 1921428) OR
(e.cdcooper = 1	AND e.nrdconta = 9970410	AND e.nrctremp = 1667339) OR (e.cdcooper = 1	AND e.nrdconta = 9971297	AND e.nrctremp = 1282218) OR
(e.cdcooper = 1	AND e.nrdconta = 9977570	AND e.nrctremp = 1596214) OR (e.cdcooper = 1	AND e.nrdconta = 9978909	AND e.nrctremp = 2104348) OR
(e.cdcooper = 1	AND e.nrdconta = 9982230	AND e.nrctremp = 1457640) OR (e.cdcooper = 1	AND e.nrdconta = 9985417	AND e.nrctremp = 1703082) OR
(e.cdcooper = 1	AND e.nrdconta = 9986049	AND e.nrctremp = 1587301) OR (e.cdcooper = 1	AND e.nrdconta = 9986448	AND e.nrctremp = 1593295) OR
(e.cdcooper = 1	AND e.nrdconta = 9987410	AND e.nrctremp = 1290916) OR (e.cdcooper = 1	AND e.nrdconta = 9988963	AND e.nrctremp = 1647101) OR
(e.cdcooper = 1	AND e.nrdconta = 9992685	AND e.nrctremp = 1548328) OR (e.cdcooper = 1	AND e.nrdconta = 9994297	AND e.nrctremp = 1957411) OR
(e.cdcooper = 1	AND e.nrdconta = 9996613	AND e.nrctremp = 1849904) OR (e.cdcooper = 1	AND e.nrdconta = 9996699	AND e.nrctremp = 1294024) OR
(e.cdcooper = 1	AND e.nrdconta = 9999191	AND e.nrctremp = 2104277) OR (e.cdcooper = 1	AND e.nrdconta = 10007962AND e.nrctremp = 	1634452) OR
(e.cdcooper = 1	AND e.nrdconta = 10008098AND e.nrctremp = 	1619614) OR (e.cdcooper = 1	AND e.nrdconta = 10011048AND e.nrctremp = 	1596231) OR
(e.cdcooper = 1	AND e.nrdconta = 10013539AND e.nrctremp = 	1921601) OR (e.cdcooper = 1	AND e.nrdconta = 10014454AND e.nrctremp = 	1569251) OR
(e.cdcooper = 1	AND e.nrdconta = 10014497AND e.nrctremp = 	1302120) OR (e.cdcooper = 1	AND e.nrdconta = 10017852AND e.nrctremp = 	1705902) OR
(e.cdcooper = 1	AND e.nrdconta = 10020594AND e.nrctremp = 	1853301) OR (e.cdcooper = 1	AND e.nrdconta = 10021361AND e.nrctremp = 	1371175) OR
(e.cdcooper = 1	AND e.nrdconta = 10021760AND e.nrctremp = 	1596442) OR (e.cdcooper = 1	AND e.nrdconta = 10022430AND e.nrctremp = 	1583844) OR
(e.cdcooper = 1	AND e.nrdconta = 10022864AND e.nrctremp = 	1376766) OR (e.cdcooper = 1	AND e.nrdconta = 10022864AND e.nrctremp = 	1587299) OR
(e.cdcooper = 1	AND e.nrdconta = 10022996AND e.nrctremp = 	1464875) OR (e.cdcooper = 1	AND e.nrdconta = 10025197AND e.nrctremp = 	1476972) OR
(e.cdcooper = 1	AND e.nrdconta = 10025650AND e.nrctremp = 	1587199) OR (e.cdcooper = 1	AND e.nrdconta = 10029524AND e.nrctremp = 	1737995) OR
(e.cdcooper = 1	AND e.nrdconta = 10030751AND e.nrctremp = 	1665196) OR (e.cdcooper = 1	AND e.nrdconta = 10032061AND e.nrctremp = 	1587241) OR
(e.cdcooper = 1	AND e.nrdconta = 10032657AND e.nrctremp = 	1921589) OR (e.cdcooper = 1	AND e.nrdconta = 10036938AND e.nrctremp = 	1696206) OR
(e.cdcooper = 1	AND e.nrdconta = 10038361AND e.nrctremp = 	1569220) OR (e.cdcooper = 1	AND e.nrdconta = 10039490AND e.nrctremp = 	1587183) OR
(e.cdcooper = 1	AND e.nrdconta = 10040706AND e.nrctremp = 	1475462) OR (e.cdcooper = 1	AND e.nrdconta = 10044159AND e.nrctremp = 	1422040) OR
(e.cdcooper = 1	AND e.nrdconta = 10045856AND e.nrctremp = 	1911357) OR (e.cdcooper = 1	AND e.nrdconta = 10047786AND e.nrctremp = 	1556594) OR
(e.cdcooper = 1	AND e.nrdconta = 10050485AND e.nrctremp = 	1587285) OR (e.cdcooper = 1	AND e.nrdconta = 10054375AND e.nrctremp = 	1599772) OR
(e.cdcooper = 1	AND e.nrdconta = 10056858AND e.nrctremp = 	1587225) OR (e.cdcooper = 1	AND e.nrdconta = 10059210AND e.nrctremp = 	1443018) OR
(e.cdcooper = 1	AND e.nrdconta = 10059741AND e.nrctremp = 	1369474) OR (e.cdcooper = 1	AND e.nrdconta = 10060227AND e.nrctremp = 	1655022) OR
(e.cdcooper = 1	AND e.nrdconta = 10061614AND e.nrctremp = 	2067685) OR (e.cdcooper = 1	AND e.nrdconta = 10064591AND e.nrctremp = 	1957415) OR
(e.cdcooper = 1	AND e.nrdconta = 10069364AND e.nrctremp = 	1420908) OR (e.cdcooper = 1	AND e.nrdconta = 10071997AND e.nrctremp = 	1723194) OR
(e.cdcooper = 1	AND e.nrdconta = 10075844AND e.nrctremp = 	1911400) OR (e.cdcooper = 1	AND e.nrdconta = 10076964AND e.nrctremp = 	1433377) OR
(e.cdcooper = 1	AND e.nrdconta = 10078614AND e.nrctremp = 	1654619) OR (e.cdcooper = 1	AND e.nrdconta = 10078746AND e.nrctremp = 	1402181) OR
(e.cdcooper = 1	AND e.nrdconta = 10080953AND e.nrctremp = 	1336086) OR (e.cdcooper = 1	AND e.nrdconta = 10084827AND e.nrctremp = 	1407717) OR
(e.cdcooper = 1	AND e.nrdconta = 10085637AND e.nrctremp = 	1686206) OR (e.cdcooper = 1	AND e.nrdconta = 10086056AND e.nrctremp = 	1911448) OR
(e.cdcooper = 1	AND e.nrdconta = 10086404AND e.nrctremp = 	2012645) OR (e.cdcooper = 1	AND e.nrdconta = 10090894AND e.nrctremp = 	1868723) OR
(e.cdcooper = 1	AND e.nrdconta = 10091572AND e.nrctremp = 	1774664) OR (e.cdcooper = 1	AND e.nrdconta = 10092846AND e.nrctremp = 	1369809) OR
(e.cdcooper = 1	AND e.nrdconta = 10095608AND e.nrctremp = 	1813753) OR (e.cdcooper = 1	AND e.nrdconta = 10097139AND e.nrctremp = 	1619415) OR
(e.cdcooper = 1	AND e.nrdconta = 10099638AND e.nrctremp = 	1619347) OR (e.cdcooper = 1	AND e.nrdconta = 10101012AND e.nrctremp = 	2039895) OR
(e.cdcooper = 1	AND e.nrdconta = 10104968AND e.nrctremp = 	1921604) OR (e.cdcooper = 1	AND e.nrdconta = 10105026AND e.nrctremp = 	1612194) OR
(e.cdcooper = 1	AND e.nrdconta = 10106758AND e.nrctremp = 	1587248) OR (e.cdcooper = 1	AND e.nrdconta = 10107606AND e.nrctremp = 	1513272) OR
(e.cdcooper = 1	AND e.nrdconta = 10107703AND e.nrctremp = 	1551050) OR (e.cdcooper = 1	AND e.nrdconta = 10107703AND e.nrctremp = 	1949319) OR
(e.cdcooper = 1	AND e.nrdconta = 10109595AND e.nrctremp = 	1486919) OR (e.cdcooper = 1	AND e.nrdconta = 10109960AND e.nrctremp = 	1496848) OR
(e.cdcooper = 1	AND e.nrdconta = 10112090AND e.nrctremp = 	1587170) OR (e.cdcooper = 1	AND e.nrdconta = 10114688AND e.nrctremp = 	2039985) OR
(e.cdcooper = 1	AND e.nrdconta = 10115820AND e.nrctremp = 	1587220) OR (e.cdcooper = 1	AND e.nrdconta = 10117296AND e.nrctremp = 	1921239) OR
(e.cdcooper = 1	AND e.nrdconta = 10117768AND e.nrctremp = 	1699988) OR (e.cdcooper = 1	AND e.nrdconta = 10119248AND e.nrctremp = 	1696382) OR
(e.cdcooper = 1	AND e.nrdconta = 10119825AND e.nrctremp = 	1390379) OR (e.cdcooper = 1	AND e.nrdconta = 10121005AND e.nrctremp = 	2039905) OR
(e.cdcooper = 1	AND e.nrdconta = 10130039AND e.nrctremp = 	1461917) OR (e.cdcooper = 1	AND e.nrdconta = 10130578AND e.nrctremp = 	1638250) OR
(e.cdcooper = 1	AND e.nrdconta = 10132996AND e.nrctremp = 	1459981) OR (e.cdcooper = 1	AND e.nrdconta = 10132996AND e.nrctremp = 	1696587) OR
(e.cdcooper = 1	AND e.nrdconta = 10133410AND e.nrctremp = 	1524843) OR (e.cdcooper = 1	AND e.nrdconta = 10134344AND e.nrctremp = 	1669172) OR
(e.cdcooper = 1	AND e.nrdconta = 10134468AND e.nrctremp = 	1724232) OR (e.cdcooper = 1	AND e.nrdconta = 10135014AND e.nrctremp = 	1655043) OR
(e.cdcooper = 1	AND e.nrdconta = 10140328AND e.nrctremp = 	1853871) OR (e.cdcooper = 1	AND e.nrdconta = 10141472AND e.nrctremp = 	1618924) OR
(e.cdcooper = 1	AND e.nrdconta = 10146350AND e.nrctremp = 	1849900) OR (e.cdcooper = 1	AND e.nrdconta = 10149414AND e.nrctremp = 	1619338) OR
(e.cdcooper = 1	AND e.nrdconta = 10151257AND e.nrctremp = 	2101952) OR (e.cdcooper = 1	AND e.nrdconta = 10154256AND e.nrctremp = 	1921251) OR
(e.cdcooper = 1	AND e.nrdconta = 10154698AND e.nrctremp = 	1850002) OR (e.cdcooper = 1	AND e.nrdconta = 10155139AND e.nrctremp = 	2151021) OR
(e.cdcooper = 1	AND e.nrdconta = 10157360AND e.nrctremp = 	2039889) OR (e.cdcooper = 1	AND e.nrdconta = 10159720AND e.nrctremp = 	1669127) OR
(e.cdcooper = 1	AND e.nrdconta = 10161252AND e.nrctremp = 	1438313) OR (e.cdcooper = 1	AND e.nrdconta = 10161627AND e.nrctremp = 	1545167) OR
(e.cdcooper = 1	AND e.nrdconta = 10166424AND e.nrctremp = 	1388005) OR (e.cdcooper = 1	AND e.nrdconta = 10171533AND e.nrctremp = 	1583810) OR
(e.cdcooper = 1	AND e.nrdconta = 10172882AND e.nrctremp = 	1587032) OR (e.cdcooper = 1	AND e.nrdconta = 10180117AND e.nrctremp = 	1669120) OR
(e.cdcooper = 1	AND e.nrdconta = 10184007AND e.nrctremp = 	1386994) OR (e.cdcooper = 1	AND e.nrdconta = 10192131AND e.nrctremp = 	1395641) OR
(e.cdcooper = 1	AND e.nrdconta = 10198288AND e.nrctremp = 	1853894) OR (e.cdcooper = 1	AND e.nrdconta = 10200983AND e.nrctremp = 	1619399) OR
(e.cdcooper = 1	AND e.nrdconta = 10202250AND e.nrctremp = 	2151024) OR (e.cdcooper = 1	AND e.nrdconta = 10203680AND e.nrctremp = 	1654597) OR
(e.cdcooper = 1	AND e.nrdconta = 10204300AND e.nrctremp = 	1571511) OR (e.cdcooper = 1	AND e.nrdconta = 10205535AND e.nrctremp = 	1669115) OR
(e.cdcooper = 1	AND e.nrdconta = 10211764AND e.nrctremp = 	1486037) OR (e.cdcooper = 1	AND e.nrdconta = 10214143AND e.nrctremp = 	1569337) OR
(e.cdcooper = 1	AND e.nrdconta = 10223517AND e.nrctremp = 	1655967) OR (e.cdcooper = 1	AND e.nrdconta = 10224823AND e.nrctremp = 	1920948) OR
(e.cdcooper = 1	AND e.nrdconta = 10226796AND e.nrctremp = 	1679999) OR (e.cdcooper = 1	AND e.nrdconta = 10229574AND e.nrctremp = 	1448771) OR
(e.cdcooper = 1	AND e.nrdconta = 10236848AND e.nrctremp = 	1492013) OR (e.cdcooper = 1	AND e.nrdconta = 10244050AND e.nrctremp = 	1682951) OR
(e.cdcooper = 1	AND e.nrdconta = 10245740AND e.nrctremp = 	2012819) OR (e.cdcooper = 1	AND e.nrdconta = 10248846AND e.nrctremp = 	1690571) OR
(e.cdcooper = 1	AND e.nrdconta = 10251430AND e.nrctremp = 	2012806) OR (e.cdcooper = 1	AND e.nrdconta = 10254242AND e.nrctremp = 	1588902) OR
(e.cdcooper = 1	AND e.nrdconta = 10256067AND e.nrctremp = 	1813734) OR (e.cdcooper = 1	AND e.nrdconta = 10256733AND e.nrctremp = 	1580982) OR
(e.cdcooper = 1	AND e.nrdconta = 10260951AND e.nrctremp = 	1419624) OR (e.cdcooper = 1	AND e.nrdconta = 10266011AND e.nrctremp = 	1583849) OR
(e.cdcooper = 1	AND e.nrdconta = 10267654AND e.nrctremp = 	1599791) OR (e.cdcooper = 1	AND e.nrdconta = 10278974AND e.nrctremp = 	1775526) OR
(e.cdcooper = 1	AND e.nrdconta = 10279652AND e.nrctremp = 	1853920) OR (e.cdcooper = 1	AND e.nrdconta = 10280871AND e.nrctremp = 	2151033) OR
(e.cdcooper = 1	AND e.nrdconta = 10281568AND e.nrctremp = 	2012368) OR (e.cdcooper = 1	AND e.nrdconta = 10285849AND e.nrctremp = 	1434843) OR
(e.cdcooper = 1	AND e.nrdconta = 10286250AND e.nrctremp = 	1587470) OR (e.cdcooper = 1	AND e.nrdconta = 10289186AND e.nrctremp = 	1474662) OR
(e.cdcooper = 1	AND e.nrdconta = 10305360AND e.nrctremp = 	1775748) OR (e.cdcooper = 1	AND e.nrdconta = 10318909AND e.nrctremp = 	1921615) OR
(e.cdcooper = 1	AND e.nrdconta = 10319735AND e.nrctremp = 	1447643) OR (e.cdcooper = 1	AND e.nrdconta = 10319840AND e.nrctremp = 	1450452) OR
(e.cdcooper = 1	AND e.nrdconta = 10322167AND e.nrctremp = 	1654594) OR (e.cdcooper = 1	AND e.nrdconta = 10323015AND e.nrctremp = 	1619465) OR
(e.cdcooper = 1	AND e.nrdconta = 10324232AND e.nrctremp = 	2012866) OR (e.cdcooper = 1	AND e.nrdconta = 10326448AND e.nrctremp = 	1619474) OR
(e.cdcooper = 1	AND e.nrdconta = 10331590AND e.nrctremp = 	1852739) OR (e.cdcooper = 1	AND e.nrdconta = 10333100AND e.nrctremp = 	2104305) OR
(e.cdcooper = 1	AND e.nrdconta = 10333258AND e.nrctremp = 	1581117) OR (e.cdcooper = 1	AND e.nrdconta = 10335390AND e.nrctremp = 	1878941) OR
(e.cdcooper = 1	AND e.nrdconta = 10336400AND e.nrctremp = 	1457606) OR (e.cdcooper = 1	AND e.nrdconta = 10337237AND e.nrctremp = 	1775325) OR
(e.cdcooper = 1	AND e.nrdconta = 10345167AND e.nrctremp = 	1696280) OR (e.cdcooper = 1	AND e.nrdconta = 10345450AND e.nrctremp = 	1461994) OR
(e.cdcooper = 1	AND e.nrdconta = 10345450AND e.nrctremp = 	1761188) OR (e.cdcooper = 1	AND e.nrdconta = 10347640AND e.nrctremp = 	1623042) OR
(e.cdcooper = 1	AND e.nrdconta = 10358447AND e.nrctremp = 	1911391) OR (e.cdcooper = 1	AND e.nrdconta = 10360964AND e.nrctremp = 	1600336) OR
(e.cdcooper = 1	AND e.nrdconta = 10364951AND e.nrctremp = 	1669119) OR (e.cdcooper = 1	AND e.nrdconta = 10370064AND e.nrctremp = 	1724149) OR
(e.cdcooper = 1	AND e.nrdconta = 10372075AND e.nrctremp = 	1696831) OR (e.cdcooper = 1	AND e.nrdconta = 10372407AND e.nrctremp = 	1557516) OR
(e.cdcooper = 1	AND e.nrdconta = 10380990AND e.nrctremp = 	2151035) OR (e.cdcooper = 1	AND e.nrdconta = 10382100AND e.nrctremp = 	1478848) OR
(e.cdcooper = 1	AND e.nrdconta = 10385126AND e.nrctremp = 	1483885) OR (e.cdcooper = 1	AND e.nrdconta = 10394630AND e.nrctremp = 	1921496) OR
(e.cdcooper = 1	AND e.nrdconta = 10395679AND e.nrctremp = 	1669092) OR (e.cdcooper = 1	AND e.nrdconta = 10399852AND e.nrctremp = 	1624000) OR
(e.cdcooper = 1	AND e.nrdconta = 10408886AND e.nrctremp = 	1775341) OR (e.cdcooper = 1	AND e.nrdconta = 10421734AND e.nrctremp = 	1724208) OR
(e.cdcooper = 1	AND e.nrdconta = 10426973AND e.nrctremp = 	1949438) OR (e.cdcooper = 1	AND e.nrdconta = 10431047AND e.nrctremp = 	1696289) OR
(e.cdcooper = 1	AND e.nrdconta = 10443207AND e.nrctremp = 	1624557) OR (e.cdcooper = 1	AND e.nrdconta = 10449140AND e.nrctremp = 	1529879) OR
(e.cdcooper = 1	AND e.nrdconta = 10452060AND e.nrctremp = 	1696180) OR (e.cdcooper = 1	AND e.nrdconta = 10452192AND e.nrctremp = 	1775496) OR
(e.cdcooper = 1	AND e.nrdconta = 10453601AND e.nrctremp = 	1724103) OR (e.cdcooper = 1	AND e.nrdconta = 10468536AND e.nrctremp = 	1775764) OR
(e.cdcooper = 1	AND e.nrdconta = 10478965AND e.nrctremp = 	1853036) OR (e.cdcooper = 1	AND e.nrdconta = 10482989AND e.nrctremp = 	1878861) OR
(e.cdcooper = 1	AND e.nrdconta = 10488049AND e.nrctremp = 	2012391) OR (e.cdcooper = 1	AND e.nrdconta = 10489959AND e.nrctremp = 	1921558) OR
(e.cdcooper = 1	AND e.nrdconta = 10490922AND e.nrctremp = 	2366667) OR (e.cdcooper = 1	AND e.nrdconta = 10499202AND e.nrctremp = 	1861156) OR
(e.cdcooper = 1	AND e.nrdconta = 10501266AND e.nrctremp = 	1775588) OR (e.cdcooper = 1	AND e.nrdconta = 10516379AND e.nrctremp = 	2104554) OR
(e.cdcooper = 1	AND e.nrdconta = 10519513AND e.nrctremp = 	1921617) OR (e.cdcooper = 1	AND e.nrdconta = 10528970AND e.nrctremp = 	1719339) OR
(e.cdcooper = 1	AND e.nrdconta = 10530231AND e.nrctremp = 	2012384) OR (e.cdcooper = 1	AND e.nrdconta = 10534210AND e.nrctremp = 	2012382) OR
(e.cdcooper = 1	AND e.nrdconta = 10537783AND e.nrctremp = 	1642151) OR (e.cdcooper = 1	AND e.nrdconta = 10547010AND e.nrctremp = 	1992513) OR
(e.cdcooper = 1	AND e.nrdconta = 10554785AND e.nrctremp = 	2144843) OR (e.cdcooper = 1	AND e.nrdconta = 10558381AND e.nrctremp = 	2039798) OR
(e.cdcooper = 1	AND e.nrdconta = 10563806AND e.nrctremp = 	1949351) OR (e.cdcooper = 1	AND e.nrdconta = 10569154AND e.nrctremp = 	2012409) OR
(e.cdcooper = 1	AND e.nrdconta = 10582789AND e.nrctremp = 	1853040) OR (e.cdcooper = 1	AND e.nrdconta = 10587152AND e.nrctremp = 	1588681) OR
(e.cdcooper = 1	AND e.nrdconta = 10591168AND e.nrctremp = 	2104759) OR (e.cdcooper = 1	AND e.nrdconta = 10591621AND e.nrctremp = 	1878928) OR
(e.cdcooper = 1	AND e.nrdconta = 10601880AND e.nrctremp = 	1807610) OR (e.cdcooper = 1	AND e.nrdconta = 10604804AND e.nrctremp = 	1911390) OR
(e.cdcooper = 1	AND e.nrdconta = 10605525AND e.nrctremp = 	2104987) OR (e.cdcooper = 1	AND e.nrdconta = 10605797AND e.nrctremp = 	2144877) OR
(e.cdcooper = 1	AND e.nrdconta = 10621989AND e.nrctremp = 	2145142) OR (e.cdcooper = 1	AND e.nrdconta = 10645640AND e.nrctremp = 	2477751) OR
(e.cdcooper = 1	AND e.nrdconta = 10650580AND e.nrctremp = 	2104764) OR (e.cdcooper = 1	AND e.nrdconta = 10670998AND e.nrctremp = 	2012499) OR
(e.cdcooper = 1	AND e.nrdconta = 10673024AND e.nrctremp = 	1949328) OR (e.cdcooper = 1	AND e.nrdconta = 10690247AND e.nrctremp = 	1646985) OR
(e.cdcooper = 1	AND e.nrdconta = 10699333AND e.nrctremp = 	2039902) OR (e.cdcooper = 1	AND e.nrdconta = 10701087AND e.nrctremp = 	1957385) OR
(e.cdcooper = 1	AND e.nrdconta = 10725130AND e.nrctremp = 	1921399) OR (e.cdcooper = 1	AND e.nrdconta = 10736697AND e.nrctremp = 	2104578) OR
(e.cdcooper = 1	AND e.nrdconta = 10738614AND e.nrctremp = 	2012337) OR (e.cdcooper = 1	AND e.nrdconta = 10745688AND e.nrctremp = 	1790656) OR
(e.cdcooper = 1	AND e.nrdconta = 10754318AND e.nrctremp = 	1771466) OR (e.cdcooper = 1	AND e.nrdconta = 10785922AND e.nrctremp = 	1726764) OR
(e.cdcooper = 1	AND e.nrdconta = 10794670AND e.nrctremp = 	2012340) OR (e.cdcooper = 1	AND e.nrdconta = 10868275AND e.nrctremp = 	1777472) OR
(e.cdcooper = 1	AND e.nrdconta = 10872191AND e.nrctremp = 	2221592) OR (e.cdcooper = 1	AND e.nrdconta = 10875123AND e.nrctremp = 	2144954) OR
(e.cdcooper = 1	AND e.nrdconta = 10894861AND e.nrctremp = 	1801979) OR (e.cdcooper = 1	AND e.nrdconta = 80018122AND e.nrctremp = 	357959) OR
(e.cdcooper = 1	AND e.nrdconta = 80024734AND e.nrctremp = 	80024734) OR (e.cdcooper = 1	AND e.nrdconta = 80028918AND e.nrctremp = 	1116029) OR
(e.cdcooper = 1	AND e.nrdconta = 80049958AND e.nrctremp = 	80049958) OR (e.cdcooper = 1	AND e.nrdconta = 80057993AND e.nrctremp = 	1013331) OR
(e.cdcooper = 1	AND e.nrdconta = 80103936AND e.nrctremp = 	80103936) OR (e.cdcooper = 1	AND e.nrdconta = 80106307AND e.nrctremp = 	840459) OR
(e.cdcooper = 1	AND e.nrdconta = 80114849AND e.nrctremp = 	1077646) OR (e.cdcooper = 1	AND e.nrdconta = 80115365AND e.nrctremp = 	1193777) OR
(e.cdcooper = 1	AND e.nrdconta = 80122850AND e.nrctremp = 	1774972) OR (e.cdcooper = 1	AND e.nrdconta = 80131719AND e.nrctremp = 	2145223) OR
(e.cdcooper = 1	AND e.nrdconta = 80132812AND e.nrctremp = 	586873) OR (e.cdcooper = 1	AND e.nrdconta = 80133010AND e.nrctremp = 	715259) OR
(e.cdcooper = 1	AND e.nrdconta = 80134491AND e.nrctremp = 	1487382) OR (e.cdcooper = 1	AND e.nrdconta = 80135269AND e.nrctremp = 	414915) OR
(e.cdcooper = 1	AND e.nrdconta = 80142257AND e.nrctremp = 	563456) OR (e.cdcooper = 1	AND e.nrdconta = 80145728AND e.nrctremp = 	80145728) OR
(e.cdcooper = 1	AND e.nrdconta = 80171974AND e.nrctremp = 	979899) OR (e.cdcooper = 1	AND e.nrdconta = 80172903AND e.nrctremp = 	80172903) OR
(e.cdcooper = 1	AND e.nrdconta = 80178685AND e.nrctremp = 	551561) OR (e.cdcooper = 1	AND e.nrdconta = 80186424AND e.nrctremp = 	613672) OR
(e.cdcooper = 1	AND e.nrdconta = 80193781AND e.nrctremp = 	695415) OR (e.cdcooper = 1	AND e.nrdconta = 80211976AND e.nrctremp = 	1186317) OR
(e.cdcooper = 1	AND e.nrdconta = 80212565AND e.nrctremp = 	1172086) OR (e.cdcooper = 1	AND e.nrdconta = 80234305AND e.nrctremp = 	80234305) OR
(e.cdcooper = 1	AND e.nrdconta = 80237452AND e.nrctremp = 	1034633) OR (e.cdcooper = 1	AND e.nrdconta = 80241271AND e.nrctremp = 	1046640) OR
(e.cdcooper = 1	AND e.nrdconta = 80241271AND e.nrctremp = 	1353346) OR (e.cdcooper = 1	AND e.nrdconta = 80246907AND e.nrctremp = 	595053) OR
(e.cdcooper = 1	AND e.nrdconta = 80246907AND e.nrctremp = 	596653) OR (e.cdcooper = 1	AND e.nrdconta = 80247580AND e.nrctremp = 	744139) OR
(e.cdcooper = 1	AND e.nrdconta = 80248950AND e.nrctremp = 	523276) OR (e.cdcooper = 1	AND e.nrdconta = 80254713AND e.nrctremp = 	794002) OR
(e.cdcooper = 1	AND e.nrdconta = 80273599AND e.nrctremp = 	1347001) OR (e.cdcooper = 1	AND e.nrdconta = 80274170AND e.nrctremp = 	1627101) OR
(e.cdcooper = 1	AND e.nrdconta = 80275150AND e.nrctremp = 	1410298) OR (e.cdcooper = 1	AND e.nrdconta = 80292186AND e.nrctremp = 	517027) OR
(e.cdcooper = 1	AND e.nrdconta = 80320210AND e.nrctremp = 	987100) OR (e.cdcooper = 1	AND e.nrdconta = 80321291AND e.nrctremp = 	958146) OR
(e.cdcooper = 1	AND e.nrdconta = 80326285AND e.nrctremp = 	222668) OR (e.cdcooper = 1	AND e.nrdconta = 80329616AND e.nrctremp = 	1159327) OR
(e.cdcooper = 1	AND e.nrdconta = 80330002AND e.nrctremp = 	762931) OR (e.cdcooper = 1	AND e.nrdconta = 80333656AND e.nrctremp = 	1614799) OR
(e.cdcooper = 1	AND e.nrdconta = 80336191AND e.nrctremp = 	80336191) OR (e.cdcooper = 1	AND e.nrdconta = 80336248AND e.nrctremp = 	1385873) OR
(e.cdcooper = 1	AND e.nrdconta = 80340601AND e.nrctremp = 	1167414) OR (e.cdcooper = 1	AND e.nrdconta = 80346669AND e.nrctremp = 	762131) OR
(e.cdcooper = 1	AND e.nrdconta = 80347134AND e.nrctremp = 	886537) OR (e.cdcooper = 1	AND e.nrdconta = 80352626AND e.nrctremp = 	915905) OR
(e.cdcooper = 1	AND e.nrdconta = 80353037AND e.nrctremp = 	952171) OR (e.cdcooper = 1	AND e.nrdconta = 80353371AND e.nrctremp = 	80353371) OR
(e.cdcooper = 1	AND e.nrdconta = 80359477AND e.nrctremp = 	1086830) OR (e.cdcooper = 1	AND e.nrdconta = 80359906AND e.nrctremp = 	51887) OR
(e.cdcooper = 1	AND e.nrdconta = 80361528AND e.nrctremp = 	31284) OR (e.cdcooper = 1	AND e.nrdconta = 80362214AND e.nrctremp = 	429226) OR
(e.cdcooper = 1	AND e.nrdconta = 80366465AND e.nrctremp = 	128307) OR (e.cdcooper = 1	AND e.nrdconta = 80368999AND e.nrctremp = 	117804) OR
(e.cdcooper = 1	AND e.nrdconta = 80368999AND e.nrctremp = 	380042) OR (e.cdcooper = 1	AND e.nrdconta = 80369030AND e.nrctremp = 	1267417) OR
(e.cdcooper = 1	AND e.nrdconta = 80369626AND e.nrctremp = 	385973) OR (e.cdcooper = 1	AND e.nrdconta = 80369758AND e.nrctremp = 	96082) OR
(e.cdcooper = 1	AND e.nrdconta = 80369855AND e.nrctremp = 	80369855) OR (e.cdcooper = 1	AND e.nrdconta = 80414400AND e.nrctremp = 	427314) OR
(e.cdcooper = 1	AND e.nrdconta = 80415342AND e.nrctremp = 	101190) OR (e.cdcooper = 1	AND e.nrdconta = 80416470AND e.nrctremp = 	955699) OR
(e.cdcooper = 1	AND e.nrdconta = 80417329AND e.nrctremp = 	872901) OR (e.cdcooper = 1	AND e.nrdconta = 80418244AND e.nrctremp = 	80418244) OR
(e.cdcooper = 1	AND e.nrdconta = 80420125AND e.nrctremp = 	1312736) OR (e.cdcooper = 1	AND e.nrdconta = 80420249AND e.nrctremp = 	1639739) OR
(e.cdcooper = 1	AND e.nrdconta = 80422039AND e.nrctremp = 	1513687) OR (e.cdcooper = 1	AND e.nrdconta = 80423019AND e.nrctremp = 	91620) OR
(e.cdcooper = 1	AND e.nrdconta = 80426573AND e.nrctremp = 	820091) OR (e.cdcooper = 1	AND e.nrdconta = 80427430AND e.nrctremp = 	410087) OR
(e.cdcooper = 1	AND e.nrdconta = 80433979AND e.nrctremp = 	875641) OR (e.cdcooper = 1	AND e.nrdconta = 80434541AND e.nrctremp = 	597277) OR
(e.cdcooper = 1	AND e.nrdconta = 80436951AND e.nrctremp = 	1349925) OR (e.cdcooper = 1	AND e.nrdconta = 80437613AND e.nrctremp = 	667561) OR
(e.cdcooper = 1	AND e.nrdconta = 80438067AND e.nrctremp = 	529588) OR (e.cdcooper = 1	AND e.nrdconta = 80438180AND e.nrctremp = 	374345) OR
(e.cdcooper = 1	AND e.nrdconta = 80476511AND e.nrctremp = 	682960) OR (e.cdcooper = 1	AND e.nrdconta = 80481108AND e.nrctremp = 	764145) OR
(e.cdcooper = 1	AND e.nrdconta = 80483887AND e.nrctremp = 	185923) OR (e.cdcooper = 1	AND e.nrdconta = 80484980AND e.nrctremp = 	907530) OR
(e.cdcooper = 1	AND e.nrdconta = 80485200AND e.nrctremp = 	712477) OR (e.cdcooper = 1	AND e.nrdconta = 80496091AND e.nrctremp = 	641954) OR
(e.cdcooper = 1	AND e.nrdconta = 80571948AND e.nrctremp = 	564090) OR (e.cdcooper = 1	AND e.nrdconta = 80572014AND e.nrctremp = 	60054) OR
(e.cdcooper = 1	AND e.nrdconta = 80578128AND e.nrctremp = 	320603) OR (e.cdcooper = 1	AND e.nrdconta = 80578128AND e.nrctremp = 	80578128) OR
(e.cdcooper = 1	AND e.nrdconta = 82216045AND e.nrctremp = 	1599204) OR (e.cdcooper = 1	AND e.nrdconta = 90123328AND e.nrctremp = 	696848) OR
(e.cdcooper = 1	AND e.nrdconta = 90136004AND e.nrctremp = 	90136004) OR (e.cdcooper = 1	AND e.nrdconta = 90160207AND e.nrctremp = 	1098061) OR
(e.cdcooper = 1	AND e.nrdconta = 90161599AND e.nrctremp = 	21149) OR (e.cdcooper = 1	AND e.nrdconta = 90164008AND e.nrctremp = 	1244409) OR
(e.cdcooper = 1	AND e.nrdconta = 90165799AND e.nrctremp = 	546951) OR (e.cdcooper = 1	AND e.nrdconta = 90165799AND e.nrctremp = 	833570) OR
(e.cdcooper = 1	AND e.nrdconta = 90222156AND e.nrctremp = 	16947) OR (e.cdcooper = 1	AND e.nrdconta = 90260465AND e.nrctremp = 	714173) OR
(e.cdcooper = 1	AND e.nrdconta = 90260864AND e.nrctremp = 	714171) OR (e.cdcooper = 1	AND e.nrdconta = 90261151AND e.nrctremp = 	199662) OR
(e.cdcooper = 1	AND e.nrdconta = 90263057AND e.nrctremp = 	1586818) OR (e.cdcooper = 1	AND e.nrdconta = 90267176AND e.nrctremp = 	1513304) OR
(e.cdcooper = 2	AND e.nrdconta = 219568	AND e.nrctremp = 224716) OR (e.cdcooper = 2	AND e.nrdconta = 229911	AND e.nrctremp = 259854) OR
(e.cdcooper = 2	AND e.nrdconta = 308102	AND e.nrctremp = 233816) OR (e.cdcooper = 2	AND e.nrdconta = 310581	AND e.nrctremp = 310581) OR
(e.cdcooper = 2	AND e.nrdconta = 342165	AND e.nrctremp = 244724) OR (e.cdcooper = 2	AND e.nrdconta = 359335	AND e.nrctremp = 233634) OR
(e.cdcooper = 2	AND e.nrdconta = 378003	AND e.nrctremp = 4185) OR (e.cdcooper = 2	AND e.nrdconta = 404888	AND e.nrctremp = 219641) OR
(e.cdcooper = 2	AND e.nrdconta = 407798	AND e.nrctremp = 246886) OR (e.cdcooper = 2	AND e.nrdconta = 453900	AND e.nrctremp = 233949) OR
(e.cdcooper = 2	AND e.nrdconta = 463450	AND e.nrctremp = 228919) OR (e.cdcooper = 2	AND e.nrdconta = 479438	AND e.nrctremp = 479438) OR
(e.cdcooper = 2	AND e.nrdconta = 482625	AND e.nrctremp = 227080) OR (e.cdcooper = 2	AND e.nrdconta = 500720	AND e.nrctremp = 4580) OR
(e.cdcooper = 2	AND e.nrdconta = 505978	AND e.nrctremp = 244149) OR (e.cdcooper = 2	AND e.nrdconta = 512168	AND e.nrctremp = 240554) OR
(e.cdcooper = 2	AND e.nrdconta = 534480	AND e.nrctremp = 227445) OR (e.cdcooper = 2	AND e.nrdconta = 539163	AND e.nrctremp = 235789) OR
(e.cdcooper = 2	AND e.nrdconta = 542571	AND e.nrctremp = 242528) OR (e.cdcooper = 2	AND e.nrdconta = 544302	AND e.nrctremp = 235832) OR
(e.cdcooper = 2	AND e.nrdconta = 549916	AND e.nrctremp = 249544) OR (e.cdcooper = 2	AND e.nrdconta = 555606	AND e.nrctremp = 239436) OR
(e.cdcooper = 2	AND e.nrdconta = 560260	AND e.nrctremp = 222571) OR (e.cdcooper = 2	AND e.nrdconta = 572969	AND e.nrctremp = 220316) OR
(e.cdcooper = 2	AND e.nrdconta = 586390	AND e.nrctremp = 239342) OR (e.cdcooper = 2	AND e.nrdconta = 602400	AND e.nrctremp = 2975) OR
(e.cdcooper = 2	AND e.nrdconta = 606014	AND e.nrctremp = 236682) OR (e.cdcooper = 2	AND e.nrdconta = 623911	AND e.nrctremp = 247567) OR
(e.cdcooper = 2	AND e.nrdconta = 641316	AND e.nrctremp = 259852) OR (e.cdcooper = 2	AND e.nrdconta = 643270	AND e.nrctremp = 240526) OR
(e.cdcooper = 2	AND e.nrdconta = 656275	AND e.nrctremp = 247519) OR (e.cdcooper = 2	AND e.nrdconta = 656666	AND e.nrctremp = 244142) OR
(e.cdcooper = 2	AND e.nrdconta = 663344	AND e.nrctremp = 247682) OR (e.cdcooper = 2	AND e.nrdconta = 669300	AND e.nrctremp = 248365) OR
(e.cdcooper = 2	AND e.nrdconta = 684724	AND e.nrctremp = 257281) OR (e.cdcooper = 2	AND e.nrdconta = 700487	AND e.nrctremp = 255757) OR
(e.cdcooper = 2	AND e.nrdconta = 706574	AND e.nrctremp = 234078) OR (e.cdcooper = 2	AND e.nrdconta = 713511	AND e.nrctremp = 253576) OR
(e.cdcooper = 2	AND e.nrdconta = 738409	AND e.nrctremp = 255906) OR (e.cdcooper = 2	AND e.nrdconta = 762679	AND e.nrctremp = 260514) OR
(e.cdcooper = 5	AND e.nrdconta = 47155	AND e.nrctremp = 4024) OR (e.cdcooper = 5	AND e.nrdconta = 51900	AND e.nrctremp = 13516) OR
(e.cdcooper = 5	AND e.nrdconta = 52736	AND e.nrctremp = 12988) OR (e.cdcooper = 5	AND e.nrdconta = 64440	AND e.nrctremp = 6489) OR
(e.cdcooper = 5	AND e.nrdconta = 68799	AND e.nrctremp = 1352) OR (e.cdcooper = 5	AND e.nrdconta = 70777	AND e.nrctremp = 13236) OR
(e.cdcooper = 5	AND e.nrdconta = 70980	AND e.nrctremp = 18027) OR (e.cdcooper = 5	AND e.nrdconta = 74829	AND e.nrctremp = 6867) OR
(e.cdcooper = 5	AND e.nrdconta = 75507	AND e.nrctremp = 4102) OR (e.cdcooper = 5	AND e.nrdconta = 75558	AND e.nrctremp = 5443) OR
(e.cdcooper = 5	AND e.nrdconta = 75981	AND e.nrctremp = 13361) OR (e.cdcooper = 5	AND e.nrdconta = 77151	AND e.nrctremp = 6450) OR
(e.cdcooper = 5	AND e.nrdconta = 77275	AND e.nrctremp = 8204) OR (e.cdcooper = 5	AND e.nrdconta = 77992	AND e.nrctremp = 151236) OR
(e.cdcooper = 5	AND e.nrdconta = 79073	AND e.nrctremp = 6669) OR (e.cdcooper = 5	AND e.nrdconta = 81400	AND e.nrctremp = 11617) OR
(e.cdcooper = 5	AND e.nrdconta = 86177	AND e.nrctremp = 5450) OR (e.cdcooper = 5	AND e.nrdconta = 89745	AND e.nrctremp = 8683) OR
(e.cdcooper = 5	AND e.nrdconta = 93939	AND e.nrctremp = 2707) OR (e.cdcooper = 5	AND e.nrdconta = 96253	AND e.nrctremp = 3016) OR
(e.cdcooper = 5	AND e.nrdconta = 96792	AND e.nrctremp = 2713) OR (e.cdcooper = 5	AND e.nrdconta = 97748	AND e.nrctremp = 8799) OR
(e.cdcooper = 5	AND e.nrdconta = 98663	AND e.nrctremp = 15523) OR (e.cdcooper = 5	AND e.nrdconta = 99180	AND e.nrctremp = 6662) OR
(e.cdcooper = 5	AND e.nrdconta = 99384	AND e.nrctremp = 99384) OR (e.cdcooper = 5	AND e.nrdconta = 104051	AND e.nrctremp = 7428) OR
(e.cdcooper = 5	AND e.nrdconta = 118079	AND e.nrctremp = 14910) OR (e.cdcooper = 5	AND e.nrdconta = 123935	AND e.nrctremp = 6254) OR
(e.cdcooper = 5	AND e.nrdconta = 124893	AND e.nrctremp = 7909) OR (e.cdcooper = 5	AND e.nrdconta = 127574	AND e.nrctremp = 10925) OR
(e.cdcooper = 5	AND e.nrdconta = 128961	AND e.nrctremp = 12241) OR (e.cdcooper = 5	AND e.nrdconta = 129313	AND e.nrctremp = 12654) OR
(e.cdcooper = 5	AND e.nrdconta = 139980	AND e.nrctremp = 8493) OR (e.cdcooper = 5	AND e.nrdconta = 143766	AND e.nrctremp = 10291) OR
(e.cdcooper = 5	AND e.nrdconta = 145815	AND e.nrctremp = 12239) OR (e.cdcooper = 5	AND e.nrdconta = 147133	AND e.nrctremp = 9646) OR
(e.cdcooper = 5	AND e.nrdconta = 149420	AND e.nrctremp = 10452) OR (e.cdcooper = 5	AND e.nrdconta = 156612	AND e.nrctremp = 14563) OR
(e.cdcooper = 5	AND e.nrdconta = 157082	AND e.nrctremp = 17475) OR (e.cdcooper = 5	AND e.nrdconta = 158933	AND e.nrctremp = 17209) OR
(e.cdcooper = 5	AND e.nrdconta = 163333	AND e.nrctremp = 13980) OR (e.cdcooper = 5	AND e.nrdconta = 164917	AND e.nrctremp = 13870) OR
(e.cdcooper = 5	AND e.nrdconta = 172707	AND e.nrctremp = 13151) OR (e.cdcooper = 5	AND e.nrdconta = 175331	AND e.nrctremp = 14692) OR
(e.cdcooper = 5	AND e.nrdconta = 176605	AND e.nrctremp = 14901) OR (e.cdcooper = 5	AND e.nrdconta = 176664	AND e.nrctremp = 15104) OR
(e.cdcooper = 5	AND e.nrdconta = 181587	AND e.nrctremp = 16321) OR (e.cdcooper = 5	AND e.nrdconta = 183547	AND e.nrctremp = 17199) OR
(e.cdcooper = 6	AND e.nrdconta = 18090	AND e.nrctremp = 213634) OR (e.cdcooper = 6	AND e.nrdconta = 23663	AND e.nrctremp = 214112) OR
(e.cdcooper = 6	AND e.nrdconta = 24201	AND e.nrctremp = 214971) OR (e.cdcooper = 6	AND e.nrdconta = 24775	AND e.nrctremp = 2019) OR
(e.cdcooper = 6	AND e.nrdconta = 27235	AND e.nrctremp = 217301) OR (e.cdcooper = 6	AND e.nrdconta = 28193	AND e.nrctremp = 217297) OR
(e.cdcooper = 6	AND e.nrdconta = 28509	AND e.nrctremp = 217823) OR (e.cdcooper = 6	AND e.nrdconta = 29726	AND e.nrctremp = 29726) OR
(e.cdcooper = 6	AND e.nrdconta = 30287	AND e.nrctremp = 216065) OR (e.cdcooper = 6	AND e.nrdconta = 37117	AND e.nrctremp = 214903) OR
(e.cdcooper = 6	AND e.nrdconta = 39080	AND e.nrctremp = 39080) OR (e.cdcooper = 6	AND e.nrdconta = 50482	AND e.nrctremp = 222333) OR
(e.cdcooper = 6	AND e.nrdconta = 53589	AND e.nrctremp = 213711) OR (e.cdcooper = 6	AND e.nrdconta = 68322	AND e.nrctremp = 216672) OR
(e.cdcooper = 6	AND e.nrdconta = 73350	AND e.nrctremp = 217482) OR (e.cdcooper = 6	AND e.nrdconta = 74519	AND e.nrctremp = 74519) OR
(e.cdcooper = 6	AND e.nrdconta = 78409	AND e.nrctremp = 78409) OR (e.cdcooper = 6	AND e.nrdconta = 78719	AND e.nrctremp = 224319) OR
(e.cdcooper = 6	AND e.nrdconta = 79430	AND e.nrctremp = 221004) OR (e.cdcooper = 6	AND e.nrdconta = 81329	AND e.nrctremp = 221422) OR
(e.cdcooper = 6	AND e.nrdconta = 81329	AND e.nrctremp = 226898) OR (e.cdcooper = 6	AND e.nrdconta = 83160	AND e.nrctremp = 83160) OR
(e.cdcooper = 6	AND e.nrdconta = 84247	AND e.nrctremp = 84247) OR (e.cdcooper = 6	AND e.nrdconta = 86592	AND e.nrctremp = 86592) OR
(e.cdcooper = 6	AND e.nrdconta = 91120	AND e.nrctremp = 219128) OR (e.cdcooper = 6	AND e.nrdconta = 92460	AND e.nrctremp = 216828) OR
(e.cdcooper = 6	AND e.nrdconta = 94439	AND e.nrctremp = 226189) OR (e.cdcooper = 6	AND e.nrdconta = 100838	AND e.nrctremp = 212332) OR
(e.cdcooper = 6	AND e.nrdconta = 101052	AND e.nrctremp = 216508) OR (e.cdcooper = 6	AND e.nrdconta = 102016	AND e.nrctremp = 213537) OR
(e.cdcooper = 6	AND e.nrdconta = 102180	AND e.nrctremp = 216051) OR (e.cdcooper = 6	AND e.nrdconta = 102245	AND e.nrctremp = 223143) OR
(e.cdcooper = 6	AND e.nrdconta = 104841	AND e.nrctremp = 104841) OR (e.cdcooper = 6	AND e.nrdconta = 105732	AND e.nrctremp = 222539) OR
(e.cdcooper = 6	AND e.nrdconta = 108561	AND e.nrctremp = 227745) OR (e.cdcooper = 6	AND e.nrdconta = 122424	AND e.nrctremp = 227530) OR
(e.cdcooper = 6	AND e.nrdconta = 123897	AND e.nrctremp = 225662) OR (e.cdcooper = 6	AND e.nrdconta = 125644	AND e.nrctremp = 226903) OR
(e.cdcooper = 6	AND e.nrdconta = 125784	AND e.nrctremp = 226406) OR (e.cdcooper = 6	AND e.nrdconta = 136956	AND e.nrctremp = 226504) OR
(e.cdcooper = 6	AND e.nrdconta = 141801	AND e.nrctremp = 226737) OR (e.cdcooper = 6	AND e.nrdconta = 143146	AND e.nrctremp = 224850) OR
(e.cdcooper = 6	AND e.nrdconta = 147010	AND e.nrctremp = 227063) OR (e.cdcooper = 6	AND e.nrdconta = 151092	AND e.nrctremp = 226393) OR
(e.cdcooper = 6	AND e.nrdconta = 151653	AND e.nrctremp = 227750) OR (e.cdcooper = 6	AND e.nrdconta = 152552	AND e.nrctremp = 225648) OR
(e.cdcooper = 6	AND e.nrdconta = 153800	AND e.nrctremp = 226409) OR (e.cdcooper = 6	AND e.nrdconta = 158720	AND e.nrctremp = 227196) OR
(e.cdcooper = 6	AND e.nrdconta = 158968	AND e.nrctremp = 226381) OR (e.cdcooper = 6	AND e.nrdconta = 159336	AND e.nrctremp = 226405) OR
(e.cdcooper = 6	AND e.nrdconta = 161160	AND e.nrctremp = 226319) OR (e.cdcooper = 6	AND e.nrdconta = 161543	AND e.nrctremp = 226401) OR
(e.cdcooper = 6	AND e.nrdconta = 164666	AND e.nrctremp = 226410) OR (e.cdcooper = 6	AND e.nrdconta = 166707	AND e.nrctremp = 227539) OR
(e.cdcooper = 6	AND e.nrdconta = 171522	AND e.nrctremp = 227975) OR (e.cdcooper = 6	AND e.nrdconta = 173509	AND e.nrctremp = 227407) OR
(e.cdcooper = 6	AND e.nrdconta = 173525	AND e.nrctremp = 227746) OR (e.cdcooper = 6	AND e.nrdconta = 500895	AND e.nrctremp = 226868) OR
(e.cdcooper = 6	AND e.nrdconta = 503010	AND e.nrctremp = 216043) OR (e.cdcooper = 6	AND e.nrdconta = 503010	AND e.nrctremp = 223112) OR
(e.cdcooper = 6	AND e.nrdconta = 503550	AND e.nrctremp = 215954) OR (e.cdcooper = 6	AND e.nrdconta = 503665	AND e.nrctremp = 221564) OR
(e.cdcooper = 6	AND e.nrdconta = 504742	AND e.nrctremp = 216969) OR (e.cdcooper = 6	AND e.nrdconta = 505137	AND e.nrctremp = 217819) OR
(e.cdcooper = 6	AND e.nrdconta = 505790	AND e.nrctremp = 215460) OR (e.cdcooper = 6	AND e.nrdconta = 506230	AND e.nrctremp = 213536) OR
(e.cdcooper = 6	AND e.nrdconta = 506745	AND e.nrctremp = 506745) OR (e.cdcooper = 6	AND e.nrdconta = 507229	AND e.nrctremp = 214944) OR
(e.cdcooper = 6	AND e.nrdconta = 508497	AND e.nrctremp = 219491) OR (e.cdcooper = 6	AND e.nrdconta = 509094	AND e.nrctremp = 220936) OR
(e.cdcooper = 7	AND e.nrdconta = 3239	AND e.nrctremp = 7396) OR (e.cdcooper = 7	AND e.nrdconta = 5037	AND e.nrctremp = 2220) OR
(e.cdcooper = 7	AND e.nrdconta = 9016	AND e.nrctremp = 1) OR (e.cdcooper = 7	AND e.nrdconta = 10421	AND e.nrctremp = 4544) OR
(e.cdcooper = 7	AND e.nrdconta = 12173	AND e.nrctremp = 4525) OR (e.cdcooper = 7	AND e.nrdconta = 12173	AND e.nrctremp = 8323) OR
(e.cdcooper = 7	AND e.nrdconta = 19437	AND e.nrctremp = 15698) OR (e.cdcooper = 7	AND e.nrdconta = 30406	AND e.nrctremp = 12684) OR
(e.cdcooper = 7	AND e.nrdconta = 64785	AND e.nrctremp = 3062) OR (e.cdcooper = 7	AND e.nrdconta = 70394	AND e.nrctremp = 241100) OR
(e.cdcooper = 7	AND e.nrdconta = 78980	AND e.nrctremp = 16362) OR (e.cdcooper = 7	AND e.nrdconta = 80730	AND e.nrctremp = 13388) OR
(e.cdcooper = 7	AND e.nrdconta = 83305	AND e.nrctremp = 8527) OR (e.cdcooper = 7	AND e.nrdconta = 83550	AND e.nrctremp = 8577) OR
(e.cdcooper = 7	AND e.nrdconta = 85022	AND e.nrctremp = 21682) OR (e.cdcooper = 7	AND e.nrdconta = 85243	AND e.nrctremp = 12347) OR
(e.cdcooper = 7	AND e.nrdconta = 88277	AND e.nrctremp = 11427) OR (e.cdcooper = 7	AND e.nrdconta = 88447	AND e.nrctremp = 88447) OR
(e.cdcooper = 7	AND e.nrdconta = 92991	AND e.nrctremp = 10321) OR (e.cdcooper = 7	AND e.nrdconta = 93025	AND e.nrctremp = 10620) OR
(e.cdcooper = 7	AND e.nrdconta = 93025	AND e.nrctremp = 93025) OR (e.cdcooper = 7	AND e.nrdconta = 95532	AND e.nrctremp = 2308) OR
(e.cdcooper = 7	AND e.nrdconta = 97217	AND e.nrctremp = 10804) OR (e.cdcooper = 7	AND e.nrdconta = 102857	AND e.nrctremp = 8782) OR
(e.cdcooper = 7	AND e.nrdconta = 103527	AND e.nrctremp = 11706) OR (e.cdcooper = 7	AND e.nrdconta = 106755	AND e.nrctremp = 30819) OR
(e.cdcooper = 7	AND e.nrdconta = 107883	AND e.nrctremp = 15263) OR (e.cdcooper = 7	AND e.nrdconta = 113867	AND e.nrctremp = 8191) OR
(e.cdcooper = 7	AND e.nrdconta = 115797	AND e.nrctremp = 14450) OR (e.cdcooper = 7	AND e.nrdconta = 118907	AND e.nrctremp = 10827) OR
(e.cdcooper = 7	AND e.nrdconta = 122211	AND e.nrctremp = 28966) OR (e.cdcooper = 7	AND e.nrdconta = 122530	AND e.nrctremp = 18094) OR
(e.cdcooper = 7	AND e.nrdconta = 129372	AND e.nrctremp = 27609) OR (e.cdcooper = 7	AND e.nrdconta = 135186	AND e.nrctremp = 32505) OR
(e.cdcooper = 7	AND e.nrdconta = 136522	AND e.nrctremp = 18390) OR (e.cdcooper = 7	AND e.nrdconta = 137529	AND e.nrctremp = 25949) OR
(e.cdcooper = 7	AND e.nrdconta = 142492	AND e.nrctremp = 142492) OR (e.cdcooper = 7	AND e.nrdconta = 151416	AND e.nrctremp = 16448) OR
(e.cdcooper = 7	AND e.nrdconta = 157392	AND e.nrctremp = 19324) OR (e.cdcooper = 7	AND e.nrdconta = 157392	AND e.nrctremp = 26422) OR
(e.cdcooper = 7	AND e.nrdconta = 160172	AND e.nrctremp = 17769) OR (e.cdcooper = 7	AND e.nrdconta = 176370	AND e.nrctremp = 20342) OR
(e.cdcooper = 7	AND e.nrdconta = 176370	AND e.nrctremp = 23171) OR (e.cdcooper = 7	AND e.nrdconta = 184403	AND e.nrctremp = 30438) OR
(e.cdcooper = 7	AND e.nrdconta = 187291	AND e.nrctremp = 26726) OR (e.cdcooper = 7	AND e.nrdconta = 200174	AND e.nrctremp = 24711) OR
(e.cdcooper = 7	AND e.nrdconta = 203440	AND e.nrctremp = 29933) OR (e.cdcooper = 7	AND e.nrdconta = 211982	AND e.nrctremp = 33135) OR
(e.cdcooper = 7	AND e.nrdconta = 215090	AND e.nrctremp = 21667) OR (e.cdcooper = 7	AND e.nrdconta = 216704	AND e.nrctremp = 21293) OR
(e.cdcooper = 7	AND e.nrdconta = 229024	AND e.nrctremp = 9698) OR (e.cdcooper = 7	AND e.nrdconta = 231100	AND e.nrctremp = 18384) OR
(e.cdcooper = 7	AND e.nrdconta = 232262	AND e.nrctremp = 4540) OR (e.cdcooper = 7	AND e.nrdconta = 233544	AND e.nrctremp = 21332) OR
(e.cdcooper = 7	AND e.nrdconta = 233889	AND e.nrctremp = 14496) OR (e.cdcooper = 7	AND e.nrdconta = 239283	AND e.nrctremp = 14561) OR
(e.cdcooper = 7	AND e.nrdconta = 242853	AND e.nrctremp = 242853) OR (e.cdcooper = 7	AND e.nrdconta = 244732	AND e.nrctremp = 18818) OR
(e.cdcooper = 7	AND e.nrdconta = 249149	AND e.nrctremp = 31938) OR (e.cdcooper = 7	AND e.nrdconta = 249998	AND e.nrctremp = 12051) OR
(e.cdcooper = 7	AND e.nrdconta = 252697	AND e.nrctremp = 31254) OR (e.cdcooper = 7	AND e.nrdconta = 263680	AND e.nrctremp = 29289) OR
(e.cdcooper = 7	AND e.nrdconta = 263915	AND e.nrctremp = 29934) OR (e.cdcooper = 7	AND e.nrdconta = 281808	AND e.nrctremp = 7883) OR
(e.cdcooper = 7	AND e.nrdconta = 311472	AND e.nrctremp = 311472) OR (e.cdcooper = 7	AND e.nrdconta = 332755	AND e.nrctremp = 27063) OR
(e.cdcooper = 7	AND e.nrdconta = 334014	AND e.nrctremp = 19638) OR (e.cdcooper = 7	AND e.nrdconta = 335576	AND e.nrctremp = 8055) OR
(e.cdcooper = 8	AND e.nrdconta = 2569	AND e.nrctremp = 2937) OR (e.cdcooper = 8	AND e.nrdconta = 5215	AND e.nrctremp = 1540) OR
(e.cdcooper = 8	AND e.nrdconta = 5576	AND e.nrctremp = 1034) OR (e.cdcooper = 8	AND e.nrdconta = 5762	AND e.nrctremp = 423) OR
(e.cdcooper = 8	AND e.nrdconta = 5827	AND e.nrctremp = 1475) OR (e.cdcooper = 8	AND e.nrdconta = 7293	AND e.nrctremp = 631) OR
(e.cdcooper = 8	AND e.nrdconta = 9792	AND e.nrctremp = 83925) OR (e.cdcooper = 8	AND e.nrdconta = 10367	AND e.nrctremp = 1222) OR
(e.cdcooper = 8	AND e.nrdconta = 10375	AND e.nrctremp = 955) OR (e.cdcooper = 8	AND e.nrdconta = 10707	AND e.nrctremp = 2056) OR
(e.cdcooper = 8	AND e.nrdconta = 10707	AND e.nrctremp = 3983) OR (e.cdcooper = 8	AND e.nrdconta = 11584	AND e.nrctremp = 3837) OR
(e.cdcooper = 8	AND e.nrdconta = 16853	AND e.nrctremp = 1842) OR (e.cdcooper = 8	AND e.nrdconta = 17175	AND e.nrctremp = 1328) OR
(e.cdcooper = 8	AND e.nrdconta = 18856	AND e.nrctremp = 3967) OR (e.cdcooper = 8	AND e.nrdconta = 19623	AND e.nrctremp = 208532) OR
(e.cdcooper = 8	AND e.nrdconta = 20095	AND e.nrctremp = 5701) OR (e.cdcooper = 8	AND e.nrdconta = 20613	AND e.nrctremp = 247) OR
(e.cdcooper = 8	AND e.nrdconta = 20630	AND e.nrctremp = 253) OR (e.cdcooper = 8	AND e.nrdconta = 24252	AND e.nrctremp = 1653) OR
(e.cdcooper = 8	AND e.nrdconta = 25828	AND e.nrctremp = 2874) OR (e.cdcooper = 8	AND e.nrdconta = 27219	AND e.nrctremp = 4376) OR
(e.cdcooper = 8	AND e.nrdconta = 32069	AND e.nrctremp = 2628) OR (e.cdcooper = 8	AND e.nrdconta = 33448	AND e.nrctremp = 3294) OR
(e.cdcooper = 8	AND e.nrdconta = 33499	AND e.nrctremp = 3408) OR (e.cdcooper = 8	AND e.nrdconta = 34312	AND e.nrctremp = 6187) OR
(e.cdcooper = 8	AND e.nrdconta = 36331	AND e.nrctremp = 5923) OR (e.cdcooper = 8	AND e.nrdconta = 39675	AND e.nrctremp = 5584) OR
(e.cdcooper = 8	AND e.nrdconta = 40967	AND e.nrctremp = 5668) OR (e.cdcooper = 9	AND e.nrdconta = 2348	AND e.nrctremp = 2653) OR
(e.cdcooper = 9	AND e.nrdconta = 4316	AND e.nrctremp = 3553) OR (e.cdcooper = 9	AND e.nrdconta = 4316	AND e.nrctremp = 4316) OR
(e.cdcooper = 9	AND e.nrdconta = 13137	AND e.nrctremp = 13137) OR (e.cdcooper = 9	AND e.nrdconta = 17108	AND e.nrctremp = 7580) OR
(e.cdcooper = 9	AND e.nrdconta = 19577	AND e.nrctremp = 19577) OR (e.cdcooper = 9	AND e.nrdconta = 23531	AND e.nrctremp = 6018) OR
(e.cdcooper = 9	AND e.nrdconta = 30791	AND e.nrctremp = 30791) OR (e.cdcooper = 9	AND e.nrdconta = 34274	AND e.nrctremp = 34274) OR
(e.cdcooper = 9	AND e.nrdconta = 39632	AND e.nrctremp = 39632) OR (e.cdcooper = 9	AND e.nrdconta = 45527	AND e.nrctremp = 6748) OR
(e.cdcooper = 9	AND e.nrdconta = 48593	AND e.nrctremp = 2212) OR (e.cdcooper = 9	AND e.nrdconta = 50938	AND e.nrctremp = 19492) OR
(e.cdcooper = 9	AND e.nrdconta = 52230	AND e.nrctremp = 3327) OR (e.cdcooper = 9	AND e.nrdconta = 52388	AND e.nrctremp = 4121002) OR
(e.cdcooper = 9	AND e.nrdconta = 53449	AND e.nrctremp = 11926) OR (e.cdcooper = 9	AND e.nrdconta = 55921	AND e.nrctremp = 55921) OR
(e.cdcooper = 9	AND e.nrdconta = 60135	AND e.nrctremp = 60135) OR (e.cdcooper = 9	AND e.nrdconta = 60801	AND e.nrctremp = 60801) OR
(e.cdcooper = 9	AND e.nrdconta = 63371	AND e.nrctremp = 3684) OR (e.cdcooper = 9	AND e.nrdconta = 75248	AND e.nrctremp = 7292) OR
(e.cdcooper = 9	AND e.nrdconta = 76422	AND e.nrctremp = 76422) OR (e.cdcooper = 9	AND e.nrdconta = 87190	AND e.nrctremp = 6645) OR
(e.cdcooper = 9	AND e.nrdconta = 88803	AND e.nrctremp = 88803) OR (e.cdcooper = 9	AND e.nrdconta = 89060	AND e.nrctremp = 2121048) OR
(e.cdcooper = 9	AND e.nrdconta = 91545	AND e.nrctremp = 91545) OR (e.cdcooper = 9	AND e.nrdconta = 96067	AND e.nrctremp = 3620) OR
(e.cdcooper = 9	AND e.nrdconta = 99775	AND e.nrctremp = 2535) OR (e.cdcooper = 9	AND e.nrdconta = 100757	AND e.nrctremp = 20726) OR
(e.cdcooper = 9	AND e.nrdconta = 104507	AND e.nrctremp = 6099) OR (e.cdcooper = 9	AND e.nrdconta = 105090	AND e.nrctremp = 105090) OR
(e.cdcooper = 9	AND e.nrdconta = 105708	AND e.nrctremp = 105708) OR (e.cdcooper = 9	AND e.nrdconta = 115886	AND e.nrctremp = 115886) OR
(e.cdcooper = 9	AND e.nrdconta = 120120	AND e.nrctremp = 10668) OR (e.cdcooper = 9	AND e.nrdconta = 121207	AND e.nrctremp = 7643) OR
(e.cdcooper = 9	AND e.nrdconta = 121657	AND e.nrctremp = 7294) OR (e.cdcooper = 9	AND e.nrdconta = 121789	AND e.nrctremp = 5691) OR
(e.cdcooper = 9	AND e.nrdconta = 125164	AND e.nrctremp = 10257) OR (e.cdcooper = 9	AND e.nrdconta = 126918	AND e.nrctremp = 5946) OR
(e.cdcooper = 9	AND e.nrdconta = 127353	AND e.nrctremp = 1676) OR (e.cdcooper = 9	AND e.nrdconta = 129283	AND e.nrctremp = 7052) OR
(e.cdcooper = 9	AND e.nrdconta = 134082	AND e.nrctremp = 3838) OR (e.cdcooper = 9	AND e.nrdconta = 135674	AND e.nrctremp = 2642) OR
(e.cdcooper = 9	AND e.nrdconta = 141470	AND e.nrctremp = 7291) OR (e.cdcooper = 9	AND e.nrdconta = 146285	AND e.nrctremp = 11240) OR
(e.cdcooper = 9	AND e.nrdconta = 151556	AND e.nrctremp = 20787) OR (e.cdcooper = 9	AND e.nrdconta = 160598	AND e.nrctremp = 7913) OR
(e.cdcooper = 9	AND e.nrdconta = 161942	AND e.nrctremp = 8157) OR (e.cdcooper = 9	AND e.nrdconta = 162205	AND e.nrctremp = 12983) OR
(e.cdcooper = 9	AND e.nrdconta = 166944	AND e.nrctremp = 6135) OR (e.cdcooper = 9	AND e.nrdconta = 168025	AND e.nrctremp = 13879) OR
(e.cdcooper = 9	AND e.nrdconta = 172529	AND e.nrctremp = 12388) OR (e.cdcooper = 9	AND e.nrdconta = 184748	AND e.nrctremp = 9790) OR
(e.cdcooper = 9	AND e.nrdconta = 194905	AND e.nrctremp = 9344) OR (e.cdcooper = 9	AND e.nrdconta = 199524	AND e.nrctremp = 11745) OR
(e.cdcooper = 9	AND e.nrdconta = 205559	AND e.nrctremp = 11573) OR (e.cdcooper = 9	AND e.nrdconta = 209538	AND e.nrctremp = 12837) OR
(e.cdcooper = 9	AND e.nrdconta = 211109	AND e.nrctremp = 12860) OR (e.cdcooper = 9	AND e.nrdconta = 216895	AND e.nrctremp = 14391) OR
(e.cdcooper = 9	AND e.nrdconta = 222046	AND e.nrctremp = 11823) OR (e.cdcooper = 9	AND e.nrdconta = 226360	AND e.nrctremp = 15367) OR
(e.cdcooper = 9	AND e.nrdconta = 236977	AND e.nrctremp = 13394) OR (e.cdcooper = 9	AND e.nrdconta = 237353	AND e.nrctremp = 13607) OR
(e.cdcooper = 9	AND e.nrdconta = 237825	AND e.nrctremp = 13778) OR (e.cdcooper = 9	AND e.nrdconta = 243582	AND e.nrctremp = 14071) OR
(e.cdcooper = 9	AND e.nrdconta = 244490	AND e.nrctremp = 24341) OR (e.cdcooper = 9	AND e.nrdconta = 248797	AND e.nrctremp = 18920) OR
(e.cdcooper = 9	AND e.nrdconta = 903094	AND e.nrctremp = 16404) OR (e.cdcooper = 9	AND e.nrdconta = 903353	AND e.nrctremp = 9931) OR
(e.cdcooper = 9	AND e.nrdconta = 904589	AND e.nrctremp = 605) OR (e.cdcooper = 9	AND e.nrdconta = 905925	AND e.nrctremp = 905925) OR
(e.cdcooper = 9	AND e.nrdconta = 906026	AND e.nrctremp = 155) OR (e.cdcooper = 9	AND e.nrdconta = 906980	AND e.nrctremp = 625) OR
(e.cdcooper = 9	AND e.nrdconta = 910678	AND e.nrctremp = 7154) OR (e.cdcooper = 9	AND e.nrdconta = 911186	AND e.nrctremp = 10455) OR
(e.cdcooper = 9	AND e.nrdconta = 911291	AND e.nrctremp = 911291) OR (e.cdcooper = 9	AND e.nrdconta = 912263	AND e.nrctremp = 6493) OR
(e.cdcooper = 10	AND e.nrdconta = 256	 AND e.nrctremp = 256) OR (e.cdcooper = 10	AND e.nrdconta = 8117	AND e.nrctremp = 7645) OR
(e.cdcooper = 10	AND e.nrdconta = 16411	AND e.nrctremp = 16411) OR (e.cdcooper = 10	AND e.nrdconta = 18767	AND e.nrctremp = 18767) OR
(e.cdcooper = 10	AND e.nrdconta = 20990	AND e.nrctremp = 3424) OR (e.cdcooper = 10	AND e.nrdconta = 24678	AND e.nrctremp = 2670) OR
(e.cdcooper = 10	AND e.nrdconta = 25461	AND e.nrctremp = 1559) OR (e.cdcooper = 10	AND e.nrdconta = 25780	AND e.nrctremp = 1558) OR
(e.cdcooper = 10	AND e.nrdconta = 25780	AND e.nrctremp = 1794) OR (e.cdcooper = 10	AND e.nrdconta = 27294	AND e.nrctremp = 27294) OR
(e.cdcooper = 10	AND e.nrdconta = 27464	AND e.nrctremp = 27464) OR (e.cdcooper = 10	AND e.nrdconta = 28932	AND e.nrctremp = 2297) OR
(e.cdcooper = 10	AND e.nrdconta = 31941	AND e.nrctremp = 31941) OR (e.cdcooper = 10	AND e.nrdconta = 33367	AND e.nrctremp = 33367) OR
(e.cdcooper = 10	AND e.nrdconta = 39195	AND e.nrctremp = 39195) OR (e.cdcooper = 10	AND e.nrdconta = 40959	AND e.nrctremp = 40959) OR
(e.cdcooper = 10	AND e.nrdconta = 42331	AND e.nrctremp = 1318) OR (e.cdcooper = 10	AND e.nrdconta = 43281	AND e.nrctremp = 43281) OR
(e.cdcooper = 10	AND e.nrdconta = 43290	AND e.nrctremp = 3302) OR (e.cdcooper = 10	AND e.nrdconta = 44105	AND e.nrctremp = 44105) OR
(e.cdcooper = 10	AND e.nrdconta = 44482	AND e.nrctremp = 44482) OR (e.cdcooper = 10	AND e.nrdconta = 44954	AND e.nrctremp = 44954) OR
(e.cdcooper = 10	AND e.nrdconta = 45071	AND e.nrctremp = 45071) OR (e.cdcooper = 10	AND e.nrdconta = 45276	AND e.nrctremp = 3633) OR
(e.cdcooper = 10	AND e.nrdconta = 46329	AND e.nrctremp = 46329) OR (e.cdcooper = 10	AND e.nrdconta = 50660	AND e.nrctremp = 50660) OR
(e.cdcooper = 10	AND e.nrdconta = 62480	AND e.nrctremp = 4920) OR (e.cdcooper = 10	AND e.nrdconta = 62693	AND e.nrctremp = 6184) OR
(e.cdcooper = 10	AND e.nrdconta = 65617	AND e.nrctremp = 9771) OR (e.cdcooper = 10	AND e.nrdconta = 79022	AND e.nrctremp = 5509) OR
(e.cdcooper = 10	AND e.nrdconta = 81647	AND e.nrctremp = 7976) OR (e.cdcooper = 10	AND e.nrdconta = 88390	AND e.nrctremp = 4994) OR
(e.cdcooper = 10	AND e.nrdconta = 100587	AND e.nrctremp = 3638) OR (e.cdcooper = 10	AND e.nrdconta = 101648	AND e.nrctremp = 3618) OR
(e.cdcooper = 10	AND e.nrdconta = 102032	AND e.nrctremp = 102032) OR (e.cdcooper = 10	AND e.nrdconta = 102237	AND e.nrctremp = 102237) OR
(e.cdcooper = 10	AND e.nrdconta = 102776	AND e.nrctremp = 4357) OR (e.cdcooper = 10	AND e.nrdconta = 102911	AND e.nrctremp = 102911) OR
(e.cdcooper = 10	AND e.nrdconta = 103667	AND e.nrctremp = 5665) OR (e.cdcooper = 11	AND e.nrdconta = 3638	AND e.nrctremp = 3638) OR
(e.cdcooper = 11	AND e.nrdconta = 4529	AND e.nrctremp = 35431) OR (e.cdcooper = 11	AND e.nrdconta = 18830	AND e.nrctremp = 18830) OR
(e.cdcooper = 11	AND e.nrdconta = 20729	AND e.nrctremp = 20729) OR (e.cdcooper = 11	AND e.nrdconta = 22071	AND e.nrctremp = 11847) OR
(e.cdcooper = 11	AND e.nrdconta = 22357	AND e.nrctremp = 23727) OR (e.cdcooper = 11	AND e.nrdconta = 25666	AND e.nrctremp = 22005) OR
(e.cdcooper = 11	AND e.nrdconta = 27928	AND e.nrctremp = 27928) OR (e.cdcooper = 11	AND e.nrdconta = 29050	AND e.nrctremp = 5814) OR
(e.cdcooper = 11	AND e.nrdconta = 30309	AND e.nrctremp = 16623) OR (e.cdcooper = 11	AND e.nrdconta = 32530	AND e.nrctremp = 66582) OR
(e.cdcooper = 11	AND e.nrdconta = 32891	AND e.nrctremp = 34617) OR (e.cdcooper = 11	AND e.nrdconta = 33774	AND e.nrctremp = 16556) OR
(e.cdcooper = 11	AND e.nrdconta = 34118	AND e.nrctremp = 56254) OR (e.cdcooper = 11	AND e.nrdconta = 35017	AND e.nrctremp = 35129) OR
(e.cdcooper = 11	AND e.nrdconta = 38717	AND e.nrctremp = 13574) OR (e.cdcooper = 11	AND e.nrdconta = 39969	AND e.nrctremp = 46685) OR
(e.cdcooper = 11	AND e.nrdconta = 44482	AND e.nrctremp = 44482) OR (e.cdcooper = 11	AND e.nrdconta = 48151	AND e.nrctremp = 24108) OR
(e.cdcooper = 11	AND e.nrdconta = 50172	AND e.nrctremp = 13449) OR (e.cdcooper = 11	AND e.nrdconta = 51659	AND e.nrctremp = 30687) OR
(e.cdcooper = 11	AND e.nrdconta = 55832	AND e.nrctremp = 69420) OR (e.cdcooper = 11	AND e.nrdconta = 56391	AND e.nrctremp = 7723) OR
(e.cdcooper = 11	AND e.nrdconta = 63436	AND e.nrctremp = 53372) OR (e.cdcooper = 11	AND e.nrdconta = 69361	AND e.nrctremp = 69361) OR
(e.cdcooper = 11	AND e.nrdconta = 74233	AND e.nrctremp = 49884) OR (e.cdcooper = 11	AND e.nrdconta = 74535	AND e.nrctremp = 86302) OR
(e.cdcooper = 11	AND e.nrdconta = 75779	AND e.nrctremp = 27239) OR (e.cdcooper = 11	AND e.nrdconta = 76279	AND e.nrctremp = 19581) OR
(e.cdcooper = 11	AND e.nrdconta = 78808	AND e.nrctremp = 9035) OR (e.cdcooper = 11	AND e.nrdconta = 81949	AND e.nrctremp = 35432) OR
(e.cdcooper = 11	AND e.nrdconta = 82350	AND e.nrctremp = 4806) OR (e.cdcooper = 11	AND e.nrdconta = 82350	AND e.nrctremp = 82350) OR
(e.cdcooper = 11	AND e.nrdconta = 86576	AND e.nrctremp = 15373) OR (e.cdcooper = 11	AND e.nrdconta = 87068	AND e.nrctremp = 19794) OR
(e.cdcooper = 11	AND e.nrdconta = 87610	AND e.nrctremp = 87610) OR (e.cdcooper = 11	AND e.nrdconta = 88951	AND e.nrctremp = 44008) OR
(e.cdcooper = 11	AND e.nrdconta = 89036	AND e.nrctremp = 33454) OR (e.cdcooper = 11	AND e.nrdconta = 94234	AND e.nrctremp = 9247) OR
(e.cdcooper = 11	AND e.nrdconta = 94722	AND e.nrctremp = 22134) OR (e.cdcooper = 11	AND e.nrdconta = 95907	AND e.nrctremp = 95907) OR
(e.cdcooper = 11	AND e.nrdconta = 97942	AND e.nrctremp = 97942) OR (e.cdcooper = 11	AND e.nrdconta = 102334	AND e.nrctremp = 102334) OR
(e.cdcooper = 11	AND e.nrdconta = 103276	AND e.nrctremp = 103276) OR (e.cdcooper = 11	AND e.nrdconta = 105252	AND e.nrctremp = 10080) OR
(e.cdcooper = 11	AND e.nrdconta = 107123	AND e.nrctremp = 9210) OR (e.cdcooper = 11	AND e.nrdconta = 107760	AND e.nrctremp = 68253) OR
(e.cdcooper = 11	AND e.nrdconta = 108740	AND e.nrctremp = 68741) OR (e.cdcooper = 11	AND e.nrdconta = 109800	AND e.nrctremp = 13679) OR
(e.cdcooper = 11	AND e.nrdconta = 112720	AND e.nrctremp = 22040) OR (e.cdcooper = 11	AND e.nrdconta = 117323	AND e.nrctremp = 117323) OR
(e.cdcooper = 11	AND e.nrdconta = 120391	AND e.nrctremp = 52889) OR (e.cdcooper = 11	AND e.nrdconta = 123617	AND e.nrctremp = 27958) OR
(e.cdcooper = 11	AND e.nrdconta = 124931	AND e.nrctremp = 58441) OR (e.cdcooper = 11	AND e.nrdconta = 125431	AND e.nrctremp = 125431) OR
(e.cdcooper = 11	AND e.nrdconta = 126780	AND e.nrctremp = 7250) OR (e.cdcooper = 11	AND e.nrdconta = 131199	AND e.nrctremp = 131199) OR
(e.cdcooper = 11	AND e.nrdconta = 133183	AND e.nrctremp = 133183) OR (e.cdcooper = 11	AND e.nrdconta = 135011	AND e.nrctremp = 51054) OR
(e.cdcooper = 11	AND e.nrdconta = 135690	AND e.nrctremp = 56240) OR (e.cdcooper = 11	AND e.nrdconta = 137049	AND e.nrctremp = 6690) OR
(e.cdcooper = 11	AND e.nrdconta = 137553	AND e.nrctremp = 137553) OR (e.cdcooper = 11	AND e.nrdconta = 140570	AND e.nrctremp = 140570) OR
(e.cdcooper = 11	AND e.nrdconta = 142484	AND e.nrctremp = 3573) OR (e.cdcooper = 11	AND e.nrdconta = 142735	AND e.nrctremp = 20624) OR
(e.cdcooper = 11	AND e.nrdconta = 151173	AND e.nrctremp = 18438) OR (e.cdcooper = 11	AND e.nrdconta = 152978	AND e.nrctremp = 152978) OR
(e.cdcooper = 11	AND e.nrdconta = 154571	AND e.nrctremp = 34508) OR (e.cdcooper = 11	AND e.nrdconta = 154849	AND e.nrctremp = 27076) OR
(e.cdcooper = 11	AND e.nrdconta = 155284	AND e.nrctremp = 65190) OR (e.cdcooper = 11	AND e.nrdconta = 158755	AND e.nrctremp = 158755) OR
(e.cdcooper = 11	AND e.nrdconta = 159956	AND e.nrctremp = 10453) OR (e.cdcooper = 11	AND e.nrdconta = 160059	AND e.nrctremp = 160059) OR
(e.cdcooper = 11	AND e.nrdconta = 164577	AND e.nrctremp = 18297) OR (e.cdcooper = 11	AND e.nrdconta = 165670	AND e.nrctremp = 26580) OR
(e.cdcooper = 11	AND e.nrdconta = 170534	AND e.nrctremp = 12818) OR (e.cdcooper = 11	AND e.nrdconta = 170739	AND e.nrctremp = 170739) OR
(e.cdcooper = 11	AND e.nrdconta = 172006	AND e.nrctremp = 6711) OR (e.cdcooper = 11	AND e.nrdconta = 173754	AND e.nrctremp = 1156) OR
(e.cdcooper = 11	AND e.nrdconta = 174947	AND e.nrctremp = 1154) OR (e.cdcooper = 11	AND e.nrdconta = 176630	AND e.nrctremp = 28367) OR
(e.cdcooper = 11	AND e.nrdconta = 177342	AND e.nrctremp = 8642) OR (e.cdcooper = 11	AND e.nrdconta = 177350	AND e.nrctremp = 33280) OR
(e.cdcooper = 11	AND e.nrdconta = 178268	AND e.nrctremp = 178268) OR (e.cdcooper = 11	AND e.nrdconta = 178306	AND e.nrctremp = 178306) OR
(e.cdcooper = 11	AND e.nrdconta = 178420	AND e.nrctremp = 178420) OR (e.cdcooper = 11	AND e.nrdconta = 178616	AND e.nrctremp = 178616) OR
(e.cdcooper = 11	AND e.nrdconta = 181978	AND e.nrctremp = 25593) OR (e.cdcooper = 11	AND e.nrdconta = 185019	AND e.nrctremp = 19606) OR
(e.cdcooper = 11	AND e.nrdconta = 186023	AND e.nrctremp = 9400) OR (e.cdcooper = 11	AND e.nrdconta = 186252	AND e.nrctremp = 186252) OR
(e.cdcooper = 11	AND e.nrdconta = 187097	AND e.nrctremp = 23624) OR (e.cdcooper = 11	AND e.nrdconta = 187631	AND e.nrctremp = 21953) OR
(e.cdcooper = 11	AND e.nrdconta = 192040	AND e.nrctremp = 10537) OR (e.cdcooper = 11	AND e.nrdconta = 198064	AND e.nrctremp = 8060) OR
(e.cdcooper = 11	AND e.nrdconta = 198374	AND e.nrctremp = 198374) OR (e.cdcooper = 11	AND e.nrdconta = 200212	AND e.nrctremp = 200212) OR
(e.cdcooper = 11	AND e.nrdconta = 202649	AND e.nrctremp = 50528) OR (e.cdcooper = 11	AND e.nrdconta = 203424	AND e.nrctremp = 7728) OR
(e.cdcooper = 11	AND e.nrdconta = 207292	AND e.nrctremp = 9243) OR (e.cdcooper = 11	AND e.nrdconta = 207969	AND e.nrctremp = 8681) OR
(e.cdcooper = 11	AND e.nrdconta = 208523	AND e.nrctremp = 36023) OR (e.cdcooper = 11	AND e.nrdconta = 208930	AND e.nrctremp = 18744) OR
(e.cdcooper = 11	AND e.nrdconta = 209147	AND e.nrctremp = 209147) OR (e.cdcooper = 11	AND e.nrdconta = 209732	AND e.nrctremp = 209732) OR
(e.cdcooper = 11	AND e.nrdconta = 209929	AND e.nrctremp = 209929) OR (e.cdcooper = 11	AND e.nrdconta = 210501	AND e.nrctremp = 210501) OR
(e.cdcooper = 11	AND e.nrdconta = 211427	AND e.nrctremp = 211427) OR (e.cdcooper = 11	AND e.nrdconta = 212393	AND e.nrctremp = 212393) OR
(e.cdcooper = 11	AND e.nrdconta = 212849	AND e.nrctremp = 212849) OR (e.cdcooper = 11	AND e.nrdconta = 213888	AND e.nrctremp = 5111) OR
(e.cdcooper = 11	AND e.nrdconta = 215554	AND e.nrctremp = 215554) OR (e.cdcooper = 11	AND e.nrdconta = 216496	AND e.nrctremp = 15485) OR
(e.cdcooper = 11	AND e.nrdconta = 218197	AND e.nrctremp = 68222) OR (e.cdcooper = 11	AND e.nrdconta = 219134	AND e.nrctremp = 30080) OR
(e.cdcooper = 11	AND e.nrdconta = 221376	AND e.nrctremp = 20380) OR (e.cdcooper = 11	AND e.nrdconta = 221848	AND e.nrctremp = 2218481) OR
(e.cdcooper = 11	AND e.nrdconta = 223301	AND e.nrctremp = 41018) OR (e.cdcooper = 11	AND e.nrdconta = 224057	AND e.nrctremp = 224057) OR
(e.cdcooper = 11	AND e.nrdconta = 224219	AND e.nrctremp = 20816) OR (e.cdcooper = 11	AND e.nrdconta = 225630	AND e.nrctremp = 14702) OR
(e.cdcooper = 11	AND e.nrdconta = 226645	AND e.nrctremp = 32116) OR (e.cdcooper = 11	AND e.nrdconta = 227129	AND e.nrctremp = 25245) OR
(e.cdcooper = 11	AND e.nrdconta = 227579	AND e.nrctremp = 15650) OR (e.cdcooper = 11	AND e.nrdconta = 229660	AND e.nrctremp = 53008) OR
(e.cdcooper = 11	AND e.nrdconta = 230723	AND e.nrctremp = 25007) OR (e.cdcooper = 11	AND e.nrdconta = 232513	AND e.nrctremp = 19982) OR
(e.cdcooper = 11	AND e.nrdconta = 233234	AND e.nrctremp = 34607) OR (e.cdcooper = 11	AND e.nrdconta = 235547	AND e.nrctremp = 235547) OR
(e.cdcooper = 11	AND e.nrdconta = 235733	AND e.nrctremp = 235733) OR (e.cdcooper = 11	AND e.nrdconta = 237442	AND e.nrctremp = 31269) OR
(e.cdcooper = 11	AND e.nrdconta = 240001	AND e.nrctremp = 240001) OR (e.cdcooper = 11	AND e.nrdconta = 240010	AND e.nrctremp = 20998) OR
(e.cdcooper = 11	AND e.nrdconta = 241172	AND e.nrctremp = 2003) OR (e.cdcooper = 11	AND e.nrdconta = 243566	AND e.nrctremp = 15471) OR
(e.cdcooper = 11	AND e.nrdconta = 243698	AND e.nrctremp = 55404) OR (e.cdcooper = 11	AND e.nrdconta = 244015	AND e.nrctremp = 55451) OR
(e.cdcooper = 11	AND e.nrdconta = 244376	AND e.nrctremp = 30837) OR (e.cdcooper = 11	AND e.nrdconta = 245208	AND e.nrctremp = 245208) OR
(e.cdcooper = 11	AND e.nrdconta = 245453	AND e.nrctremp = 16625) OR (e.cdcooper = 11	AND e.nrdconta = 245500	AND e.nrctremp = 245500) OR
(e.cdcooper = 11	AND e.nrdconta = 246050	AND e.nrctremp = 246050) OR (e.cdcooper = 11	AND e.nrdconta = 246581	AND e.nrctremp = 21244) OR
(e.cdcooper = 11	AND e.nrdconta = 246751	AND e.nrctremp = 45740) OR (e.cdcooper = 11	AND e.nrdconta = 248150	AND e.nrctremp = 25954) OR
(e.cdcooper = 11	AND e.nrdconta = 248649	AND e.nrctremp = 14753) OR (e.cdcooper = 11	AND e.nrdconta = 250538	AND e.nrctremp = 24288) OR
(e.cdcooper = 11	AND e.nrdconta = 250856	AND e.nrctremp = 250856) OR (e.cdcooper = 11	AND e.nrdconta = 251771	AND e.nrctremp = 53004) OR
(e.cdcooper = 11	AND e.nrdconta = 254169	AND e.nrctremp = 12032) OR (e.cdcooper = 11	AND e.nrdconta = 256862	AND e.nrctremp = 47089) OR
(e.cdcooper = 11	AND e.nrdconta = 258210	AND e.nrctremp = 11632) OR (e.cdcooper = 11	AND e.nrdconta = 258563	AND e.nrctremp = 258563) OR
(e.cdcooper = 11	AND e.nrdconta = 258954	AND e.nrctremp = 19650) OR (e.cdcooper = 11	AND e.nrdconta = 259110	AND e.nrctremp = 259110) OR
(e.cdcooper = 11	AND e.nrdconta = 259853	AND e.nrctremp = 259853) OR (e.cdcooper = 11	AND e.nrdconta = 260240	AND e.nrctremp = 11011) OR
(e.cdcooper = 11	AND e.nrdconta = 260509	AND e.nrctremp = 260509) OR (e.cdcooper = 11	AND e.nrdconta = 260525	AND e.nrctremp = 260525) OR
(e.cdcooper = 11	AND e.nrdconta = 261092	AND e.nrctremp = 261092) OR (e.cdcooper = 11	AND e.nrdconta = 262536	AND e.nrctremp = 30339) OR
(e.cdcooper = 11	AND e.nrdconta = 262609	AND e.nrctremp = 15720) OR (e.cdcooper = 11	AND e.nrdconta = 262650	AND e.nrctremp = 262650) OR
(e.cdcooper = 11	AND e.nrdconta = 264644	AND e.nrctremp = 264644) OR (e.cdcooper = 11	AND e.nrdconta = 264717	AND e.nrctremp = 264717) OR
(e.cdcooper = 11	AND e.nrdconta = 264830	AND e.nrctremp = 264830) OR (e.cdcooper = 11	AND e.nrdconta = 266639	AND e.nrctremp = 53424) OR
(e.cdcooper = 11	AND e.nrdconta = 266833	AND e.nrctremp = 266833) OR (e.cdcooper = 11	AND e.nrdconta = 267686	AND e.nrctremp = 267686) OR
(e.cdcooper = 11	AND e.nrdconta = 268330	AND e.nrctremp = 268330) OR (e.cdcooper = 11	AND e.nrdconta = 268712	AND e.nrctremp = 45675) OR
(e.cdcooper = 11	AND e.nrdconta = 269204	AND e.nrctremp = 269204) OR (e.cdcooper = 11	AND e.nrdconta = 269751	AND e.nrctremp = 269751) OR
(e.cdcooper = 11	AND e.nrdconta = 271039	AND e.nrctremp = 271039) OR (e.cdcooper = 11	AND e.nrdconta = 271292	AND e.nrctremp = 271292) OR
(e.cdcooper = 11	AND e.nrdconta = 271411	AND e.nrctremp = 33275) OR (e.cdcooper = 11	AND e.nrdconta = 271420	AND e.nrctremp = 271420) OR
(e.cdcooper = 11	AND e.nrdconta = 271543	AND e.nrctremp = 271543) OR (e.cdcooper = 11	AND e.nrdconta = 272809	AND e.nrctremp = 64415) OR
(e.cdcooper = 11	AND e.nrdconta = 274119	AND e.nrctremp = 57187) OR (e.cdcooper = 11	AND e.nrdconta = 275328	AND e.nrctremp = 54400) OR
(e.cdcooper = 11	AND e.nrdconta = 277010	AND e.nrctremp = 19600) OR (e.cdcooper = 11	AND e.nrdconta = 278246	AND e.nrctremp = 16410) OR
(e.cdcooper = 11	AND e.nrdconta = 281000	AND e.nrctremp = 281000) OR (e.cdcooper = 11	AND e.nrdconta = 282537	AND e.nrctremp = 13584) OR
(e.cdcooper = 11	AND e.nrdconta = 283290	AND e.nrctremp = 14912) OR (e.cdcooper = 11	AND e.nrdconta = 284319	AND e.nrctremp = 284319) OR
(e.cdcooper = 11	AND e.nrdconta = 285013	AND e.nrctremp = 285013) OR (e.cdcooper = 11	AND e.nrdconta = 285102	AND e.nrctremp = 404105) OR
(e.cdcooper = 11	AND e.nrdconta = 285544	AND e.nrctremp = 54066) OR (e.cdcooper = 11	AND e.nrdconta = 286044	AND e.nrctremp = 286044) OR
(e.cdcooper = 11	AND e.nrdconta = 286346	AND e.nrctremp = 27060) OR (e.cdcooper = 11	AND e.nrdconta = 287385	AND e.nrctremp = 13210) OR
(e.cdcooper = 11	AND e.nrdconta = 287580	AND e.nrctremp = 287580) OR (e.cdcooper = 11	AND e.nrdconta = 289183	AND e.nrctremp = 1150) OR
(e.cdcooper = 11	AND e.nrdconta = 290122	AND e.nrctremp = 290122) OR (e.cdcooper = 11	AND e.nrdconta = 290190	AND e.nrctremp = 290190) OR
(e.cdcooper = 11	AND e.nrdconta = 290300	AND e.nrctremp = 290300) OR (e.cdcooper = 11	AND e.nrdconta = 290564	AND e.nrctremp = 20318) OR
(e.cdcooper = 11	AND e.nrdconta = 291188	AND e.nrctremp = 291188) OR (e.cdcooper = 11	AND e.nrdconta = 291633	AND e.nrctremp = 20416) OR
(e.cdcooper = 11	AND e.nrdconta = 291803	AND e.nrctremp = 291803) OR (e.cdcooper = 11	AND e.nrdconta = 292800	AND e.nrctremp = 292800) OR
(e.cdcooper = 11	AND e.nrdconta = 293830	AND e.nrctremp = 14293) OR (e.cdcooper = 11	AND e.nrdconta = 294020	AND e.nrctremp = 294020) OR
(e.cdcooper = 11	AND e.nrdconta = 295221	AND e.nrctremp = 32132) OR (e.cdcooper = 11	AND e.nrdconta = 295345	AND e.nrctremp = 292630) OR
(e.cdcooper = 11	AND e.nrdconta = 295590	AND e.nrctremp = 70597) OR (e.cdcooper = 11	AND e.nrdconta = 297160	AND e.nrctremp = 19634) OR
(e.cdcooper = 11	AND e.nrdconta = 299391	AND e.nrctremp = 33513) OR (e.cdcooper = 11	AND e.nrdconta = 299812	AND e.nrctremp = 299812) OR
(e.cdcooper = 11	AND e.nrdconta = 299820	AND e.nrctremp = 299820) OR (e.cdcooper = 11	AND e.nrdconta = 300349	AND e.nrctremp = 300349) OR
(e.cdcooper = 11	AND e.nrdconta = 300543	AND e.nrctremp = 34853) OR (e.cdcooper = 11	AND e.nrdconta = 300608	AND e.nrctremp = 300608) OR
(e.cdcooper = 11	AND e.nrdconta = 301469	AND e.nrctremp = 301469) OR (e.cdcooper = 11	AND e.nrdconta = 301833	AND e.nrctremp = 18478) OR
(e.cdcooper = 11	AND e.nrdconta = 302236	AND e.nrctremp = 302236) OR (e.cdcooper = 11	AND e.nrdconta = 303488	AND e.nrctremp = 54071) OR
(e.cdcooper = 11	AND e.nrdconta = 304026	AND e.nrctremp = 45902) OR (e.cdcooper = 11	AND e.nrdconta = 304115	AND e.nrctremp = 304115) OR
(e.cdcooper = 11	AND e.nrdconta = 304441	AND e.nrctremp = 304441) OR (e.cdcooper = 11	AND e.nrdconta = 305553	AND e.nrctremp = 305553) OR
(e.cdcooper = 11	AND e.nrdconta = 305570	AND e.nrctremp = 18830) OR (e.cdcooper = 11	AND e.nrdconta = 305642	AND e.nrctremp = 305642) OR
(e.cdcooper = 11	AND e.nrdconta = 305928	AND e.nrctremp = 305928) OR (e.cdcooper = 11	AND e.nrdconta = 307173	AND e.nrctremp = 307173) OR
(e.cdcooper = 11	AND e.nrdconta = 307912	AND e.nrctremp = 16560) OR (e.cdcooper = 11	AND e.nrdconta = 308919	AND e.nrctremp = 55448) OR
(e.cdcooper = 11	AND e.nrdconta = 309494	AND e.nrctremp = 66392) OR (e.cdcooper = 11	AND e.nrdconta = 313637	AND e.nrctremp = 28299) OR
(e.cdcooper = 11	AND e.nrdconta = 315923	AND e.nrctremp = 315923) OR (e.cdcooper = 11	AND e.nrdconta = 315940	AND e.nrctremp = 315940) OR
(e.cdcooper = 11	AND e.nrdconta = 316890	AND e.nrctremp = 3168901) OR (e.cdcooper = 11	AND e.nrdconta = 319210	AND e.nrctremp = 57099) OR
(e.cdcooper = 11	AND e.nrdconta = 319546	AND e.nrctremp = 20218) OR (e.cdcooper = 11	AND e.nrdconta = 320552	AND e.nrctremp = 320552) OR
(e.cdcooper = 11	AND e.nrdconta = 321265	AND e.nrctremp = 57176) OR (e.cdcooper = 11	AND e.nrdconta = 321460	AND e.nrctremp = 321460) OR
(e.cdcooper = 11	AND e.nrdconta = 322130	AND e.nrctremp = 54425) OR (e.cdcooper = 11	AND e.nrdconta = 322520	AND e.nrctremp = 27781) OR
(e.cdcooper = 11	AND e.nrdconta = 322598	AND e.nrctremp = 31028) OR (e.cdcooper = 11	AND e.nrdconta = 323357	AND e.nrctremp = 53416) OR
(e.cdcooper = 11	AND e.nrdconta = 325155	AND e.nrctremp = 25765) OR (e.cdcooper = 11	AND e.nrdconta = 326534	AND e.nrctremp = 326534) OR
(e.cdcooper = 11	AND e.nrdconta = 327409	AND e.nrctremp = 327409) OR (e.cdcooper = 11	AND e.nrdconta = 329592	AND e.nrctremp = 329592) OR
(e.cdcooper = 11	AND e.nrdconta = 329720	AND e.nrctremp = 25019) OR (e.cdcooper = 11	AND e.nrdconta = 330051	AND e.nrctremp = 23557) OR
(e.cdcooper = 11	AND e.nrdconta = 330159	AND e.nrctremp = 57210) OR (e.cdcooper = 11	AND e.nrdconta = 330779	AND e.nrctremp = 46565) OR
(e.cdcooper = 11	AND e.nrdconta = 330973	AND e.nrctremp = 22833) OR (e.cdcooper = 11	AND e.nrdconta = 333603	AND e.nrctremp = 30835) OR
(e.cdcooper = 11	AND e.nrdconta = 333794	AND e.nrctremp = 333794) OR (e.cdcooper = 11	AND e.nrdconta = 336017	AND e.nrctremp = 336017) OR
(e.cdcooper = 11	AND e.nrdconta = 337617	AND e.nrctremp = 39762) OR (e.cdcooper = 11	AND e.nrdconta = 339873	AND e.nrctremp = 3398731) OR
(e.cdcooper = 11	AND e.nrdconta = 340383	AND e.nrctremp = 32642) OR (e.cdcooper = 11	AND e.nrdconta = 341762	AND e.nrctremp = 25972) OR
(e.cdcooper = 11	AND e.nrdconta = 342947	AND e.nrctremp = 342947) OR (e.cdcooper = 11	AND e.nrdconta = 344133	AND e.nrctremp = 53592) OR
(e.cdcooper = 11	AND e.nrdconta = 344265	AND e.nrctremp = 33690) OR (e.cdcooper = 11	AND e.nrdconta = 344265	AND e.nrctremp = 39166) OR
(e.cdcooper = 11	AND e.nrdconta = 344362	AND e.nrctremp = 28656) OR (e.cdcooper = 11	AND e.nrdconta = 346322	AND e.nrctremp = 53458) OR
(e.cdcooper = 11	AND e.nrdconta = 348880	AND e.nrctremp = 64836) OR (e.cdcooper = 11	AND e.nrdconta = 351059	AND e.nrctremp = 351059) OR
(e.cdcooper = 11	AND e.nrdconta = 351148	AND e.nrctremp = 47439) OR (e.cdcooper = 11	AND e.nrdconta = 353396	AND e.nrctremp = 36498) OR
(e.cdcooper = 11	AND e.nrdconta = 354120	AND e.nrctremp = 28788) OR (e.cdcooper = 11	AND e.nrdconta = 356182	AND e.nrctremp = 47498) OR
(e.cdcooper = 11	AND e.nrdconta = 358010	AND e.nrctremp = 68206) OR (e.cdcooper = 11	AND e.nrdconta = 358185	AND e.nrctremp = 25666) OR
(e.cdcooper = 11	AND e.nrdconta = 359211	AND e.nrctremp = 27637) OR (e.cdcooper = 11	AND e.nrdconta = 359211	AND e.nrctremp = 33257) OR
(e.cdcooper = 11	AND e.nrdconta = 360252	AND e.nrctremp = 65166) OR (e.cdcooper = 11	AND e.nrdconta = 360279	AND e.nrctremp = 53471) OR
(e.cdcooper = 11	AND e.nrdconta = 361356	AND e.nrctremp = 26432) OR (e.cdcooper = 11	AND e.nrdconta = 361496	AND e.nrctremp = 45970) OR
(e.cdcooper = 11	AND e.nrdconta = 362956	AND e.nrctremp = 55378) OR (e.cdcooper = 11	AND e.nrdconta = 363707	AND e.nrctremp = 58664) OR
(e.cdcooper = 11	AND e.nrdconta = 363863	AND e.nrctremp = 63673) OR (e.cdcooper = 11	AND e.nrdconta = 366366	AND e.nrctremp = 57116) OR
(e.cdcooper = 11	AND e.nrdconta = 368679	AND e.nrctremp = 59243) OR (e.cdcooper = 11	AND e.nrdconta = 369047	AND e.nrctremp = 43667) OR
(e.cdcooper = 11	AND e.nrdconta = 369705	AND e.nrctremp = 25150) OR (e.cdcooper = 11	AND e.nrdconta = 371106	AND e.nrctremp = 53598) OR
(e.cdcooper = 11	AND e.nrdconta = 373699	AND e.nrctremp = 54409) OR (e.cdcooper = 11	AND e.nrdconta = 374873	AND e.nrctremp = 32794) OR
(e.cdcooper = 11	AND e.nrdconta = 377015	AND e.nrctremp = 65189) OR (e.cdcooper = 11	AND e.nrdconta = 377430	AND e.nrctremp = 68205) OR
(e.cdcooper = 11	AND e.nrdconta = 384194	AND e.nrctremp = 67773) OR (e.cdcooper = 11	AND e.nrdconta = 386359	AND e.nrctremp = 43238) OR
(e.cdcooper = 11	AND e.nrdconta = 387851	AND e.nrctremp = 52233) OR (e.cdcooper = 11	AND e.nrdconta = 390909	AND e.nrctremp = 64772) OR
(e.cdcooper = 11	AND e.nrdconta = 390917	AND e.nrctremp = 38511) OR (e.cdcooper = 11	AND e.nrdconta = 390917	AND e.nrctremp = 66550) OR
(e.cdcooper = 11	AND e.nrdconta = 391000	AND e.nrctremp = 50560) OR (e.cdcooper = 11	AND e.nrdconta = 391115	AND e.nrctremp = 43938) OR
(e.cdcooper = 11	AND e.nrdconta = 391301	AND e.nrctremp = 65855) OR (e.cdcooper = 11	AND e.nrdconta = 391816	AND e.nrctremp = 40663) OR
(e.cdcooper = 11	AND e.nrdconta = 392073	AND e.nrctremp = 53589) OR (e.cdcooper = 11	AND e.nrdconta = 392847	AND e.nrctremp = 57165) OR
(e.cdcooper = 11	AND e.nrdconta = 395714	AND e.nrctremp = 67018) OR (e.cdcooper = 11	AND e.nrdconta = 396567	AND e.nrctremp = 53427) OR
(e.cdcooper = 11	AND e.nrdconta = 401129	AND e.nrctremp = 39219) OR (e.cdcooper = 11	AND e.nrdconta = 406546	AND e.nrctremp = 60468) OR
(e.cdcooper = 11	AND e.nrdconta = 409367	AND e.nrctremp = 56954) OR (e.cdcooper = 11	AND e.nrdconta = 410870	AND e.nrctremp = 37006) OR
(e.cdcooper = 11	AND e.nrdconta = 412619	AND e.nrctremp = 37070) OR (e.cdcooper = 11	AND e.nrdconta = 413798	AND e.nrctremp = 42453) OR
(e.cdcooper = 11	AND e.nrdconta = 415731	AND e.nrctremp = 58665) OR (e.cdcooper = 11	AND e.nrdconta = 415987	AND e.nrctremp = 53400) OR
(e.cdcooper = 11	AND e.nrdconta = 416894	AND e.nrctremp = 47021) OR (e.cdcooper = 11	AND e.nrdconta = 418781	AND e.nrctremp = 46292) OR
(e.cdcooper = 11	AND e.nrdconta = 421600	AND e.nrctremp = 45417) OR (e.cdcooper = 11	AND e.nrdconta = 421995	AND e.nrctremp = 67794) OR
(e.cdcooper = 11	AND e.nrdconta = 423408	AND e.nrctremp = 55412) OR (e.cdcooper = 11	AND e.nrdconta = 430390	AND e.nrctremp = 69860) OR
(e.cdcooper = 11	AND e.nrdconta = 433330	AND e.nrctremp = 45533) OR (e.cdcooper = 11	AND e.nrdconta = 433330	AND e.nrctremp = 47492) OR
(e.cdcooper = 11	AND e.nrdconta = 435252	AND e.nrctremp = 57162) OR (e.cdcooper = 11	AND e.nrdconta = 441589	AND e.nrctremp = 56950) OR
(e.cdcooper = 11	AND e.nrdconta = 442879	AND e.nrctremp = 57102) OR (e.cdcooper = 11	AND e.nrdconta = 443719	AND e.nrctremp = 45594) OR
(e.cdcooper = 11	AND e.nrdconta = 444421	AND e.nrctremp = 53451) OR (e.cdcooper = 11	AND e.nrdconta = 445347	AND e.nrctremp = 68031) OR
(e.cdcooper = 11	AND e.nrdconta = 447080	AND e.nrctremp = 65090) OR (e.cdcooper = 11	AND e.nrdconta = 447358	AND e.nrctremp = 54053) OR
(e.cdcooper = 11	AND e.nrdconta = 449032	AND e.nrctremp = 53478) OR (e.cdcooper = 11	AND e.nrdconta = 454931	AND e.nrctremp = 55983) OR
(e.cdcooper = 11	AND e.nrdconta = 455911	AND e.nrctremp = 42309) OR (e.cdcooper = 11	AND e.nrdconta = 460052	AND e.nrctremp = 43274) OR
(e.cdcooper = 11	AND e.nrdconta = 461814	AND e.nrctremp = 57068) OR (e.cdcooper = 11	AND e.nrdconta = 462284	AND e.nrctremp = 53480) OR
(e.cdcooper = 11	AND e.nrdconta = 467146	AND e.nrctremp = 44089) OR (e.cdcooper = 11	AND e.nrdconta = 468126	AND e.nrctremp = 44887) OR
(e.cdcooper = 11	AND e.nrdconta = 475335	AND e.nrctremp = 65225) OR (e.cdcooper = 11	AND e.nrdconta = 487260	AND e.nrctremp = 69234) OR
(e.cdcooper = 11	AND e.nrdconta = 489425	AND e.nrctremp = 52056) OR (e.cdcooper = 11	AND e.nrdconta = 489883	AND e.nrctremp = 62525) OR
(e.cdcooper = 11	AND e.nrdconta = 491179	AND e.nrctremp = 58230) OR (e.cdcooper = 11	AND e.nrdconta = 491586	AND e.nrctremp = 66565) OR
(e.cdcooper = 11	AND e.nrdconta = 494364	AND e.nrctremp = 55865) OR (e.cdcooper = 11	AND e.nrdconta = 497436	AND e.nrctremp = 69907) OR
(e.cdcooper = 11	AND e.nrdconta = 524557	AND e.nrctremp = 57560) OR (e.cdcooper = 11	AND e.nrdconta = 533254	AND e.nrctremp = 69231) OR
(e.cdcooper = 11	AND e.nrdconta = 539392	AND e.nrctremp = 58660) OR (e.cdcooper = 11	AND e.nrdconta = 539392	AND e.nrctremp = 69825) OR
(e.cdcooper = 11	AND e.nrdconta = 552135	AND e.nrctremp = 71320) OR (e.cdcooper = 11	AND e.nrdconta = 562491	AND e.nrctremp = 69841) OR
(e.cdcooper = 12	AND e.nrdconta = 1015	AND e.nrctremp = 4272) OR (e.cdcooper = 12	AND e.nrdconta = 1082	AND e.nrctremp = 1082) OR
(e.cdcooper = 12	AND e.nrdconta = 3921	AND e.nrctremp = 7539) OR (e.cdcooper = 12	AND e.nrdconta = 6688	AND e.nrctremp = 10863) OR
(e.cdcooper = 12	AND e.nrdconta = 6742	AND e.nrctremp = 4433) OR (e.cdcooper = 12	AND e.nrdconta = 9440	AND e.nrctremp = 4291) OR
(e.cdcooper = 12	AND e.nrdconta = 12319	AND e.nrctremp = 11247) OR (e.cdcooper = 12	AND e.nrdconta = 13102	AND e.nrctremp = 11044) OR
(e.cdcooper = 12	AND e.nrdconta = 15172	AND e.nrctremp = 12404) OR (e.cdcooper = 12	AND e.nrdconta = 20257	AND e.nrctremp = 1925) OR
(e.cdcooper = 12	AND e.nrdconta = 21261	AND e.nrctremp = 5118) OR (e.cdcooper = 12	AND e.nrdconta = 25429	AND e.nrctremp = 11340) OR
(e.cdcooper = 12	AND e.nrdconta = 26522	AND e.nrctremp = 3496) OR (e.cdcooper = 12	AND e.nrdconta = 31216	AND e.nrctremp = 12848) OR
(e.cdcooper = 12	AND e.nrdconta = 32387	AND e.nrctremp = 11229) OR (e.cdcooper = 12	AND e.nrdconta = 33880	AND e.nrctremp = 1863) OR
(e.cdcooper = 12	AND e.nrdconta = 36307	AND e.nrctremp = 15001) OR (e.cdcooper = 12	AND e.nrdconta = 36463	AND e.nrctremp = 14928) OR
(e.cdcooper = 12	AND e.nrdconta = 36986	AND e.nrctremp = 36986) OR (e.cdcooper = 12	AND e.nrdconta = 37451	AND e.nrctremp = 2250) OR
(e.cdcooper = 12	AND e.nrdconta = 43427	AND e.nrctremp = 158164) OR (e.cdcooper = 12	AND e.nrdconta = 46078	AND e.nrctremp = 3355) OR
(e.cdcooper = 12	AND e.nrdconta = 48429	AND e.nrctremp = 4014) OR (e.cdcooper = 12	AND e.nrdconta = 48500	AND e.nrctremp = 9049) OR
(e.cdcooper = 12	AND e.nrdconta = 51233	AND e.nrctremp = 9991) OR (e.cdcooper = 12	AND e.nrdconta = 51942	AND e.nrctremp = 51942) OR
(e.cdcooper = 12	AND e.nrdconta = 54151	AND e.nrctremp = 54151) OR (e.cdcooper = 12	AND e.nrdconta = 54259	AND e.nrctremp = 13008) OR
(e.cdcooper = 12	AND e.nrdconta = 57169	AND e.nrctremp = 8079) OR (e.cdcooper = 12	AND e.nrdconta = 57169	AND e.nrctremp = 12170) OR
(e.cdcooper = 12	AND e.nrdconta = 61620	AND e.nrctremp = 2528) OR (e.cdcooper = 12	AND e.nrdconta = 63720	AND e.nrctremp = 8210) OR
(e.cdcooper = 12	AND e.nrdconta = 64319	AND e.nrctremp = 8183) OR (e.cdcooper = 12	AND e.nrdconta = 66575	AND e.nrctremp = 10510) OR
(e.cdcooper = 12	AND e.nrdconta = 66770	AND e.nrctremp = 5587) OR (e.cdcooper = 12	AND e.nrdconta = 68942	AND e.nrctremp = 4043) OR
(e.cdcooper = 12	AND e.nrdconta = 69078	AND e.nrctremp = 12040) OR (e.cdcooper = 12	AND e.nrdconta = 70149	AND e.nrctremp = 10386) OR
(e.cdcooper = 12	AND e.nrdconta = 70351	AND e.nrctremp = 4136) OR (e.cdcooper = 12	AND e.nrdconta = 72435	AND e.nrctremp = 11146) OR
(e.cdcooper = 12	AND e.nrdconta = 75515	AND e.nrctremp = 7348) OR (e.cdcooper = 12	AND e.nrdconta = 76082	AND e.nrctremp = 19091) OR
(e.cdcooper = 12	AND e.nrdconta = 77119	AND e.nrctremp = 10679) OR (e.cdcooper = 12	AND e.nrdconta = 78263	AND e.nrctremp = 7573) OR
(e.cdcooper = 12	AND e.nrdconta = 79235	AND e.nrctremp = 13780) OR (e.cdcooper = 12	AND e.nrdconta = 79243	AND e.nrctremp = 9878) OR
(e.cdcooper = 12	AND e.nrdconta = 87149	AND e.nrctremp = 14907) OR (e.cdcooper = 12	AND e.nrdconta = 88250	AND e.nrctremp = 1820485) OR
(e.cdcooper = 12	AND e.nrdconta = 90026	AND e.nrctremp = 9951) OR (e.cdcooper = 12	AND e.nrdconta = 90816	AND e.nrctremp = 7304) OR
(e.cdcooper = 12	AND e.nrdconta = 90913	AND e.nrctremp = 10693) OR (e.cdcooper = 12	AND e.nrdconta = 100765	AND e.nrctremp = 17441) OR
(e.cdcooper = 12	AND e.nrdconta = 102822	AND e.nrctremp = 17883) OR (e.cdcooper = 12	AND e.nrdconta = 103209	AND e.nrctremp = 8959) OR
(e.cdcooper = 12	AND e.nrdconta = 105228	AND e.nrctremp = 10786) OR (e.cdcooper = 12	AND e.nrdconta = 109770	AND e.nrctremp = 10130) OR
(e.cdcooper = 12	AND e.nrdconta = 110531	AND e.nrctremp = 10259) OR (e.cdcooper = 12	AND e.nrdconta = 116947	AND e.nrctremp = 13164) OR
(e.cdcooper = 12	AND e.nrdconta = 118044	AND e.nrctremp = 15432) OR (e.cdcooper = 12	AND e.nrdconta = 121517	AND e.nrctremp = 15138) OR
(e.cdcooper = 12	AND e.nrdconta = 122319	AND e.nrctremp = 15690) OR (e.cdcooper = 12	AND e.nrdconta = 126020	AND e.nrctremp = 18679) OR
(e.cdcooper = 13	AND e.nrdconta = 36994	AND e.nrctremp = 14181) OR (e.cdcooper = 13	AND e.nrdconta = 44458	AND e.nrctremp = 8612) OR
(e.cdcooper = 13	AND e.nrdconta = 48186	AND e.nrctremp = 7985) OR (e.cdcooper = 13	AND e.nrdconta = 51357	AND e.nrctremp = 20232) OR
(e.cdcooper = 13	AND e.nrdconta = 52493	AND e.nrctremp = 16444) OR (e.cdcooper = 13	AND e.nrdconta = 52582	AND e.nrctremp = 16297) OR
(e.cdcooper = 13	AND e.nrdconta = 53333	AND e.nrctremp = 4172) OR (e.cdcooper = 13	AND e.nrdconta = 57061	AND e.nrctremp = 12877) OR
(e.cdcooper = 13	AND e.nrdconta = 59412	AND e.nrctremp = 13022) OR (e.cdcooper = 13	AND e.nrdconta = 61760	AND e.nrctremp = 61760) OR
(e.cdcooper = 13	AND e.nrdconta = 78280	AND e.nrctremp = 30181) OR (e.cdcooper = 13	AND e.nrdconta = 80616	AND e.nrctremp = 10896) OR
(e.cdcooper = 13	AND e.nrdconta = 81167	AND e.nrctremp = 37771) OR (e.cdcooper = 13	AND e.nrdconta = 84310	AND e.nrctremp = 11028) OR
(e.cdcooper = 13	AND e.nrdconta = 84344	AND e.nrctremp = 17262) OR (e.cdcooper = 13	AND e.nrdconta = 84352	AND e.nrctremp = 58915) OR
(e.cdcooper = 13	AND e.nrdconta = 84581	AND e.nrctremp = 13497) OR (e.cdcooper = 13	AND e.nrdconta = 88625	AND e.nrctremp = 21356) OR
(e.cdcooper = 13	AND e.nrdconta = 96415	AND e.nrctremp = 43037) OR (e.cdcooper = 13	AND e.nrdconta = 102067	AND e.nrctremp = 25212) OR
(e.cdcooper = 13	AND e.nrdconta = 102580	AND e.nrctremp = 51632) OR (e.cdcooper = 13	AND e.nrdconta = 108774	AND e.nrctremp = 53277) OR
(e.cdcooper = 13	AND e.nrdconta = 135240	AND e.nrctremp = 20622) OR (e.cdcooper = 13	AND e.nrdconta = 139017	AND e.nrctremp = 18460) OR
(e.cdcooper = 13	AND e.nrdconta = 146986	AND e.nrctremp = 28415) OR (e.cdcooper = 13	AND e.nrdconta = 148300	AND e.nrctremp = 59947) OR
(e.cdcooper = 13	AND e.nrdconta = 149233	AND e.nrctremp = 31280) OR (e.cdcooper = 13	AND e.nrdconta = 150916	AND e.nrctremp = 34097) OR
(e.cdcooper = 13	AND e.nrdconta = 152307	AND e.nrctremp = 19430) OR (e.cdcooper = 13	AND e.nrdconta = 165301	AND e.nrctremp = 34346) OR
(e.cdcooper = 13	AND e.nrdconta = 176508	AND e.nrctremp = 28029) OR (e.cdcooper = 13	AND e.nrdconta = 177504	AND e.nrctremp = 33841) OR
(e.cdcooper = 13	AND e.nrdconta = 188760	AND e.nrctremp = 46057) OR (e.cdcooper = 13	AND e.nrdconta = 188964	AND e.nrctremp = 25691) OR
(e.cdcooper = 13	AND e.nrdconta = 201502	AND e.nrctremp = 8941) OR (e.cdcooper = 13	AND e.nrdconta = 207810	AND e.nrctremp = 25534) OR
(e.cdcooper = 13	AND e.nrdconta = 210650	AND e.nrctremp = 34308) OR (e.cdcooper = 13	AND e.nrdconta = 210650	AND e.nrctremp = 44381) OR
(e.cdcooper = 13	AND e.nrdconta = 220809	AND e.nrctremp = 26012) OR (e.cdcooper = 13	AND e.nrdconta = 221244	AND e.nrctremp = 37908) OR
(e.cdcooper = 13	AND e.nrdconta = 222038	AND e.nrctremp = 27465) OR (e.cdcooper = 13	AND e.nrdconta = 223280	AND e.nrctremp = 32396) OR
(e.cdcooper = 13	AND e.nrdconta = 227498	AND e.nrctremp = 2442) OR (e.cdcooper = 13	AND e.nrdconta = 229687	AND e.nrctremp = 7285) OR
(e.cdcooper = 13	AND e.nrdconta = 230839	AND e.nrctremp = 3394) OR (e.cdcooper = 13	AND e.nrdconta = 230839	AND e.nrctremp = 230839) OR
(e.cdcooper = 13	AND e.nrdconta = 231096	AND e.nrctremp = 90902) OR (e.cdcooper = 13	AND e.nrdconta = 233595	AND e.nrctremp = 17300) OR
(e.cdcooper = 13	AND e.nrdconta = 234508	AND e.nrctremp = 7662) OR (e.cdcooper = 13	AND e.nrdconta = 234710	AND e.nrctremp = 10462) OR
(e.cdcooper = 13	AND e.nrdconta = 234800	AND e.nrctremp = 15398) OR (e.cdcooper = 13	AND e.nrdconta = 236403	AND e.nrctremp = 250108) OR
(e.cdcooper = 13	AND e.nrdconta = 243353	AND e.nrctremp = 6343) OR (e.cdcooper = 13	AND e.nrdconta = 246280	AND e.nrctremp = 28472) OR
(e.cdcooper = 13	AND e.nrdconta = 250929	AND e.nrctremp = 35054) OR (e.cdcooper = 13	AND e.nrdconta = 250929	AND e.nrctremp = 55519) OR
(e.cdcooper = 13	AND e.nrdconta = 252751	AND e.nrctremp = 51645) OR (e.cdcooper = 13	AND e.nrdconta = 254851	AND e.nrctremp = 52117) OR
(e.cdcooper = 13	AND e.nrdconta = 256030	AND e.nrctremp = 2828) OR (e.cdcooper = 13	AND e.nrdconta = 262021	AND e.nrctremp = 33454) OR
(e.cdcooper = 13	AND e.nrdconta = 269301	AND e.nrctremp = 36941) OR (e.cdcooper = 13	AND e.nrdconta = 273791	AND e.nrctremp = 47804) OR
(e.cdcooper = 13	AND e.nrdconta = 275115	AND e.nrctremp = 48831) OR (e.cdcooper = 13	AND e.nrdconta = 276120	AND e.nrctremp = 44986) OR
(e.cdcooper = 13	AND e.nrdconta = 278165	AND e.nrctremp = 63571) OR (e.cdcooper = 13	AND e.nrdconta = 278408	AND e.nrctremp = 58246) OR
(e.cdcooper = 13	AND e.nrdconta = 284564	AND e.nrctremp = 53477) OR (e.cdcooper = 13	AND e.nrdconta = 284866	AND e.nrctremp = 53175) OR
(e.cdcooper = 13	AND e.nrdconta = 286869	AND e.nrctremp = 57717) OR (e.cdcooper = 13	AND e.nrdconta = 292478	AND e.nrctremp = 49903) OR
(e.cdcooper = 13	AND e.nrdconta = 296023	AND e.nrctremp = 38633) OR (e.cdcooper = 13	AND e.nrdconta = 296678	AND e.nrctremp = 47974) OR
(e.cdcooper = 13	AND e.nrdconta = 300543	AND e.nrctremp = 8341) OR (e.cdcooper = 13	AND e.nrdconta = 305880	AND e.nrctremp = 10048) OR
(e.cdcooper = 13	AND e.nrdconta = 306754	AND e.nrctremp = 12551) OR (e.cdcooper = 13	AND e.nrdconta = 308498	AND e.nrctremp = 53093) OR
(e.cdcooper = 13	AND e.nrdconta = 310280	AND e.nrctremp = 18556) OR (e.cdcooper = 13	AND e.nrdconta = 313602	AND e.nrctremp = 6823) OR
(e.cdcooper = 13	AND e.nrdconta = 324140	AND e.nrctremp = 40239) OR (e.cdcooper = 13	AND e.nrdconta = 334103	AND e.nrctremp = 53470) OR
(e.cdcooper = 13	AND e.nrdconta = 338230	AND e.nrctremp = 52126) OR (e.cdcooper = 13	AND e.nrdconta = 340324	AND e.nrctremp = 44008) OR
(e.cdcooper = 13	AND e.nrdconta = 354589	AND e.nrctremp = 56916) OR (e.cdcooper = 13	AND e.nrdconta = 401773	AND e.nrctremp = 31380) OR
(e.cdcooper = 13	AND e.nrdconta = 401811	AND e.nrctremp = 401811) OR (e.cdcooper = 13	AND e.nrdconta = 401854	AND e.nrctremp = 43015) OR
(e.cdcooper = 13	AND e.nrdconta = 401862	AND e.nrctremp = 46156) OR (e.cdcooper = 13	AND e.nrdconta = 401919	AND e.nrctremp = 16712) OR
(e.cdcooper = 13	AND e.nrdconta = 406961	AND e.nrctremp = 40849) OR (e.cdcooper = 13	AND e.nrdconta = 407542	AND e.nrctremp = 15488) OR
(e.cdcooper = 13	AND e.nrdconta = 411604	AND e.nrctremp = 9825) OR (e.cdcooper = 13	AND e.nrdconta = 501530	AND e.nrctremp = 501530) OR
(e.cdcooper = 13	AND e.nrdconta = 501875	AND e.nrctremp = 9269) OR (e.cdcooper = 13	AND e.nrdconta = 501883	AND e.nrctremp = 7584) OR
(e.cdcooper = 13	AND e.nrdconta = 502472	AND e.nrctremp = 18212) OR (e.cdcooper = 13	AND e.nrdconta = 701815	AND e.nrctremp = 8110) OR
(e.cdcooper = 13	AND e.nrdconta = 702161	AND e.nrctremp = 702161) OR (e.cdcooper = 13	AND e.nrdconta = 703842	AND e.nrctremp = 12798) OR
(e.cdcooper = 13	AND e.nrdconta = 707228	AND e.nrctremp = 19702) OR (e.cdcooper = 13	AND e.nrdconta = 710920	AND e.nrctremp = 19713) OR
(e.cdcooper = 13	AND e.nrdconta = 710920	AND e.nrctremp = 710920) OR (e.cdcooper = 13	AND e.nrdconta = 730017	AND e.nrctremp = 17122) OR
(e.cdcooper = 14	AND e.nrdconta = 507	AND e.nrctremp = 3440) OR (e.cdcooper = 14	AND e.nrdconta = 7846	AND e.nrctremp = 7428) OR
(e.cdcooper = 14	AND e.nrdconta = 9512	AND e.nrctremp = 912) OR (e.cdcooper = 14	AND e.nrdconta = 10464	AND e.nrctremp = 3047) OR
(e.cdcooper = 14	AND e.nrdconta = 10979	AND e.nrctremp = 1953) OR (e.cdcooper = 14	AND e.nrdconta = 11207	AND e.nrctremp = 11024) OR
(e.cdcooper = 14	AND e.nrdconta = 11207	AND e.nrctremp = 11207) OR (e.cdcooper = 14	AND e.nrdconta = 12041	AND e.nrctremp = 4590) OR
(e.cdcooper = 14	AND e.nrdconta = 13234	AND e.nrctremp = 1402) OR (e.cdcooper = 14	AND e.nrdconta = 15407	AND e.nrctremp = 1282) OR
(e.cdcooper = 14	AND e.nrdconta = 15598	AND e.nrctremp = 903) OR (e.cdcooper = 14	AND e.nrdconta = 15997	AND e.nrctremp = 4083) OR
(e.cdcooper = 14	AND e.nrdconta = 17981	AND e.nrctremp = 17981) OR (e.cdcooper = 14	AND e.nrdconta = 18180	AND e.nrctremp = 5298) OR
(e.cdcooper = 14	AND e.nrdconta = 18414	AND e.nrctremp = 234258) OR (e.cdcooper = 14	AND e.nrdconta = 18562	AND e.nrctremp = 11013) OR
(e.cdcooper = 14	AND e.nrdconta = 20990	AND e.nrctremp = 20990) OR (e.cdcooper = 14	AND e.nrdconta = 22373	AND e.nrctremp = 22373) OR
(e.cdcooper = 14	AND e.nrdconta = 22527	AND e.nrctremp = 1722) OR (e.cdcooper = 14	AND e.nrdconta = 22705	AND e.nrctremp = 1412) OR
(e.cdcooper = 14	AND e.nrdconta = 22705	AND e.nrctremp = 22705) OR (e.cdcooper = 14	AND e.nrdconta = 24945	AND e.nrctremp = 24945) OR
(e.cdcooper = 14	AND e.nrdconta = 25160	AND e.nrctremp = 7785) OR (e.cdcooper = 14	AND e.nrdconta = 27103	AND e.nrctremp = 5124) OR
(e.cdcooper = 14	AND e.nrdconta = 29912	AND e.nrctremp = 29912) OR (e.cdcooper = 14	AND e.nrdconta = 30074	AND e.nrctremp = 829) OR
(e.cdcooper = 14	AND e.nrdconta = 30074	AND e.nrctremp = 30074) OR (e.cdcooper = 14	AND e.nrdconta = 30139	AND e.nrctremp = 5337) OR
(e.cdcooper = 14	AND e.nrdconta = 31445	AND e.nrctremp = 31445) OR (e.cdcooper = 14	AND e.nrdconta = 33405	AND e.nrctremp = 33405) OR
(e.cdcooper = 14	AND e.nrdconta = 36935	AND e.nrctremp = 3136) OR (e.cdcooper = 14	AND e.nrdconta = 37460	AND e.nrctremp = 9675) OR
(e.cdcooper = 14	AND e.nrdconta = 40100	AND e.nrctremp = 5158) OR (e.cdcooper = 14	AND e.nrdconta = 42714	AND e.nrctremp = 4343) OR
(e.cdcooper = 14	AND e.nrdconta = 44148	AND e.nrctremp = 9099) OR (e.cdcooper = 14	AND e.nrdconta = 45527	AND e.nrctremp = 45527) OR
(e.cdcooper = 14	AND e.nrdconta = 45535	AND e.nrctremp = 45535) OR (e.cdcooper = 14	AND e.nrdconta = 45659	AND e.nrctremp = 3599) OR
(e.cdcooper = 14	AND e.nrdconta = 46710	AND e.nrctremp = 3884) OR (e.cdcooper = 14	AND e.nrdconta = 47724	AND e.nrctremp = 5145) OR
(e.cdcooper = 14	AND e.nrdconta = 48186	AND e.nrctremp = 48186) OR (e.cdcooper = 14	AND e.nrdconta = 49310	AND e.nrctremp = 4012) OR
(e.cdcooper = 14	AND e.nrdconta = 51420	AND e.nrctremp = 4000) OR (e.cdcooper = 14	AND e.nrdconta = 52515	AND e.nrctremp = 4335) OR
(e.cdcooper = 14	AND e.nrdconta = 55042	AND e.nrctremp = 55042) OR (e.cdcooper = 14	AND e.nrdconta = 56154	AND e.nrctremp = 4543) OR
(e.cdcooper = 14	AND e.nrdconta = 56154	AND e.nrctremp = 6551) OR (e.cdcooper = 14	AND e.nrdconta = 56634	AND e.nrctremp = 7698) OR
(e.cdcooper = 14	AND e.nrdconta = 61166	AND e.nrctremp = 5356) OR (e.cdcooper = 14	AND e.nrdconta = 64955	AND e.nrctremp = 5663) OR
(e.cdcooper = 14	AND e.nrdconta = 65560	AND e.nrctremp = 11005) OR (e.cdcooper = 14	AND e.nrdconta = 68055	AND e.nrctremp = 8521) OR
(e.cdcooper = 14	AND e.nrdconta = 68349	AND e.nrctremp = 11933) OR (e.cdcooper = 14	AND e.nrdconta = 72982	AND e.nrctremp = 7811) OR
(e.cdcooper = 14	AND e.nrdconta = 73008	AND e.nrctremp = 6372) OR (e.cdcooper = 14	AND e.nrdconta = 73008	AND e.nrctremp = 7344) OR
(e.cdcooper = 14	AND e.nrdconta = 73466	AND e.nrctremp = 6116) OR (e.cdcooper = 14	AND e.nrdconta = 76007	AND e.nrctremp = 6531) OR
(e.cdcooper = 14	AND e.nrdconta = 76970	AND e.nrctremp = 11270) OR (e.cdcooper = 14	AND e.nrdconta = 77496	AND e.nrctremp = 7203) OR
(e.cdcooper = 14	AND e.nrdconta = 85596	AND e.nrctremp = 7509) OR (e.cdcooper = 14	AND e.nrdconta = 103721	AND e.nrctremp = 10498) OR
(e.cdcooper = 16	AND e.nrdconta = 1414	AND e.nrctremp = 35969) OR (e.cdcooper = 16	AND e.nrdconta = 1708	AND e.nrctremp = 1708) OR
(e.cdcooper = 16	AND e.nrdconta = 1899	AND e.nrctremp = 22067) OR (e.cdcooper = 16	AND e.nrdconta = 2992	AND e.nrctremp = 25912) OR
(e.cdcooper = 16	AND e.nrdconta = 3301	AND e.nrctremp = 3301) OR (e.cdcooper = 16	AND e.nrdconta = 6017	AND e.nrctremp = 6017) OR
(e.cdcooper = 16	AND e.nrdconta = 6424	AND e.nrctremp = 118958) OR (e.cdcooper = 16	AND e.nrdconta = 8907	AND e.nrctremp = 51979) OR
(e.cdcooper = 16	AND e.nrdconta = 8940	AND e.nrctremp = 22916) OR (e.cdcooper = 16	AND e.nrdconta = 15342	AND e.nrctremp = 15342) OR
(e.cdcooper = 16	AND e.nrdconta = 15377	AND e.nrctremp = 15377) OR (e.cdcooper = 16	AND e.nrdconta = 18686	AND e.nrctremp = 18686) OR
(e.cdcooper = 16	AND e.nrdconta = 19577	AND e.nrctremp = 24194) OR (e.cdcooper = 16	AND e.nrdconta = 20320	AND e.nrctremp = 20320) OR
(e.cdcooper = 16	AND e.nrdconta = 21458	AND e.nrctremp = 21458) OR (e.cdcooper = 16	AND e.nrdconta = 22004	AND e.nrctremp = 22004) OR
(e.cdcooper = 16	AND e.nrdconta = 22284	AND e.nrctremp = 22284) OR (e.cdcooper = 16	AND e.nrdconta = 23086	AND e.nrctremp = 23086) OR
(e.cdcooper = 16	AND e.nrdconta = 26336	AND e.nrctremp = 13204) OR (e.cdcooper = 16	AND e.nrdconta = 26654	AND e.nrctremp = 26654) OR
(e.cdcooper = 16	AND e.nrdconta = 27219	AND e.nrctremp = 111611) OR (e.cdcooper = 16	AND e.nrdconta = 27413	AND e.nrctremp = 7435) OR
(e.cdcooper = 16	AND e.nrdconta = 29386	AND e.nrctremp = 29386) OR (e.cdcooper = 16	AND e.nrdconta = 29580	AND e.nrctremp = 12689) OR
(e.cdcooper = 16	AND e.nrdconta = 30147	AND e.nrctremp = 30147) OR (e.cdcooper = 16	AND e.nrdconta = 30694	AND e.nrctremp = 30694) OR
(e.cdcooper = 16	AND e.nrdconta = 30775	AND e.nrctremp = 30775) OR (e.cdcooper = 16	AND e.nrdconta = 32093	AND e.nrctremp = 30069) OR
(e.cdcooper = 16	AND e.nrdconta = 32620	AND e.nrctremp = 32620) OR (e.cdcooper = 16	AND e.nrdconta = 33197	AND e.nrctremp = 33197) OR
(e.cdcooper = 16	AND e.nrdconta = 34517	AND e.nrctremp = 60444) OR (e.cdcooper = 16	AND e.nrdconta = 34851	AND e.nrctremp = 21115) OR
(e.cdcooper = 16	AND e.nrdconta = 35335	AND e.nrctremp = 35335) OR (e.cdcooper = 16	AND e.nrdconta = 37451	AND e.nrctremp = 142820) OR
(e.cdcooper = 16	AND e.nrdconta = 40037	AND e.nrctremp = 40037) OR (e.cdcooper = 16	AND e.nrdconta = 40410	AND e.nrctremp = 1735) OR
(e.cdcooper = 16	AND e.nrdconta = 40410	AND e.nrctremp = 40410) OR (e.cdcooper = 16	AND e.nrdconta = 40622	AND e.nrctremp = 21251) OR
(e.cdcooper = 16	AND e.nrdconta = 40711	AND e.nrctremp = 4034) OR (e.cdcooper = 16	AND e.nrdconta = 40711	AND e.nrctremp = 15413) OR
(e.cdcooper = 16	AND e.nrdconta = 41165	AND e.nrctremp = 41165) OR (e.cdcooper = 16	AND e.nrdconta = 41246	AND e.nrctremp = 125764) OR
(e.cdcooper = 16	AND e.nrdconta = 42633	AND e.nrctremp = 14725) OR (e.cdcooper = 16	AND e.nrdconta = 42714	AND e.nrctremp = 33516) OR
(e.cdcooper = 16	AND e.nrdconta = 43028	AND e.nrctremp = 2401) OR (e.cdcooper = 16	AND e.nrdconta = 44431	AND e.nrctremp = 44431) OR
(e.cdcooper = 16	AND e.nrdconta = 44458	AND e.nrctremp = 44458) OR (e.cdcooper = 16	AND e.nrdconta = 44938	AND e.nrctremp = 79627) OR
(e.cdcooper = 16	AND e.nrdconta = 45845	AND e.nrctremp = 30923) OR (e.cdcooper = 16	AND e.nrdconta = 46981	AND e.nrctremp = 27917) OR
(e.cdcooper = 16	AND e.nrdconta = 47139	AND e.nrctremp = 47139) OR (e.cdcooper = 16	AND e.nrdconta = 47147	AND e.nrctremp = 47147) OR
(e.cdcooper = 16	AND e.nrdconta = 47449	AND e.nrctremp = 33705) OR (e.cdcooper = 16	AND e.nrdconta = 48704	AND e.nrctremp = 6635) OR
(e.cdcooper = 16	AND e.nrdconta = 49034	AND e.nrctremp = 49034) OR (e.cdcooper = 16	AND e.nrdconta = 50563	AND e.nrctremp = 50563) OR
(e.cdcooper = 16	AND e.nrdconta = 50644	AND e.nrctremp = 50644) OR (e.cdcooper = 16	AND e.nrdconta = 51330	AND e.nrctremp = 41303) OR
(e.cdcooper = 16	AND e.nrdconta = 53546	AND e.nrctremp = 53546) OR (e.cdcooper = 16	AND e.nrdconta = 53970	AND e.nrctremp = 53970) OR
(e.cdcooper = 16	AND e.nrdconta = 53996	AND e.nrctremp = 53996) OR (e.cdcooper = 16	AND e.nrdconta = 55069	AND e.nrctremp = 116372) OR
(e.cdcooper = 16	AND e.nrdconta = 55808	AND e.nrctremp = 191225) OR (e.cdcooper = 16	AND e.nrdconta = 56596	AND e.nrctremp = 64151) OR
(e.cdcooper = 16	AND e.nrdconta = 56731	AND e.nrctremp = 5209) OR (e.cdcooper = 16	AND e.nrdconta = 56898	AND e.nrctremp = 56898) OR
(e.cdcooper = 16	AND e.nrdconta = 57037	AND e.nrctremp = 57037) OR (e.cdcooper = 16	AND e.nrdconta = 57185	AND e.nrctremp = 57185) OR
(e.cdcooper = 16	AND e.nrdconta = 57371	AND e.nrctremp = 24043) OR (e.cdcooper = 16	AND e.nrdconta = 57630	AND e.nrctremp = 57630) OR
(e.cdcooper = 16	AND e.nrdconta = 58289	AND e.nrctremp = 11897) OR (e.cdcooper = 16	AND e.nrdconta = 59854	AND e.nrctremp = 80652) OR
(e.cdcooper = 16	AND e.nrdconta = 61867	AND e.nrctremp = 9594) OR (e.cdcooper = 16	AND e.nrdconta = 62413	AND e.nrctremp = 159952) OR
(e.cdcooper = 16	AND e.nrdconta = 63410	AND e.nrctremp = 24107) OR (e.cdcooper = 16	AND e.nrdconta = 63428	AND e.nrctremp = 63428) OR
(e.cdcooper = 16	AND e.nrdconta = 64254	AND e.nrctremp = 11173) OR (e.cdcooper = 16	AND e.nrdconta = 64599	AND e.nrctremp = 24338) OR
(e.cdcooper = 16	AND e.nrdconta = 64599	AND e.nrctremp = 94766) OR (e.cdcooper = 16	AND e.nrdconta = 65935	AND e.nrctremp = 65935) OR
(e.cdcooper = 16	AND e.nrdconta = 67784	AND e.nrctremp = 48368) OR (e.cdcooper = 16	AND e.nrdconta = 67938	AND e.nrctremp = 67938) OR
(e.cdcooper = 16	AND e.nrdconta = 67946	AND e.nrctremp = 67946) OR (e.cdcooper = 16	AND e.nrdconta = 68365	AND e.nrctremp = 68365) OR
(e.cdcooper = 16	AND e.nrdconta = 69248	AND e.nrctremp = 69248) OR (e.cdcooper = 16	AND e.nrdconta = 70890	AND e.nrctremp = 100615) OR
(e.cdcooper = 16	AND e.nrdconta = 70912	AND e.nrctremp = 95907) OR (e.cdcooper = 16	AND e.nrdconta = 71668	AND e.nrctremp = 24192) OR
(e.cdcooper = 16	AND e.nrdconta = 74993	AND e.nrctremp = 74993) OR (e.cdcooper = 16	AND e.nrdconta = 75868	AND e.nrctremp = 30953) OR
(e.cdcooper = 16	AND e.nrdconta = 76490	AND e.nrctremp = 76490) OR (e.cdcooper = 16	AND e.nrdconta = 76619	AND e.nrctremp = 70822) OR
(e.cdcooper = 16	AND e.nrdconta = 78158	AND e.nrctremp = 78158) OR (e.cdcooper = 16	AND e.nrdconta = 78360	AND e.nrctremp = 29414) OR
(e.cdcooper = 16	AND e.nrdconta = 79359	AND e.nrctremp = 79359) OR (e.cdcooper = 16	AND e.nrdconta = 79367	AND e.nrctremp = 79367) OR
(e.cdcooper = 16	AND e.nrdconta = 80535	AND e.nrctremp = 80535) OR (e.cdcooper = 16	AND e.nrdconta = 81760	AND e.nrctremp = 81760) OR
(e.cdcooper = 16	AND e.nrdconta = 82120	AND e.nrctremp = 82120) OR (e.cdcooper = 16	AND e.nrdconta = 85014	AND e.nrctremp = 66845) OR
(e.cdcooper = 16	AND e.nrdconta = 85758	AND e.nrctremp = 79716) OR (e.cdcooper = 16	AND e.nrdconta = 86460	AND e.nrctremp = 86460) OR
(e.cdcooper = 16	AND e.nrdconta = 87386	AND e.nrctremp = 96493) OR (e.cdcooper = 16	AND e.nrdconta = 87572	AND e.nrctremp = 87572) OR
(e.cdcooper = 16	AND e.nrdconta = 87742	AND e.nrctremp = 16750) OR (e.cdcooper = 16	AND e.nrdconta = 89249	AND e.nrctremp = 18185) OR
(e.cdcooper = 16	AND e.nrdconta = 91537	AND e.nrctremp = 91537) OR (e.cdcooper = 16	AND e.nrdconta = 91677	AND e.nrctremp = 116798) OR
(e.cdcooper = 16	AND e.nrdconta = 92223	AND e.nrctremp = 92223) OR (e.cdcooper = 16	AND e.nrdconta = 92304	AND e.nrctremp = 18622) OR
(e.cdcooper = 16	AND e.nrdconta = 92320	AND e.nrctremp = 80692) OR (e.cdcooper = 16	AND e.nrdconta = 93530	AND e.nrctremp = 93530) OR
(e.cdcooper = 16	AND e.nrdconta = 93955	AND e.nrctremp = 93955) OR (e.cdcooper = 16	AND e.nrdconta = 94170	AND e.nrctremp = 94170) OR
(e.cdcooper = 16	AND e.nrdconta = 94218	AND e.nrctremp = 24896) OR (e.cdcooper = 16	AND e.nrdconta = 95087	AND e.nrctremp = 70338) OR
(e.cdcooper = 16	AND e.nrdconta = 95567	AND e.nrctremp = 117168) OR (e.cdcooper = 16	AND e.nrdconta = 96369	AND e.nrctremp = 96369) OR
(e.cdcooper = 16	AND e.nrdconta = 98183	AND e.nrctremp = 98183) OR (e.cdcooper = 16	AND e.nrdconta = 98680	AND e.nrctremp = 98680) OR
(e.cdcooper = 16	AND e.nrdconta = 98736	AND e.nrctremp = 98736) OR (e.cdcooper = 16	AND e.nrdconta = 98744	AND e.nrctremp = 98744) OR
(e.cdcooper = 16	AND e.nrdconta = 99007	AND e.nrctremp = 99007) OR (e.cdcooper = 16	AND e.nrdconta = 101010	AND e.nrctremp = 101010) OR
(e.cdcooper = 16	AND e.nrdconta = 101206	AND e.nrctremp = 32095) OR (e.cdcooper = 16	AND e.nrdconta = 101303	AND e.nrctremp = 101303) OR
(e.cdcooper = 16	AND e.nrdconta = 101338	AND e.nrctremp = 101338) OR (e.cdcooper = 16	AND e.nrdconta = 102164	AND e.nrctremp = 155) OR
(e.cdcooper = 16	AND e.nrdconta = 104310	AND e.nrctremp = 104310) OR (e.cdcooper = 16	AND e.nrdconta = 105112	AND e.nrctremp = 12183) OR
(e.cdcooper = 16	AND e.nrdconta = 105252	AND e.nrctremp = 2539) OR (e.cdcooper = 16	AND e.nrdconta = 108170	AND e.nrctremp = 108170) OR
(e.cdcooper = 16	AND e.nrdconta = 109029	AND e.nrctremp = 114056) OR (e.cdcooper = 16	AND e.nrdconta = 110183	AND e.nrctremp = 110183) OR
(e.cdcooper = 16	AND e.nrdconta = 110361	AND e.nrctremp = 27420) OR (e.cdcooper = 16	AND e.nrdconta = 111023	AND e.nrctremp = 111023) OR
(e.cdcooper = 16	AND e.nrdconta = 111619	AND e.nrctremp = 100627) OR (e.cdcooper = 16	AND e.nrdconta = 111651	AND e.nrctremp = 111651) OR
(e.cdcooper = 16	AND e.nrdconta = 111899	AND e.nrctremp = 111899) OR (e.cdcooper = 16	AND e.nrdconta = 112879	AND e.nrctremp = 112879) OR
(e.cdcooper = 16	AND e.nrdconta = 113425	AND e.nrctremp = 113425) OR (e.cdcooper = 16	AND e.nrdconta = 113760	AND e.nrctremp = 114060) OR
(e.cdcooper = 16	AND e.nrdconta = 113948	AND e.nrctremp = 113948) OR (e.cdcooper = 16	AND e.nrdconta = 114707	AND e.nrctremp = 131966) OR
(e.cdcooper = 16	AND e.nrdconta = 114782	AND e.nrctremp = 114782) OR (e.cdcooper = 16	AND e.nrdconta = 117005	AND e.nrctremp = 117005) OR
(e.cdcooper = 16	AND e.nrdconta = 117021	AND e.nrctremp = 117021) OR (e.cdcooper = 16	AND e.nrdconta = 117803	AND e.nrctremp = 117803) OR
(e.cdcooper = 16	AND e.nrdconta = 117854	AND e.nrctremp = 25494) OR (e.cdcooper = 16	AND e.nrdconta = 119504	AND e.nrctremp = 119504) OR
(e.cdcooper = 16	AND e.nrdconta = 119776	AND e.nrctremp = 119776) OR (e.cdcooper = 16	AND e.nrdconta = 120111	AND e.nrctremp = 120111) OR
(e.cdcooper = 16	AND e.nrdconta = 120510	AND e.nrctremp = 111469) OR (e.cdcooper = 16	AND e.nrdconta = 120936	AND e.nrctremp = 120936) OR
(e.cdcooper = 16	AND e.nrdconta = 120944	AND e.nrctremp = 46674) OR (e.cdcooper = 16	AND e.nrdconta = 123480	AND e.nrctremp = 123480) OR
(e.cdcooper = 16	AND e.nrdconta = 123790	AND e.nrctremp = 21887) OR (e.cdcooper = 16	AND e.nrdconta = 124915	AND e.nrctremp = 124915) OR
(e.cdcooper = 16	AND e.nrdconta = 125326	AND e.nrctremp = 18800) OR (e.cdcooper = 16	AND e.nrdconta = 125466	AND e.nrctremp = 125466) OR
(e.cdcooper = 16	AND e.nrdconta = 126004	AND e.nrctremp = 126004) OR (e.cdcooper = 16	AND e.nrdconta = 126594	AND e.nrctremp = 126594) OR
(e.cdcooper = 16	AND e.nrdconta = 126705	AND e.nrctremp = 126705) OR (e.cdcooper = 16	AND e.nrdconta = 126845	AND e.nrctremp = 126845) OR
(e.cdcooper = 16	AND e.nrdconta = 127736	AND e.nrctremp = 119904) OR (e.cdcooper = 16	AND e.nrdconta = 127876	AND e.nrctremp = 36063) OR
(e.cdcooper = 16	AND e.nrdconta = 128597	AND e.nrctremp = 129563) OR (e.cdcooper = 16	AND e.nrdconta = 128627	AND e.nrctremp = 47331) OR
(e.cdcooper = 16	AND e.nrdconta = 131539	AND e.nrctremp = 5796) OR (e.cdcooper = 16	AND e.nrdconta = 131539	AND e.nrctremp = 18129) OR
(e.cdcooper = 16	AND e.nrdconta = 131733	AND e.nrctremp = 18480) OR (e.cdcooper = 16	AND e.nrdconta = 134287	AND e.nrctremp = 119895) OR
(e.cdcooper = 16	AND e.nrdconta = 134384	AND e.nrctremp = 126812) OR (e.cdcooper = 16	AND e.nrdconta = 134570	AND e.nrctremp = 134570) OR
(e.cdcooper = 16	AND e.nrdconta = 134961	AND e.nrctremp = 134961) OR (e.cdcooper = 16	AND e.nrdconta = 135348	AND e.nrctremp = 135348) OR
(e.cdcooper = 16	AND e.nrdconta = 137065	AND e.nrctremp = 137065) OR (e.cdcooper = 16	AND e.nrdconta = 137154	AND e.nrctremp = 20151) OR
(e.cdcooper = 16	AND e.nrdconta = 137375	AND e.nrctremp = 137375) OR (e.cdcooper = 16	AND e.nrdconta = 139408	AND e.nrctremp = 34715) OR
(e.cdcooper = 16	AND e.nrdconta = 139572	AND e.nrctremp = 139572) OR (e.cdcooper = 16	AND e.nrdconta = 139998	AND e.nrctremp = 139998) OR
(e.cdcooper = 16	AND e.nrdconta = 140015	AND e.nrctremp = 69835) OR (e.cdcooper = 16	AND e.nrdconta = 140384	AND e.nrctremp = 4544) OR
(e.cdcooper = 16	AND e.nrdconta = 140384	AND e.nrctremp = 140384) OR (e.cdcooper = 16	AND e.nrdconta = 140759	AND e.nrctremp = 140759) OR
(e.cdcooper = 16	AND e.nrdconta = 141364	AND e.nrctremp = 134585) OR (e.cdcooper = 16	AND e.nrdconta = 142379	AND e.nrctremp = 142379) OR
(e.cdcooper = 16	AND e.nrdconta = 142824	AND e.nrctremp = 142824) OR (e.cdcooper = 16	AND e.nrdconta = 143146	AND e.nrctremp = 143146) OR
(e.cdcooper = 16	AND e.nrdconta = 146323	AND e.nrctremp = 27125) OR (e.cdcooper = 16	AND e.nrdconta = 146951	AND e.nrctremp = 146951) OR
(e.cdcooper = 16	AND e.nrdconta = 148300	AND e.nrctremp = 148300) OR (e.cdcooper = 16	AND e.nrdconta = 148636	AND e.nrctremp = 148636) OR
(e.cdcooper = 16	AND e.nrdconta = 149586	AND e.nrctremp = 59987) OR (e.cdcooper = 16	AND e.nrdconta = 151645	AND e.nrctremp = 20978) OR
(e.cdcooper = 16	AND e.nrdconta = 151858	AND e.nrctremp = 151858) OR (e.cdcooper = 16	AND e.nrdconta = 152374	AND e.nrctremp = 13114) OR
(e.cdcooper = 16	AND e.nrdconta = 152455	AND e.nrctremp = 22125) OR (e.cdcooper = 16	AND e.nrdconta = 153176	AND e.nrctremp = 41347) OR
(e.cdcooper = 16	AND e.nrdconta = 153923	AND e.nrctremp = 153923) OR (e.cdcooper = 16	AND e.nrdconta = 154377	AND e.nrctremp = 154377) OR
(e.cdcooper = 16	AND e.nrdconta = 155004	AND e.nrctremp = 155004) OR (e.cdcooper = 16	AND e.nrdconta = 155470	AND e.nrctremp = 155470) OR
(e.cdcooper = 16	AND e.nrdconta = 156370	AND e.nrctremp = 156370) OR (e.cdcooper = 16	AND e.nrdconta = 156523	AND e.nrctremp = 156523) OR
(e.cdcooper = 16	AND e.nrdconta = 156833	AND e.nrctremp = 156833) OR (e.cdcooper = 16	AND e.nrdconta = 157554	AND e.nrctremp = 157554) OR
(e.cdcooper = 16	AND e.nrdconta = 158046	AND e.nrctremp = 158046) OR (e.cdcooper = 16	AND e.nrdconta = 159905	AND e.nrctremp = 159905) OR
(e.cdcooper = 16	AND e.nrdconta = 160164	AND e.nrctremp = 24365) OR (e.cdcooper = 16	AND e.nrdconta = 160288	AND e.nrctremp = 160288) OR
(e.cdcooper = 16	AND e.nrdconta = 160334	AND e.nrctremp = 160334) OR (e.cdcooper = 16	AND e.nrdconta = 161055	AND e.nrctremp = 161055) OR
(e.cdcooper = 16	AND e.nrdconta = 163236	AND e.nrctremp = 38192) OR (e.cdcooper = 16	AND e.nrdconta = 165476	AND e.nrctremp = 165476) OR
(e.cdcooper = 16	AND e.nrdconta = 167452	AND e.nrctremp = 167452) OR (e.cdcooper = 16	AND e.nrdconta = 167703	AND e.nrctremp = 167703) OR
(e.cdcooper = 16	AND e.nrdconta = 168335	AND e.nrctremp = 168335) OR (e.cdcooper = 16	AND e.nrdconta = 168696	AND e.nrctremp = 131948) OR
(e.cdcooper = 16	AND e.nrdconta = 169137	AND e.nrctremp = 169137) OR (e.cdcooper = 16	AND e.nrdconta = 169323	AND e.nrctremp = 169323) OR
(e.cdcooper = 16	AND e.nrdconta = 169790	AND e.nrctremp = 169790) OR (e.cdcooper = 16	AND e.nrdconta = 170151	AND e.nrctremp = 115527) OR
(e.cdcooper = 16	AND e.nrdconta = 171522	AND e.nrctremp = 21181) OR (e.cdcooper = 16	AND e.nrdconta = 174033	AND e.nrctremp = 114122) OR
(e.cdcooper = 16	AND e.nrdconta = 176850	AND e.nrctremp = 176850) OR (e.cdcooper = 16	AND e.nrdconta = 178268	AND e.nrctremp = 12988) OR
(e.cdcooper = 16	AND e.nrdconta = 180645	AND e.nrctremp = 88678) OR (e.cdcooper = 16	AND e.nrdconta = 183563	AND e.nrctremp = 183563) OR
(e.cdcooper = 16	AND e.nrdconta = 183962	AND e.nrctremp = 114083) OR (e.cdcooper = 16	AND e.nrdconta = 184160	AND e.nrctremp = 184160) OR
(e.cdcooper = 16	AND e.nrdconta = 184330	AND e.nrctremp = 16526) OR (e.cdcooper = 16	AND e.nrdconta = 184357	AND e.nrctremp = 17184) OR
(e.cdcooper = 16	AND e.nrdconta = 184403	AND e.nrctremp = 184403) OR (e.cdcooper = 16	AND e.nrdconta = 184594	AND e.nrctremp = 184594) OR
(e.cdcooper = 16	AND e.nrdconta = 185566	AND e.nrctremp = 185566) OR (e.cdcooper = 16	AND e.nrdconta = 186988	AND e.nrctremp = 186988) OR
(e.cdcooper = 16	AND e.nrdconta = 187747	AND e.nrctremp = 12443) OR (e.cdcooper = 16	AND e.nrdconta = 189960	AND e.nrctremp = 189960) OR
(e.cdcooper = 16	AND e.nrdconta = 190403	AND e.nrctremp = 190403) OR (e.cdcooper = 16	AND e.nrdconta = 190454	AND e.nrctremp = 190454) OR
(e.cdcooper = 16	AND e.nrdconta = 191370	AND e.nrctremp = 36253) OR (e.cdcooper = 16	AND e.nrdconta = 191906	AND e.nrctremp = 191906) OR
(e.cdcooper = 16	AND e.nrdconta = 192058	AND e.nrctremp = 17063) OR (e.cdcooper = 16	AND e.nrdconta = 192309	AND e.nrctremp = 192309) OR
(e.cdcooper = 16	AND e.nrdconta = 192678	AND e.nrctremp = 192678) OR (e.cdcooper = 16	AND e.nrdconta = 193984	AND e.nrctremp = 122805) OR
(e.cdcooper = 16	AND e.nrdconta = 198099	AND e.nrctremp = 128526) OR (e.cdcooper = 16	AND e.nrdconta = 199567	AND e.nrctremp = 199567) OR
(e.cdcooper = 16	AND e.nrdconta = 199680	AND e.nrctremp = 199680) OR (e.cdcooper = 16	AND e.nrdconta = 200085	AND e.nrctremp = 200085) OR
(e.cdcooper = 16	AND e.nrdconta = 200727	AND e.nrctremp = 200727) OR (e.cdcooper = 16	AND e.nrdconta = 201154	AND e.nrctremp = 86894) OR
(e.cdcooper = 16	AND e.nrdconta = 202223	AND e.nrctremp = 17617) OR (e.cdcooper = 16	AND e.nrdconta = 202770	AND e.nrctremp = 202770) OR
(e.cdcooper = 16	AND e.nrdconta = 202797	AND e.nrctremp = 202797) OR (e.cdcooper = 16	AND e.nrdconta = 203076	AND e.nrctremp = 203076) OR
(e.cdcooper = 16	AND e.nrdconta = 203491	AND e.nrctremp = 81285) OR (e.cdcooper = 16	AND e.nrdconta = 204099	AND e.nrctremp = 204099) OR
(e.cdcooper = 16	AND e.nrdconta = 205419	AND e.nrctremp = 205419) OR (e.cdcooper = 16	AND e.nrdconta = 205460	AND e.nrctremp = 132973) OR
(e.cdcooper = 16	AND e.nrdconta = 205648	AND e.nrctremp = 205648) OR (e.cdcooper = 16	AND e.nrdconta = 207780	AND e.nrctremp = 207780) OR
(e.cdcooper = 16	AND e.nrdconta = 208574	AND e.nrctremp = 208574) OR (e.cdcooper = 16	AND e.nrdconta = 208825	AND e.nrctremp = 64005) OR
(e.cdcooper = 16	AND e.nrdconta = 209147	AND e.nrctremp = 209147) OR (e.cdcooper = 16	AND e.nrdconta = 209554	AND e.nrctremp = 209554) OR
(e.cdcooper = 16	AND e.nrdconta = 211010	AND e.nrctremp = 117115) OR (e.cdcooper = 16	AND e.nrdconta = 211893	AND e.nrctremp = 211893) OR
(e.cdcooper = 16	AND e.nrdconta = 212156	AND e.nrctremp = 212156) OR (e.cdcooper = 16	AND e.nrdconta = 212350	AND e.nrctremp = 137991) OR
(e.cdcooper = 16	AND e.nrdconta = 212601	AND e.nrctremp = 212601) OR (e.cdcooper = 16	AND e.nrdconta = 213322	AND e.nrctremp = 213322) OR
(e.cdcooper = 16	AND e.nrdconta = 213730	AND e.nrctremp = 213730) OR (e.cdcooper = 16	AND e.nrdconta = 214345	AND e.nrctremp = 214345) OR
(e.cdcooper = 16	AND e.nrdconta = 215880	AND e.nrctremp = 215880) OR (e.cdcooper = 16	AND e.nrdconta = 218090	AND e.nrctremp = 218090) OR
(e.cdcooper = 16	AND e.nrdconta = 218510	AND e.nrctremp = 218510) OR (e.cdcooper = 16	AND e.nrdconta = 218782	AND e.nrctremp = 54045) OR
(e.cdcooper = 16	AND e.nrdconta = 219657	AND e.nrctremp = 219657) OR (e.cdcooper = 16	AND e.nrdconta = 219703	AND e.nrctremp = 219703) OR
(e.cdcooper = 16	AND e.nrdconta = 220949	AND e.nrctremp = 123767) OR (e.cdcooper = 16	AND e.nrdconta = 221520	AND e.nrctremp = 27363) OR
(e.cdcooper = 16	AND e.nrdconta = 223433	AND e.nrctremp = 52713) OR (e.cdcooper = 16	AND e.nrdconta = 223476	AND e.nrctremp = 223476) OR
(e.cdcooper = 16	AND e.nrdconta = 227986	AND e.nrctremp = 227986) OR (e.cdcooper = 16	AND e.nrdconta = 228044	AND e.nrctremp = 228044) OR
(e.cdcooper = 16	AND e.nrdconta = 228320	AND e.nrctremp = 122859) OR (e.cdcooper = 16	AND e.nrdconta = 228478	AND e.nrctremp = 228478) OR
(e.cdcooper = 16	AND e.nrdconta = 228575	AND e.nrctremp = 68370) OR (e.cdcooper = 16	AND e.nrdconta = 228818	AND e.nrctremp = 228818) OR
(e.cdcooper = 16	AND e.nrdconta = 228990	AND e.nrctremp = 228990) OR (e.cdcooper = 16	AND e.nrdconta = 229300	AND e.nrctremp = 34701) OR
(e.cdcooper = 16	AND e.nrdconta = 229571	AND e.nrctremp = 62653) OR (e.cdcooper = 16	AND e.nrdconta = 230022	AND e.nrctremp = 103621) OR
(e.cdcooper = 16	AND e.nrdconta = 230979	AND e.nrctremp = 230979) OR (e.cdcooper = 16	AND e.nrdconta = 231363	AND e.nrctremp = 231363) OR
(e.cdcooper = 16	AND e.nrdconta = 231770	AND e.nrctremp = 54088) OR (e.cdcooper = 16	AND e.nrdconta = 233544	AND e.nrctremp = 233544) OR
(e.cdcooper = 16	AND e.nrdconta = 234168	AND e.nrctremp = 24495) OR (e.cdcooper = 16	AND e.nrdconta = 235610	AND e.nrctremp = 235610) OR
(e.cdcooper = 16	AND e.nrdconta = 237078	AND e.nrctremp = 84509) OR (e.cdcooper = 16	AND e.nrdconta = 237256	AND e.nrctremp = 36445) OR
(e.cdcooper = 16	AND e.nrdconta = 238210	AND e.nrctremp = 98734) OR (e.cdcooper = 16	AND e.nrdconta = 238490	AND e.nrctremp = 82164) OR
(e.cdcooper = 16	AND e.nrdconta = 238740	AND e.nrctremp = 28281) OR (e.cdcooper = 16	AND e.nrdconta = 239313	AND e.nrctremp = 130686) OR
(e.cdcooper = 16	AND e.nrdconta = 241083	AND e.nrctremp = 10752) OR (e.cdcooper = 16	AND e.nrdconta = 242616	AND e.nrctremp = 242616) OR
(e.cdcooper = 16	AND e.nrdconta = 242780	AND e.nrctremp = 242780) OR (e.cdcooper = 16	AND e.nrdconta = 243051	AND e.nrctremp = 64897) OR
(e.cdcooper = 16	AND e.nrdconta = 243086	AND e.nrctremp = 117911) OR (e.cdcooper = 16	AND e.nrdconta = 244287	AND e.nrctremp = 244287) OR
(e.cdcooper = 16	AND e.nrdconta = 245747	AND e.nrctremp = 76093) OR (e.cdcooper = 16	AND e.nrdconta = 246255	AND e.nrctremp = 246255) OR
(e.cdcooper = 16	AND e.nrdconta = 247480	AND e.nrctremp = 80602) OR (e.cdcooper = 16	AND e.nrdconta = 248800	AND e.nrctremp = 248800) OR
(e.cdcooper = 16	AND e.nrdconta = 249734	AND e.nrctremp = 123750) OR (e.cdcooper = 16	AND e.nrdconta = 250805	AND e.nrctremp = 250805) OR
(e.cdcooper = 16	AND e.nrdconta = 251330	AND e.nrctremp = 251330) OR (e.cdcooper = 16	AND e.nrdconta = 253570	AND e.nrctremp = 253570) OR
(e.cdcooper = 16	AND e.nrdconta = 254592	AND e.nrctremp = 74444) OR (e.cdcooper = 16	AND e.nrdconta = 255874	AND e.nrctremp = 45395) OR
(e.cdcooper = 16	AND e.nrdconta = 257540	AND e.nrctremp = 50599) OR (e.cdcooper = 16	AND e.nrdconta = 258547	AND e.nrctremp = 258547) OR
(e.cdcooper = 16	AND e.nrdconta = 259195	AND e.nrctremp = 113662) OR (e.cdcooper = 16	AND e.nrdconta = 259691	AND e.nrctremp = 259691) OR
(e.cdcooper = 16	AND e.nrdconta = 259730	AND e.nrctremp = 259730) OR (e.cdcooper = 16	AND e.nrdconta = 260169	AND e.nrctremp = 260169) OR
(e.cdcooper = 16	AND e.nrdconta = 260177	AND e.nrctremp = 76205) OR (e.cdcooper = 16	AND e.nrdconta = 260304	AND e.nrctremp = 82050) OR
(e.cdcooper = 16	AND e.nrdconta = 260320	AND e.nrctremp = 260320) OR (e.cdcooper = 16	AND e.nrdconta = 261769	AND e.nrctremp = 30660) OR
(e.cdcooper = 16	AND e.nrdconta = 261971	AND e.nrctremp = 106349) OR (e.cdcooper = 16	AND e.nrdconta = 263303	AND e.nrctremp = 135642) OR
(e.cdcooper = 16	AND e.nrdconta = 264750	AND e.nrctremp = 264750) OR (e.cdcooper = 16	AND e.nrdconta = 266582	AND e.nrctremp = 266582) OR
(e.cdcooper = 16	AND e.nrdconta = 268283	AND e.nrctremp = 43779) OR (e.cdcooper = 16	AND e.nrdconta = 270539	AND e.nrctremp = 70093) OR
(e.cdcooper = 16	AND e.nrdconta = 271683	AND e.nrctremp = 114079) OR (e.cdcooper = 16	AND e.nrdconta = 272078	AND e.nrctremp = 272078) OR
(e.cdcooper = 16	AND e.nrdconta = 272167	AND e.nrctremp = 272167) OR (e.cdcooper = 16	AND e.nrdconta = 272884	AND e.nrctremp = 63543) OR
(e.cdcooper = 16	AND e.nrdconta = 274283	AND e.nrctremp = 123748) OR (e.cdcooper = 16	AND e.nrdconta = 275190	AND e.nrctremp = 96205) OR
(e.cdcooper = 16	AND e.nrdconta = 277991	AND e.nrctremp = 277991) OR (e.cdcooper = 16	AND e.nrdconta = 280232	AND e.nrctremp = 134722) OR
(e.cdcooper = 16	AND e.nrdconta = 280402	AND e.nrctremp = 50894) OR (e.cdcooper = 16	AND e.nrdconta = 280569	AND e.nrctremp = 79069) OR
(e.cdcooper = 16	AND e.nrdconta = 280666	AND e.nrctremp = 120787) OR (e.cdcooper = 16	AND e.nrdconta = 280860	AND e.nrctremp = 280860) OR
(e.cdcooper = 16	AND e.nrdconta = 280887	AND e.nrctremp = 79766) OR (e.cdcooper = 16	AND e.nrdconta = 282120	AND e.nrctremp = 18691) OR
(e.cdcooper = 16	AND e.nrdconta = 282219	AND e.nrctremp = 67399) OR (e.cdcooper = 16	AND e.nrdconta = 282332	AND e.nrctremp = 56595) OR
(e.cdcooper = 16	AND e.nrdconta = 284629	AND e.nrctremp = 284629) OR (e.cdcooper = 16	AND e.nrdconta = 284653	AND e.nrctremp = 284653) OR
(e.cdcooper = 16	AND e.nrdconta = 285129	AND e.nrctremp = 72363) OR (e.cdcooper = 16	AND e.nrdconta = 285706	AND e.nrctremp = 59661) OR
(e.cdcooper = 16	AND e.nrdconta = 287091	AND e.nrctremp = 119706) OR (e.cdcooper = 16	AND e.nrdconta = 287679	AND e.nrctremp = 104056) OR
(e.cdcooper = 16	AND e.nrdconta = 287679	AND e.nrctremp = 119914) OR (e.cdcooper = 16	AND e.nrdconta = 288900	AND e.nrctremp = 125742) OR
(e.cdcooper = 16	AND e.nrdconta = 290637	AND e.nrctremp = 110370) OR (e.cdcooper = 16	AND e.nrdconta = 291048	AND e.nrctremp = 123058) OR
(e.cdcooper = 16	AND e.nrdconta = 292974	AND e.nrctremp = 28646) OR (e.cdcooper = 16	AND e.nrdconta = 293083	AND e.nrctremp = 116203) OR
(e.cdcooper = 16	AND e.nrdconta = 296074	AND e.nrctremp = 78008) OR (e.cdcooper = 16	AND e.nrdconta = 296678	AND e.nrctremp = 296678) OR
(e.cdcooper = 16	AND e.nrdconta = 297704	AND e.nrctremp = 97621) OR (e.cdcooper = 16	AND e.nrdconta = 298999	AND e.nrctremp = 7292) OR
(e.cdcooper = 16	AND e.nrdconta = 299049	AND e.nrctremp = 128802) OR (e.cdcooper = 16	AND e.nrdconta = 299600	AND e.nrctremp = 83730) OR
(e.cdcooper = 16	AND e.nrdconta = 301531	AND e.nrctremp = 71788) OR (e.cdcooper = 16	AND e.nrdconta = 301868	AND e.nrctremp = 85940) OR
(e.cdcooper = 16	AND e.nrdconta = 303313	AND e.nrctremp = 131911) OR (e.cdcooper = 16	AND e.nrdconta = 303615	AND e.nrctremp = 56352) OR
(e.cdcooper = 16	AND e.nrdconta = 304549	AND e.nrctremp = 53559) OR (e.cdcooper = 16	AND e.nrdconta = 308625	AND e.nrctremp = 78626) OR
(e.cdcooper = 16	AND e.nrdconta = 308722	AND e.nrctremp = 122780) OR (e.cdcooper = 16	AND e.nrdconta = 311960	AND e.nrctremp = 66452) OR
(e.cdcooper = 16	AND e.nrdconta = 312274	AND e.nrctremp = 65192) OR (e.cdcooper = 16	AND e.nrdconta = 312363	AND e.nrctremp = 76340) OR
(e.cdcooper = 16	AND e.nrdconta = 313572	AND e.nrctremp = 96267) OR (e.cdcooper = 16	AND e.nrdconta = 315575	AND e.nrctremp = 107145) OR
(e.cdcooper = 16	AND e.nrdconta = 317128	AND e.nrctremp = 73484) OR (e.cdcooper = 16	AND e.nrdconta = 319970	AND e.nrctremp = 107802) OR
(e.cdcooper = 16	AND e.nrdconta = 321079	AND e.nrctremp = 115570) OR (e.cdcooper = 16	AND e.nrdconta = 323071	AND e.nrctremp = 77636) OR
(e.cdcooper = 16	AND e.nrdconta = 324043	AND e.nrctremp = 134780) OR (e.cdcooper = 16	AND e.nrdconta = 324426	AND e.nrctremp = 98738) OR
(e.cdcooper = 16	AND e.nrdconta = 324990	AND e.nrctremp = 59916) OR (e.cdcooper = 16	AND e.nrdconta = 325228	AND e.nrctremp = 103191) OR
(e.cdcooper = 16	AND e.nrdconta = 327387	AND e.nrctremp = 126813) OR (e.cdcooper = 16	AND e.nrdconta = 327409	AND e.nrctremp = 117203) OR
(e.cdcooper = 16	AND e.nrdconta = 330205	AND e.nrctremp = 117149) OR (e.cdcooper = 16	AND e.nrdconta = 332445	AND e.nrctremp = 93156) OR
(e.cdcooper = 16	AND e.nrdconta = 332615	AND e.nrctremp = 57900) OR (e.cdcooper = 16	AND e.nrdconta = 333964	AND e.nrctremp = 140126) OR
(e.cdcooper = 16	AND e.nrdconta = 335860	AND e.nrctremp = 117121) OR (e.cdcooper = 16	AND e.nrdconta = 337439	AND e.nrctremp = 117216) OR
(e.cdcooper = 16	AND e.nrdconta = 338028	AND e.nrctremp = 117137) OR (e.cdcooper = 16	AND e.nrdconta = 338036	AND e.nrctremp = 64502) OR
(e.cdcooper = 16	AND e.nrdconta = 339075	AND e.nrctremp = 98706) OR (e.cdcooper = 16	AND e.nrdconta = 339296	AND e.nrctremp = 94316) OR
(e.cdcooper = 16	AND e.nrdconta = 340731	AND e.nrctremp = 76686) OR (e.cdcooper = 16	AND e.nrdconta = 343080	AND e.nrctremp = 77824) OR
(e.cdcooper = 16	AND e.nrdconta = 343331	AND e.nrctremp = 117210) OR (e.cdcooper = 16	AND e.nrdconta = 345040	AND e.nrctremp = 86072) OR
(e.cdcooper = 16	AND e.nrdconta = 345040	AND e.nrctremp = 117182) OR (e.cdcooper = 16	AND e.nrdconta = 348112	AND e.nrctremp = 126988) OR
(e.cdcooper = 16	AND e.nrdconta = 350117	AND e.nrctremp = 117139) OR (e.cdcooper = 16	AND e.nrdconta = 351601	AND e.nrctremp = 91946) OR
(e.cdcooper = 16	AND e.nrdconta = 351881	AND e.nrctremp = 83102) OR (e.cdcooper = 16	AND e.nrdconta = 352926	AND e.nrctremp = 80936) OR
(e.cdcooper = 16	AND e.nrdconta = 353434	AND e.nrctremp = 120799) OR (e.cdcooper = 16	AND e.nrdconta = 354759	AND e.nrctremp = 81986) OR
(e.cdcooper = 16	AND e.nrdconta = 355089	AND e.nrctremp = 79778) OR (e.cdcooper = 16	AND e.nrdconta = 355089	AND e.nrctremp = 126831) OR
(e.cdcooper = 16	AND e.nrdconta = 355674	AND e.nrctremp = 125725) OR (e.cdcooper = 16	AND e.nrdconta = 357090	AND e.nrctremp = 122795) OR
(e.cdcooper = 16	AND e.nrdconta = 358657	AND e.nrctremp = 21058) OR (e.cdcooper = 16	AND e.nrdconta = 361437	AND e.nrctremp = 85519) OR
(e.cdcooper = 16	AND e.nrdconta = 361666	AND e.nrctremp = 141390) OR (e.cdcooper = 16	AND e.nrdconta = 362832	AND e.nrctremp = 96249) OR
(e.cdcooper = 16	AND e.nrdconta = 363570	AND e.nrctremp = 75078) OR (e.cdcooper = 16	AND e.nrdconta = 364070	AND e.nrctremp = 25023) OR
(e.cdcooper = 16	AND e.nrdconta = 364649	AND e.nrctremp = 65807) OR (e.cdcooper = 16	AND e.nrdconta = 365858	AND e.nrctremp = 82212) OR
(e.cdcooper = 16	AND e.nrdconta = 366030	AND e.nrctremp = 79096) OR (e.cdcooper = 16	AND e.nrdconta = 367311	AND e.nrctremp = 95902) OR
(e.cdcooper = 16	AND e.nrdconta = 369160	AND e.nrctremp = 92716) OR (e.cdcooper = 16	AND e.nrdconta = 369241	AND e.nrctremp = 66954) OR
(e.cdcooper = 16	AND e.nrdconta = 369314	AND e.nrctremp = 66821) OR (e.cdcooper = 16	AND e.nrdconta = 369527	AND e.nrctremp = 134769) OR
(e.cdcooper = 16	AND e.nrdconta = 374008	AND e.nrctremp = 125397) OR (e.cdcooper = 16	AND e.nrdconta = 374067	AND e.nrctremp = 117152) OR
(e.cdcooper = 16	AND e.nrdconta = 375225	AND e.nrctremp = 68365) OR (e.cdcooper = 16	AND e.nrdconta = 375993	AND e.nrctremp = 103592) OR
(e.cdcooper = 16	AND e.nrdconta = 376396	AND e.nrctremp = 101394) OR (e.cdcooper = 16	AND e.nrdconta = 376507	AND e.nrctremp = 74439) OR
(e.cdcooper = 16	AND e.nrdconta = 379476	AND e.nrctremp = 122810) OR (e.cdcooper = 16	AND e.nrdconta = 379603	AND e.nrctremp = 133326) OR
(e.cdcooper = 16	AND e.nrdconta = 382817	AND e.nrctremp = 70244) OR (e.cdcooper = 16	AND e.nrdconta = 386154	AND e.nrctremp = 113204) OR
(e.cdcooper = 16	AND e.nrdconta = 386375	AND e.nrctremp = 119875) OR (e.cdcooper = 16	AND e.nrdconta = 386650	AND e.nrctremp = 95919) OR
(e.cdcooper = 16	AND e.nrdconta = 388688	AND e.nrctremp = 125163) OR (e.cdcooper = 16	AND e.nrdconta = 388882	AND e.nrctremp = 116872) OR
(e.cdcooper = 16	AND e.nrdconta = 390593	AND e.nrctremp = 109805) OR (e.cdcooper = 16	AND e.nrdconta = 391166	AND e.nrctremp = 90696) OR
(e.cdcooper = 16	AND e.nrdconta = 391646	AND e.nrctremp = 115326) OR (e.cdcooper = 16	AND e.nrdconta = 392367	AND e.nrctremp = 115533) OR
(e.cdcooper = 16	AND e.nrdconta = 392499	AND e.nrctremp = 80414) OR (e.cdcooper = 16	AND e.nrdconta = 395250	AND e.nrctremp = 113657) OR
(e.cdcooper = 16	AND e.nrdconta = 396389	AND e.nrctremp = 100686) OR (e.cdcooper = 16	AND e.nrdconta = 396397	AND e.nrctremp = 114081) OR
(e.cdcooper = 16	AND e.nrdconta = 396400	AND e.nrctremp = 73646) OR (e.cdcooper = 16	AND e.nrdconta = 397237	AND e.nrctremp = 103554) OR
(e.cdcooper = 16	AND e.nrdconta = 398152	AND e.nrctremp = 74166) OR (e.cdcooper = 16	AND e.nrdconta = 400610	AND e.nrctremp = 92660) OR
(e.cdcooper = 16	AND e.nrdconta = 401455	AND e.nrctremp = 129557) OR (e.cdcooper = 16	AND e.nrdconta = 401900	AND e.nrctremp = 74646) OR
(e.cdcooper = 16	AND e.nrdconta = 403962	AND e.nrctremp = 128758) OR (e.cdcooper = 16	AND e.nrdconta = 405213	AND e.nrctremp = 97169) OR
(e.cdcooper = 16	AND e.nrdconta = 405272	AND e.nrctremp = 79780) OR (e.cdcooper = 16	AND e.nrdconta = 406520	AND e.nrctremp = 98667) OR
(e.cdcooper = 16	AND e.nrdconta = 407976	AND e.nrctremp = 124070) OR (e.cdcooper = 16	AND e.nrdconta = 408425	AND e.nrctremp = 122774) OR
(e.cdcooper = 16	AND e.nrdconta = 409138	AND e.nrctremp = 125732) OR (e.cdcooper = 16	AND e.nrdconta = 409472	AND e.nrctremp = 76393) OR
(e.cdcooper = 16	AND e.nrdconta = 409553	AND e.nrctremp = 76594) OR (e.cdcooper = 16	AND e.nrdconta = 409618	AND e.nrctremp = 119878) OR
(e.cdcooper = 16	AND e.nrdconta = 411841	AND e.nrctremp = 77082) OR (e.cdcooper = 16	AND e.nrdconta = 414441	AND e.nrctremp = 107089) OR
(e.cdcooper = 16	AND e.nrdconta = 418617	AND e.nrctremp = 138027) OR (e.cdcooper = 16	AND e.nrdconta = 419265	AND e.nrctremp = 111465) OR
(e.cdcooper = 16	AND e.nrdconta = 419869	AND e.nrctremp = 87132) OR (e.cdcooper = 16	AND e.nrdconta = 420018	AND e.nrctremp = 117175) OR
(e.cdcooper = 16	AND e.nrdconta = 420280	AND e.nrctremp = 79163) OR (e.cdcooper = 16	AND e.nrdconta = 421944	AND e.nrctremp = 110387) OR
(e.cdcooper = 16	AND e.nrdconta = 422975	AND e.nrctremp = 141415) OR (e.cdcooper = 16	AND e.nrdconta = 426148	AND e.nrctremp = 128628) OR
(e.cdcooper = 16	AND e.nrdconta = 426440	AND e.nrctremp = 122786) OR (e.cdcooper = 16	AND e.nrdconta = 427330	AND e.nrctremp = 117199) OR
(e.cdcooper = 16	AND e.nrdconta = 427411	AND e.nrctremp = 96294) OR (e.cdcooper = 16	AND e.nrdconta = 427411	AND e.nrctremp = 135644) OR
(e.cdcooper = 16	AND e.nrdconta = 429112	AND e.nrctremp = 119887) OR (e.cdcooper = 16	AND e.nrdconta = 429945	AND e.nrctremp = 117825) OR
(e.cdcooper = 16	AND e.nrdconta = 430536	AND e.nrctremp = 87998) OR (e.cdcooper = 16	AND e.nrdconta = 431990	AND e.nrctremp = 83452) OR
(e.cdcooper = 16	AND e.nrdconta = 432350	AND e.nrctremp = 125066) OR (e.cdcooper = 16	AND e.nrdconta = 433209	AND e.nrctremp = 121831) OR
(e.cdcooper = 16	AND e.nrdconta = 435260	AND e.nrctremp = 106731) OR (e.cdcooper = 16	AND e.nrdconta = 438553	AND e.nrctremp = 117197) OR
(e.cdcooper = 16	AND e.nrdconta = 440930	AND e.nrctremp = 125806) OR (e.cdcooper = 16	AND e.nrdconta = 443301	AND e.nrctremp = 98761) OR
(e.cdcooper = 16	AND e.nrdconta = 445614	AND e.nrctremp = 85861) OR (e.cdcooper = 16	AND e.nrdconta = 446130	AND e.nrctremp = 117921) OR
(e.cdcooper = 16	AND e.nrdconta = 446823	AND e.nrctremp = 98624) OR (e.cdcooper = 16	AND e.nrdconta = 450529	AND e.nrctremp = 117202) OR
(e.cdcooper = 16	AND e.nrdconta = 451630	AND e.nrctremp = 119932) OR (e.cdcooper = 16	AND e.nrdconta = 452467	AND e.nrctremp = 111460) OR
(e.cdcooper = 16	AND e.nrdconta = 454702	AND e.nrctremp = 110326) OR (e.cdcooper = 16	AND e.nrdconta = 459780	AND e.nrctremp = 120812) OR
(e.cdcooper = 16	AND e.nrdconta = 459895	AND e.nrctremp = 130288) OR (e.cdcooper = 16	AND e.nrdconta = 461849	AND e.nrctremp = 114086) OR
(e.cdcooper = 16	AND e.nrdconta = 461954	AND e.nrctremp = 120813) OR (e.cdcooper = 16	AND e.nrdconta = 462195	AND e.nrctremp = 117165) OR
(e.cdcooper = 16	AND e.nrdconta = 462420	AND e.nrctremp = 122814) OR (e.cdcooper = 16	AND e.nrdconta = 468169	AND e.nrctremp = 109560) OR
(e.cdcooper = 16	AND e.nrdconta = 472476	AND e.nrctremp = 122821) OR (e.cdcooper = 16	AND e.nrdconta = 476846	AND e.nrctremp = 110378) OR
(e.cdcooper = 16	AND e.nrdconta = 478270	AND e.nrctremp = 119700) OR (e.cdcooper = 16	AND e.nrdconta = 481874	AND e.nrctremp = 101022) OR
(e.cdcooper = 16	AND e.nrdconta = 483036	AND e.nrctremp = 143001) OR (e.cdcooper = 16	AND e.nrdconta = 484270	AND e.nrctremp = 118251) OR
(e.cdcooper = 16	AND e.nrdconta = 486787	AND e.nrctremp = 114129) OR (e.cdcooper = 16	AND e.nrdconta = 494780	AND e.nrctremp = 131956) OR
(e.cdcooper = 16	AND e.nrdconta = 502901	AND e.nrctremp = 134771) OR (e.cdcooper = 16	AND e.nrdconta = 503002	AND e.nrctremp = 126835) OR
(e.cdcooper = 16	AND e.nrdconta = 508616	AND e.nrctremp = 117163) OR (e.cdcooper = 16	AND e.nrdconta = 512958	AND e.nrctremp = 122824) OR
(e.cdcooper = 16	AND e.nrdconta = 525081	AND e.nrctremp = 109037) OR (e.cdcooper = 16	AND e.nrdconta = 525081	AND e.nrctremp = 115128) OR
(e.cdcooper = 16	AND e.nrdconta = 531200	AND e.nrctremp = 109372) OR (e.cdcooper = 16	AND e.nrdconta = 531200	AND e.nrctremp = 123736) OR
(e.cdcooper = 16	AND e.nrdconta = 538175	AND e.nrctremp = 120517) OR (e.cdcooper = 16	AND e.nrdconta = 541281	AND e.nrctremp = 112408) OR
(e.cdcooper = 16	AND e.nrdconta = 541907	AND e.nrctremp = 143952) OR (e.cdcooper = 16	AND e.nrdconta = 542709	AND e.nrctremp = 123657) OR
(e.cdcooper = 16	AND e.nrdconta = 547530	AND e.nrctremp = 117842) OR (e.cdcooper = 16	AND e.nrdconta = 562483	AND e.nrctremp = 117376) OR
(e.cdcooper = 16	AND e.nrdconta = 574406	AND e.nrctremp = 124246) OR (e.cdcooper = 16	AND e.nrdconta = 587346	AND e.nrctremp = 135021) OR
(e.cdcooper = 16	AND e.nrdconta = 613045	AND e.nrctremp = 72676) OR (e.cdcooper = 16	AND e.nrdconta = 613614	AND e.nrctremp = 6127) OR
(e.cdcooper = 16	AND e.nrdconta = 616001	AND e.nrctremp = 616001) OR (e.cdcooper = 16	AND e.nrdconta = 945978	AND e.nrctremp = 11064) OR
(e.cdcooper = 16	AND e.nrdconta = 950955	AND e.nrctremp = 114123) OR (e.cdcooper = 16	AND e.nrdconta = 1835335	AND e.nrctremp = 4909) OR
(e.cdcooper = 16	AND e.nrdconta = 1887670	AND e.nrctremp = 84677) OR (e.cdcooper = 16	AND e.nrdconta = 1908278	AND e.nrctremp = 11329) OR
(e.cdcooper = 16	AND e.nrdconta = 2005158	AND e.nrctremp = 31619) OR (e.cdcooper = 16	AND e.nrdconta = 2063808	AND e.nrctremp = 2063808) OR
(e.cdcooper = 16	AND e.nrdconta = 2112795	AND e.nrctremp = 22338) OR (e.cdcooper = 16	AND e.nrdconta = 2135280	AND e.nrctremp = 200688) OR
(e.cdcooper = 16	AND e.nrdconta = 2136236	AND e.nrctremp = 8218) OR (e.cdcooper = 16	AND e.nrdconta = 2155591	AND e.nrctremp = 20211) OR
(e.cdcooper = 16	AND e.nrdconta = 2156318	AND e.nrctremp = 14687) OR (e.cdcooper = 16	AND e.nrdconta = 2266245	AND e.nrctremp = 15159) OR
(e.cdcooper = 16	AND e.nrdconta = 2292599	AND e.nrctremp = 86133) OR (e.cdcooper = 16	AND e.nrdconta = 2358212	AND e.nrctremp = 2358212) OR
(e.cdcooper = 16	AND e.nrdconta = 2376334	AND e.nrctremp = 2376334) OR (e.cdcooper = 16	AND e.nrdconta = 2407930	AND e.nrctremp = 20517) OR
(e.cdcooper = 16	AND e.nrdconta = 2459418	AND e.nrctremp = 3027) OR (e.cdcooper = 16	AND e.nrdconta = 2472228	AND e.nrctremp = 15246) OR
(e.cdcooper = 16	AND e.nrdconta = 2472686	AND e.nrctremp = 2472686) OR (e.cdcooper = 16	AND e.nrdconta = 2473232	AND e.nrctremp = 18261) OR
(e.cdcooper = 16	AND e.nrdconta = 2473232	AND e.nrctremp = 2473232) OR (e.cdcooper = 16	AND e.nrdconta = 2500124	AND e.nrctremp = 40578) OR
(e.cdcooper = 16	AND e.nrdconta = 2539551	AND e.nrctremp = 9990) OR (e.cdcooper = 16	AND e.nrdconta = 2557894	AND e.nrctremp = 15991) OR
(e.cdcooper = 16	AND e.nrdconta = 2594706	AND e.nrctremp = 2594706) OR (e.cdcooper = 16	AND e.nrdconta = 2602024	AND e.nrctremp = 15179) OR
(e.cdcooper = 16	AND e.nrdconta = 2649551	AND e.nrctremp = 14540) OR (e.cdcooper = 16	AND e.nrdconta = 2688832	AND e.nrctremp = 13870) OR
(e.cdcooper = 16	AND e.nrdconta = 2693763	AND e.nrctremp = 18912) OR (e.cdcooper = 16	AND e.nrdconta = 2721996	AND e.nrctremp = 2721996) OR
(e.cdcooper = 16	AND e.nrdconta = 2733170	AND e.nrctremp = 8624) OR (e.cdcooper = 16	AND e.nrdconta = 2735075	AND e.nrctremp = 2735075) OR
(e.cdcooper = 16	AND e.nrdconta = 2736659	AND e.nrctremp = 17432) OR (e.cdcooper = 16	AND e.nrdconta = 2766132	AND e.nrctremp = 2766132) OR
(e.cdcooper = 16	AND e.nrdconta = 2767058	AND e.nrctremp = 2767058) OR (e.cdcooper = 16	AND e.nrdconta = 2796716	AND e.nrctremp = 2796716) OR
(e.cdcooper = 16	AND e.nrdconta = 2796902	AND e.nrctremp = 11847) OR (e.cdcooper = 16	AND e.nrdconta = 2797640	AND e.nrctremp = 2797640) OR
(e.cdcooper = 16	AND e.nrdconta = 2853736	AND e.nrctremp = 20025) OR (e.cdcooper = 16	AND e.nrdconta = 2885522	AND e.nrctremp = 26569) OR
(e.cdcooper = 16	AND e.nrdconta = 2889382	AND e.nrctremp = 144807) OR (e.cdcooper = 16	AND e.nrdconta = 2921995	AND e.nrctremp = 6829) OR
(e.cdcooper = 16	AND e.nrdconta = 2945398	AND e.nrctremp = 10104) OR (e.cdcooper = 16	AND e.nrdconta = 2957680	AND e.nrctremp = 52507) OR
(e.cdcooper = 16	AND e.nrdconta = 2957728	AND e.nrctremp = 14656) OR (e.cdcooper = 16	AND e.nrdconta = 2957850	AND e.nrctremp = 134754) OR
(e.cdcooper = 16	AND e.nrdconta = 2986523	AND e.nrctremp = 88470) OR (e.cdcooper = 16	AND e.nrdconta = 2986558	AND e.nrctremp = 47601) OR
(e.cdcooper = 16	AND e.nrdconta = 2986558	AND e.nrctremp = 52299) OR (e.cdcooper = 16	AND e.nrdconta = 3038980	AND e.nrctremp = 3038980) OR
(e.cdcooper = 16	AND e.nrdconta = 3063364	AND e.nrctremp = 60220) OR (e.cdcooper = 16	AND e.nrdconta = 3064212	AND e.nrctremp = 68723) OR
(e.cdcooper = 16	AND e.nrdconta = 3075613	AND e.nrctremp = 81278) OR (e.cdcooper = 16	AND e.nrdconta = 3076245	AND e.nrctremp = 117918) OR
(e.cdcooper = 16	AND e.nrdconta = 3076636	AND e.nrctremp = 3076636) OR (e.cdcooper = 16	AND e.nrdconta = 3081664	AND e.nrctremp = 91088) OR
(e.cdcooper = 16	AND e.nrdconta = 3205754	AND e.nrctremp = 3205754) OR (e.cdcooper = 16	AND e.nrdconta = 3206432	AND e.nrctremp = 76097) OR
(e.cdcooper = 16	AND e.nrdconta = 3224651	AND e.nrctremp = 11029) OR (e.cdcooper = 16	AND e.nrdconta = 3512401	AND e.nrctremp = 126836) OR
(e.cdcooper = 16	AND e.nrdconta = 3540189	AND e.nrctremp = 3540189) OR (e.cdcooper = 16	AND e.nrdconta = 3540464	AND e.nrctremp = 144684) OR
(e.cdcooper = 16	AND e.nrdconta = 3541061	AND e.nrctremp = 21748) OR (e.cdcooper = 16	AND e.nrdconta = 3587088	AND e.nrctremp = 3587088) OR
(e.cdcooper = 16	AND e.nrdconta = 3587630	AND e.nrctremp = 3587630) OR (e.cdcooper = 16	AND e.nrdconta = 3611418	AND e.nrctremp = 3611418) OR
(e.cdcooper = 16	AND e.nrdconta = 3620808	AND e.nrctremp = 3620808) OR (e.cdcooper = 16	AND e.nrdconta = 3679322	AND e.nrctremp = 95801) OR
(e.cdcooper = 16	AND e.nrdconta = 3679608	AND e.nrctremp = 111477) OR (e.cdcooper = 16	AND e.nrdconta = 3680630	AND e.nrctremp = 3680630) OR
(e.cdcooper = 16	AND e.nrdconta = 3745872	AND e.nrctremp = 3745872) OR (e.cdcooper = 16	AND e.nrdconta = 3803210	AND e.nrctremp = 3803210) OR
(e.cdcooper = 16	AND e.nrdconta = 3807029	AND e.nrctremp = 14961) OR (e.cdcooper = 16	AND e.nrdconta = 3808386	AND e.nrctremp = 8444) OR
(e.cdcooper = 16	AND e.nrdconta = 3850625	AND e.nrctremp = 117113) OR (e.cdcooper = 16	AND e.nrdconta = 3851923	AND e.nrctremp = 3851923) OR
(e.cdcooper = 16	AND e.nrdconta = 3909549	AND e.nrctremp = 25587) OR (e.cdcooper = 16	AND e.nrdconta = 3909573	AND e.nrctremp = 14266) OR
(e.cdcooper = 16	AND e.nrdconta = 3963640	AND e.nrctremp = 9602) OR (e.cdcooper = 16	AND e.nrdconta = 3970094	AND e.nrctremp = 29887) OR
(e.cdcooper = 16	AND e.nrdconta = 3971007	AND e.nrctremp = 3971007) OR (e.cdcooper = 16	AND e.nrdconta = 3988694	AND e.nrctremp = 3988694) OR
(e.cdcooper = 16	AND e.nrdconta = 3989151	AND e.nrctremp = 35340) OR (e.cdcooper = 16	AND e.nrdconta = 6034241	AND e.nrctremp = 109611) OR
(e.cdcooper = 16	AND e.nrdconta = 6061486	AND e.nrctremp = 135619) OR (e.cdcooper = 16	AND e.nrdconta = 6076386	AND e.nrctremp = 40214) OR
(e.cdcooper = 16	AND e.nrdconta = 6077315	AND e.nrctremp = 6077315) OR (e.cdcooper = 16	AND e.nrdconta = 6096492	AND e.nrctremp = 6096492) OR
(e.cdcooper = 16	AND e.nrdconta = 6096611	AND e.nrctremp = 6096611) OR (e.cdcooper = 16	AND e.nrdconta = 6126456	AND e.nrctremp = 6126456) OR
(e.cdcooper = 16	AND e.nrdconta = 6126880	AND e.nrctremp = 6126880) OR (e.cdcooper = 16	AND e.nrdconta = 6156843	AND e.nrctremp = 5778) OR
(e.cdcooper = 16	AND e.nrdconta = 6255493	AND e.nrctremp = 101176) OR (e.cdcooper = 16	AND e.nrdconta = 6268714	AND e.nrctremp = 15192) OR
(e.cdcooper = 16	AND e.nrdconta = 6276288	AND e.nrctremp = 16484) OR (e.cdcooper = 16	AND e.nrdconta = 6283250	AND e.nrctremp = 6558) OR
(e.cdcooper = 16	AND e.nrdconta = 6283268	AND e.nrctremp = 129571) OR (e.cdcooper = 16	AND e.nrdconta = 6284191	AND e.nrctremp = 54770) OR
(e.cdcooper = 16	AND e.nrdconta = 6310141	AND e.nrctremp = 125781) OR (e.cdcooper = 16	AND e.nrdconta = 6310460	AND e.nrctremp = 28289) OR
(e.cdcooper = 16	AND e.nrdconta = 6310710	AND e.nrctremp = 6310710) OR (e.cdcooper = 16	AND e.nrdconta = 6310761	AND e.nrctremp = 24807) OR
(e.cdcooper = 16	AND e.nrdconta = 6311156	AND e.nrctremp = 46440) OR (e.cdcooper = 16	AND e.nrdconta = 6331041	AND e.nrctremp = 6331041) OR
(e.cdcooper = 16	AND e.nrdconta = 6331289	AND e.nrctremp = 10882) OR (e.cdcooper = 16	AND e.nrdconta = 6431526	AND e.nrctremp = 6980) OR
(e.cdcooper = 16	AND e.nrdconta = 6432646	AND e.nrctremp = 6432646) OR (e.cdcooper = 16	AND e.nrdconta = 6432891	AND e.nrctremp = 6432891) OR
(e.cdcooper = 16	AND e.nrdconta = 6436811	AND e.nrctremp = 6436811) OR (e.cdcooper = 16	AND e.nrdconta = 6438350	AND e.nrctremp = 6438350) OR
(e.cdcooper = 16	AND e.nrdconta = 6533256	AND e.nrctremp = 128612) OR (e.cdcooper = 16	AND e.nrdconta = 6533809	AND e.nrctremp = 47049) OR
(e.cdcooper = 16	AND e.nrdconta = 6552846	AND e.nrctremp = 33751) OR (e.cdcooper = 16	AND e.nrdconta = 6552900	AND e.nrctremp = 19308) OR
(e.cdcooper = 16	AND e.nrdconta = 6554687	AND e.nrctremp = 57166) OR (e.cdcooper = 16	AND e.nrdconta = 6609651	AND e.nrctremp = 74386) OR
(e.cdcooper = 16	AND e.nrdconta = 6641652	AND e.nrctremp = 6641652) OR (e.cdcooper = 16	AND e.nrdconta = 6641814	AND e.nrctremp = 65358) OR
(e.cdcooper = 16	AND e.nrdconta = 6642624	AND e.nrctremp = 6642624) OR (e.cdcooper = 16	AND e.nrdconta = 6648282	AND e.nrctremp = 8281) OR
(e.cdcooper = 16	AND e.nrdconta = 6670598	AND e.nrctremp = 6670598) OR (e.cdcooper = 16	AND e.nrdconta = 6671039	AND e.nrctremp = 7316) OR
(e.cdcooper = 16	AND e.nrdconta = 6671039	AND e.nrctremp = 6671039) OR (e.cdcooper = 16	AND e.nrdconta = 6671772	AND e.nrctremp = 55494) OR
(e.cdcooper = 16	AND e.nrdconta = 6734197	AND e.nrctremp = 52301) OR (e.cdcooper = 16	AND e.nrdconta = 6734766	AND e.nrctremp = 6734766) OR
(e.cdcooper = 16	AND e.nrdconta = 6781411	AND e.nrctremp = 9521) OR (e.cdcooper = 16	AND e.nrdconta = 6792421	AND e.nrctremp = 6792421));
  rw_principal cr_principal%ROWTYPE;

  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  CURSOR cr_craplem5(pr_cdcooper craplem.cdcooper%TYPE
                    ,pr_nrdconta craplem.nrdconta%TYPE
                    ,pr_nrctremp craplem.nrctremp%TYPE
                    ,pr_dtmvtolt craplem.dtmvtolt%TYPE
                    ) IS
    SELECT nvl(SUM(lem.vllanmto),0) vllanmto
      FROM craplem lem
     WHERE to_char(lem.dtmvtolt, 'MMRRRR') = to_char(pr_dtmvtolt, 'MMRRRR')
       AND lem.cdhistor = 2409
       AND lem.cdcooper = pr_cdcooper
       AND lem.nrdconta = pr_nrdconta
       AND lem.nrctremp = pr_nrctremp;
  rw_craplem5 cr_craplem5%ROWTYPE;
  
  CURSOR cr_devedor(pr_cdcooper craplem.cdcooper%TYPE
                   ,pr_nrdconta craplem.nrdconta%TYPE
                   ,pr_nrctremp craplem.nrctremp%TYPE) IS
    SELECT cdcooper,
           nrdconta,
           SUM(decode(inprejuz,1,vlsdprej, --> Para contas em prejuizo, somar valor saldo em prejuizo
                                vlsdeved)) vlsdeved
      FROM crapepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND (inliquid = 0 OR (inliquid = 1 AND inprejuz = 1))
       AND (nvl(vlsdeved,0) <> 0 OR 
            nvl(vlsdprej,0) <> 0)
     GROUP BY cdcooper, nrdconta;
  rw_devedor cr_devedor%ROWTYPE;
  
  CURSOR cr_crapdir(pr_cdcooper craplem.cdcooper%TYPE
                   ,pr_nrdconta craplem.nrdconta%TYPE) IS
    SELECT vlsddvem 
      FROM crapdir
     WHERE cdcooper = pr_cdcooper 
       AND nrdconta = pr_nrdconta
       AND dtmvtolt = '31/12/2020';
  rw_crapdir cr_crapdir%ROWTYPE;
  
  --
  vr_tab_extrato_epr      extr0002.typ_tab_extrato_epr; 
  TYPE typ_tab_extrato_epr_novo IS TABLE OF extr0002.typ_reg_extrato_epr INDEX BY VARCHAR2(100);
  vr_tab_extrato_epr_novo typ_tab_extrato_epr_novo;
  pr_tab_extrato_epr_aux  extr0002.typ_tab_extrato_epr_aux;
  vr_des_reto VARCHAR2(1000);
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_index_extrato PLS_INTEGER;
  vr_index_novo    VARCHAR2(100);
  vr_index_epr_aux PLS_INTEGER;
  vr_flgloop  BOOLEAN := FALSE;
  vr_vlsaldo1 NUMBER;
  vr_vlsaldo2 NUMBER;
  vr_exc_proximo EXCEPTION;
  vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
  vr_tab_calculado empr0001.typ_tab_calculado;
  vr_vljurdia NUMBER;
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_vlsdprej NUMBER;
  vr_flgativo INTEGER;
  vr_vlsddvem NUMBER;
  vr_vldezemb NUMBER;
  
  PROCEDURE pc_obtem_extrato_emprest    (pr_cdcooper    IN crapcop.cdcooper%TYPE       --Codigo Cooperativa
                                          ,pr_cdagenci    IN crapass.cdagenci%TYPE       --Codigo Agencia
                                          ,pr_nrdcaixa    IN INTEGER                     --Numero do Caixa
                                          ,pr_cdoperad    IN VARCHAR2                    --Codigo Operador
                                          ,pr_nmdatela    IN VARCHAR2                    --Nome da Tela
                                          ,pr_idorigem    IN INTEGER                     --Origem dos Dados
                                          ,pr_nrdconta    IN crapass.nrdconta%TYPE       --Numero da Conta do Associado
                                          ,pr_idseqttl    IN INTEGER                     --Sequencial do Titular
                                          ,pr_nrctremp    IN crapepr.nrctremp%TYPE       --Contrato Emprestimo
                                          ,pr_dtiniper    IN DATE                        --Inicio periodo
                                          ,pr_dtfimper    IN DATE                        --Final periodo
                                          ,pr_flgerlog    IN BOOLEAN                     --Imprimir log
                                          ,pr_extrato_epr OUT extr0002.typ_tab_extrato_epr        --Tipo de tabela com extrato emprestimo
                                          ,pr_des_reto    OUT VARCHAR2                   --Retorno OK ou NOK
                                          ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS  --Tabela de Erros
  BEGIN
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_obtem_extrato_emprest             Antigo: procedures/b1wgen0002.p/obtem-extrato-emprestimo
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2014                           Ultima atualizacao: 06/05/2020
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo   : Procedure para obter extrato do emprestimo
  --
  -- Alterações : 14/07/2014 - Conversão Progress -> Oracle (Alisson - AMcom)
  --              
  --              09/02/2015 - Ajuste no calculo do prejuizo para o emprestimo PP.
  --                           (James/Oscar)
  -- 
  --              08/10/2015 - Tratar os históricos de estorno do produto PP. (Oscar)                   
  --              14/10/2015 - Incluir o tratamento de pagamento de avalista 
  --                           que foi esquecido na migração para o Oracle. (Oscar)
  --
  --              15/08/2017 - Inclusao do campo qtdiacal e historicos do Pos-Fixado. (Jaison/James - PRJ298) 
  --
  --              03/04/2018 - M324 ajuste na configuração de extrato para emprestimo (Rafael Monteiro - Mouts)
  --
  --              31/07/2018 - P410 - Inclusao de Histórico para não compor Saldo no IOF do Prejuizo (Marcos-Envolti)
  --
  --              25/09/2018 - Incluir novos historicos de estorno de financiamento 2784,2785,2786,2787.
  --                           PRJ450 - Regulatorio(Odirlei - AMcom)     
  --
  --              05/03/2020 - Ajuste no extrato para emprestimo do consignado com pgto de avalista,
  --                           somando Historico de IOF com Atrado. Squad Produto (Fernanda Kelli - AMcom)   
  --
  --              06/05/2020 - Ajuste no extrato para emprestimo do consignado. Somar Juros e Multa ao valor do
  --                           lançto no pagto da parcela, mesmo qdo o pgto for realizados após o estorno do mesmo.
  --                           Squad Produto - RITM0064513 (Fernanda Kelli - AMcom)
  --   
  --              09/06/2020 - INC0043234 - Ajuste no extrato para emprestimo com pgto PP de avalista,
  --                           somando Historico de IOF com Atrasado. Squad Emprestimos (Elton - AMcom)   
  --
  --
  --              16/09/2020 - Adicionados tratamentos para extrato prejuizo pp
  --                           PRJ0019378 (Darlei Zillmer / Supero)
  ---------------------------------------------------------------------------------------------------------------
  DECLARE
      --Tabela de Memoria primeira parcela
      TYPE typ_tab_flgpripa IS TABLE OF BOOLEAN INDEX BY PLS_INTEGER;
      vr_tab_flgpripa typ_tab_flgpripa;
      
      -- Buscar cadastro auxiliar de emprestimo
      CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%type,
                         pr_nrdconta IN crapepr.nrdconta%type,
                         pr_nrctremp IN crapepr.nrctremp%type) is
        SELECT crapepr.tpemprst
              ,crapepr.inprejuz
              ,crapepr.dtprejuz
              ,crapepr.tpdescto
              ,crapepr.rowid
        FROM crapepr crapepr
        WHERE crapepr.cdcooper = pr_cdcooper
        AND   crapepr.nrdconta = pr_nrdconta
        AND   crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%rowtype;
      
      -- Buscar informações de pagamentos do empréstimos
      CURSOR cr_craplem (pr_cdcooper IN craplem.cdcooper%type
                        ,pr_nrdconta IN craplem.nrdconta%type
                        ,pr_nrctremp IN craplem.nrctremp%type
                        ,pr_dtiniper IN DATE
                        ,pr_dtfimper IN DATE) IS
        SELECT /*+ INDEX (craplem CRAPLEM##CRAPLEM6) */
               to_char(craplem.dtmvtolt,'dd') ddlanmto
              ,craplem.dtmvtolt
              ,craplem.cdhistor
              ,craplem.vlpreemp
              ,craplem.vllanmto
              ,craplem.nrparepr
              ,craplem.cdcooper
              ,craplem.nrdconta
              ,craplem.nrctremp
              ,craplem.nrseqdig
              ,craplem.cdagenci
              ,craplem.cdbccxlt
              ,craplem.nrdolote
              ,craplem.nrdocmto
              ,craplem.txjurepr
              ,craplem.nrseqava
              ,craplem.qtdiacal
              ,craplem.vltaxprd
              ,craplem.dthrtran
            --  ,DECODE(craplem.cdorigem,1,'Ayllos',2,'Caixa',3,'Internet',4,'Cash',5,'Ayllos WEB',6,'URA',7,'Batch',8,'Mensageria',20,'Folha (Consignado)',' ') cdorigem
              ,DECODE(craplem.cdorigem,1,'Debito CC',2,'Caixa',3,'Internet',4,'Cash',5,'Debito CC',6,'URA',7,'Debito CC',8,'Mensageria',20,'Folha',' ') cdorigem
              ,count(*) over (partition by  craplem.cdcooper,craplem.nrdconta,craplem.dtmvtolt) nrtotdat
              ,row_number() over (partition by craplem.dtmvtolt ORDER BY craplem.cdcooper
                                                                        ,craplem.nrdconta
                                                                        ,craplem.dtmvtolt
                                                                        ,craplem.cdhistor
                                                                        ,craplem.nrdocmto
                                                                        ,craplem.progress_recid) nrseqdat
          FROM craplem craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND ((craplem.dtmvtolt >= pr_dtiniper AND pr_dtiniper IS NOT NULL) OR pr_dtiniper IS NULL)          
           AND ((craplem.dtmvtolt <= pr_dtfimper AND pr_dtfimper IS NOT NULL) OR pr_dtfimper IS NULL)
         ORDER BY craplem.dtmvtolt, craplem.cdhistor;
      rw_craplem cr_craplem%ROWTYPE;
      -- Buscar informações de pagamentos do empréstimos
      CURSOR cr_craplem_his (pr_cdcooper IN crapepr.cdcooper%type
                            ,pr_nrdconta IN crapepr.nrdconta%type
                            ,pr_nrctremp IN crapepr.nrctremp%type
                            ,pr_nrparepr IN craplem.nrparepr%type
                            ,pr_dtmvtolt IN craplem.dtmvtolt%type
                            ,pr_cdhistor IN craplem.cdhistor%TYPE) IS
        SELECT craplem.vllanmto
        FROM craplem craplem
        WHERE craplem.cdcooper = pr_cdcooper
        AND   craplem.nrdconta = pr_nrdconta
        AND   craplem.nrctremp = pr_nrctremp
        AND   craplem.nrparepr = pr_nrparepr
        AND   craplem.dtmvtolt = pr_dtmvtolt  
        AND   craplem.cdhistor = pr_cdhistor
        ORDER BY cdcooper,dtmvtolt,cdagenci,cdbccxlt,nrdolote,nrdconta,nrdocmto;
      rw_craplem_his cr_craplem_his%ROWTYPE; 
      
      -- cursor para historicos de prejuizo pp
      CURSOR cr_lemprej(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE
                       ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
        SELECT 1
          FROM craplem l
         WHERE l.cdcooper = pr_cdcooper
           AND l.nrdconta = pr_nrdconta
           AND l.nrctremp = pr_nrctremp
           AND l.dtmvtolt = pr_dtmvtolt
           AND l.cdhistor IN (3052, 3051, 3054, 3053);
      rw_lemprej cr_lemprej%ROWTYPE;
      
      CURSOR cr_craplcr(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
        SELECT l.dsoperac
          FROM craplcr l, crapepr e
         WHERE e.cdcooper = l.cdcooper
           AND e.cdlcremp = l.cdlcremp
           AND e.cdcooper = pr_cdcooper
           AND e.nrdconta = pr_nrdconta
           AND e.nrctremp = pr_nrctremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      
      --Selecionar Historicos
      CURSOR cr_craphis (pr_cdcooper IN craphis.cdcooper%TYPE
                       ,pr_cdhistor IN craphis.cdhistor%TYPE) IS        
        SELECT craphis.indebfol
              ,craphis.inhistor
              ,craphis.dshistor
              ,craphis.indebcre
              ,craphis.cdhistor
              ,craphis.dsextrat
        FROM craphis craphis
        WHERE craphis.cdcooper = pr_cdcooper       
        AND   craphis.cdhistor = pr_cdhistor;                      
      rw_craphis cr_craphis%ROWTYPE;  
      --Variaveis Locais
      vr_cdhistor INTEGER;
      vr_vllantmo NUMBER;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      --Variaveis de indices
      vr_index PLS_INTEGER;
      --Variaveis de Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecoes
      vr_exc_erro EXCEPTION;

      vr_index_novo PLS_INTEGER;
      vr_cdhistorlem INTEGER;
    BEGIN
      --Limpar tabelas memoria
      pr_tab_erro.DELETE;
      pr_extrato_epr.DELETE;
      
      --Inicializar transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Obter extrato do emprestimo.';

      --Consultar Emprestimo
      OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      --Se Encontrou
      IF cr_crapepr%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapepr;  
        --mensagem Critica
        vr_cdcritic:= 356;
        vr_dscritic:= NULL;
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Sair Programa
        RETURN;                     
      END IF;
      --Fechar Cursor
      CLOSE cr_crapepr; 
      
      --Percorrer Lancamentos Emprestimo
      FOR rw_craplem IN cr_craplem (pr_cdcooper  => pr_cdcooper
                                   ,pr_nrdconta  => pr_nrdconta
                                   ,pr_nrctremp  => pr_nrctremp
                                   ,pr_dtiniper  => pr_dtiniper 
                                   ,pr_dtfimper  => pr_dtfimper) LOOP
        --Se for a primeira ocorrencia da data
        IF rw_craplem.nrseqdat = 1 OR 
           (rw_crapepr.tpemprst = 1 AND rw_crapepr.tpdescto = 2 )THEN --RITM0064513 Squad Produtos 
          --Marcar tabela primeira parcela como false
          FOR idx IN 1..999 LOOP
            vr_tab_flgpripa(idx):= FALSE;
          END LOOP;  
        END IF;                             
        /* Desprezando historicos de concessao de credito com juros a apropriar e lancamendo para desconto */               
        IF rw_craplem.cdhistor IN (1032,1033,1034,1035,1048,1049,2566,2567,2388,2473,2389,2390,2475,2392,2474,2393,2394,2476) THEN
          --Proximo registro
          CONTINUE;
        END IF;
        /* Desprezando historicos de concessao de credito com juros a apropriar e lancamendo para desconto */
        -- rmm desconsiderar pagamentos prejuizo (2390,2392,2388,2475)        
        IF rw_crapepr.tpemprst = 1 AND rw_craplem.cdhistor IN --(2390,2392,2388,2475,2391,2395) 
          (2386,2388,2473,2389,2390,2475,2387,2392,2474,2393,2394,2476,1731) THEN
          CONTINUE;          
        END IF;
        
        IF NOT extr0002.fn_extrato_prejuizo_ativo(pr_cdcooper => pr_cdcooper
                                        ,pr_tpemprst => 1) THEN
          IF rw_crapepr.tpemprst = 1 AND rw_craplem.cdhistor IN (2701,2702,2391,2395,1731) THEN
            CONTINUE;          
          END IF;          
        END IF;
        
        
        IF NOT extr0002.fn_extrato_prejuizo_ativo(pr_cdcooper => pr_cdcooper
                                        ,pr_tpemprst => 1) THEN
        --
        /* Verifica se o contrato estah em prejuizo */
        IF rw_crapepr.tpemprst = 1 AND
           rw_crapepr.inprejuz = 1 AND 
           rw_craplem.dtmvtolt >= rw_crapepr.dtprejuz THEN
           
             -- Lote do novo emprestimo 
           IF rw_craplem.nrdolote <= 600000 OR rw_craplem.nrdolote >= 650000 THEN
             CONTINUE;
           END IF;

        END IF;
        END IF;
        
        --Criar Extrato
        vr_index:= pr_extrato_epr.count + 1;
        --
        pr_extrato_epr(vr_index).dthrtran := rw_craplem.dthrtran;
        --Se existe valor emprestimo 
        IF rw_craplem.vlpreemp > 0 THEN
          pr_extrato_epr(vr_index).qtpresta:= apli0001.fn_round(rw_craplem.vllanmto / rw_craplem.vlpreemp,4);
        ELSE
          pr_extrato_epr(vr_index).qtpresta:= 0;
        END IF;    
        /*Historicos que nao vao compor o saldo, mas vao aparecer no relatorio*/
        IF rw_craplem.cdhistor IN (1048,1049,1050,1051,1717,1720,1708,1711,2566,2567, /*2382,*/ 2411, 2415, 2423,2416,2390,2475,2394,2476,2735,
                                   --> Novos historicos de estorno de financiamento
                                   2784,2785,2786,2787,2882,2883,2887,2884,2886,2954,2955,2956,2953,2735
                                   --> Estorno IOF Comp. Consignado (P437)
                                   ,3013) THEN 
          --marcar para nao mostrar saldo
          pr_extrato_epr(vr_index).flgsaldo:= FALSE;                           
        END IF;
        /*Historicos que nao vao aparecer no relatorio, mas vao compor saldo */
        IF rw_craplem.cdhistor IN (2471,2472,2358,2359,2878,2883,2887,2882,2884,2885,2886,2888,2954,2955,2956,2953,2388,2390,2405,2411,2415 /* POS */) THEN
          --marcar com false para nao listar
          pr_extrato_epr(vr_index).flglista:= FALSE;  
        END IF;        
        -- INICIO - PRJ298.3
        -- Não exibir no extrato
        IF NOT extr0002.fn_extrato_prejuizo_ativo(pr_cdcooper => pr_cdcooper
                                        ,pr_tpemprst => 1) THEN
          /* Historicos que nao vao aparecer no relatorio, mas vao compor saldo */
          IF rw_craplem.cdhistor IN (1040,1041,1042,1043) THEN /* PP */
            -- marcar com false para nao listar / flgsaldo vem como true por default
            pr_extrato_epr(vr_index).flglista:= FALSE;  
          END IF;  
        IF rw_crapepr.tpemprst = 1 AND rw_craplem.cdhistor = 2409 THEN
          --
          pr_extrato_epr(vr_index).flglista := FALSE;
          --
        END IF;
        ELSE
          /* Estória 2 , nao exibir e não calcular para estes historicos */
          IF rw_craplem.cdhistor IN (2396,2397,2381,2382,2385,2400,3356,3357,3358,3359,1733,1735) THEN
            -- marcar com false para nao listar e nao calcular
            pr_extrato_epr(vr_index).flglista:= FALSE;  
            pr_extrato_epr(vr_index).flgsaldo:= FALSE;  
          END IF;  
             
        END IF;
        
        -- FIM - PRJ298.3
        /* Verifica se o contrato estah em prejuizo */
        IF rw_crapepr.tpemprst = 1 AND
           rw_crapepr.inprejuz = 1 AND 
           rw_craplem.dtmvtolt >= rw_crapepr.dtprejuz THEN
           
           /* Multa e Juros de Mora de Prejuizo */
           /* M324 - inclusao dos novos historicos de multas e juros */
           IF rw_craplem.cdhistor IN (1733,1734,1735,1736, 2382, 2411, 2415, 2423,2416,2390,2475,2394,2476,2735) THEN
             pr_extrato_epr(vr_index).flgsaldo := FALSE;
           END IF;  
           
        END IF;
             
        -- Se for POS e estiver Em Prejuizo
        IF rw_crapepr.tpemprst = 2 AND
           rw_crapepr.inprejuz = 1 THEN
          --
          IF rw_craplem.cdhistor IN(2471,2472,2358,2359,2878,2884,2885,2888,2405,2411,2415,2735) THEN
            --
            pr_extrato_epr(vr_index).flgsaldo:= FALSE;
            --
          END IF;
          --
        END IF;
              
        --Valor Lancamento
        vr_vllantmo:= rw_craplem.vllanmto;
        /* Se lancamento de pagamento*/
        IF rw_craplem.cdhistor IN (1044,1039,1057,1045 /* PP */) THEN 
          --Se nao for primeira parcela
          IF vr_tab_flgpripa.EXISTS(rw_craplem.nrparepr) AND
             vr_tab_flgpripa(rw_craplem.nrparepr) = FALSE THEN

            /* Historico de juros de mora */
            CASE WHEN rw_craplem.cdhistor = 1044 THEN
                 vr_cdhistor := 1077; /* Devedor */ 
                 WHEN rw_craplem.cdhistor = 1045 THEN
                 vr_cdhistor := 1619; /* Aval */
                 WHEN rw_craplem.cdhistor = 1057 THEN
                 vr_cdhistor := 1620; /* Aval */                 
            ELSE     
                 vr_cdhistor := 1078; /* Devedor */
            END CASE;
               
            /* Achar juros de inadimplencia desta parcela */
            OPEN cr_craplem_his (pr_cdcooper => rw_craplem.cdcooper
                                ,pr_nrdconta => rw_craplem.nrdconta
                                ,pr_nrctremp => rw_craplem.nrctremp
                                ,pr_nrparepr => rw_craplem.nrparepr
                                ,pr_dtmvtolt => rw_craplem.dtmvtolt
                                ,pr_cdhistor => vr_cdhistor);
            FETCH cr_craplem_his INTO rw_craplem_his;
            --Se encontrou
            IF cr_craplem_his%FOUND THEN
              --Acumular valor lancamento
              vr_vllantmo:= nvl(vr_vllantmo,0) + nvl(rw_craplem_his.vllanmto,0);
            END IF;  
            --Fechar Cursor
            CLOSE cr_craplem_his;                

            /* Historico de juros de multa */
            CASE WHEN rw_craplem.cdhistor = 1044 THEN
                 vr_cdhistor := 1047; /* Devedor */ 
                 WHEN rw_craplem.cdhistor = 1045 THEN
                 vr_cdhistor := 1540; /* Aval */
                 WHEN rw_craplem.cdhistor = 1057 THEN
                 vr_cdhistor := 1618; /* Aval */                 
            ELSE     
                 vr_cdhistor := 1076; /* Devedor */
            END CASE;

            /* Achar juros de inadimplencia desta parcela */
            OPEN cr_craplem_his (pr_cdcooper => rw_craplem.cdcooper
                                ,pr_nrdconta => rw_craplem.nrdconta
                                ,pr_nrctremp => rw_craplem.nrctremp
                                ,pr_nrparepr => rw_craplem.nrparepr
                                ,pr_dtmvtolt => rw_craplem.dtmvtolt
                                ,pr_cdhistor => vr_cdhistor);
            FETCH cr_craplem_his INTO rw_craplem_his;
            --Se encontrou
            IF cr_craplem_his%FOUND THEN
              --Acumular valor lancamento
              vr_vllantmo:= nvl(vr_vllantmo,0) + nvl(rw_craplem_his.vllanmto,0);
            END IF;  
            --Fechar Cursor
            CLOSE cr_craplem_his; 
            
            -- Historico de IOF 
            CASE WHEN rw_craplem.cdhistor IN(1044,1045) THEN
               vr_cdhistor := 2311; -- Devedor 
            ELSE     
               vr_cdhistor := 2312; -- Devedor 
            END CASE;  

            /* Achar juros de inadimplencia desta parcela */
            OPEN cr_craplem_his (pr_cdcooper => rw_craplem.cdcooper
                                ,pr_nrdconta => rw_craplem.nrdconta
                                ,pr_nrctremp => rw_craplem.nrctremp
                                ,pr_nrparepr => rw_craplem.nrparepr
                                ,pr_dtmvtolt => rw_craplem.dtmvtolt
                                ,pr_cdhistor => vr_cdhistor);
            FETCH cr_craplem_his INTO rw_craplem_his;
            --Se encontrou
            IF cr_craplem_his%FOUND THEN
              --Acumular valor lancamento
              vr_vllantmo:= nvl(vr_vllantmo,0) + nvl(rw_craplem_his.vllanmto,0);
            END IF;  
            --Fechar Cursor
            CLOSE cr_craplem_his;
            --Atualizar tabela primeira parcela
            vr_tab_flgpripa(rw_craplem.nrparepr):= TRUE;  
          END IF;  
        END IF; --rw_craplem.cdhistor IN (1044,1039)
        --Selecionar Historicos
        OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                        ,pr_cdhistor => rw_craplem.cdhistor);
        FETCH cr_craphis INTO rw_craphis;
        --Se nao encontrou
        IF cr_craphis%NOTFOUND THEN
          pr_extrato_epr(vr_index).dshistor:= rw_craplem.cdhistor;
          pr_extrato_epr(vr_index).dshistoi:= rw_craplem.cdhistor;
          pr_extrato_epr(vr_index).indebcre:= '*';
        ELSE 
          pr_extrato_epr(vr_index).dshistor:= to_char(rw_craphis.cdhistor,'fm0000')||' - '|| rw_craphis.dshistor;
          pr_extrato_epr(vr_index).dshistoi:= rw_craphis.dshistor;
          pr_extrato_epr(vr_index).indebcre:= rw_craphis.indebcre;
          pr_extrato_epr(vr_index).dsextrat:= rw_craphis.dsextrat;
        END IF;
        --Fechar Cursor
        CLOSE cr_craphis; 
        
        /* Pagamento de avalista */
        IF rw_craphis.cdhistor IN (1057,1045,1620,1619,1618,1540 /* PP */
                                  ,2335,2336,2377,2375,2369,2367 /* POS */) 
          AND rw_craplem.nrseqava > 0 THEN
           
           pr_extrato_epr(vr_index).dshistor := pr_extrato_epr(vr_index).dshistor || ' ' ||
                                                TO_CHAR(rw_craplem.nrseqava);
           pr_extrato_epr(vr_index).dsextrat := rw_craphis.dsextrat || ' ' || 
                                                TO_CHAR(rw_craplem.nrseqava);
        END IF;
        
        --Historico de Debito
        IF rw_craphis.cdhistor IN (1077,1078,1619,1620) THEN
           pr_extrato_epr(vr_index).indebcre:= 'D'; 
        END IF;
        
        --Popular informacoes no Extrato
        pr_extrato_epr(vr_index).dtmvtolt:= rw_craplem.dtmvtolt;
        pr_extrato_epr(vr_index).nranomes:= to_number(to_char(rw_craplem.dtmvtolt,'YYYYMM'));
        pr_extrato_epr(vr_index).cdhistor:= rw_craplem.cdhistor;
        pr_extrato_epr(vr_index).nrseqdig:= rw_craplem.nrseqdig;
        pr_extrato_epr(vr_index).cdagenci:= rw_craplem.cdagenci;
        pr_extrato_epr(vr_index).cdbccxlt:= rw_craplem.cdbccxlt;
        pr_extrato_epr(vr_index).nrdolote:= rw_craplem.nrdolote;
        pr_extrato_epr(vr_index).nrdocmto:= rw_craplem.nrdocmto;
        pr_extrato_epr(vr_index).vllanmto:= vr_vllantmo;
        pr_extrato_epr(vr_index).txjurepr:= rw_craplem.txjurepr;
        pr_extrato_epr(vr_index).tpemprst:= rw_crapepr.tpemprst;
        pr_extrato_epr(vr_index).qtdiacal:= rw_craplem.qtdiacal;
        pr_extrato_epr(vr_index).vltaxprd:= rw_craplem.vltaxprd;        
        
        IF rw_craplem.cdhistor IN(1039,1044,1045,1057 /* PP */
                             ,3026,3027 /*Consignado*/
                                 ,2331,2330,2336,2335 /* POS */) THEN
          pr_extrato_epr(vr_index).cdorigem:= rw_craplem.cdorigem;
        ELSE
          pr_extrato_epr(vr_index).cdorigem:= ' ';
        END IF;
        
        --Numero parcelas diferente zero
        IF NVL(rw_craplem.nrparepr,0) <> 0 THEN
          pr_extrato_epr(vr_index).nrparepr:= rw_craplem.nrparepr;
        ELSIF rw_craplem.cdhistor IN (1040,1041,1042,1043 /* PP */
                                     ,2471,2472,2358,2359 /* POS */) THEN
          /* Se ajuste, parcela = 99 para aparecer por ultimo no extrato*/
          pr_extrato_epr(vr_index).nrparepr:= NULL;
        END IF;  
        
        IF extr0002.fn_extrato_prejuizo_ativo(pr_cdcooper => pr_cdcooper
                                    ,pr_tpemprst => 1) = TRUE THEN 
          --> Necesario verificar antes de criar se ja existe os novos historicos para esse contrato
          -- Ver se nao tem o lancamento do historico novo nesse mesmo dia, tratamento para o legado
          -- para nao mexer nos lancamentos com baca ou data de corte, tratamos somente na impressao
          IF rw_craplem.cdhistor IN (2411, 2415,1733,1735) THEN
            OPEN cr_lemprej(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp
                           ,pr_dtmvtolt => rw_craplem.dtmvtolt);
            FETCH cr_lemprej INTO rw_lemprej;
            IF cr_lemprej%NOTFOUND THEN 
              vr_index_novo := pr_extrato_epr.count + 1;
              pr_extrato_epr(vr_index_novo) := pr_extrato_epr(vr_index);
              pr_extrato_epr(vr_index_novo).flglista:= TRUE;  
              pr_extrato_epr(vr_index_novo).flgsaldo:= TRUE;
              pr_extrato_epr(vr_index_novo).indebcre:= 'D';
              
              IF rw_craplem.cdhistor IN (2411) THEN   
                OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctremp);
                FETCH cr_craplcr INTO rw_craplcr;
                CLOSE cr_craplcr;
                IF rw_craplcr.dsoperac = 'FINANCIAMENTO' THEN 
                  vr_cdhistorlem := 3053; /* 3053 - MULTA FINANCIAMENTO PRE-FIXADO */  
                ELSE --'EMPRESTIMO'
                  vr_cdhistorlem := 3051; /* 3051 - MULTA EMPRESTIMO PRE-FIXADO */  
                END IF;
              ELSIF rw_craplem.cdhistor IN (2415) THEN 
                OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctremp);
                FETCH cr_craplcr INTO rw_craplcr;
                CLOSE cr_craplcr;
                IF rw_craplcr.dsoperac = 'FINANCIAMENTO' THEN 
                  vr_cdhistorlem := 3054; /* 3054 - JURO MORA FINANCIAMENTO PRE-FIXADO */  
                ELSE --'EMPRESTIMO'
                  vr_cdhistorlem := 3052; /* 3052 - JURO MORA EMPRESTIMO PRE-FIXADO */
                END IF; 
              END IF;
              OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                             ,pr_cdhistor => vr_cdhistorlem);
              FETCH cr_craphis INTO rw_craphis;
              pr_extrato_epr(vr_index_novo).dshistor:= to_char(rw_craphis.cdhistor,'fm0000')||' - '|| rw_craphis.dshistor;
              pr_extrato_epr(vr_index_novo).dshistoi:= rw_craphis.dshistor;
              pr_extrato_epr(vr_index_novo).dsextrat:= rw_craphis.dsextrat;
              CLOSE cr_craphis;
            END IF;
            CLOSE cr_lemprej;
          END IF;
        END IF;
      END LOOP;
        
      -- Se foi solicitado geração de LOG
      IF pr_flgerlog THEN
        -- Chamar geração de LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;    
      --Retorno OK
      pr_des_reto:= 'OK';  
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado geração de LOG
        IF pr_flgerlog THEN
          -- Chamar geração de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;  
      WHEN OTHERS THEN
        
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na pc_obtem_extrato_emprestimo --> '|| sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado geração de LOG
        IF pr_flgerlog THEN
          -- Chamar geração de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;    
      END;
    END pc_obtem_extrato_emprest; 
BEGIN
	dbms_output.enable(NULL);
  
    --Buscar Data do Sistema para a cooperativa 
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    FOR rw_principal IN cr_principal LOOP
    --Limpar tabela Emprestimo
      vr_tab_extrato_epr.DELETE; 
      pr_tab_extrato_epr_aux.DELETE;
      vr_vlsaldo1 := 0;
      --Obter Extrato do Emprestimo
      pc_obtem_extrato_emprest (pr_cdcooper    => rw_principal.cdcooper            --Codigo Cooperativa
                               ,pr_cdagenci    => 0                              --Codigo Agencia
                               ,pr_nrdcaixa    => 0                              --Numero do Caixa
                               ,pr_cdoperad    => 1                              --Codigo Operador
                               ,pr_nmdatela    => 'ATENDA'                       --Nome da Tela
                               ,pr_idorigem    => 5                              --Origem dos Dados
                               ,pr_nrdconta    => rw_principal.nrdconta          --Numero da Conta do Associado
                               ,pr_idseqttl    => 1                              --Sequencial do Titular
                               ,pr_nrctremp    => rw_principal.nrctremp          --Numero Contrato Emprestimo           
                               ,pr_dtiniper    => NULL                           --Inicio periodo Extrato
                               ,pr_dtfimper    => to_date('05/01/2021')          --Final periodo Extrato
                               ,pr_flgerlog    => FALSE                          --Imprimir log
                               ,pr_extrato_epr => vr_tab_extrato_epr             --Tipo de tabela com extrato emprestimo
                               ,pr_des_reto    => vr_des_reto                    --Retorno OK ou NOK
                               ,pr_tab_erro    => vr_tab_erro);                  --Tabela de Erros
      
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN 
        RETURN;
      END IF; 
      
      --Percorrer todo o extrato emprestimo para carregar tabela auxiliar
      vr_index_novo:= vr_tab_extrato_epr.FIRST;
      WHILE vr_index_novo IS NOT NULL LOOP
        BEGIN
          --Primeira Ocorrencia
          IF vr_flgloop = FALSE THEN
            /* Saldo Inicial */
            vr_vlsaldo1:= vr_tab_extrato_epr(vr_index_novo).vllanmto; 
            vr_flgloop := TRUE;
            --Proximo Registro
            RAISE vr_exc_proximo;            
          END IF; 
          --Se for Credito
          IF vr_tab_extrato_epr(vr_index_novo).indebcre = 'C' THEN
            --Se possuir Saldo
            IF vr_tab_extrato_epr(vr_index_novo).flgsaldo THEN
              vr_vlsaldo1:= nvl(vr_vlsaldo1,0) - vr_tab_extrato_epr(vr_index_novo).vllanmto;
            END IF;    
          ELSIF vr_tab_extrato_epr(vr_index_novo).indebcre = 'D' THEN 
            --Valor Debito
            --Se possuir Saldo
            IF vr_tab_extrato_epr(vr_index_novo).flgsaldo THEN
              vr_vlsaldo1:= nvl(vr_vlsaldo1,0) + vr_tab_extrato_epr(vr_index_novo).vllanmto;
            END IF;    
          END IF;
          IF to_char(vr_tab_extrato_epr(vr_index_novo).dtmvtolt, 'DD/MM/YYYY') IN ('30/12/2020', '31/12/2020') THEN
            vr_vldezemb := vr_vlsaldo1;
          END IF;
        EXCEPTION
          WHEN vr_exc_proximo THEN
            NULL;
        END;       
        --Proximo Registro Extrato
        vr_index_novo:= vr_tab_extrato_epr.NEXT(vr_index_novo);
      END LOOP; 
      
      IF rw_principal.inprejuz = 1 AND extr0002.fn_extrato_prejuizo_ativo(pr_cdcooper => rw_principal.cdcooper
                                                                       ,pr_tpemprst => 1) = TRUE THEN
              
        rw_craplem5 := NULL;
        vr_vlsdprej := 0;
        OPEN cr_craplem5(pr_cdcooper => rw_principal.cdcooper
                        ,pr_nrdconta => rw_principal.nrdconta
                        ,pr_nrctremp => rw_principal.nrctremp
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        FETCH cr_craplem5 INTO rw_craplem5;
        CLOSE cr_craplem5;

        vr_vljurdia := 0;

        prej0001.pc_calcula_juros_diario(pr_cdcooper => rw_principal.cdcooper            -- IN
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- IN
                                        ,pr_dtmvtoan => rw_crapdat.dtmvtoan -- IN
                                        ,pr_nrdconta => rw_principal.nrdconta            -- IN
                                        ,pr_nrctremp => rw_principal.nrctremp    -- IN
                                        ,pr_vljurdia => vr_vljurdia            -- OUT
                                        ,pr_cdcritic => vr_cdcritic            -- OUT
                                        ,pr_dscritic => vr_dscritic            -- OUT
                                        );  
        --
        vr_vlsdprej := nvl(rw_principal.vlsdprej, 0) +
                      (nvl(rw_principal.vlttmupr, 0) - nvl(rw_principal.vlpgmupr, 0)) +
                      (nvl(rw_principal.vlttjmpr, 0) - nvl(rw_principal.vlpgjmpr, 0)) +
                      (nvl(rw_principal.vltiofpr, 0) - nvl(rw_principal.vlpiofpr, 0)); 
                            
        IF vr_vlsdprej > 0 THEN
          vr_vlsdprej := vr_vlsdprej + (nvl(vr_vljurdia,0) - nvl(rw_craplem5.vllanmto, 0));
        END IF;
        
      END IF;
     
      IF vr_vlsdprej < vr_vlsaldo1 THEN
        OPEN cr_crapdir(pr_cdcooper => rw_principal.cdcooper
                       ,pr_nrdconta => rw_principal.nrdconta);
        FETCH cr_crapdir INTO rw_crapdir;
        CLOSE cr_crapdir;
        -- Total atual da crapdir
        vr_vlsddvem := rw_crapdir.vlsddvem;
        -- Tirar o contrato antigo
        OPEN cr_devedor(pr_cdcooper => rw_principal.cdcooper
                       ,pr_nrdconta => rw_principal.nrdconta
                       ,pr_nrctremp => rw_principal.nrctremp);
        FETCH cr_devedor INTO rw_devedor;
        CLOSE cr_devedor;
        vr_vlsddvem := vr_vlsddvem - rw_devedor.vlsdeved;
        -- Atualizar devedor do contrato
        BEGIN 
          /*UPDATE crapepr
             SET vlsdprej = vr_vlsaldo1
           WHERE cdcooper = rw_principal.cdcooper
             AND nrdconta = rw_principal.nrdconta
             AND nrctremp = rw_principal.nrctremp;*/
			dbms_output.put_line('UPDATE crapepr SET vlsdprej = ' || to_char(vr_vlsaldo1) || ' WHERE cdcooper = ' || to_char(rw_principal.cdcooper) || ' AND nrdconta = ' || to_char(rw_principal.nrdconta) || ' AND nrctremp = ' || to_char(rw_principal.nrctremp) || ' AND vlsdprej > 0;');
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('Erro crapepr na Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp || ' - ' || vr_vlsdprej || '/' || vr_vlsaldo1 || ' - ' || SQLERRM);
        END;
        -- Somar o novo devedor na crapdir
        BEGIN 
        /*  UPDATE crapdir
             SET vlsddvem = vr_vlsddvem + vr_vldezemb
           WHERE cdcooper = rw_principal.cdcooper
             AND nrdconta = rw_principal.nrdconta
             AND dtmvtolt = '31/12/2020'; */
			dbms_output.put_line('UPDATE crapdir SET vlsddvem = ' || to_char(vr_vlsddvem + vr_vldezemb) || ' WHERE cdcooper = ' || to_char(rw_principal.cdcooper) || ' AND nrdconta = ' || to_char(rw_principal.nrdconta) || ' AND dtmvtolt = ''31/12/2020'';');		
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('Erro crapdir na Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp || ' - ' || SQLERRM);
        END;
        dbms_output.put_line('Atualizado na Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp || ' - ' || vr_vlsdprej || '/' || vr_vlsaldo1);
      END IF;
    END LOOP;
    COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20010, 'Erro: '||SQLERRM);
END;
