DECLARE
  vr_dscritic VARCHAR2(2000);
  vr_dserro   VARCHAR2(2000);
  CURSOR cr_crapcob IS
    SELECT ROWID
          ,cdcooper
          ,nrdconta
          ,nrcnvcob
          ,nrdocmto
      FROM crapcob
     WHERE (cdcooper, nrdconta, nrcnvcob, nrdocmto) IN ((1, 8058830, 101004, 20054141));
BEGIN
  FOR rw_crapcob IN cr_crapcob LOOP
    UPDATE crapcob
       SET insitcrt = 0
          ,dtsitcrt = NULL
     WHERE cdcooper = rw_crapcob.cdcooper
       AND nrdconta = rw_crapcob.nrdconta
       AND nrcnvcob = rw_crapcob.nrcnvcob
       AND nrdocmto = rw_crapcob.nrdocmto;
    paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                 ,pr_cdoperad => '1'
                                 ,pr_dtmvtolt => trunc(SYSDATE)
                                 ,pr_dsmensag => 'Protesto cancelado manualmente'
                                 ,pr_des_erro => vr_dserro
                                 ,pr_dscritic => vr_dscritic);
  
    COMMIT;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    SISTEMA.excecaoInterna(pr_compleme => 'INC0220273');
END;
