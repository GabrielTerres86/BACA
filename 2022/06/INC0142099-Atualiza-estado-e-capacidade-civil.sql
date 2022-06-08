DECLARE

  CURSOR cr_crapdat (pr_cdcooper IN CECRED.crapass.CDCOOPER%TYPE) IS
    SELECT d.dtmvtolt
    FROM CECRED.crapdat d
    WHERE d.cdcooper = pr_cdcooper;
    
  vr_dtmvtolt CECRED.crapdat.DTMVTOLT%TYPE;
  vr_cdcooper CECRED.crapass.CDCOOPER%TYPE;
  vr_nrdconta CECRED.crapass.NRDCONTA%TYPE;
  vr_nrdrowid ROWID;

BEGIN
  
  vr_cdcooper := 1;
  vr_nrdconta := 14810832;
  
  OPEN cr_crapdat(vr_cdcooper);
  FETCH cr_crapdat INTO vr_dtmvtolt;
  CLOSE cr_crapdat;
  
  UPDATE CECRED.CRAPTTL t
    SET t.inhabmen = 0
      , t.cdestcvl = 1
  WHERE t.nrdconta = vr_nrdconta
    AND t.cdcooper = vr_cdcooper
    AND t.nrcpfcgc = 16292985903;
  
  CECRED.GENE0001.pc_gera_log(pr_cdcooper  => vr_cdcooper,
                               pr_cdoperad => 1,
                               pr_dscritic => null,
                               pr_dsorigem => 'Aimaro',
                               pr_dstransa => 'INC0142099 - Ajuste do estado civil e da capacidade civil para solteiro e menor conforme solicitado no Incidente.',
                               pr_dttransa => vr_dtmvtolt,
                               pr_flgtrans => 1,
                               pr_hrtransa => gene0002.fn_busca_time,
                               pr_idseqttl => 1,
                               pr_nmdatela => 'JOB', 
                               pr_nrdconta => vr_nrdconta,
                               pr_nrdrowid => vr_nrdrowid);
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
