--RITM0059186 Alterar email para recebimento do relat�rio 043 gerado no processo de pr�vias de sobras.

update crapprm prm
   set prm.dsvlrprm = 'nayara.cestari@ailos.coop.br;crislaine.souza@ailos.coop.br;juliana.ferreira@ailos.coop.br'
 where prm.nmsistem = 'CRED'
   and prm.cdacesso = 'CRRL043_EMAIL'
   and prm.cdcooper = 0;
   
 COMMIT;
