-- INC0067996 - Ajustar o sequencial dos convênios que tiveram arquivos gerados manualmente.
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460296, '17/11/2020', 18, 2, '3239-EF00001800000000846029620201117.CNV', 8, 1066.92)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460464, '17/11/2020', 21, 2, '3239-EF00002100000000846046420201117.CNV', 1, 131.26)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460313, '17/11/2020', 39, 2, '3239-EF00003900000000846031320201117.CNV', 49, 7812.37)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8480162, '17/11/2020', 41, 2, '3239-EF00004100000000848016220201117.CNV', 1, 69.99)
/
update crapcon c
   set c.nrseqatu = c.nrseqatu + 1
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((296, 4, 1),
                                                (464, 4, 1),
                                                (313, 4, 1),
                                                (162, 4, 1))
/
commit
/
