BEGIN

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('BUSCASEGVIDASIGAS', 'TELA_ATENDA_SEGURO', 'pc_detalha_seguro_vida_sigas', 'pr_nrdconta, pr_cdcooper, pr_idcontrato', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'TELA_ATENDA_SEGURO'));

END;