 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Cadastro de parâmetros e mensageria
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : Cadastra os registros de parâmetros e mensageria para as funcionalidades da Release 3
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- remove qualquer "lixo" de BD que possa ter  
/*
DELETE FROM crapaca WHERE nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'DSCT0003') ;
DELETE FROM craprdr WHERE nmprogra = 'DSCT0003';

DELETE FROM crapaca WHERE nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADPCP') ;
DELETE FROM craprdr WHERE nmprogra = 'TELA_CADPCP';

DELETE FROM crapaca WHERE nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_APRDES') ;
DELETE FROM craprdr WHERE nmprogra = 'TELA_APRDES';

DELETE FROM crapaca WHERE nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'CADPCN') ;
DELETE FROM craprdr WHERE nmprogra = 'CADPCN';

DELETE FROM crapaca WHERE nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TITCTO') ;
DELETE FROM craprdr WHERE nmprogra = 'TITCTO';
*/

-- PARÂMETROS

INSERT INTO crapprm (SELECT 'CRED',cdcooper,'FL_VIRADA_BORDERO','Guarda se uma cooperativa está trabalhando com os borderos novos ou velhos','0',NULL FROM crapcop where flgativo = 1);
INSERT INTO crapprm (SELECT 'CRED',cdcooper,'PERCENTUAL_MULTA_DSCT','Percentual de multa sobre atraso de títulos descontados vencidos','2',NULL FROM crapcop where flgativo = 1);
INSERT INTO crapprm (SELECT 'CRED',cdcooper,'COBTIT_BLQ_RESG_CC','Bloqueio de resgate de debitos c/c (crps735)','N',NULL FROM crapcop where flgativo = 1);

-- parâmetro de data do cálculo de juros (REMOVER ESTE PARÂMETRO DA IMPLEMENTAÇÃO!)
/*
INSERT INTO crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) 
  SELECT 
    'CRED',
    cdcooper,
    'DT_CALC_JUR_SIMP_BORD',
    'Data inicio para calculo de juros simples para títulos',
    '08/05/2018'
  FROM crapcop WHERE flgativo = 1;
*/
-- MENSAGERIA

-- DSC0003
INSERT INTO craprdr (nrseqrdr, nmprogra, dtsolici)
     VALUES (SEQRDR_NRSEQRDR.NEXTVAL, 'DSCT0003', SYSDATE);

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'DSCT0003_BUSCAR_ASSOCIADO', 'DSCT0003', 'pc_buscar_associado_web', 'pr_nrdconta,pr_nrcpfcgc', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'DSCT0003'));

-- ATENDA->DESCONTOS->TITULOS
INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'VIRADA_BORDERO', 'DSCT0003', 'pc_virada_bordero', '', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'REJEITAR_BORDERO_TITULO', 'DSCT0003', 'pc_rejeitar_bordero_web', 'pr_nrdconta,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCA_BORDEROS', 'TELA_ATENDA_DSCTO_TIT', 'pc_busca_borderos_web', 'pr_nrdconta,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'ALTERAR_TITULOS_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_altera_bordero', 'pr_tpctrlim,pr_insitlim,pr_nrdconta,pr_chave,pr_dtmvtolt,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LIBERAR_BORDERO', 'DSCT0003', 'pc_liberar_bordero_web', 'pr_nrdconta,pr_nrborder,pr_confirma', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'RESGATAR_TITULOS_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_resgate_titulo_bordero_web', 'pr_nrctrlim,pr_nrdconta,pr_dtmvtolt,pr_dtmvtoan,pr_dtresgat,pr_inproces,pr_chave', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_TITULOS_RESGATE', 'TELA_ATENDA_DSCTO_TIT', 'pc_buscar_titulos_resgate_web', 'pr_nrdconta,pr_dtmvtolt,pr_nrinssac,pr_vltitulo,pr_dtvencto,pr_nrnosnum,pr_nrctrlim,pr_nrborder,pr_insitlim,pr_tpctrlim', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_DADOS_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_buscar_dados_bordero_web', 'pr_nrdconta,pr_nrborder,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'EFETUA_ANALISE_BORDERO', 'DSCT0003', 'pc_efetua_analise_bordero_web', 'pr_nrdconta,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'INSERIR_TITULOS_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_insere_bordero_web', 'pr_tpctrlim,pr_insitlim,pr_nrdconta,pr_chave,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LISTAR_DETALHE_TITULO', 'TELA_ATENDA_DSCTO_TIT', 'pc_detalhes_tit_bordero_web', 'pr_nrdconta,pr_chave', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'SOLICITA_BIRO_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_solicita_biro_bordero_web', 'pr_nrdconta,pr_chave', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'VALIDAR_TITULOS_ALTERACAO', 'TELA_ATENDA_DSCTO_TIT', 'pc_validar_titulos_alteracao', 'pr_nrdconta,pr_chave,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_TIT_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_buscar_tit_bordero_web', 'pr_nrdconta,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_TITULOS_BORDERO', 'TELA_ATENDA_DSCTO_TIT', 'pc_buscar_titulos_bordero_web', 'pr_nrdconta,pr_dtmvtolt,pr_nrinssac,pr_vltitulo,pr_dtvencto,pr_nrnosnum,pr_nrctrlim,pr_insitlim,pr_tpctrlim,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LISTAR_TITULOS_RESUMO', 'TELA_ATENDA_DSCTO_TIT', 'pc_listar_titulos_resumo_web', 'pr_nrdconta,pr_chave', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LISTAR_TITULOS_RESUMO_RESGATAR', 'TELA_ATENDA_DSCTO_TIT', 'pc_titulos_resumo_resgatar_web', 'pr_nrdconta,pr_chave', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'OBTEM_DADOS_CONTRATO_LIMITE', 'TELA_ATENDA_DSCTO_TIT', 'pc_busca_dados_limite_web', 'pr_nrdconta,pr_tpctrlim,pr_insitlim,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'ALTERAR_PROPOSTA_MANUTENCAO', 'TELA_ATENDA_DSCTO_TIT', 'pc_alterar_proposta_manute_web', 'pr_nrdconta,pr_nrctrlim,pr_tpctrlim,pr_vllimite,pr_cddlinha', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'CONTINGENCIA_IBRATAN', 'TELA_ATENDA_DSCTO_TIT', 'pc_contingencia_ibratan_web', '', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

