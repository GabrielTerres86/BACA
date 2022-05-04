BEGIN

  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_REG_JOB_RMSBO_AIMARO', 'Quantidade mínima de registros para gerar jobs na geração de remessa de baixa operacional no AIMARO', '1000', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_JOB_PAR_RMSBO_AIMARO', 'Quantidade máxima de jobs executados em paralelo na geração de remessa de baixa operacional no AIMARO', '3', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_COMMIT_RMSBO_AIMARO', 'Quantidade de registros para commitar após a geração da remessa da baixa operacional no AIMARO', '50', NULL);

  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_REG_JOB_RMSBO_AIM_CTG', 'Quantidade mínima de registros para gerar jobs na geração de remessa de baixa operacional em contingência no AIMARO', '1000', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_JOB_PAR_RMSBO_AIM_CTG', 'Quantidade máxima de jobs executados em paralelo na geração de remessa de baixa operacional em contingência no AIMARO', '3', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_COMMIT_RMSBO_AIM_CTG', 'Quantidade de registros para commitar após a geração da remessa da baixa operacional em contingência no AIMARO', '50', NULL);

  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_REG_JOB_RMSBO_JDNPC', 'Quantidade mínima de registros para gerar jobs na geração de remessa de baixa operacional para a JDNPC', '300', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_JOB_PAR_RMSBO_JDNCP', 'Quantidade máxima de Jobs executados em paralelo na baixa operacional para o processo de envio da remessa para a JDNPC', '5', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_COMMIT_RMSBO_JDNCP', 'Quantidade de registros para commitar após a geração da remessa da baixa operacional para a JDNPC', '25', NULL);

  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_REG_JOB_RETORNOBO', 'Quantidade mínima de registros para gerar jobs de para busca do retorno da remessa de baixa operacional', '300', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_JOB_PAR_RETORNOBO', 'Quantidade máxima de Jobs executados em paralelo para busca do retorno da baixa operacional', '5', NULL);
  INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  VALUES ('CRED', 0, 'QT_COMMIT_RETORNOBO', 'Quantidade de registros para commitar no processo de consulta do retorno da remessa de baixa operacional', '25', NULL);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0023522');
    ROLLBACK;
END;