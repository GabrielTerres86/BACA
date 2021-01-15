insert into crapprm
  (nmsistem,
   cdcooper,
   cdacesso,
   dstexprm,
   dsvlrprm)
values
  ('CRED',
   0,
   'DIR_RECEBE_BANCOOB',
   'Diretorio que recebe os arquivos de convenios Bancoob',
   '/usr/connect/bancoob/recebe')
/
insert into crapprm
  (nmsistem,
   cdcooper,
   cdacesso,
   dstexprm,
   dsvlrprm)
values
  ('CRED',
   0,
   'DIR_RECEBIDOS_BANCOOB',
   'Diretorio que possui os arquivos recebidos e processados dos convenios Bancoob',
   '/usr/sistemas/bancoob/convenios/recebidos')
/
commit
/
