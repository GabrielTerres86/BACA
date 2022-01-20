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

  CURSOR cr_crapope(pr_cddopcao IN craptel.cddopcao%TYPE,
					pr_cdcooper IN craptel.cdcooper%TYPE) IS
		SELECT 'PEAC',
				CDDOPCAO,
				CDOPERAD,
				NMROTINA,
				CDCOOPER,
				NRMODULO,
				IDEVENTO,
				IDAMBACE 
		FROM CRAPACE ace
		WHERE NMDATELA = 'PRONAM'
		AND CDDOPCAO = pr_cddopcao
		AND cdcooper = nvl(pr_cdcooper, ace.cdcooper)
       AND NOT EXISTS (SELECT 1
              FROM crapace c
             WHERE c.cdcooper = ace.cdcooper
               AND c.idambace = ace.idambace
               AND UPPER(c.nmdatela) = 'PEAC'
               AND UPPER(TRIM(c.cdoperad)) = UPPER(TRIM(ace.cdoperad))
               AND c.cddopcao = ace.cddopcao);

  vr_nmdatela craptel.nmdatela%TYPE := 'PEAC';
  vr_nrmodulo craptel.nrmodulo%TYPE := 3; --Empréstimos
  vr_cdopptel craptel.cdopptel%TYPE := '@,C,B,L';
  vr_tldatela craptel.tldatela%TYPE := 'Acompanhamento Operacoes PEAC';
  vr_tlrestel craptel.tlrestel%TYPE := 'Acompanhamento Operacoes PEAC';
  vr_lsopptel craptel.lsopptel%TYPE := 'ACESSO,CONSULTA,BLOQUEIO HONRA,LIMITES';
  vr_nrseqrdr NUMBER;
  rw_crapcop crapcop%ROWTYPE;
  rw_crapope crapope%ROWTYPE;
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

  FOR rw_crapope IN cr_crapope('@', NULL) LOOP
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
  END LOOP;

  FOR rw_crapope IN cr_crapope('C', NULL) LOOP
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
  END LOOP;
  
  FOR rw_crapope IN cr_crapope('B', 3) LOOP
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
      ,'L'
      ,rw_crapope.cdoperad
      ,rw_crapope.cdcooper
      ,rw_crapope.nrmodulo
      ,rw_crapope.idevento
      ,rw_crapope.idambace);
  END LOOP;

  INSERT INTO craprdr
    (nmprogra
    ,dtsolici)
  VALUES
    ('TELA_PEAC'
    ,TRUNC(SYSDATE))
  RETURNING nrseqrdr INTO vr_nrseqrdr;

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('CONSULTA_CONTRATOS_PEAC'
    ,'TELA_PEAC'
    ,'pc_consultar_contratos_web'
    ,'pr_cdcooper,pr_nrdconta,pr_nrcontrato,pr_nriniseq,pr_nrregist,pr_datrini,pr_datrfim,pr_sthonra'
    ,vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('GRAVA_HONRAPEAC'
    ,'TELA_PEAC'
    ,'pc_atualizar_innaohonrar_web'
    ,'pr_contratos'
    ,vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('REPROCESS_CONTRATOPEAC'
    ,'TELA_PEAC'
    ,'pc_atualizar_reprocess_web'
    ,'pr_contratos'
    ,vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('CONSULTA_LIMITES_PEAC'
    ,'TELA_PEAC'
    ,'pc_consultar_limites_web'
    ,''
    ,vr_nrseqrdr);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;
