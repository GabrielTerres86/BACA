-- PRB0043867
-- Ajustar o sequencial dos convênios que tiveram arquivos B gerados manualmente.
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (6, 7, 8460004, to_date('03122020','ddmmyyyy'), 1, 2, '3232-EF00000100000000846000420201203.CNV', 1, 0);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460004, to_date('03122020','ddmmyyyy'), 9, 2, '3239-EF00000900000000846000420201203.CNV', 37, 0);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460464, to_date('03122020','ddmmyyyy'), 25, 2, '3239-EF00002500000000846046420201203.CNV', 22, 0);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (2, 7, 8460004, to_date('03122020','ddmmyyyy'), 2, 2, '3265-EF00000200000000846000420201203.CNV', 1, 0);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (5, 7, 8460464, to_date('03122020','ddmmyyyy'), 2, 2, '3318-EF00000200000000846046420201203.CNV', 1, 0);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (7, 7, 8460004, to_date('03122020','ddmmyyyy'), 2, 2, '4416-EF00000200000000846000420201203.CNV', 1, 0);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (11, 7, 8460004, to_date('03122020','ddmmyyyy'), 3, 2, '4438-EF00000300000000846000420201203.CNV', 3, 0);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (11, 7, 8460464, to_date('03122020','ddmmyyyy'), 5, 2, '4438-EF00000500000000846046420201203.CNV', 3, 0);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (13, 7, 8460004, to_date('03122020','ddmmyyyy'), 2, 2, '4457-EF00000200000000846000420201203.CNV', 1, 0);
update crapcon c
   set c.nrseqatu = c.nrseqatu + 1
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((4, 4, 6),
                                                (4, 4, 1),
                                                (464, 4, 1),
                                                (4, 4, 2),
                                                (464, 4, 5),
                                                (4, 4, 7),
                                                (4, 4, 11),
                                                (464, 4, 11),
                                                (4, 4, 13));
-- Ajustar o sequencial dos convênios que tiveram arquivos F gerados manualmente.
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460004, to_date('03122020','ddmmyyyy'), 10, 2, '3239-EF00001000000000846000420201203.CNV', 8, 0);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460464, to_date('03122020','ddmmyyyy'), 26, 2, '3239-EF00002600000000846046420201203.CNV', 3, 0);
update crapcon c
   set c.nrseqatu = c.nrseqatu + 1
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((4, 4, 1),
                                                (464, 4, 1));
-- Encerrar as autorizações
update crapatr a
   set a.dtfimatr = to_date('03122020','ddmmyyyy')
 where a.cdhistor = 3292
   and a.dtfimatr is null
   and a.cdempres in (8460004, 8460464);
-- Incluir os registros F de pagamentos não efetivados
insert into tbconv_deb_nao_efetiv values (1, 10359915,  82, 4, 0, 'F9999817584027            3239000000103599152020120200000000002303930670523059                                                                       0', trunc(sysdate), 8460082);
insert into tbconv_deb_nao_efetiv values (1,  9155104,  82, 4, 0, 'F8999409011975            3239000000091551042020120200000000001437230670523645                                                                       0', trunc(sysdate), 8460082);
insert into tbconv_deb_nao_efetiv values (1,   411655, 313, 4, 0, 'F401371808625             3239000000004116552020120200000000001413830671151110                                                                       0', trunc(sysdate), 8460313);
insert into tbconv_deb_nao_efetiv values (1,  1988859, 313, 4, 0, 'F401437955284             3239000000019888592020120200000000002160430671149021                                                                       0', trunc(sysdate), 8460313);
insert into tbconv_deb_nao_efetiv values (1,  7866470, 313, 4, 0, 'F401982941843             3239000000078664702020120200000000001139904671149645                                                                       0', trunc(sysdate), 8460313);
insert into tbconv_deb_nao_efetiv values (1, 10859799, 313, 4, 0, 'F401995422713             3239000000108597992020120200000000001064430671148670                                                                       0', trunc(sysdate), 8460313);
--
commit;
