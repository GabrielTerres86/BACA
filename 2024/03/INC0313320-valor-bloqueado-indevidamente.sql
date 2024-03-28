DECLARE

  CURSOR cr_crapass IS
    SELECT t.cdcooper
         , t.nrdconta
      FROM cecred.crapass t
     WHERE t.progress_recid = 2077318;
     
  CURSOR cr_crapsld(pr_cdcooper  cecred.crapsld.cdcooper%TYPE
                   ,pr_nrdconta  cecred.crapsld.nrdconta%TYPE) IS 
    SELECT s.vlsdblpr
         , s.vlsddisp
      FROM cecred.crapsld s
     WHERE s.cdcooper = pr_cdcooper
       AND s.nrdconta = pr_nrdconta;

  vr_cdcooper  NUMBER;
  vr_nrdconta  NUMBER;
  vr_nrdrowid  VARCHAR2(50);
  vr_vlsdblpr  NUMBER;
  vr_vlsddisp  NUMBER;

BEGIN
  
  OPEN  cr_crapass;
  FETCH cr_crapass INTO vr_cdcooper, vr_nrdconta;
  CLOSE cr_crapass;
  
  IF vr_cdcooper IS NULL OR vr_nrdconta IS NULL THEN
    raise_application_error(-20001,'Cooperativa e conta não encontrada pelo recid: '||vr_cdcooper||'-'||vr_nrdconta);
  END IF;
  
  OPEN  cr_crapsld(vr_cdcooper, vr_nrdconta);
  FETCH cr_crapsld INTO vr_vlsdblpr, vr_vlsddisp;
  CLOSE cr_crapsld;     
  
  CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                             ,pr_cdoperad => '1'
                             ,pr_dscritic => NULL
                             ,pr_dsorigem => 'AIMARO'
                             ,pr_dstransa => 'Ajuste de saldo bloqueado indevidamente (CRAPSLD) por script - INC0313320'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 1
                             ,pr_hrtransa => GENE0002.fn_busca_time
                             ,pr_idseqttl => 0
                             ,pr_nmdatela => NULL
                             ,pr_nrdconta => vr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);

  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'crapsld.VLSDDISP'
                                  ,pr_dsdadant => vr_vlsddisp
                                  ,pr_dsdadatu => vr_vlsddisp + vr_vlsdblpr);
  
  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'crapsld.VLSDBLPR'
                                  ,pr_dsdadant => vr_vlsdblpr
                                  ,pr_dsdadatu => 0);
  
  BEGIN
    UPDATE cecred.crapsld t 
       SET t.vlsddisp = t.vlsddisp + t.vlsdblpr
         , t.vlsdblpr = 0
     WHERE t.cdcooper = vr_cdcooper
       AND t.nrdconta = vr_nrdconta;
  EXCEPTION 
    WHEN OTHERS THEN
      raise_application_error(-20002,'Erro ao atualizar registro de saldo CRAPSLD: '||SQLERRM);
  END;
    
  COMMIT;
END;
