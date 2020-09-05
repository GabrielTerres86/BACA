DECLARE
  vr_rowid VARCHAR2(50);
  vr_dserro VARCHAR2(100);
  vr_dscritic VARCHAR2(4000);
  
BEGIN
  --
  UPDATE CRAPCOB COB
  SET COB.INSITCRT = 0
     ,COB.DTSITCRT = NULL
     ,COB.DTBLOQUE = NULL
  WHERE COB.CDCOOPER = 16
  AND   COB.NRDCONTA = 200450
  AND   COB.NRDOCMTO = 6196
  AND   COB.NRCNVCOB = 115070
  RETURNING ROWID INTO vr_rowid;  
  -- 
  paga0001.pc_cria_log_cobranca(pr_idtabcob => vr_rowid
                            , pr_cdoperad => '1'
                            , pr_dtmvtolt => trunc(SYSDATE)
                            , pr_dsmensag => 'Titulo retirado de protesto manualmente'
                            , pr_des_erro => vr_dserro
                            , pr_dscritic => vr_dscritic );
                            
  COMMIT;                            
  
END;
  

