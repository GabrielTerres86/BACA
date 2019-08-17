/* 
  DDLs Chamado DDL_Ch_REQ0048519_001
  19/03/2019 - Ana - Envolti 
  Alteração email Ana no cadastro para recebimento do relatório com as execuções da cadeia.
*/

UPDATE CRAPPRM T SET 
T.DSVLRPRM = 'ana.volles@ailos.coop.br'
WHERE T.NMSISTEM = 'CRED' AND T.CDACESSO = 'PC_LISTA_TBGEN_EMAIL_2';

COMMIT;

