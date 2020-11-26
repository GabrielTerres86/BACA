-- PRB0043867
-- Documentos com autorizações canceladas, pendente envio do registro F ao Bancoob.
insert into tbconv_deb_nao_efetiv values ( 1,  8269238,  82, 4, 0, 'F8999909916233            3239000000082692382020112500000000000994430667903180                                                                       0', trunc(sysdate), 8460082)
/
insert into tbconv_deb_nao_efetiv values ( 1,  9129081,  82, 4, 0, 'F8999952868075            3239000000091290812020112500000000001969601667906798                                                                       0', trunc(sysdate), 8460082)
/
insert into tbconv_deb_nao_efetiv values ( 1, 11841087, 296, 4, 0, 'F2030011140836            3239000000118410872020112500000000000734901666392153                                                                       0', trunc(sysdate), 8460296)
/
insert into tbconv_deb_nao_efetiv values (11,    74438,  82, 4, 0, 'F8999856958212            4438000000000744382020112500000000000605930667907093                                                                       0', trunc(sysdate), 8460082)
/
insert into tbconv_deb_nao_efetiv values (14,   150185, 111, 3, 0, 'F0000043499058            4468000000001501852020112400000000002683230664009297                                                                       0', trunc(sysdate), 8360111)
/
-- Ajustar o sequencial dos convênios que o Bancoob enviou fora de sequência para então permitir a integração
update crapcon c set c.nrseqint = 3
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((1330, 2, 1))
/
update crapcon c set c.nrseqint = 200
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((305, 4, 1))
/
update crapcon c set c.nrseqint = 27
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((305, 4, 2))
/
update crapcon c set c.nrseqint = 2
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((80, 4, 7))
/
commit
/