-- APRDES
INSERT INTO craprdr (nrseqrdr, nmprogra, dtsolici)
     VALUES (SEQRDR_NRSEQRDR.NEXTVAL, 'TELA_APRDES', SYSDATE);

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'ATUALIZA_CHECAGEM_OPERADOR', 'TELA_APRDES', 'pc_atualiza_checagem_operador', 'pr_nrdconta,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_APRDES'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_BORDERO', 'TELA_APRDES', 'pc_buscar_bordero_web', 'pr_nrdconta,pr_nrborder,pr_dtborini,pr_dtborfim', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_APRDES'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_TITULO', 'TELA_APRDES', 'pc_buscar_titulos_resgate_web', 'pr_nrdconta,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_APRDES'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'CONCLUI_CHECAGEM', 'TELA_APRDES', 'pc_conclui_checagem', 'pr_nrdconta,pr_nrborder,pr_titulos', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_APRDES'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'VISUALIZAR_DETALHES_TITULO_MESA', 'TELA_APRDES', 'pc_detalhes_titulo_web', 'pr_nrdconta,pr_nrborder,pr_chave', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_APRDES'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'INSERIR_PARECER', 'TELA_APRDES', 'pc_inserir_parecer', 'pr_nrdconta,pr_nrborder,pr_titulos,pr_dsparecer', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_APRDES'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'VERIFICA_STATUS_BORDERO', 'TELA_APRDES', 'pc_verifica_status_bordero_web', 'pr_nrdconta,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_APRDES'));

-- CADPCP
INSERT INTO craprdr (nrseqrdr, nmprogra, dtsolici)
     VALUES (SEQRDR_NRSEQRDR.NEXTVAL, 'TELA_CADPCP', SYSDATE);

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'CADPCP_BUSCA_CONTA', 'TELA_CADPCP', 'pc_busca_conta', 'pr_nrdconta', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADPCP'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'CADPCP_ALTERAR_PAGADOR', 'TELA_CADPCP', 'pc_alterar_pagador', 'pr_nrdconta,pr_nrinssac,pr_vlpercen', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADPCP'));

-- CADPCN
INSERT INTO craprdr (nrseqrdr, nmprogra, dtsolici)
     VALUES (SEQRDR_NRSEQRDR.NEXTVAL, 'CADPCN', SYSDATE);

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'CADPCN_BUSCAR', 'TELA_CADPCN', 'pc_buscar_cnae', 'pr_cdcnae', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'CADPCN'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'CADPCN_INCLUSAO', 'TELA_CADPCN', 'pc_incluir_cnae', 'pr_cdcnae,pr_vlmaximo', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'CADPCN'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'CADPCN_ALTERACAO', 'TELA_CADPCN', 'pc_alterar_cnae', 'pr_cdcnae,pr_vlmaximo', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'CADPCN'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'CADPCN_EXCLUSAO', 'TELA_CADPCN', 'pc_excluir_cnae', 'pr_cdcnae', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'CADPCN'));

