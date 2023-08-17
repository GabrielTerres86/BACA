DECLARE 
  vr_nmdcampo  craplgi.nmdcampo%TYPE := 'crapsnh.vllimweb';
  vr_dstransa  craplgm.dstransa%TYPE := 'Alterar Limite Web - RITM0321941';
  vr_cdoperad  craplgm.cdoperad%TYPE := 't0035324';
  vr_nrdrowid ROWID;
  vr_qtlinhas PLS_INTEGER := 0;

 CURSOR cr_lgi IS
   SELECT lgi.cdcooper
         ,lgi.nrdconta
         ,lgi.idseqttl
         ,lgi.dsdadant
     FROM craplgi lgi
         ,craplgm lgm
    WHERE lgi.cdcooper = lgm.cdcooper
      AND lgi.nrdconta = lgm.nrdconta
      AND lgi.idseqttl = lgm.idseqttl
      AND lgi.nmdcampo = vr_nmdcampo
      AND lgm.dstransa = vr_dstransa
      AND lgm.cdoperad = vr_cdoperad
      AND lgm.flgtrans = 1
      AND lgm.nmdatela = 'SCRIPT ADHOC';
BEGIN
  FOR rw_lgi IN cr_lgi LOOP
    vr_qtlinhas := vr_qtlinhas + 1;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => rw_lgi.cdcooper
                               ,pr_nrdconta => rw_lgi.nrdconta
                               ,pr_idseqttl => rw_lgi.idseqttl
                               ,pr_cdoperad => vr_cdoperad
                               ,pr_dscritic => 'Registro revertido com sucesso.'
                               ,pr_dsorigem => 'AIMARO'
                               ,pr_dstransa => vr_dstransa
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 1
                               ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                               ,pr_nmdatela => 'ROLLBACK SCR'
                               ,pr_nrdrowid => vr_nrdrowid);
                           
    UPDATE crapsnh snh
       SET snh.vllimweb = rw_lgi.dsdadant
     WHERE snh.cdcooper = rw_lgi.cdcooper
       AND snh.nrdconta = rw_lgi.nrdconta
       AND snh.idseqttl = rw_lgi.idseqttl
       AND snh.tpdsenha = 1;
       
    IF vr_qtlinhas = 1000 THEN
      COMMIT;
      vr_qtlinhas := 0;
    END IF;
    
  END LOOP;
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 3
                                ,pr_compleme => ' Erro não tratado - Script: => ' || vr_dstransa);                           
END;
