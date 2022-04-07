DECLARE
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
BEGIN
  UPDATE craptel
     SET cdopptel = cdopptel || ',R'
        ,lsopptel = lsopptel || ',RETORNO/CRITICAS'
        ,idambtel = 2
   WHERE nmdatela = 'PEAC'
     AND cdopptel NOT LIKE '%,R%';
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
      ('CONSULTA_RETORNOS_PEAC'
      ,'TELA_PEAC'
      ,'pc_consultar_retornos_web'
      ,'pr_cdcooper,pr_tipooperacao,pr_nrdconta,pr_nrcontrato,pr_dtinicio,pr_dtfim,pr_status,pr_nriniseq,pr_nrregist'
      ,vr_nrseqrdr);
  EXCEPTION
    WHEN dup_val_on_index THEN
      NULL;
  END;

  BEGIN
    INSERT INTO crapaca
      (NMDEACAO
      ,NMPACKAG
      ,NMPROCED
      ,LSTPARAM
      ,NRSEQRDR)
    VALUES
      ('CONSULTA_CRITICAS_PEAC'
      ,'TELA_PEAC'
      ,'pc_consultar_criticas_web'
      ,'pr_idoperacao'
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
    (SELECT nmdatela
           ,'R'
           ,cdoperad
           ,cdcooper
           ,nrmodulo
           ,idevento
           ,idambace
       FROM crapace ace
      WHERE UPPER(ace.nmdatela) = 'PEAC'
        AND ace.cddopcao = 'C'
        AND ace.cdcooper = 3
        AND ace.idambace = 2
        AND NOT EXISTS (SELECT 1
               FROM crapace ace2
              WHERE UPPER(ace2.nmdatela) = UPPER(ace.nmdatela)
                AND ace2.cddopcao = 'R'
                AND UPPER(TRIM(ace2.cdoperad)) = UPPER(TRIM(ace.cdoperad))
                AND ace2.cdcooper = ace.cdcooper
                AND ace2.idambace = ace.idambace));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
