BEGIN
    insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    values ('CARREGA_DATAS_PAGTO_CONSIG', 'TELA_ATENDA_SIMULACAO', 'pc_retorna_dtvenc_consig', 'pr_nrdconta,pr_cdcooper,pr_diascare', (SELECT   nrseqrdr  from craprdr  WHERE nmprogra= 'TELA_ATENDA_SIMULACAO'));
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK; 
END;