 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Cadastro de parâmetros e mensageria
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Andrew Albuquerque (GFT)
    Data        : Agosto/2018
    Objetivo    : Cadastra os registros de parâmetros e mensageria para as funcionalidades da Release 4
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
INSERT INTO crapprm (SELECT 'CRED',cdcooper,'FLG_CRPS538_CONCLUIDA','Define se a crps538 foi concluida no processo noturno','1',NULL FROM crapcop where flgativo = 1);


-- Parâmetros Tela COBTIT

-- MENSAGERIA

-- ATENDA->DESCONTOS->TITULOS
INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'LISTAR_HIST_ALT_LIMITE', 'TELA_ATENDA_DSCTO_TIT', 'pc_busca_hist_alt_limite_web', 'pr_nrdconta,pr_tpctrlim,pr_nrctrlim', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_DESCTO'));

-- Consultar Prejuizo
INSERT INTO CRAPACA(NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
     VALUES (SEQACA_NRSEQACA.NEXTVAL,'BUSCA_DADOS_PREJUIZO','DSCT0003','pc_busca_dados_prejuizo_web','pr_nrdconta,pr_nrborder',(SELECT nrseqrdr FROM craprdr WHERE nmprogra ='DSCT0003'));

-- Pagar prejuizo
INSERT INTO CRAPACA(NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
     VALUES (SEQACA_NRSEQACA.NEXTVAL,'CALCULA_POSSUI_SALDO_PREJUIZO','DSCT0003','pc_calcula_saldo_prejuizo_web','pr_nrdconta,pr_nrborder,pr_vlaboprj,pr_vlpagmto',(SELECT nrseqrdr FROM craprdr WHERE nmprogra ='DSCT0003'));
	 
INSERT INTO CRAPACA(NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
     VALUES (SEQACA_NRSEQACA.NEXTVAL,'PAGAR_PREJUIZO','DSCT0003','pc_pagar_prejuizo_web','pr_nrdconta,pr_nrborder,pr_vlaboprj,pr_vlpagmto',(SELECT nrseqrdr FROM craprdr WHERE nmprogra ='DSCT0003'));
     
-- Tela Estorn
INSERT INTO CRAPACA(NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES (SEQACA_NRSEQACA.NEXTVAL,'BUSCAR_BORDEROS_LIBERADOS','DSCT0003','pc_buscar_borderos_liberados','pr_nrdconta,pr_nrctremp,pr_nrborder',(SELECT nrseqrdr FROM craprdr WHERE nmprogra ='DSCT0003'));
UPDATE crapaca SET lstparam = lstparam||',pr_cdtpprod' WHERE nmdeacao = 'ESTORN_CONSULTAR_EST';
UPDATE crapaca SET lstparam = lstparam||',pr_cdtpprod' WHERE nmdeacao = 'ESTORN_CONSULTAR_DET_EST' ;
UPDATE crapaca SET nmpackag = 'TELA_ESTORN', lstparam = lstparam || ',pr_cdtpprod', nmproced = 'pc_tela_busca_lancto' WHERE nmdeacao = 'ESTORN_CON_LANCTO_EST' 
UPDATE crapaca SET nmpackag = 'TELA_ESTORN', lstparam = lstparam || ',pr_cdtpprod', nmproced = 'pc_tela_valida_lancto' WHERE nmdeacao = 'ESTORN_VALIDA_INC'
UPDATE crapaca SET nmpackag = 'TELA_ESTORN', nmproced = 'pc_tela_estornar_web', lstparam = 'pr_nrdconta,pr_nrctremp,pr_dsjustificativa' WHERE nmdeacao = 'ESTORN_INC_LANCTO_EST'
UPDATE crapaca SET nmpackag = 'TELA_ESTORN', nmproced = 'pc_tela_imprimir_relatorio_web', lstparam = lstparam || ', pr_cdtpprod' WHERE nmdeacao = 'ESTORN_IMPRESSAO'

-- TAB089 - Insere o parametro pr_vlmaxdst para a chamada da procedure pc_alterar da tela TAB089	   
UPDATE crapaca aca SET aca.lstparam = aca.lstparam || ' ,pr_avtperda,pr_vlperavt,pr_vlmaxdst' WHERE aca.nmdeacao = 'TAB089_ALTERAR';

-- COBTIT
insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (SEQACA_NRSEQACA.NEXTVAL, 'DADOS_PREJUIZO', 'TELA_COBTIT', 'pc_busca_dados_prejuizo_web', 'pr_nrdconta,pr_nrborder,pr_dtvencto', (SELECT nrseqrdr FROM craprdr where nmprogra = 'COBTIT'));

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (SEQACA_NRSEQACA.NEXTVAL, 'GERAR_BOLETO_PREJUIZO', 'TELA_COBTIT', 'pc_gerar_boleto_prejuizo_web', 'pr_nrdconta,pr_nrborder,pr_vlboleto,pr_flvlpagm,pr_dtvencto,pr_nrcpfava', (SELECT nrseqrdr FROM craprdr where nmprogra = 'COBTIT'));


-- Estorno
INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES ((SELECT MAX(NRSEQACA)+1 FROM CRAPACA), 'ESTORN_INC_LANCTO_EST_PRJ', 'TELA_ESTORN', 'pc_efetua_estorno_prj_web', 'pr_nrdconta,pr_nrborder,pr_justificativa', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ESTORN'));

-- Consulta antes de cancelar contrato
INSERT INTO crapaca(nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr) VALUES ('VERIFICA_BORDERO_CONTRATO', 'DSCT0003','pc_verifica_contrato_bodero', 'pr_nrdconta, pr_nrctrlim',724)
commit;
end;
