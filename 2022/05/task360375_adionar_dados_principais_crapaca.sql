BEGIN
  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('BUSCA_DADOS_PRINCIPAIS_CTR',
     'EMPR0026',
     'pc_obterDadosPrincipaisContratoWeb',
     'pr_cdcooper, pr_nrdconta',
     (SELECT NRSEQRDR
        FROM craprdr
       WHERE upper(NMPROGRA) = 'ATENDA'));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
	RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;