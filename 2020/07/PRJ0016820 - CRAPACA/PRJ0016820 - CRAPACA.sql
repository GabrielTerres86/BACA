-- Parametros da Tela Aimaro para o Oracle

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (SEQACA_NRSEQACA.NEXTVAL, 'CONSULTAMOVCMP_P2', 'TELA_MOVCMP', 'pc_lotes_processados', 'pr_vcooper,pr_tparquiv,pr_dtinicial,pr_dtfinal', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_MOVCMP'));

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (SEQACA_NRSEQACA.NEXTVAL, 'CONSULTAMOVCMP_P1', 'TELA_MOVCMP', 'pc_protocolos_cob', 'pr_vcooper,pr_tparquiv,pr_dtinicial,pr_dtfinal', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_MOVCMP'));

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (SEQACA_NRSEQACA.NEXTVAL, 'CONSULTAMOVCMP_P3', 'TELA_MOVCMP', 'pc_lotes_criticas', 'pr_vcooper,pr_tparquiv,pr_dtinicial,pr_dtfinal', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_MOVCMP'));

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (SEQACA_NRSEQACA.NEXTVAL, 'CONSULTAMOVCMP_P5', 'TELA_MOVCMP', 'pc_lotes_criticas_detalhes', 'pr_vcooper,pr_dtmvtolt,pr_nrispbif,pr_tpdocmto,pr_tparquiv,pr_nrversao', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_MOVCMP'));

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (SEQACA_NRSEQACA.NEXTVAL, 'CONSULTAMOVCMP_P4', 'TELA_MOVCMP', 'pc_protocolos_cob_detalhes', 'pr_tparquiv,pr_cdocorrencia', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_MOVCMP'));

COMMIT;

