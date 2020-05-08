PL/SQL Developer Test script 3.0
23
-- SQL - 31094 
DECLARE
BEGIN
  UPDATE crawepr t
     SET t.dsnivris = risc0004.fn_traduz_risco(innivris => t.dsnivris)
   WHERE LENGTH(TRIM(TRANSLATE(t.dsnivris, '0123456789', ' '))) IS NULL
     AND trim(t.dsnivris) IS NOT NULL;
   -- where copiada do history do bug;
   dbms_output.put_line('Atualizados: ' || SQL%rowcount);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('Erro ao atualizar crawepr.dsnivris: ' || SQLERRM);
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                               pr_ind_tipo_log => 1,
                               pr_des_log      => 'Erro ao atualizar crawepr.dsnivris: ' || SQLERRM,
                               pr_dstiplog     => NULL,
                               pr_nmarqlog     => 'log_corrige_dsnivris',
                               pr_cdprograma   => 'BACANIVRIS',
                               pr_tpexecucao   => 2);
END;
0
0
