BEGIN

  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_REG_JOB_RMSBO_AIMARO', 'Quantidade m�nima de registros para gerar jobs na gera��o de remessa de baixa operacional no AIMARO', '1000', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_JOB_PAR_RMSBO_AIMARO', 'Quantidade m�xima de jobs executados em paralelo na gera��o de remessa de baixa operacional no AIMARO', '3', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_COMMIT_RMSBO_AIMARO', 'Quantidade de registros para commitar ap�s a gera��o da remessa da baixa operacional no AIMARO', '50', NULL);

  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_REG_JOB_RMSBO_AIM_CTG', 'Quantidade m�nima de registros para gerar jobs na gera��o de remessa de baixa operacional em conting�ncia no AIMARO', '1000', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_JOB_PAR_RMSBO_AIM_CTG', 'Quantidade m�xima de jobs executados em paralelo na gera��o de remessa de baixa operacional em conting�ncia no AIMARO', '3', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_COMMIT_RMSBO_AIM_CTG', 'Quantidade de registros para commitar ap�s a gera��o da remessa da baixa operacional em conting�ncia no AIMARO', '50', NULL);

  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_REG_JOB_RMSBO_JDNPC', 'Quantidade m�nima de registros para gerar jobs na gera��o de remessa de baixa operacional para a JDNPC', '300', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_JOB_PAR_RMSBO_JDNCP', 'Quantidade m�xima de Jobs executados em paralelo na baixa operacional para o processo de envio da remessa para a JDNPC', '5', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_COMMIT_RMSBO_JDNCP', 'Quantidade de registros para commitar ap�s a gera��o da remessa da baixa operacional para a JDNPC', '25', NULL);

  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_REG_JOB_RETORNOBO', 'Quantidade m�nima de registros para gerar jobs de para busca do retorno da remessa de baixa operacional', '300', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_JOB_PAR_RETORNOBO', 'Quantidade m�xima de Jobs executados em paralelo para busca do retorno da baixa operacional', '5', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_COMMIT_RETORNOBO', 'Quantidade de registros para commitar no processo de consulta do retorno da remessa de baixa operacional', '25', NULL);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0023522');
    ROLLBACK;
END;