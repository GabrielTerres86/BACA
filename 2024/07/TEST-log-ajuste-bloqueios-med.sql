DECLARE
vr_lgrowid ROWID;
vr_lgrowid1 ROWID;

BEGIN

  INSERT INTO CONTACORRENTE.TBCC_SOLICITACAO_BLOQUEIO_ANALITICO (IDSOLBLQ, DHDEVOLUCAO, VLBLOQUEADO, INTENTATIVA_DEVOLUCAO, INNOTIFICADO, INESTORNADO) 
  VALUES ('197525F43B5E01C4E0630ACC82061AC0', TO_DATE('2024-07-18 08:00:00', 'yyyy-mm-dd hh24:mi:ss'), 0.4, 1, 0, 0);

  gene0001.pc_gera_log(pr_cdcooper => 12
  ,pr_cdoperad => '1'
  ,pr_dscritic => ' '
  ,pr_dsorigem => 'AIMARO'
  ,pr_dstransa => 'Altera dados do bloqueio no Conta Corrente'
  ,pr_dttransa => TRUNC(SYSDATE)
  ,pr_flgtrans => 1
  ,pr_hrtransa => gene0002.fn_busca_time
  ,pr_idseqttl => 1
  ,pr_nmdatela => ''
  ,pr_nrdconta => 99933942
  ,pr_nrdrowid => vr_lgrowid);

  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
  ,pr_nmdcampo => 'IDSOLBLQ'
  ,pr_dsdadant => NULL
  ,pr_dsdadatu => '197525F43B5E01C4E0630ACC82061AC0');
            
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
  ,pr_nmdcampo => 'DHDEVOLUCAO'
  ,pr_dsdadant => NULL
  ,pr_dsdadatu => '2024-07-18 08:00:00');

  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
  ,pr_nmdcampo => 'VLBLOQUEADO'
  ,pr_dsdadant => NULL
  ,pr_dsdadatu => '0,4');

  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
  ,pr_nmdcampo => 'INTENTATIVA_DEVOLUCAO'
  ,pr_dsdadant =>NULL
  ,pr_dsdadatu => '1');

  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
  ,pr_nmdcampo => 'INNOTIFICADO'
  ,pr_dsdadant => NULL
  ,pr_dsdadatu => '0');

  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
  ,pr_nmdcampo => 'INESTORNADO'
  ,pr_dsdadant => NULL
  ,pr_dsdadatu => '0');
  
  UPDATE CONTACORRENTE.TBCC_SOLICITACAO_BLOQUEIO SET VLDEVOLVIDO = 3.90
	WHERE IDSOLBLQ = '197525F43B5E01C4E0630ACC82061AC0' AND NRDCONTA = 99933942 AND CDCOOPER = 12;

  gene0001.pc_gera_log(pr_cdcooper => 12
  ,pr_cdoperad => '1'
  ,pr_dscritic => ' '
  ,pr_dsorigem => 'AIMARO'
  ,pr_dstransa => 'Altera dados do bloqueio no Conta Corrente'
  ,pr_dttransa => TRUNC(SYSDATE)
  ,pr_flgtrans => 1
  ,pr_hrtransa => gene0002.fn_busca_time
  ,pr_idseqttl => 1
  ,pr_nmdatela => ''
  ,pr_nrdconta => 99933942
  ,pr_nrdrowid => vr_lgrowid2);

  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid2
  ,pr_nmdcampo => 'VLDEVOLVIDO'
  ,pr_dsdadant => '3,50'
  ,pr_dsdadatu => '3,90');

COMMIT;
END;