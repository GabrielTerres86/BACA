BEGIN
  INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('PROCESSA_CARGA_CDC', NULL, 'credito.processarArquivoCdc', 'pr_nmarquivo,pr_tpprodut', 586);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
