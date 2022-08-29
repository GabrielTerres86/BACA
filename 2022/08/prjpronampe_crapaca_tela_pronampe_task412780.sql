BEGIN
  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('CONSULTA_CNPJ_CONTA',
     'TELA_PRONAM',
     'pc_consulta_conta_web',
     'pr_cdcooper,pr_nrdconta,pr_nrcpfcgc',
     (SELECT NRSEQRDR
        FROM craprdr
       WHERE upper(NMPROGRA) = 'TELA_PRONAM'));
     
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;
