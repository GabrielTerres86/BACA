/*
  PRB0044161 - Incluir parametro de controle para execucao com paralelismo de pagamentos INSS
  11/02/2021 - Jackson
*/
INSERT INTO crapprm
  (NMSISTEM
  ,CDCOOPER
  ,CDACESSO
  ,DSTEXPRM
  ,DSVLRPRM)
VALUES
  ('CRED'
  ,0
  ,'CRPS648INSS'
  ,'99;99 = Executa sem paralelismo | 0;9 = Executa com paralelismo'
  ,'0;9');

COMMIT;
