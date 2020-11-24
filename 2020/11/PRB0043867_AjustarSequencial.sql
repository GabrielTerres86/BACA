-- PRB0043867
-- Ajustar o sequencial dos convênios que tiveram arquivos gerados manualmente.
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 67561, '24/11/2020', 9, 2, '3239-EF00000900000000006756120201124.CNV', 6, 164.56)
/
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (16, 7, 67561, '24/11/2020', 2, 2, '4420-EF00000200000000006756120201124.CNV', 2, 104.49)
/
update crapcon c
   set c.nrseqatu = c.nrseqatu + 1
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((6, 4, 1),
                                                (6, 4, 16))
/
-- Documentos com autorizações canceladas, pendente envio do registro F ao Bancoob.
insert into tbconv_deb_nao_efetiv values ( 1, 8895538,  82, 4, 0, 'F8999945826745            3239000000088955382020112300000000002161830667903010                                                                       0', trunc(sysdate), 8460082)
/
insert into tbconv_deb_nao_efetiv values ( 1, 7867972,  82, 4, 0, 'F8999910104980            3239000000078679722020112300000000001169830667903178                                                                       0', trunc(sysdate), 8460082)
/
insert into tbconv_deb_nao_efetiv values ( 1, 7757999,  82, 4, 0, 'F8999357515668            3239000000077579992020112300000000001587301667905450                                                                       0', trunc(sysdate), 8460082)
/
insert into tbconv_deb_nao_efetiv values ( 1, 7174136,  82, 4, 0, 'F8999769595065            3239000000071741362020112300000000000738401667907288                                                                       0', trunc(sysdate), 8460082)
/
insert into tbconv_deb_nao_efetiv values ( 1,  928070, 313, 4, 0, 'F401853070259             3239000000009280702020112000000000003045430666359040                                                                       0', trunc(sysdate), 8460313)
/
insert into tbconv_deb_nao_efetiv values ( 1, 2281589, 313, 4, 0, 'F401991791951             3239000000022815892020112000000000001806830664114435                                                                       0', trunc(sysdate), 8460313)
/
insert into tbconv_deb_nao_efetiv values ( 1, 7627866, 313, 4, 0, 'F401917552554             3239000000076278662020112000000000000611930664113312                                                                       0', trunc(sysdate), 8460313)
/
insert into tbconv_deb_nao_efetiv values ( 1, 2631180, 162, 4, 0, 'F180161424                3239000000026311802020112000000000000592830668376142                                                                       0', trunc(sysdate), 8480162)
/
insert into tbconv_deb_nao_efetiv values ( 2,  560901,  82, 4, 0, 'F8999849807379            3265000000005609012020112300000000001430030667903327                                                                       0', trunc(sysdate), 8460082)
/
insert into tbconv_deb_nao_efetiv values (14,   53481, 111, 3, 0, 'F0000095665056            4468000000000534812020112300000000001070730663039693                                                                       0', trunc(sysdate), 8360111)
/
-- Ajustar o sequencial dos convênios que o Bancoob enviou fora de sequência para então permitir a integração
update crapcon c set c.nrseqint = 2
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((80, 4, 6))
/
update crapcon c set c.nrseqint = 4
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 6))
/
update crapcon c set c.nrseqint = 5
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((430, 4, 1))
/
update crapcon c set c.nrseqint = 12
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((80, 4, 1))
/
update crapcon c set c.nrseqint = 27
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 1))
/
update crapcon c set c.nrseqint = 4
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((80, 4, 2))
/
update crapcon c set c.nrseqint = 6
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 2))
/
update crapcon c set c.nrseqint = 3
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 5))
/
update crapcon c set c.nrseqint = 8
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 7))
/
update crapcon c set c.nrseqint = 6
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 16))
/
update crapcon c set c.nrseqint = 3
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 8))
/
update crapcon c set c.nrseqint = 4
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 11))
/
update crapcon c set c.nrseqint = 3
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 10))
/
update crapcon c set c.nrseqint = 3
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 9))
/
update crapcon c set c.nrseqint = 7
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((79, 4, 9))
/
update crapcon c set c.nrseqint = 3
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 12))
/
update crapcon c set c.nrseqint = 4
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 13))
/
update crapcon c set c.nrseqint = 4
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((80, 4, 13))
/
update crapcon c set c.nrseqint = 3
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((313, 4, 14))
/
--
commit
/
