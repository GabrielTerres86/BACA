BEGIN
  INSERT INTO craprdr
    (NMPROGRA,
     DTSOLICI)
  VALUES
    ('RATBND',
     SYSDATE);

  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('EXCLUIR_RATBND',
     NULL,
     'credito.excluirRatingBndesWeb',
     'pr_cdcooper, pr_nrdconta, pr_nrctremp',
     (SELECT NRSEQRDR
        FROM craprdr
       WHERE upper(NMPROGRA) = 'RATBND'));
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;