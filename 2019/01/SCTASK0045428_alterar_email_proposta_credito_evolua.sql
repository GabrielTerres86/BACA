update crapprm prm
   set prm.dsvlrprm = 'negocios@evolua.coop.br'
 where prm.cdcooper = 14
   and prm.cdacesso = 'EMAIL_SOL_CRED_AUTO';

COMMIT;
