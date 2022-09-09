BEGIN
  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('PROCESSA_COBRANCA',
     'TELA_PRONAM',
     'pc_processa_cobranca_web',
     'pr_cobrancas',
     (SELECT NRSEQRDR
        FROM craprdr
       WHERE upper(NMPROGRA) = 'TELA_PRONAM'));
     
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;
