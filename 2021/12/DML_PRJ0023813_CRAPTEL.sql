DECLARE
  --Cooperativas ativas que não possuem o cadastro de tela
  CURSOR cr_crapcop(pr_nmdatela IN craptel.nmdatela%TYPE) IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND NOT EXISTS (SELECT 1
              FROM craptel tel
             WHERE tel.nmdatela = pr_nmdatela
               AND tel.cdcooper = cop.cdcooper);

  CURSOR cr_crapope(pr_nmdatela IN craptel.nmdatela%TYPE) IS
    SELECT DISTINCT pr_nmdatela nmdatela
                   ,ace.cddopcao
                   ,upper(TRIM(ace.cdoperad)) cdoperad
                   ,ace.cdcooper cdcooper
                   ,3 nrmodulo
                   ,0 idevento
                   ,ace.idambace idambace
      FROM crapace ace
          ,crapope ope
          ,crapcop cop
     WHERE ace.cdcooper = cop.cdcooper
       AND ace.cdcooper = ope.cdcooper
       AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
       AND UPPER(ace.nmdatela) = 'CADCYB'
       AND UPPER(ace.cddopcao) = 'C'
       AND ace.idambace = 2
       AND ope.cdsitope = 1
       AND cop.flgativo = 1
       AND NOT EXISTS (SELECT 1
              FROM crapace c
             WHERE c.cdcooper = ope.cdcooper
               AND c.idambace = ace.idambace
               AND UPPER(c.nmdatela) = pr_nmdatela
               AND UPPER(TRIM(c.cdoperad)) = UPPER(TRIM(ope.cdoperad))
               AND c.cddopcao IN ('C', 'B'));

  vr_nmdatela craptel.nmdatela%TYPE := 'PEAC';
  vr_nrmodulo craptel.nrmodulo%TYPE := 3; --Empréstimos
  vr_cdopptel craptel.cdopptel%TYPE := '@,C,B';
  vr_tldatela craptel.tldatela%TYPE := 'Acompanhamento Operacoes PEAC';
  vr_tlrestel craptel.tlrestel%TYPE := 'Acompanhamento Operacoes PEAC';
  vr_lsopptel craptel.lsopptel%TYPE := 'ACESSO,CONSULTA,BLOQUEIO HONRA';
  vr_nrseqrdr NUMBER;
BEGIN
  --Para cada cooperativa insere a tela
  FOR rw_crapcop IN cr_crapcop(vr_nmdatela) LOOP
    INSERT INTO craptel
      (nmdatela
      ,nrmodulo
      ,cdopptel
      ,tldatela
      ,tlrestel
      ,lsopptel
      ,cdcooper)
    VALUES
      (vr_nmdatela
      ,vr_nrmodulo
      ,vr_cdopptel
      ,vr_tldatela
      ,vr_tlrestel
      ,vr_lsopptel
      ,rw_crapcop.cdcooper);
  END LOOP;

  FOR rw_crapope IN cr_crapope(vr_nmdatela) LOOP
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
    VALUES
      (rw_crapope.nmdatela
      ,rw_crapope.cddopcao
      ,rw_crapope.cdoperad
      ,rw_crapope.cdcooper
      ,rw_crapope.nrmodulo
      ,rw_crapope.idevento
      ,rw_crapope.idambace);
  
    IF (rw_crapope.cdoperad LIKE 'F003%') THEN
      INSERT INTO crapace
        (nmdatela
        ,cddopcao
        ,cdoperad
        ,cdcooper
        ,nrmodulo
        ,idevento
        ,idambace)
      VALUES
        (rw_crapope.nmdatela
        ,'B'
        ,rw_crapope.cdoperad
        ,rw_crapope.cdcooper
        ,rw_crapope.nrmodulo
        ,rw_crapope.idevento
        ,rw_crapope.idambace);
    END IF;
  END LOOP;

  INSERT INTO craprdr
    (nmprogra
    ,dtsolici)
  VALUES
    ('TELA_PEAC'
    ,TRUNC(SYSDATE))
  RETURNING nrseqrdr INTO vr_nrseqrdr;
/*
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('CONSULTA_CONTRATOS'
    ,'TELA_PEAC'
    ,'pc_consultar_contratos_web'
    ,'pr_cdcooper,pr_nrdconta,pr_nrcontrato,pr_nriniseq,pr_nrregist,pr_datrini,pr_datrfim'
    ,vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('GRAVA_HONRAPEACP'
    ,'TELA_PEAC'
    ,'pc_atualizar_innaohonrar_web'
    ,'pr_contratos'
    ,vr_nrseqrdr);
*/
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;
