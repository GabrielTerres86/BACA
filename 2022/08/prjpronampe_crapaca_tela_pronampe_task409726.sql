BEGIN
  INSERT INTO cecred.crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('IMP_FATURAMENTO_API_PRONAM',
     'TELA_PRONAM',
     'pc_rel_faturamento_api',
     'pr_cdcooper,pr_datini,pr_datfim,pr_tipo',
     (SELECT NRSEQRDR
        FROM cecred.craprdr
       WHERE upper(NMPROGRA) = 'TELA_PRONAM'));
     
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;
