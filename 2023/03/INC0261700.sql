DECLARE                                 
  CURSOR c_port_recebe IS
  SELECT t.cdcooper
        ,t.nrdconta
        ,t.nrsolicitacao
        ,t.idsituacao
        ,t.rowid
     FROM tbcc_portabilidade_envia t
    WHERE t.idsituacao = 5
      AND TRIM(t.nrnu_portabilidade) IS NULL;                                

  vc_idSituacaoEnvia             CONSTANT NUMBER(1)    := 7;
  vc_dttransa                    CONSTANT DATE         := TRUNC(SYSDATE);
  vc_hrtransa                    CONSTANT NUMBER(5)    := GENE0002.fn_busca_time;
  
  vr_nrdrowidPortabilidade       ROWID;
  vr_nrdrowid                    ROWID;
  vr_cdoperad                    cecred.craplgm.cdoperad%TYPE;
  vr_dstransa                    VARCHAR2(4000);
  vr_tabela                      VARCHAR2(4000);
  vr_cdcritic                    cecred.crapcri.cdcritic%type;
  vr_dscritic                    cecred.crapcri.dscritic%type;
  
  v_code NUMBER;
  v_errm VARCHAR2(64);
  
BEGIN

  vr_tabela := 'TBCC_PORTABILIDADE_ENVIA';
  vr_dstransa := 'Alteracao da situacao portabilidade - INC0261700 - ' || vr_tabela;

  FOR r_port_envia in c_port_recebe LOOP
    
    vr_nrdrowid := null;
    vr_nrdrowidPortabilidade := r_port_envia.rowid;
  
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => r_port_envia.cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => vr_dstransa,
                         pr_dttransa => vc_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => vc_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => r_port_envia.nrdconta,
                         pr_nrdrowid => vr_nrdrowid);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.nrsolicitacao',
                              pr_dsdadant => r_port_envia.nrsolicitacao,
                              pr_dsdadatu => r_port_envia.nrsolicitacao);


    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.idsituacao',
                              pr_dsdadant => r_port_envia.idsituacao,
                              pr_dsdadatu => vc_idSituacaoEnvia);

                               
    UPDATE CECRED.tbcc_portabilidade_envia t
       SET t.idsituacao            = vc_idSituacaoEnvia
     WHERE rowid = r_port_envia.rowid;
     
    COMMIT;
    
  END LOOP;
  
EXCEPTION
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1 , 64);
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao executar update em ' || vr_tabela || ' e ROWID: ' || vr_nrdrowidPortabilidade||  ' - ' || v_code || ' - ' || v_errm);
END;  

