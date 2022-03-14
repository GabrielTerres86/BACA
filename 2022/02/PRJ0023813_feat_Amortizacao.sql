DECLARE
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;

BEGIN

  UPDATE craptel
     SET cdopptel = cdopptel || ',A'
        ,lsopptel = lsopptel || ',AMORTIZACAO'
        ,idambtel = 2
   WHERE nmdatela = 'PEAC'
     AND cdopptel NOT LIKE '%,A%';

  COMMIT;

  SELECT nrseqrdr
    INTO vr_nrseqrdr
    FROM craprdr
   WHERE nmprogra = 'TELA_PEAC';

  BEGIN
    INSERT INTO crapaca
      (nmdeacao
      ,nmpackag
      ,nmproced
      ,lstparam
      ,nrseqrdr)
    VALUES
      ('CONSULTA_AMORTIZ_PEAC'
      ,'TELA_PEAC'
      ,'pc_consultar_amortizacao_web'
      ,'pr_cdcooper,pr_nrdconta,pr_nrcontrato,pr_nriniseq,pr_nrregist,pr_datrini,pr_datrfim'
      ,vr_nrseqrdr);
  EXCEPTION
    WHEN dup_val_on_index THEN
      NULL;
  END;

  COMMIT;

  INSERT INTO crapace
    (nmdatela
    ,cddopcao
    ,cdoperad
    ,cdcooper
    ,nrmodulo
    ,idevento
    ,idambace)
    SELECT nmdatela
          ,'A'
          ,cdoperad
          ,cdcooper
          ,nrmodulo
          ,idevento
          ,idambace
      FROM crapace
     WHERE UPPER(nmdatela) = 'PEAC'
       AND cddopcao = 'C'
       AND cdcooper = 3
       AND idambace = 2
       AND NOT EXISTS (SELECT 1
              FROM crapace
             WHERE UPPER(nmdatela) = 'PEAC'
               AND cddopcao = 'A'
               AND cdcooper = 3
               AND idambace = 2);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500,'Erro no script PRJ0023813_feat_Amortizacao. Erro: '||SQLERRM);
END;
