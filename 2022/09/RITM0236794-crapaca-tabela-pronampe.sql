BEGIN
  INSERT INTO cecred.crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('CONSULTA_FATURAMENTO_RECEITA',
     'TELA_PRONAM',
     'pc_consultar_fat_rec_web',
     'pr_cdcooper, pr_nrdconta, pr_nriniseq, pr_nrregist',
     (SELECT NRSEQRDR
        FROM cecred.craprdr
       WHERE upper(NMPROGRA) = 'TELA_PRONAM'));
	   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
	RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;