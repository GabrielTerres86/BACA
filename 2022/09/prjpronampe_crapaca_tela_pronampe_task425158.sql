BEGIN
  INSERT INTO cecred.crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('CONSULTA_AUT_FAT',
     'TELA_PRONAM',
     'pc_consulta_aut_fat_web',
     'pr_cdcooper,pr_nrdconta,pr_dstokenautorizacao',
     (SELECT NRSEQRDR
        FROM cecred.craprdr
       WHERE upper(NMPROGRA) = 'TELA_PRONAM'));
     
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;
