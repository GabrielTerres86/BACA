
/* Desativa a migracao da poupanca para a cooperativa especificada */

delete from crapprm where nmsistem = 'CRED' and cdcooper = 1 and cdacesso = 'MIGRA_POUPANCA_PROG';

commit;
