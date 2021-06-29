/*
    Script para adicionar parametros de mensageria.
    Daniel Lombardi, Anderson F. Mout'S

*/
INSERT INTO crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES (4619, 'CONSULTAR_CONV_BLOQPAG', 'TELA_CONBLQ', 'pc_consulta_conv_bloqpag', 'pr_cdcooper, pr_periodoini,pr_periodofim,pr_NRDCONTA,pr_cdsegmto,pr_NRCONVEN,pr_flagbarr, pr_canalpagamento,pr_nrregist,pr_nriniseq', 2265);

INSERT into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES (4620, 'EXP_CSV_CONV_BLOQPAG', 'TELA_CONBLQ', 'pc_gera_csv_bloqpag', 'pr_cdcooper, pr_periodoini,pr_periodofim,pr_NRDCONTA,pr_cdsegmto,pr_NRCONVEN,pr_flagbarr, pr_canalpagamento', 2265);

COMMIT;
