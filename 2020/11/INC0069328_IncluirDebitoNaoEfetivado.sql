-- INC0069328
-- Documentos com pagamento não efetivado, pendente envio do registro F ao Bancoob.
insert into tbconv_deb_nao_efetiv values (1, 8997110, 313, 4, 0, 'F401636517571             3239000000089971102020112600000000000897804671148749                                                                       0', trunc(sysdate), 8460313)
/
-- Ajustar o sequencial dos convênios que o Bancoob enviou fora de sequência para então permitir a integração
update crapcon c set c.nrseqint = 3
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((1330, 2, 5))
/
update crapcon c set c.nrseqint = 2
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((1330, 2, 7))
/
update crapcon c set c.nrseqint = 2
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((1330, 2, 8))
/
update crapcon c set c.nrseqint = 4
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((1330, 2, 9))
/
commit
/
