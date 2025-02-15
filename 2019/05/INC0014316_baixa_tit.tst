PL/SQL Developer Test script 3.0
595
declare 
 -- Local variables here 
 i           INTEGER; 
 vr_dserro   VARCHAR2(100); 
 vr_dscritic VARCHAR2(4000); 

 CURSOR cr_crapcob IS 
   SELECT cob.rowid 
       ,cob.incobran 
       ,cob.cdcooper 
       ,cob.nrdconta 
       ,cob.nrcnvcob 
       ,cob.nrdocmto 
       ,cob.dsdoccop 
       ,cob.nrnosnum 
    FROM crapcob cob 
   WHERE cob.cdcooper = 1
     AND cob.nrdconta = 3067297
     AND cob.nrcnvcob = 10120
     AND cob.nrnosnum IN (03067297000009363,
                          03067297000009364,
                          03067297000009365,
                          03067297000009366,
                          03067297000009367,
                          03067297000009368,
                          03067297000009369,
                          03067297000009370,
                          03067297000009371,
                          03067297000009444,
                          03067297000009445,
                          03067297000009446,
                          03067297000009447,
                          03067297000009448,
                          03067297000009449,
                          03067297000009450,
                          03067297000009451,
                          03067297000009452,
                          03067297000009120,
                          03067297000009121,
                          03067297000009122,
                          03067297000009123,
                          03067297000009124,
                          03067297000009125,
                          03067297000009126,
                          03067297000009127,
                          03067297000009128,
                          03067297000009147,
                          03067297000009148,
                          03067297000009149,
                          03067297000009150,
                          03067297000009151,
                          03067297000009152,
                          03067297000009153,
                          03067297000009154,
                          03067297000009155,
                          03067297000009849,
                          03067297000009850,
                          03067297000009851,
                          03067297000009852,
                          03067297000009853,
                          03067297000009854,
                          03067297000009855,
                          03067297000009856,
                          03067297000009857,
                          03067297000009111,
                          03067297000009112,
                          03067297000009113,
                          03067297000009114,
                          03067297000009115,
                          03067297000009116,
                          03067297000009117,
                          03067297000009118,
                          03067297000009119,
                          03067297000009732,
                          03067297000009733,
                          03067297000009734,
                          03067297000009735,
                          03067297000009736,
                          03067297000009737,
                          03067297000009738,
                          03067297000009739,
                          03067297000009740,
                          03067297000009165,
                          03067297000009166,
                          03067297000009167,
                          03067297000009168,
                          03067297000009169,
                          03067297000009170,
                          03067297000009171,
                          03067297000009172,
                          03067297000009173,
                          03067297000009480,
                          03067297000009481,
                          03067297000009482,
                          03067297000009483,
                          03067297000009484,
                          03067297000009485,
                          03067297000009486,
                          03067297000009487,
                          03067297000009488,
                          03067297000009489,
                          03067297000009490,
                          03067297000009491,
                          03067297000009492,
                          03067297000009493,
                          03067297000009494,
                          03067297000009495,
                          03067297000009496,
                          03067297000009497,
                          03067297000009228,
                          03067297000009229,
                          03067297000009230,
                          03067297000009231,
                          03067297000009232,
                          03067297000009233,
                          03067297000009234,
                          03067297000009235,
                          03067297000009236,
                          03067297000009435,
                          03067297000009436,
                          03067297000009437,
                          03067297000009438,
                          03067297000009439,
                          03067297000009440,
                          03067297000009441,
                          03067297000009442,
                          03067297000009443,
                          03067297000009291,
                          03067297000009292,
                          03067297000009293,
                          03067297000009294,
                          03067297000009295,
                          03067297000009296,
                          03067297000009297,
                          03067297000009298,
                          03067297000009299,
                          03067297000009462,
                          03067297000009463,
                          03067297000009464,
                          03067297000009465,
                          03067297000009466,
                          03067297000009467,
                          03067297000009468,
                          03067297000009469,
                          03067297000009470,
                          03067297000009912,
                          03067297000009913,
                          03067297000009914,
                          03067297000009915,
                          03067297000009916,
                          03067297000009917,
                          03067297000009918,
                          03067297000009919,
                          03067297000009920,
                          03067297000007945,
                          03067297000008153,
                          03067297000008154,
                          03067297000008155,
                          03067297000008156,
                          03067297000008157,
                          03067297000008158,
                          03067297000008159,
                          03067297000008160,
                          03067297000008161,
                          03067297000008209,
                          03067297000008633,
                          03067297000008634,
                          03067297000008635,
                          03067297000008636,
                          03067297000008637,
                          03067297000008638,
                          03067297000008639,
                          03067297000008640,
                          03067297000008641,
                          03067297000008677,
                          03067297000008993,
                          03067297000008994,
                          03067297000008995,
                          03067297000008996,
                          03067297000008997,
                          03067297000008998,
                          03067297000008999,
                          03067297000009000,
                          03067297000009001,
                          03067297000009101,
                          03067297000009543,
                          03067297000009544,
                          03067297000009545,
                          03067297000009546,
                          03067297000009547,
                          03067297000009548,
                          03067297000009549,
                          03067297000009550,
                          03067297000009551,
                          03067297000009273,
                          03067297000009274,
                          03067297000009275,
                          03067297000009276,
                          03067297000009277,
                          03067297000009278,
                          03067297000009279,
                          03067297000009280,
                          03067297000009281,
                          03067297000009264,
                          03067297000009265,
                          03067297000009266,
                          03067297000009267,
                          03067297000009268,
                          03067297000009269,
                          03067297000009270,
                          03067297000009271,
                          03067297000009272,
                          03067297000009453,
                          03067297000009454,
                          03067297000009455,
                          03067297000009456,
                          03067297000009457,
                          03067297000009458,
                          03067297000009459,
                          03067297000009460,
                          03067297000009461,
                          03067297000009822,
                          03067297000009823,
                          03067297000009824,
                          03067297000009825,
                          03067297000009826,
                          03067297000009827,
                          03067297000009828,
                          03067297000009829,
                          03067297000009830,
                          03067297000009408,
                          03067297000009409,
                          03067297000009410,
                          03067297000009411,
                          03067297000009412,
                          03067297000009413,
                          03067297000009414,
                          03067297000009415,
                          03067297000009416,
                          03067297000009804,
                          03067297000009805,
                          03067297000009806,
                          03067297000009807,
                          03067297000009808,
                          03067297000009809,
                          03067297000009810,
                          03067297000009811,
                          03067297000009812,
                          03067297000009246,
                          03067297000009247,
                          03067297000009248,
                          03067297000009249,
                          03067297000009250,
                          03067297000009251,
                          03067297000009252,
                          03067297000009253,
                          03067297000009254,
                          03067297000009517,
                          03067297000009518,
                          03067297000009519,
                          03067297000009520,
                          03067297000009521,
                          03067297000009522,
                          03067297000009523,
                          03067297000009524,
                          03067297000009390,
                          03067297000009391,
                          03067297000009392,
                          03067297000009393,
                          03067297000009394,
                          03067297000009395,
                          03067297000009396,
                          03067297000009397,
                          03067297000009398,
                          03067297000009255,
                          03067297000009256,
                          03067297000009257,
                          03067297000009258,
                          03067297000009259,
                          03067297000009260,
                          03067297000009261,
                          03067297000009262,
                          03067297000009263,
                          03067297000009876,
                          03067297000009877,
                          03067297000009878,
                          03067297000009879,
                          03067297000009880,
                          03067297000009881,
                          03067297000009882,
                          03067297000009883,
                          03067297000009884,
                          03067297000010280,
                          03067297000010281,
                          03067297000010282,
                          03067297000010283,
                          03067297000010284,
                          03067297000010285,
                          03067297000010286,
                          03067297000010287,
                          03067297000010288,
                          03067297000010289,
                          03067297000009102,
                          03067297000009103,
                          03067297000009104,
                          03067297000009105,
                          03067297000009106,
                          03067297000009107,
                          03067297000009108,
                          03067297000009109,
                          03067297000009110,
                          03067297000009183,
                          03067297000009184,
                          03067297000009185,
                          03067297000009186,
                          03067297000009187,
                          03067297000009188,
                          03067297000009189,
                          03067297000009190,
                          03067297000009191,
                          03067297000009498,
                          03067297000009499,
                          03067297000009500,
                          03067297000009501,
                          03067297000009502,
                          03067297000009503,
                          03067297000009504,
                          03067297000009505,
                          03067297000009506,
                          03067297000009192,
                          03067297000009193,
                          03067297000009194,
                          03067297000009195,
                          03067297000009196,
                          03067297000009197,
                          03067297000009198,
                          03067297000009199,
                          03067297000009200,
                          03067297000009318,
                          03067297000009319,
                          03067297000009320,
                          03067297000009321,
                          03067297000009322,
                          03067297000009323,
                          03067297000009324,
                          03067297000009325,
                          03067297000009326,
                          03067297000009831,
                          03067297000009832,
                          03067297000009833,
                          03067297000009834,
                          03067297000009835,
                          03067297000009836,
                          03067297000009837,
                          03067297000009838,
                          03067297000009839,
                          03067297000009219,
                          03067297000009220,
                          03067297000009221,
                          03067297000009222,
                          03067297000009223,
                          03067297000009224,
                          03067297000009225,
                          03067297000009226,
                          03067297000009227,
                          03067297000009174,
                          03067297000009175,
                          03067297000009176,
                          03067297000009177,
                          03067297000009178,
                          03067297000009179,
                          03067297000009180,
                          03067297000009181,
                          03067297000009182,
                          03067297000009201,
                          03067297000009202,
                          03067297000009203,
                          03067297000009204,
                          03067297000009205,
                          03067297000009206,
                          03067297000009207,
                          03067297000009208,
                          03067297000009209,
                          03067297000009336,
                          03067297000009337,
                          03067297000009338,
                          03067297000009339,
                          03067297000009340,
                          03067297000009341,
                          03067297000009342,
                          03067297000009343,
                          03067297000009344,
                          03067297000009525,
                          03067297000009526,
                          03067297000009527,
                          03067297000009528,
                          03067297000009529,
                          03067297000009530,
                          03067297000009531,
                          03067297000009532,
                          03067297000009533,
                          03067297000009759,
                          03067297000009760,
                          03067297000009761,
                          03067297000009762,
                          03067297000009763,
                          03067297000009764,
                          03067297000009765,
                          03067297000009766,
                          03067297000009767,
                          03067297000009345,
                          03067297000009346,
                          03067297000009347,
                          03067297000009348,
                          03067297000009349,
                          03067297000009350,
                          03067297000009351,
                          03067297000009352,
                          03067297000009353,
                          03067297000009867,
                          03067297000009868,
                          03067297000009869,
                          03067297000009870,
                          03067297000009871,
                          03067297000009872,
                          03067297000009873,
                          03067297000009874,
                          03067297000009875,
                          03067297000009606,
                          03067297000009607,
                          03067297000009608,
                          03067297000009609,
                          03067297000009610,
                          03067297000009611,
                          03067297000009612,
                          03067297000009613,
                          03067297000009614,
                          03067297000009210,
                          03067297000009211,
                          03067297000009212,
                          03067297000009213,
                          03067297000009214,
                          03067297000009215,
                          03067297000009216,
                          03067297000009217,
                          03067297000009218,
                          03067297000009534,
                          03067297000009535,
                          03067297000009536,
                          03067297000009537,
                          03067297000009538,
                          03067297000009539,
                          03067297000009540,
                          03067297000009541,
                          03067297000009542,
                          03067297000009138,
                          03067297000009139,
                          03067297000009140,
                          03067297000009141,
                          03067297000009142,
                          03067297000009143,
                          03067297000009144,
                          03067297000009145,
                          03067297000009146,
                          03067297000009327,
                          03067297000009328,
                          03067297000009329,
                          03067297000009330,
                          03067297000009331,
                          03067297000009332,
                          03067297000009333,
                          03067297000009334,
                          03067297000009335,
                          03067297000009300,
                          03067297000009301,
                          03067297000009302,
                          03067297000009303,
                          03067297000009304,
                          03067297000009305,
                          03067297000009306,
                          03067297000009307,
                          03067297000009308,
                          03067297000009507,
                          03067297000009508,
                          03067297000009509,
                          03067297000009510,
                          03067297000009511,
                          03067297000009512,
                          03067297000009513,
                          03067297000009514,
                          03067297000009515,
                          03067297000009237,
                          03067297000009238,
                          03067297000009239,
                          03067297000009240,
                          03067297000009241,
                          03067297000009242,
                          03067297000009243,
                          03067297000009244,
                          03067297000009245,
                          03067297000009471,
                          03067297000009472,
                          03067297000009473,
                          03067297000009474,
                          03067297000009475,
                          03067297000009476,
                          03067297000009477,
                          03067297000009478,
                          03067297000009479,
                          03067297000010377,
                          03067297000010378,
                          03067297000010379,
                          03067297000010380,
                          03067297000010381,
                          03067297000010382,
                          03067297000010383,
                          03067297000010384,
                          03067297000009993,
                          03067297000009994,
                          03067297000009995,
                          03067297000009996,
                          03067297000009997,
                          03067297000009998,
                          03067297000009999,
                          03067297000010000,
                          03067297000010001,
                          03067297000010385,
                          03067297000010386,
                          03067297000010387,
                          03067297000010388,
                          03067297000010389,
                          03067297000010390,
                          03067297000010391,
                          03067297000010392)
   ORDER BY COB.CDCOOPER, COB.NRDCONTA, COB.DSDOCCOP, COB.NRDOCMTO; 

