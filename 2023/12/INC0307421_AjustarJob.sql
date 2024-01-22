BEGIN
  UPDATE cecred.tbgen_batch_jobs a
     SET a.dtprox_execucao = a.dtprox_execucao - (40 / (60 * 24))
   WHERE a.nmjob = 'JBCYB_ATUALIZA_DADOS_CYBER'
     AND to_char(a.dtprox_execucao, 'HH24:MI') = '19:30';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
