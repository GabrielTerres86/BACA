-- INC0067996 - Ajustar o sequencial dos convênios que tiveram arquivos gerados manualmente.
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460296, '18/11/2020', 19, 2, '3239-EF00001900000000846029620201118.CNV', 7, 1066.92)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460464, '18/11/2020', 22, 2, '3239-EF00002200000000846046420201118.CNV', 1, 131.26)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8261426, '18/11/2020', 24, 2, '3239-EF00002400000000826142620201118.CNV', 1, 38.06)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460313, '18/11/2020', 40, 2, '3239-EF00004000000000846031320201118.CNV', 49, 7812.37)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8480162, '18/11/2020', 42, 2, '3239-EF00004200000000848016220201118.CNV', 1, 69.99)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (9, 7, 8460079, '18/11/2020', 2, 2, '4444-EF00000200000000846007920201118.CNV', 2, 145.93)
/
update crapcon c
   set c.nrseqatu = c.nrseqatu + 1
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((296, 4, 1),
                                                (464, 4, 1),
                                                (1426, 2, 1),
                                                (313, 4, 1),
                                                (162, 4, 1),
                                                (79, 4, 9))
/
commit
/
