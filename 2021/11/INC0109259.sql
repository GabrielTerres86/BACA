DECLARE
  vr_idintegrante      tbcc_grupo_economico_integ.idintegrante%type      := 277002;
  vr_idgrupo           tbcc_grupo_economico_integ.idgrupo%type           := 77924;
  vr_cdcooper          tbcc_grupo_economico_integ.cdcooper%type          := 1;
  vr_nrdconta          tbcc_grupo_economico_integ.nrdconta%type          := 8826374;
  vr_cdoperad_exclusao tbcc_grupo_economico_integ.cdoperad_exclusao%type := '1';
  vr_nrdrowid          ROWID;
BEGIN
  -- Exclusao do Integrante do Grupo Economico
  UPDATE tbcc_grupo_economico_integ
     SET cdoperad_exclusao = vr_cdoperad_exclusao
        ,dtexclusao = TRUNC(SYSDATE)
   WHERE idintegrante = vr_idintegrante
     AND cdcooper = vr_cdcooper
     AND nrdconta = vr_nrdconta
  ;
    
  -- Gravar o LOG da atualizacao
  gene0001.pc_gera_log(pr_cdcooper => 1
                      ,pr_cdoperad => vr_cdoperad_exclusao
                      ,pr_dscritic => ''
                      ,pr_dsorigem => 'AIMARO'
                      ,pr_dstransa => 'Exclusao Integrante do Grupo Economico'
                      ,pr_dttransa => TRUNC(SYSDATE)
                      ,pr_flgtrans => 1 --> TRUE
                      ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                      ,pr_idseqttl => 1
                      ,pr_nmdatela => 'GRP ECONOMIC'
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrdrowid => vr_nrdrowid);
    
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           ,pr_nmdcampo => 'Grupo'
                           ,pr_dsdadant => ' '
                           ,pr_dsdadatu => vr_idgrupo);
                              
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           ,pr_nmdcampo => 'Integrante'
                           ,pr_dsdadant => ' '
                           ,pr_dsdadatu => vr_idintegrante);
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Problemas ao excluir integrante do grupo econômico -> '||SQLERRM);
END; 