
/* Ativa a migracao da poupanca para as cooperativas especificadas */

insert into crapprm 
   (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
values
  ('CRED', 6, 'MIGRA_POUPANCA_PROG', 'Ativa a migracao para esta cooperativa', 1);

insert into crapprm 
   (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
values
  ('CRED', 2, 'MIGRA_POUPANCA_PROG', 'Ativa a migracao para esta cooperativa', 1);

commit;