-- TITCTO
INSERT INTO craprdr (nrseqrdr, nmprogra, dtsolici)
     VALUES (SEQRDR_NRSEQRDR.NEXTVAL, 'TITCTO', SYSDATE);

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'TITCTO_CONSULTA', 'TELA_TITCTO', 'pc_obtem_dados_titcto_web', 'pr_nrdconta,pr_tpcobran,pr_flresgat', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TITCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'TITCTO_RESUMO_DIA', 'TELA_TITCTO', 'pc_obtem_dados_resumo_dia_web', 'pr_nrdconta,pr_tpcobran,pr_dtvencto,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TITCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'TITCTO_CONCILIACAO', 'TELA_TITCTO', 'pc_obtem_dados_conciliacao_web', 'pr_tpcobran,pr_dtvencto,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TITCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'TITCTO_LOTEAMENTO', 'TELA_TITCTO', 'pc_obtem_dados_loteamento_web', 'pr_nrdconta,pr_tpcobran,pr_tpdepesq,pr_nrdocmto,pr_vltitulo,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TITCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'TITCTO_CONSULTA_IMPRESSAO', 'TELA_TITCTO', 'pc_gerar_impressao_titcto_c', 'pr_nrdconta,pr_tpcobran,pr_flresgat,pr_dtmvtolt', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TITCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'TITCTO_LOTE_IMPRESSAO', 'TELA_TITCTO', 'pc_gerar_impressao_titcto_l', 'pr_dtmvtolt,pr_cdagenci', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TITCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'TITCTO_CONSULTA_PAGADOR_REMETENTE', 'TELA_TITCTO', 'pc_consulta_pag_remetente_web', 'pr_nrdconta,pr_tpcobran', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TITCTO'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'TITCTO_BORDERO_IMPRESSAO', 'TELA_TITCTO', 'pc_gerar_impressao_titcto_b', 'pr_dtiniper,pr_dtfimper,pr_cdagenci,pr_nrdconta,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TITCTO'));

-- COBRAN
INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'COBR_PESQUISA_PAGADORES', 'COBR0012', 'pc_pesquisa_pagadores', 'pr_nrdconta,pr_nmdsacad,pr_nriniseq,pr_nrregist', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBRAN'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'COBR_OBTER_PAGADOR', 'COBR0012', 'pc_obter_pagador', 'pr_nrdconta,pr_nrinssac', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBRAN'));

