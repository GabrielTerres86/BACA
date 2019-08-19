
/* Ativa a migracao da poupanca para a cooperativa especificada */

insert into crapprm 
   (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
values
  ('CRED', 1, 'MIGRA_POUPANCA_PROG', 'Ativa a migracao para esta cooperativa', 1);

commit;
