-- Ajustar o sequencial dos convênios que tiveram arquivos gerados manualmente.
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (6, 7, 8480162, '13/11/2020', 11, 2, '3232-EF00001100000000848016220201113.CNV', 1, 65)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8360048, '13/11/2020', 8, 2, '3239-EF00000800000000836004820201113.CNV', 1, 257.08)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8480162, '13/11/2020', 38, 2, '3239-EF00003800000000848016220201113.CNV', 37, 1940.66)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (2, 7, 8261426, '13/11/2020', 9, 2, '3265-EF00000900000000826142620201113.CNV', 2, 76.91)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (2, 7, 8480162, '13/11/2020', 15, 2, '3265-EF00001500000000848016220201113.CNV', 1, 65)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (5, 7, 8480162, '13/11/2020', 3, 2, '3318-EF00000300000000848016220201113.CNV', 1, 24.98)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (7, 7, 8480162, '13/11/2020', 16, 2, '4416-EF00001600000000848016220201113.CNV', 2, 101.27)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (16, 7, 8480162, '13/11/2020', 31, 2, '4420-EF00003100000000848016220201113.CNV', 8, 491.23)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (11, 7, 8480162, '13/11/2020', 15, 2, '4438-EF00001500000000848016220201113.CNV', 1, 131.84)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (10, 7, 8480162, '13/11/2020', 5, 2, '4443-EF00000500000000848016220201113.CNV', 1, 30.01)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (9, 7, 8480162, '13/11/2020', 21, 2, '4444-EF00002100000000848016220201113.CNV', 1, 26.99)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (12, 7, 8480162, '13/11/2020', 11, 2, '4449-EF00001100000000848016220201113.CNV', 1, 65)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (13, 7, 8480162, '13/11/2020', 22, 2, '4457-EF00002200000000848016220201113.CNV', 4, 454.95)
/
update gncontr g
   set g.nmarquiv = '4457-EF00002100000000848016220201113.CNV',
       g.cdsitret = 2
 where g.nmarquiv = '4457-EF00002100000000848016220201112.CNV'
/
update crapcon c
   set c.nrseqatu = c.nrseqatu + 1
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((162, 4, 6),
                                                (48, 3, 1),
                                                (162, 4, 1),
                                                (1426, 2, 2),
                                                (162, 4, 2),
                                                (162, 4, 5),
                                                (162, 4, 7),
                                                (162, 4, 16),
                                                (162, 4, 11),
                                                (162, 4, 10),
                                                (162, 4, 9),
                                                (162, 4, 12),
                                                (162, 4, 13))
/
update crapcon c
   set c.nrseqatu = 1,
       c.nrseqint = 2
 where c.cdempcon = 51
   and c.cdsegmto = 3
   and c.cdcooper = 1
/
commit
/
