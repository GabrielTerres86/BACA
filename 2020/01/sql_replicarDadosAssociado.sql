--Update da replicar associado
UPDATE CRAPACA SET NMPACKAG = NULL, NMPROCED = 'replicarDadosAssociado_Web' WHERE NMPROCED = 'pc_duplica_conta' AND NMPACKAG = 'CADA0003' AND NRSEQRDR = 211;

