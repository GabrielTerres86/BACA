BEGIN
  UPDATE crapprm prm
     SET prm.dsvlrprm = prm.dsvlrprm || ',(3068463,871275)'
   WHERE prm.cdcooper = 1
     AND prm.cdacesso = 'CTA_CTR_ACAO_JUDICIAL';
     
  COMMIT;
END;
