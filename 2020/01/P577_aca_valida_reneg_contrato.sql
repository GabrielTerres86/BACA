BEGIN
  DECLARE
    vr_params crapaca.lstparam%TYPE;
  BEGIN

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('VALIDA_RENEG_CONTRATO', 'EMPR0021', 'pc_valida_reneg_contrato_web', 'pr_cdcooper,pr_nrdconta,pr_contrato,pr_nrctremp,pr_nrctsele', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'ATENDA'));

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('RECALCULA_RENEG_CONTRATO', 'EMPR0021', 'pc_recalcula_divida_web', 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_flgdocje,pr_idfiniof,pr_dtdpagto,pr_qtpreemp,pr_cdlcremp,pr_cdfinemp,pr_tpemprst,pr_idfintar,pr_idcarenc,pr_flgdeftr,pr_dtcarenc', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'ATENDA'));

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('RESUMO_RENEG', 'EMPR0021', 'pc_busca_resumo_ren_web', 'pr_cdcooper,pr_nrdconta,pr_dadosctr,pr_flgdocje,pr_idfiniof,pr_dtdpagto,pr_qtpreemp,pr_cdlcremp,pr_cdfinemp,pr_tpemprst,pr_idfintar', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'ATENDA'));

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('MANIPULA_RENEGOCIACAO', 'EMPR0021', 'pc_manipula_renegociacao_web', 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_flgdocje,pr_idfiniof,pr_dtdpagto,pr_qtpreemp,pr_cdlcremp,pr_cdfinemp,pr_idfintar,pr_dadosctr,pr_cddopcao', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'ATENDA'));

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('BUSCA_DADOS_CAPA', 'EMPR0021', 'pc_busca_renegociacao_web', 'pr_cdcooper,pr_nrdconta,pr_nrctremp', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'ATENDA'));

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('INS_HIS_GARANTIA', 'EMPR0021', 'pc_insere_hist_garantia', 'pr_cdcooper,pr_nrdconta,pr_nrctremp', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'ATENDA'));
	
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('VAL_ALT_VALOR', 'EMPR0021', 'pc_valida_alteracao_valor_web', 'pr_cdcooper,pr_nrdconta,pr_nrctremp', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'ATENDA'));
	
    -- Busca dados do TR para renegociação
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('BUSCA_DADOS_TR_REN', 'EMPR0021', 'pc_consulta_dados_tr_web', 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_cdlcremp', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'ATENDA'));

    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('EFETIVA_RENEG', 'EMPR0021', 'pc_efetiva_renegociacao', 'pr_cdcooper,pr_nrdconta,pr_nrctremp', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'ATENDA'));

    -- Atualiza dados do TR para renegociação
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('ATUALIZA_CONTRATO_TR', 'EMPR0021', 'pc_atualiza_tr_web', 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_tpctrato,pr_idseqttl,pr_dsavali1,pr_dsavali2,pr_dsarrprp,pr_dsdrendi,pr_dsjusren,pr_dsdebens,pr_dsdalien,pr_dsinterv', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'ATENDA'));
    
	SELECT lstparam 
      INTO vr_params
      FROM crapaca 
     WHERE nmdeacao = 'GAROPC_BUSCA_DADOS';
     
    UPDATE crapaca 
       SET lstparam = vr_params || ',pr_cdorigem'
     WHERE nmdeacao = 'GAROPC_BUSCA_DADOS';

    vr_params := '';
    
    SELECT lstparam 
      INTO vr_params
      FROM crapaca 
     WHERE nmdeacao = 'GAROPC_GRAVA_DADOS';
     
    UPDATE crapaca 
       SET lstparam = vr_params || ',pr_cdorigem'
     WHERE nmdeacao = 'GAROPC_GRAVA_DADOS';
     
    COMMIT;
  END;
END;
