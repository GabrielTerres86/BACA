/* 
  DDLs Chamado DDL_Ch_RITM0031859_001
  31/07/2019 - Ana Volles
  Inclusão email no cadastro para recebimento do relatório com as execuções da cadeia.

SELECT * FROM CRAPPRM T
WHERE T.NMSISTEM = 'CRED' AND T.CDACESSO = 'PC_LISTA_TBGEN_EMAIL_1';

SELECT * FROM CRAPPRM T
WHERE T.NMSISTEM = 'CRED' AND T.CDACESSO = 'PC_LISTA_TBGEN_EMAIL_2';
*/


BEGIN

  UPDATE CRAPPRM T SET 
  T.DSVLRPRM = 'rodrigo.siewerdt@ailos.coop.br, helio.mariano@ailos.coop.br, marcos@ailos.coop.br, frank.ribeiro@ailos.coop.br, renan.censi@ailos.coop.br, jhonatan.moraes@ailos.coop.br'
  WHERE T.NMSISTEM = 'CRED' AND T.CDACESSO = 'PC_LISTA_TBGEN_EMAIL_1';

  UPDATE CRAPPRM T SET 
  T.DSVLRPRM = 'ana.volles@ailos.coop.br, plantonistas@ailos.coop.br'
  WHERE T.NMSISTEM = 'CRED' AND T.CDACESSO = 'PC_LISTA_TBGEN_EMAIL_2';


  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
