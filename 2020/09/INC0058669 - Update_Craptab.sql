--Atualiza a tabela craptab incluindo os novos bancos 274 e 368.
update craptab c
  set DSTEXTAB = ('7,91,128,130,260,274,368')
where c.cdcooper = 0
  and UPPER(c.nmsistem) = '%CRED%'
  and UPPER(c.tptabela) = '%GENERI%'
  and c.cdempres = 0
  and UPPER(c.cdacesso) = 'AGE_ATIVAS_CAF'
  and c.tpregist = 0 ;
commit;
