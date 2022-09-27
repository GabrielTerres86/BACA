DECLARE
  vr_nrseqrdr cecred.craprdr.nrseqrdr%type;
BEGIN
  INSERT INTO crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('GERA_ARQUIVO7AB'
    ,null
    ,'credito.gerarArquivoCercAp007Web'
    ,'pr_cdcooper,pr_nrdconta,pr_nrctremp'
    ,1045);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
