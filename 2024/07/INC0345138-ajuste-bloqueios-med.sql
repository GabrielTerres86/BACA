DECLARE
vr_lgrowid ROWID;
vr_lgrowid1 ROWID;
vr_lgrowid2 ROWID;

BEGIN

	INSERT INTO CONTACORRENTE.TBCC_SOLICITACAO_BLOQUEIO_ANALITICO (IDSOLBLQ, DHDEVOLUCAO, VLBLOQUEADO, INTENTATIVA_DEVOLUCAO, INNOTIFICADO, INESTORNADO) 
		VALUES ('1CE8C835BAA10474E0630A29357C445A', TO_DATE('2024-07-11 21:00:45', 'yyyy-mm-dd hh24:mi:ss'), 2451.68, 1, 0, 0);

	gene0001.pc_gera_log(pr_cdcooper => 1
	,pr_cdoperad => '1'
	,pr_dscritic => ' '
	,pr_dsorigem => 'AIMARO'
	,pr_dstransa => 'Altera dados do bloqueio no Conta Corrente'
	,pr_dttransa => TRUNC(SYSDATE)
	,pr_flgtrans => 1
	,pr_hrtransa => gene0002.fn_busca_time
	,pr_idseqttl => 1
	,pr_nmdatela => ''
	,pr_nrdconta => 9735658
	,pr_nrdrowid => vr_lgrowid);

	gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
	,pr_nmdcampo => 'IDSOLBLQ'
	,pr_dsdadant => NULL
	,pr_dsdadatu => '1CE8C835BAA10474E0630A29357C445A');
						
	gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
	,pr_nmdcampo => 'DHDEVOLUCAO'
	,pr_dsdadant => NULL
	,pr_dsdadatu => '2024-07-11 21:00:45');

	gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
	,pr_nmdcampo => 'VLBLOQUEADO'
	,pr_dsdadant => NULL
	,pr_dsdadatu => '2451,68');

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

	INSERT INTO CONTACORRENTE.TBCC_SOLICITACAO_BLOQUEIO_ANALITICO (IDSOLBLQ, DHDEVOLUCAO, VLBLOQUEADO, INTENTATIVA_DEVOLUCAO, INNOTIFICADO, INESTORNADO) 
		VALUES ('1CE8C835BAA10474E0630A29357C445A', TO_DATE('2024-07-12 00:00:44', 'yyyy-mm-dd hh24:mi:ss'), 2451.68, 1, 0, 0);

	gene0001.pc_gera_log(pr_cdcooper => 1
	,pr_cdoperad => '1'
	,pr_dscritic => ' '
	,pr_dsorigem => 'AIMARO'
	,pr_dstransa => 'Altera dados do bloqueio no Conta Corrente'
	,pr_dttransa => TRUNC(SYSDATE)
	,pr_flgtrans => 1
	,pr_hrtransa => gene0002.fn_busca_time
	,pr_idseqttl => 1
	,pr_nmdatela => ''
	,pr_nrdconta => 9735658
	,pr_nrdrowid => vr_lgrowid1);

	gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid1
	,pr_nmdcampo => 'IDSOLBLQ'
	,pr_dsdadant => NULL
	,pr_dsdadatu => '1CE8C835BAA10474E0630A29357C445A');
						
	gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid1
	,pr_nmdcampo => 'DHDEVOLUCAO'
	,pr_dsdadant => NULL
	,pr_dsdadatu => '2024-07-12 00:00:44');

	gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid1
	,pr_nmdcampo => 'VLBLOQUEADO'
	,pr_dsdadant => NULL
	,pr_dsdadatu => '2451,68');

	gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid1
	,pr_nmdcampo => 'INTENTATIVA_DEVOLUCAO'
	,pr_dsdadant =>NULL
	,pr_dsdadatu => '1');

	gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid1
	,pr_nmdcampo => 'INNOTIFICADO'
	,pr_dsdadant => NULL
	,pr_dsdadatu => '0');

	gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid1
	,pr_nmdcampo => 'INESTORNADO'
	,pr_dsdadant => NULL
	,pr_dsdadatu => '0');
	
	UPDATE CONTACORRENTE.TBCC_SOLICITACAO_BLOQUEIO SET VLDEVOLVIDO = 10227.44
		WHERE IDSOLBLQ = '1CE8C835BAA10474E0630A29357C445A' AND NRDCONTA = 9735658 AND CDCOOPER = 1;

	gene0001.pc_gera_log(pr_cdcooper => 1
	,pr_cdoperad => '1'
	,pr_dscritic => ' '
	,pr_dsorigem => 'AIMARO'
	,pr_dstransa => 'Altera dados do bloqueio no Conta Corrente'
	,pr_dttransa => TRUNC(SYSDATE)
	,pr_flgtrans => 1
	,pr_hrtransa => gene0002.fn_busca_time
	,pr_idseqttl => 1
	,pr_nmdatela => ''
	,pr_nrdconta => 9735658
	,pr_nrdrowid => vr_lgrowid2);

	gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid2
	,pr_nmdcampo => 'VLDEVOLVIDO'
	,pr_dsdadant => '5324,08'
	,pr_dsdadatu => '10227,44');

COMMIT;
END;