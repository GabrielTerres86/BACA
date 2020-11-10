-- INC0066790 - Ajustar o sequencial dos convênios que tiveram arquivos gerados manualmente.
-- Primeira parte, referente a arquivos do dia 06/11
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (6, 7, 8460464, '06/11/2020', 1, 2, '3232-EF00000100000000846046420201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (6, 7, 8360048, '06/11/2020', 2, 2, '3232-EF00000200000000836004820201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (6, 7, 8480162, '06/11/2020', 10, 2, '3232-EF00001000000000848016220201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (1, 7, 8460004, '06/11/2020', 4, 2, '3239-EF00000400000000846000420201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (1, 7, 8460464, '06/11/2020', 16, 2, '3239-EF00001600000000846046420201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (1, 7, 8480162, '06/11/2020', 32, 2, '3239-EF00003200000000848016220201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (2, 7, 8480162, '06/11/2020', 12, 2, '3265-EF00001200000000848016220201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (5, 7, 8260016, '06/11/2020', 1, 2, '3318-EF00000100000000826001620201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (5, 7, 8460004, '06/11/2020', 1, 2, '3318-EF00000100000000846000420201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (7, 7, 8480162, '06/11/2020', 12, 2, '4416-EF00001200000000848016220201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (16, 7, 8480162, '06/11/2020', 25, 2, '4420-EF00002500000000848016220201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (8, 7, 8460296, '06/11/2020', 5, 2, '4435-EF00000500000000846029620201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (11, 7, 8460004, '06/11/2020', 1, 2, '4438-EF00000100000000846000420201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (11, 7, 8480162, '06/11/2020', 12, 2, '4438-EF00001200000000848016220201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (10, 7, 8260843, '06/11/2020', 16, 2, '4443-EF00001600000000826084320201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (9, 7, 8480162, '06/11/2020', 17, 2, '4444-EF00001700000000848016220201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (13, 7, 8480162, '06/11/2020', 17, 2, '4457-EF00001700000000848016220201106.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (14, 7, 8480162, '06/11/2020', 10, 2, '4468-EF00001000000000848016220201106.CNV')
/
update crapcon c
   set c.nrseqatu = c.nrseqatu + 1
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((464, 4, 6),
                                                (48, 3, 6),
                                                (4, 4, 1),
                                                (464, 4, 1),
                                                (16, 2, 5),
                                                (4, 4, 5),
                                                (4, 4, 11),
                                                (162, 4, 9),
                                                (162, 4, 13))
/
-- Segunda parte, referente a arquivos do dia 10/11
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (6, 7, 8490172, '10/11/2020', 1, 2, '3232-EF00000100000000849017220201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (1, 7, 8460296, '10/11/2020', 10, 2, '3239-EF00001000000000846029620201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (1, 7, 8261426, '10/11/2020', 17, 2, '3239-EF00001700000000826142620201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (1, 7, 8480162, '10/11/2020', 33, 2, '3239-EF00003300000000848016220201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (2, 7, 8490020, '10/11/2020', 1, 2, '3265-EF00000100000000849002020201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (2, 7, 8261426, '10/11/2020', 6, 2, '3265-EF00000600000000826142620201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (2, 7, 8460296, '10/11/2020', 6, 2, '3265-EF00000600000000846029620201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (7, 7, 8480162, '10/11/2020', 13, 2, '4416-EF00001300000000848016220201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (16, 7, 8480162, '10/11/2020', 26, 2, '4420-EF00002600000000848016220201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (8, 7, 8480162, '10/11/2020', 4, 2, '4435-EF00000400000000848016220201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (9, 7, 8460296, '10/11/2020', 5, 2, '4444-EF00000500000000846029620201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (13, 7, 8480162, '10/11/2020', 18, 2, '4457-EF00001800000000848016220201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (6, 7, 8460464, '10/11/2020', 2, 2, '3232-EF00000200000000846046420201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (5, 7, 8460004, '10/11/2020', 2, 2, '3318-EF00000200000000846000420201110.CNV')
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv)
values (11, 7, 8460004, '10/11/2020', 2, 2, '4438-EF00000200000000846000420201110.CNV')
/
update crapcon c
   set c.nrseqatu = c.nrseqatu + 1
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((296, 4, 1),
                                                (1426, 2, 1),
                                                (162, 4, 1),
                                                (1426, 2, 2),
                                                (296, 4, 2),
                                                (162, 4, 7),
                                                (4, 4, 16),
                                                (162, 4, 8),
                                                (296, 4, 9),
                                                (162, 4, 13),
                                                (464, 4, 6),
                                                (4, 4, 5),
                                                (4, 4, 11))
/
commit
/
