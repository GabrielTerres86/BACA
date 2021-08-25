BEGIN
    insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    values ((select max(nrseqaca)+1 from crapaca), 'CARREGA_DATAS_PAGTO', 'TELA_ATENDA_SIMULACAO', 'pc_retorna_dtvenc', 'pr_nrdconta,pr_cdcooper', (SELECT   nrseqrdr  from craprdr  WHERE nmprogra= 'TELA_ATENDA_SIMULACAO'));

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK; 
END;