BEGIN 

 dbms_output.put_line('Situacao (0=A, 3=B, 5=L) - Cooperativa - Conta - Convenio - Boleto - Documento'); 

 -- Test statements here 
 FOR rw IN cr_crapcob LOOP 

   dbms_output.put_line(rw.incobran || ' - ' || 
   rw.cdcooper || ' - ' || 
   rw.nrdconta || ' - ' || 
   rw.nrcnvcob || ' - ' || 
   rw.nrdocmto || ' - ' || 
   rw.dsdoccop || ' - ' || 
   rw.nrnosnum ); 

   IF rw.incobran = 0 THEN 
     UPDATE crapcob 
        SET incobran = 3, 
            dtdbaixa = TRUNC(SYSDATE) 
      WHERE cdcooper = rw.cdcooper 
        AND nrdconta = rw.nrdconta 
        AND nrcnvcob = rw.nrcnvcob 
        AND nrdocmto = rw.nrdocmto; 

     paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                                 , pr_cdoperad => '1' 
                                 , pr_dtmvtolt => trunc(SYSDATE) 
                                 , pr_dsmensag => 'Titulo baixado manualmente' 
                                 , pr_des_erro => vr_dserro 
                                 , pr_dscritic => vr_dscritic ); 

   END IF; 

   COMMIT; 

 END LOOP; 
/*
 dbms_output.put_line(' '); 
 dbms_output.put_line('Apos atualizacao'); 

 FOR rw IN cr_crapcob LOOP 

   dbms_output.put_line(rw.incobran || ' - ' || 
   rw.cdcooper || ' - ' || 
   rw.nrdconta || ' - ' || 
   rw.nrcnvcob || ' - ' || 
   rw.nrdocmto || ' - ' || 
   rw.dsdoccop || ' - ' || 
   rw.nrnosnum); 

 END LOOP; 
*/
 COMMIT; 

EXCEPTION 
 WHEN OTHERS THEN 
   ROLLBACK; 
   RAISE; 
END;
0
0
