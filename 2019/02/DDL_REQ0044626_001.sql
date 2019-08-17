/* 
  DDLs Chamado DDL_Ch_REQ0044626_001
  19/02/2019 - Ana - Envolti 
  Inclusão email no cadastro para recebimento do relatório com as execuções da cadeia.
*/

UPDATE CRAPPRM T SET 
T.DSVLRPRM = 'rodrigo.siewerdt@ailos.coop.br, helio.mariano@ailos.coop.br, rosangela.heidorn@ailos.coop.br, 
marcos@ailos.coop.br, frank.ribeiro@ailos.coop.br, renan.censi@ailos.coop.br'
WHERE T.NMSISTEM = 'CRED' AND T.CDACESSO = 'PC_LISTA_TBGEN_EMAIL_1';

COMMIT;

