declare 
  vr_cdcritic varchar2(200);
  vr_dscritic varchar2(2000);
  vr_dserro   varchar2(2000);
  vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
  
  CURSOR cr_crapcob is 
    SELECT ROWID, cdcooper, nrdconta, nrcnvcob, nrdocmto
      FROM cecred.crapcob
     WHERE (cdcooper, nrdconta, nrcnvcob, nrdocmto) IN
              ((1, 80426751, 10120, 1354)
              ,(1, 9454128, 101001, 672)
              ,(1, 9454128, 101001, 702)
              ,(1, 8595003, 101001, 647)
              ,(1, 9735941, 101002, 636)
              ,(1, 6710190, 101002, 10770)
              ,(1, 6710190, 101002, 10775)
              ,(1, 9911987, 101002, 1337)
              ,(1, 8607524, 101002, 4158)
              ,(1, 9273573, 101002, 439)
              ,(1, 10584030, 101002, 352)
              ,(1, 11064480, 101002, 17)
              ,(1, 7355041, 101002, 1568)
              ,(1, 11376112, 101002, 1190)
              ,(1, 7459254, 101002, 201)
              ,(1, 11593180, 101002, 666)
              ,(1, 11512385, 101002, 5648)
              ,(1, 11512385, 101002, 5664)
              ,(1, 11830026, 101002, 7597)
              ,(1, 9578340, 101002, 258)
              ,(1, 9040471, 101002, 161)
              ,(1, 9040471, 101002, 175)
              ,(1, 12413909, 101002, 10)
              ,(1, 12389803, 101002, 466)
              ,(1, 12591785, 101002, 1746)
              ,(1, 12801216, 101002, 303)
              ,(1, 12505153, 101002, 1706)
              ,(1, 13134205, 101002, 1226)
              ,(1, 11844191, 101002, 1925)
              ,(1, 12666637, 101002, 9)
              ,(1, 12783668, 101002, 1529)
              ,(1, 12008540, 101002, 168)
              ,(1, 13994131, 101002, 260)
              ,(1, 12181048, 101002, 1294)
              ,(1, 9653074, 101002, 8687)
              ,(1, 8571163, 101002, 9314)
              ,(1, 14545993, 101002, 280)
              ,(1, 11420251, 101002, 906)
              ,(1, 11420251, 101002, 963)
              ,(1, 14819899, 101002, 104)
              ,(1, 14126290, 101002, 27)
              ,(1, 13367919, 101002, 506)
              ,(1, 13367919, 101002, 517)
              ,(1, 14844192, 101002, 317)
              ,(1, 15373355, 101002, 20)
              ,(1, 15400220, 101002, 2438)
              ,(1, 15761070, 101002, 7)
              ,(1, 12327891, 101002, 770)
              ,(1, 12327891, 101002, 970)
              ,(1, 14412241, 101002, 16)
              ,(1, 12512230, 101002, 17)
              ,(1, 9939431, 101002, 8)
              ,(1, 11951281, 101002, 33)
              ,(1, 8830630, 101002, 10877)
              ,(1, 8761680, 101004, 6546)
              ,(1, 8015961, 101004, 3327366)
              ,(1, 9993096, 101004, 10203)
              ,(1, 7731469, 101004, 19220)
              ,(1, 9040471, 101004, 274654)
              ,(1, 11767499, 101004, 3321)
              ,(1, 7918330, 101004, 4443)
              ,(1, 12941409, 101004, 414225319)
              ,(1, 12941409, 101004, 414225326)
              ,(1, 12941409, 101004, 414225333)
              ,(1, 12941409, 101004, 414225340)
              ,(1, 12941409, 101004, 414225358)
              ,(1, 12941409, 101004, 414225365)
              ,(1, 12941409, 101004, 414225372)
              ,(1, 8257167, 101004, 8331)
              ,(1, 14302381, 101004, 547)
              ,(1, 14302381, 101004, 548)
              ,(1, 14777029, 101004, 177124)
              ,(1, 8190810, 101004, 11934)
              ,(1, 9444882, 101004, 8484)
              ,(1, 7153120, 101070, 2495)
              ,(2, 820229, 102002, 1380)
              ,(2, 831204, 102002, 285)
              ,(2, 15158560, 102002, 904)
              ,(2, 826235, 102002, 523)
              ,(2, 16602935, 102002, 107)
              ,(2, 16861558, 102004, 2)
              ,(2, 16861558, 102004, 3)
              ,(2, 16861558, 102004, 4)
              ,(2, 16861558, 102004, 6)
              ,(2, 16861558, 102004, 7)
              ,(2, 16861558, 102004, 8)
              ,(2, 16861558, 102004, 9)
              ,(2, 16861558, 102004, 15)
              ,(5, 126063, 104001, 978)
              ,(5, 126063, 104001, 987)
              ,(5, 16399056, 104001, 35)
              ,(5, 224693, 104002, 3342)
              ,(5, 224693, 104002, 3380)
              ,(5, 319872, 104002, 53)
              ,(5, 364355, 104002, 96)
              ,(5, 360961, 104003, 76)
              ,(5, 248487, 104003, 4500)
              ,(5, 248487, 104003, 4633)
              ,(5, 311936, 104004, 1043)
              ,(5, 108065, 104004, 1053)
              ,(6, 501832, 10510, 7406)
              ,(7, 190764, 106002, 979)
              ,(7, 190764, 106002, 1003)
              ,(7, 278190, 106002, 367)
              ,(7, 384968, 106002, 38)
              ,(7, 160466, 106002, 10759)
              ,(7, 352659, 106002, 17)
              ,(7, 446106, 106002, 48)
              ,(7, 16033663, 106002, 225)
              ,(7, 395471, 106004, 2677)
              ,(7, 395471, 106004, 2820)
              ,(7, 395471, 106004, 2823)
              ,(7, 395471, 106004, 2934)
              ,(7, 395471, 106004, 2936)
              ,(9, 447412, 108001, 146)
              ,(9, 134899, 108002, 737)
              ,(9, 300519, 108001, 2608)
              ,(9, 168289, 108002, 2460)
              ,(9, 271420, 108002, 602)
              ,(9, 271420, 108002, 608)
              ,(9, 271420, 108002, 614)
              ,(9, 271420, 108002, 620)
              ,(9, 239534, 108002, 3296)
              ,(9, 319384, 108002, 679)
              ,(9, 280119, 108002, 3368)
              ,(9, 308560, 108002, 2244)
              ,(9, 420514, 108002, 273)
              ,(9, 548243, 108002, 127)
              ,(9, 463795, 108002, 777)
              ,(9, 463795, 108002, 810)
              ,(9, 559490, 108002, 146)
              ,(9, 442470, 108002, 352)
              ,(9, 357960, 108002, 149)
              ,(9, 357960, 108002, 214)
              ,(9, 357960, 108002, 217)
              ,(9, 357960, 108002, 236)
              ,(9, 357960, 108002, 251)
              ,(9, 357960, 108002, 265)
              ,(9, 357960, 108002, 177)
              ,(9, 357960, 108002, 281)
              ,(9, 357960, 108002, 304)
              ,(9, 357960, 108002, 328)
              ,(9, 239720, 108002, 581)
              ,(9, 382248, 108002, 4922)
              ,(9, 382248, 108002, 4964)
              ,(9, 382248, 108002, 4977)
              ,(9, 382248, 108002, 5002)
              ,(9, 382248, 108002, 5036)
              ,(9, 382248, 108002, 5095)
              ,(9, 241202, 108004, 40003)
              ,(9, 241202, 108004, 40004)
              ,(9, 241202, 108004, 40005)
              ,(9, 208140, 108004, 15260)
              ,(9, 208140, 108004, 15330)
              ,(9, 208140, 108004, 15331)
              ,(9, 208140, 108004, 15441)
              ,(9, 121568, 108004, 17393)
              ,(9, 121568, 108004, 17394)
              ,(9, 287717, 108004, 10518801)
              ,(9, 287717, 108004, 10519701)
              ,(9, 293180, 108004, 12512)
              ,(9, 293180, 108004, 13140)
              ,(9, 293180, 108004, 13158)
              ,(9, 293180, 108004, 13276)
              ,(9, 293180, 108004, 13302)
              ,(9, 173398, 108004, 1490)
              ,(9, 465020, 108004, 1786)
              ,(9, 471607, 108004, 1507)
              ,(9, 471607, 108004, 1510)
              ,(9, 357960, 108004, 2079)
              ,(10, 145564, 110002, 426)
              ,(10, 220736, 110002, 33)
              ,(10, 205915, 110002, 1938)
              ,(10, 197645, 110002, 1478)
              ,(10, 100706, 110004, 200724)
              ,(10, 41920, 110004, 719462)
              ,(10, 114952, 110004, 194)
              ,(10, 238449, 110004, 49054)
              ,(10, 238449, 110004, 51457)
              ,(11, 15479447, 109001, 105)
              ,(11, 572306, 109001, 87)
              ,(11, 572306, 109001, 96)
              ,(11, 16168763, 109001, 546)
              ,(11, 550620, 109002, 245)
              ,(11, 935158, 109002, 919)
              ,(11, 935158, 109002, 899)
              ,(11, 458988, 109002, 8082)
              ,(11, 458988, 109002, 8104)
              ,(11, 458988, 109002, 8207)
              ,(11, 607746, 109004, 13569)
              ,(12, 208353, 111002, 185)
              ,(12, 208353, 111002, 188)
              ,(12, 208353, 111002, 190)
              ,(12, 207071, 111004, 2486)
              ,(13, 249580, 112001, 1900)
              ,(13, 381365, 112001, 493)
              ,(13, 381365, 112001, 500)
              ,(13, 726427, 112001, 51)
              ,(13, 726427, 112001, 56)
              ,(13, 15784215, 112001, 18)
              ,(13, 63894, 112001, 71)
              ,(13, 16094093, 112001, 8)
              ,(13, 44156, 112001, 7087)
              ,(13, 15813266, 112002, 106)
              ,(13, 453307, 112003, 3067)
              ,(13, 601969, 112003, 5503258)
              ,(13, 577952, 112004, 231301)
              ,(13, 201634, 112071, 6567)
              ,(13, 201634, 112071, 6682)
              ,(14, 176656, 113001, 181)
              ,(14, 50466, 113001, 1294)
              ,(14, 4766, 113001, 961)
              ,(14, 301779, 113001, 239)
              ,(14, 366951, 113001, 103)
              ,(14, 209414, 113002, 690)
              ,(14, 20834, 113002, 324)
              ,(14, 393843, 113002, 48)
              ,(14, 143812, 113003, 65138)
              ,(14, 143812, 113003, 63884)
              ,(14, 132438, 113004, 100002389)
              ,(16, 456438, 115001, 784)
              ,(16, 774251, 115002, 598)
              ,(16, 774251, 115002, 630)
              ,(16, 844152, 115002, 81)
              ,(16, 663042, 115002, 17)
              ,(16, 553425, 115002, 179)
              ,(16, 15941906, 115002, 133)
              ,(16, 1043625, 115002, 1338)
              ,(16, 357359, 115002, 3587)
              ,(16, 508110, 115002, 2715)
              ,(16, 2175738, 115004, 1603)
              ,(16, 817295, 115004, 3173)
              ,(16, 1050621, 115004, 340)
              ,(16, 6157777, 115004, 100004701)
              ,(16, 218731, 115004, 500008667)
              ,(16, 201936, 115002, 25413));
