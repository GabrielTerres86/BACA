DECLARE

  i           INTEGER;
  vr_des_erro VARCHAR2(100);
  vr_dscritic VARCHAR2(1000);
BEGIN
  FOR rw IN (SELECT cob.rowid cob_rowid
               FROM cecred.craptdb tdb
                   ,cecred.crapcob cob
              WHERE tdb.cdcooper = 13
                AND tdb.dtvencto > '21/07/2023'
                AND tdb.insittit = 4
                AND cob.cdcooper = tdb.cdcooper
                AND cob.nrdconta = tdb.nrdconta
                AND cob.nrcnvcob = tdb.nrcnvcob
                AND cob.nrdocmto = tdb.nrdocmto
                AND cob.qtdiaprt > 0
                AND cob.incobran = 0
                AND tdb.nrdconta = 15180
                AND tdb.nrdocmto IN (4597, 4598, 4599, 4600)) LOOP
  
    UPDATE cecred.crapcob
       SET flgdprot = 0
          ,qtdiaprt = 0
          ,insitcrt = 0
          ,dtbloque = NULL
          ,dtsitcrt = NULL
     WHERE ROWID = rw.cob_rowid;
  
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw.cob_rowid
                                 ,pr_cdoperad => '1'
                                 ,pr_dtmvtolt => SYSDATE
                                 ,pr_dsmensag => 'Cancel. Instrucao Automatica de Protesto'
                                 ,pr_des_erro => vr_des_erro
                                 ,pr_dscritic => vr_dscritic);
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'INC0284401');
    RAISE;
  
END;
