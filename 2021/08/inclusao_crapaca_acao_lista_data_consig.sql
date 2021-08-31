BEGIN
    insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    values ((select max(nrseqaca)+1 from crapaca), 'CARREGA_DATAS_PAGTO_CONSIG', 'TELA_ATENDA_SIMULACAO', 'pc_retorna_dtvenc_consig', 'pr_nrdconta,pr_cdcooper,pr_diascare', (SELECT   nrseqrdr  from craprdr  WHERE nmprogra= 'TELA_ATENDA_SIMULACAO'));
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK; 
END;