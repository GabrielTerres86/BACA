/* 
  DDLs Chamado DDL_Ch_REQ0019502_001
  15/05/2019 - Ana - Envolti 
  Inclus�o email plantonistas@ailos.coop.br no cadastro para recebimento do relat�rio com as execu��es da cadeia.
*/

UPDATE CRAPPRM T SET 
T.DSVLRPRM = 
'rodrigo.siewerdt@ailos.coop.br, helio.mariano@ailos.coop.br, rosangela.heidorn@ailos.coop.br, marcos@ailos.coop.br, frank.ribeiro@ailos.coop.br, renan.censi@ailos.coop.br, plantonistas@ailos.coop.br'
WHERE T.NMSISTEM = 'CRED' AND T.CDACESSO = 'PC_LISTA_TBGEN_EMAIL_1';

COMMIT;





