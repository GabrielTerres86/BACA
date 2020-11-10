-- INC0066790 - Ajustar o sequencial dos convênios que tiveram arquivos gerados manualmente.
-- Primeira parte, referente a arquivos do dia 06/11
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos, qtdoctos, vldoctos)
values (6, 7, 8460464, '06/11/2020', 1, 2, '3232-EF00000100000000846046420201106.CNV', 1, 1081.68)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (6, 7, 8360048, '06/11/2020', 2, 2, '3232-EF00000200000000836004820201106.CNV', 1, 130.67)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (6, 7, 8480162, '06/11/2020', 10, 2, '3232-EF00001000000000848016220201106.CNV', 2, 115.57)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460004, '06/11/2020', 4, 2, '3239-EF00000400000000846000420201106.CNV', 4, 642.98)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460464, '06/11/2020', 16, 2, '3239-EF00001600000000846046420201106.CNV', 1, 159.91)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8480162, '06/11/2020', 32, 2, '3239-EF00003200000000848016220201106.CNV', 125, 7518.84)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (2, 7, 8480162, '06/11/2020', 12, 2, '3265-EF00001200000000848016220201106.CNV', 8, 522.48)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (5, 7, 8260016, '06/11/2020', 1, 2, '3318-EF00000100000000826001620201106.CNV', 1, 38.22)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (5, 7, 8460004, '06/11/2020', 1, 2, '3318-EF00000100000000846000420201106.CNV', 1, 167.52)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (7, 7, 8480162, '06/11/2020', 12, 2, '4416-EF00001200000000848016220201106.CNV', 3, 284.29)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (16, 7, 8480162, '06/11/2020', 25, 2, '4420-EF00002500000000848016220201106.CNV', 37, 2210.32)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (8, 7, 8460296, '06/11/2020', 5, 2, '4435-EF00000500000000846029620201106.CNV', 1, 100)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (11, 7, 8460004, '06/11/2020', 1, 2, '4438-EF00000100000000846000420201106.CNV', 1, 151.62)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (11, 7, 8480162, '06/11/2020', 12, 2, '4438-EF00001200000000848016220201106.CNV', 1, 56.12)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (10, 7, 8260843, '06/11/2020', 16, 2, '4443-EF00001600000000826084320201106.CNV', 1, 47.35)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (9, 7, 8480162, '06/11/2020', 17, 2, '4444-EF00001700000000848016220201106.CNV', 3, 151.56)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (13, 7, 8480162, '06/11/2020', 17, 2, '4457-EF00001700000000848016220201106.CNV', 2, 91.29)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (14, 7, 8480162, '06/11/2020', 10, 2, '4468-EF00001000000000848016220201106.CNV', 1, 74.73)
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
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (6, 7, 8490172, '10/11/2020', 1, 2, '3232-EF00000100000000849017220201110.CNV', 1, 30.91)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460296, '10/11/2020', 11, 2, '3239-EF00001100000000846029620201110.CNV', 151, 23550.5)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8261426, '10/11/2020', 18, 2, '3239-EF00001800000000826142620201110.CNV', 3, 114.18)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8480162, '10/11/2020', 33, 2, '3239-EF00003300000000848016220201110.CNV', 29, 2001.26)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (2, 7, 8490020, '10/11/2020', 1, 2, '3265-EF00000100000000849002020201110.CNV', 1, 261.47)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (2, 7, 8261426, '10/11/2020', 6, 2, '3265-EF00000600000000826142620201110.CNV', 1, 38.06)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (2, 7, 8460296, '10/11/2020', 7, 2, '3265-EF00000700000000846029620201110.CNV', 2, 273.98)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (7, 7, 8480162, '10/11/2020', 13, 2, '4416-EF00001300000000848016220201110.CNV', 1, 21.99)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (16, 7, 8480162, '10/11/2020', 26, 2, '4420-EF00002600000000848016220201110.CNV', 6, 442.59)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (8, 7, 8480162, '10/11/2020', 4, 2, '4435-EF00000400000000848016220201110.CNV', 1, 50)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (9, 7, 8460296, '10/11/2020', 5, 2, '4444-EF00000500000000846029620201110.CNV', 1, 75)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (13, 7, 8480162, '10/11/2020', 18, 2, '4457-EF00001800000000848016220201110.CNV', 1, 48.87)
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
                                                (162, 4, 13))
/
commit
/