begin
  FOR rw IN cr_crapcob LOOP 
       
    cobr0007.pc_inst_protestar(pr_cdcooper => rw.cdcooper
                             , pr_nrdconta => rw.nrdconta
                             , pr_nrcnvcob => rw.nrcnvcob
                             , pr_nrdocmto => rw.nrdocmto
                             , pr_cdocorre => '09'
                             , pr_cdtpinsc => 0
                             , pr_dtmvtolt => trunc(SYSDATE)
                             , pr_cdoperad => '1'
                             , pr_nrremass => 0
                             , pr_tab_lat_consolidada => vr_tab_lat_consolidada
                             , pr_cdcritic => vr_cdcritic
                             , pr_dscritic => vr_dscritic);
                             
    IF vr_dscritic IS NULL OR nvl(vr_cdcritic,0) = 0 THEN

       paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                                   , pr_cdoperad => '1' 
                                   , pr_dtmvtolt => trunc(SYSDATE) 
                                   , pr_dsmensag => 'Solicita��o de protesto manualmente'
                                   , pr_des_erro => vr_dserro 
                                   , pr_dscritic => vr_dscritic ); 
    ELSE

       IF nvl(vr_cdcritic,0) > 0 THEN
          vr_dscritic := 'Erro ao solicitar protesto: ' || gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       
       paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                                   , pr_cdoperad => '1' 
                                   , pr_dtmvtolt => trunc(SYSDATE) 
                                   , pr_dsmensag => vr_dscritic
                                   , pr_des_erro => vr_dserro 
                                   , pr_dscritic => vr_dscritic );      
    END IF;

    COMMIT; 
  END LOOP; 

  EXCEPTION
    WHEN others THEN
      ROLLBACK;
      sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'INC0278703');
END;