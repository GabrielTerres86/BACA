-- INC0067279 - Ajustar o sequencial dos convênios que tiveram arquivos gerados manualmente.
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8360048, '12/11/2020', 7, 2, '3239-EF00000700000000836004820201112.CNV', 1, 106.9)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (2, 7, 8261426, '12/11/2020', 8, 2, '3265-EF00000800000000826142620201112.CNV', 1, 72.96)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (16, 7, 8480162, '12/11/2020', 29, 2, '4420-EF00002900000000848016220201112.CNV', 1, 62.99)
/
update crapcon c
   set c.nrseqatu = c.nrseqatu + 1
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((48, 3, 1),
                                                (1426, 2, 2),
                                                (162, 4, 16))
/
insert into tbconv_deb_nao_efetiv
  (cdcooper,
   nrdconta,
   cdempcon,
   cdsegmto,
   inproces,
   dslinarq,
   dtmvtolt,
   cdempres)
values
  (16,
   22683,
   162,
   4,
   0,
   'F841592687                4420000000000226832020111000000000000629930661753118                                                                       0',
   '10/11/2020',
   8480162)
/
commit
/