-- COBTIT
INSERT INTO craprdr (nrseqrdr, nmprogra, dtsolici)
     VALUES (SEQRDR_NRSEQRDR.NEXTVAL, 'COBTIT', SYSDATE);

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_BORDEROS_VENCIDOS', 'TELA_COBTIT', 'pc_buscar_bordero_vencido_web', 'pr_nrdconta,pr_nriniseq,pr_nrregist', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LISTAR_FERIADOS', 'TELA_COBTIT', 'pc_listar_feriados_web', 'pr_dtmvtolt,pr_dtfinal', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LISTAR_TITULOS', 'TELA_COBTIT', 'pc_buscar_titulo_vencido_web', 'pr_nrdconta,pr_nrborder,pr_dtvencto', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'GERAR_BOLETO', 'TELA_COBTIT', 'pc_gerar_boleto_web', 'pr_nrdconta,pr_nrborder,pr_nrtitulo,pr_dtvencto,pr_nrcpfava ', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LISTA_AVALISTAS', 'TELA_COBTIT', 'pc_lista_avalista_web', 'pr_nrdconta,pr_nrborder ', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'COBTIT_BUSCAR_EMAIL', 'TELA_COBTIT', 'pc_buscar_email_web', 'pr_nrdconta,pr_nriniseq,pr_nrregist ', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'COBTIT_BUSCAR_TELEFONE', 'TELA_COBTIT', 'pc_buscar_telefone_web', 'pr_nrdconta,pr_flcelula,pr_nriniseq,pr_nrregist ', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'COBTIT_BUSCA_LISTA_PA', 'TELA_COBTIT', 'pc_lista_pa_web', 'pr_cdagenci,pr_nriniseq,pr_nrregist ', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_BOLETOS', 'TELA_COBTIT', 'pc_buscar_boletos_web', 'pr_cdagenci,pr_nrborder,pr_nrdconta,pr_dtbaixai,pr_dtbaixaf,pr_dtemissi,pr_dtemissf,pr_dtvencti,pr_dtvenctf,pr_dtpagtoi,pr_dtpagtof,pr_nriniseq,pr_nrregist', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT') );

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES (SEQACA_NRSEQACA.NEXTVAL, 'EFETUAR_BAIXA_BOLETO', 'TELA_COBTIT', 'pc_baixa_boleto_web', 'pr_nrdconta,pr_nrborder,pr_nrctacob,pr_nrcnvcob,pr_nrdocmto,pr_dtmvtolt,pr_dsjustif', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES (SEQACA_NRSEQACA.NEXTVAL, 'IMPRIMIR_BOLETO_PDF', 'TELA_COBTIT', 'pc_gerar_pdf_boleto_web', 'pr_nrdconta, pr_nrcnvcob, pr_nrdocmto', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES (SEQACA_NRSEQACA.NEXTVAL, 'ENVIAR_BOLETO', 'TELA_COBTIT', 'pc_enviar_boleto_web', 'pr_nrdconta, pr_nrborder, pr_nrctacob, pr_nrcnvcob, pr_nrdocmto, pr_nmcontat, pr_tpdenvio, pr_dsdemail, pr_indretor, pr_nrdddsms, pr_nrtelsms', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCAR_TEXTO_SMS', 'TELA_COBTIT', 'pc_busca_texto_sms_web', 'pr_nrdconta, pr_lindigit', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
   VALUES (SEQACA_NRSEQACA.NEXTVAL, 'COBTIT_BUSCAR_LOG', 'TELA_COBTIT', 'pc_buscar_log_web', 'pr_nrdconta,pr_nrdocmto,pr_nrcnvcob,pr_nriniseq,pr_nrregist', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
   VALUES (SEQACA_NRSEQACA.NEXTVAL, 'COBTIT_ARQUIVOS', 'TELA_COBTIT', 'pc_busca_arquivos_web', 'pr_dtarqini,pr_dtarqfim,pr_nmarquiv,pr_nriniseq,pr_nrregist', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
   VALUES (SEQACA_NRSEQACA.NEXTVAL, 'COBTIT_RELATORIO', 'TELA_COBTIT', 'pc_gera_relatorio_web', 'pr_idarquiv,pr_flgcriti', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
   VALUES (SEQACA_NRSEQACA.NEXTVAL, 'COBTIT_IMP_ARQUIVO', 'TELA_COBTIT', 'pc_importar_arquivo', 'pr_nmarquiv,pr_flgreimp', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
   VALUES (SEQACA_NRSEQACA.NEXTVAL, 'COBTIT_GERA_ARQPAR', 'TELA_COBTIT', 'pc_gera_arquivo_parc_web', 'pr_idarquiv', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));
   
INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
   VALUES (SEQACA_NRSEQACA.NEXTVAL, 'COBTIT_GERA_BOLETO', 'TELA_COBTIT', 'pc_gera_boletagem', 'pr_idarquiv', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
   VALUES (SEQACA_NRSEQACA.NEXTVAL, 'BUSCA_PRAZO_VCTO_MAX_COBTIT', 'TELA_COBTIT', 'pc_busca_prazo_vcto_max', 'pr_nrdconta,pr_nrborder', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBTIT'));

-- TAB096
INSERT INTO craprdr (nrseqrdr, nmprogra, dtsolici)
     VALUES (SEQRDR_NRSEQRDR.NEXTVAL, 'TELA_TAB096', SYSDATE);

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
   VALUES (SEQACA_NRSEQACA.NEXTVAL, 'TAB096_GRAVAR', 'TELA_TAB096', 'pc_gravar_web', 'pr_cdcooper,pr_nrconven,pr_nrdconta,pr_prazomax,pr_prazobxa,pr_vlrminpp,pr_vlrmintr,pr_dslinha1,pr_dslinha2,pr_dslinha3,pr_dslinha4,pr_dstxtsms,pr_dstxtema,pr_blqemiss,pr_qtdmaxbl,pr_flgblqvl,pr_descprej,pr_tpproduto', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_TAB096'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
   VALUES (SEQACA_NRSEQACA.NEXTVAL, 'TAB096_BUSCAR', 'TELA_TAB096', 'pc_buscar_web', 'pr_cdcooper,pr_tpproduto', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_TAB096'));

-- CADCYB
INSERT INTO crapaca (nrseqaca,nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr) 
   VALUES (SEQACA_NRSEQACA.NEXTVAL, 'PARCYB_BUSCAR_TITULOS_BORDERO','CYBE0003','pc_buscar_titulos_bordero','pr_nrdconta,pr_nrborder,pr_nrdocmto', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'PARCYB'))

commit;
end;