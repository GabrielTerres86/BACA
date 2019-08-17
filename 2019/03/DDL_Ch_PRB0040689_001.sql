/* 
  DDLs Chamado PRB0040689 - 22/03/2019 - Belli - Envolti.
  - Inclusão de e-mail para quando ser diagnosticado algum problema mas o sistema não para possa ter uma ação rapida.
    O sistema alem de gerar um Log completo vai postar um e-mail para equipe de TI de sustentação.
	Registro genérico.
	- Caso 1 Falta de cadastro em type no meio do programa GECO0001
*/

INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
VALUES ('CRED', 0, 'ALERTA_SUSTENTACAO', 'E-Mail com erro de programa mas que não parou o programa', 'sustentacao@ailos.coop.br', NULL);


COMMIT;
