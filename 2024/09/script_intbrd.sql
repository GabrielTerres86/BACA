DECLARE
  vr_nrseqrdr cecred.craprdr.nrseqrdr%TYPE;
BEGIN
  INSERT INTO cecred.craprdr
    (nmprogra, dtsolici)
  VALUES
    ('INTBRD', SYSDATE)
  RETURNING nrseqrdr INTO vr_nrseqrdr;
  INSERT INTO cecred.craptel
    (nmdatela
    ,nrmodulo
    ,cdopptel
    ,tldatela
    ,tlrestel
    ,flgteldf
    ,flgtelbl
    ,nmrotina
    ,lsopptel
    ,inacesso
    ,cdcooper
    ,idsistem
    ,idevento
    ,nrordrot
    ,nrdnivel
    ,nmrotpai
    ,idambtel)
  VALUES
    ('INTBRD'
    ,5
    ,'C,A'
    ,'INTEGRACAO BORDERO TOPAZ'
    ,'INTEGRACAO BORDERO TOPAZ'
    ,0
    ,1
    ,' '
    ,'CONSULTAR,ALTERAR'
    ,1
    ,3
    ,1
    ,0
    ,1
    ,1
    ,' '
    ,2);
  INSERT INTO cecred.crapprg
    (nmsistem
    ,cdprogra
    ,dsprogra##1
    ,dsprogra##2
    ,dsprogra##3
    ,dsprogra##4
    ,nrsolici
    ,nrordprg
    ,inctrprg
    ,cdrelato##1
    ,cdrelato##2
    ,cdrelato##3
    ,cdrelato##4
    ,cdrelato##5
    ,inlibprg
    ,cdcooper
    ,qtminmed)
  VALUES
    ('CRED'
    ,'INTBRD'
    ,'INTEGRACAO BORDERO TOPAZ'
    ,' '
    ,' '
    ,' '
    ,50
    ,(SELECT MAX(g.nrordprg) + 1
       FROM cecred.crapprg g
      WHERE g.cdcooper = 3
            AND g.nrsolici = 50)
    ,1
    ,0
    ,0
    ,0
    ,0
    ,0
    ,1
    ,3
    ,NULL);
  INSERT INTO cecred.crapaca
    (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES
    ('BUSCA_INTBRD'
    ,NULL
    ,'credito.obterIntegracaoBorderoRejTopaz'
    ,'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_cdacao,pr_pagina,pr_dtopeini,pr_dtopefin,pr_cddopcao,pr_idtrnsc '
    ,vr_nrseqrdr);
  INSERT INTO cecred.crapaca
    (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES
    ('BUSCA_BRD_INTEGR'
    ,NULL
    ,'credito.obterBorderosIntegr'
    ,'pr_nrdconta '
    ,vr_nrseqrdr);
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'C', 'f0033078', ' ', 3, 1, 0, 2);
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'A', 'f0033078', ' ', 3, 1, 0, 2);
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'C', 'f0034476', ' ', 3, 1, 0, 2);
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'A', 'f0034476', ' ', 3, 1, 0, 2);
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'C', 'f0034976', ' ', 3, 1, 0, 2);
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'A', 'f0034976', ' ', 3, 1, 0, 2);
    
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'C', 'f0034370', ' ', 3, 1, 0, 2);
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'A', 'f0034370', ' ', 3, 1, 0, 2);
    
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'C', 'f0033754', ' ', 3, 1, 0, 2);
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'A', 'f0033754', ' ', 3, 1, 0, 2);
            
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'C', 'f0032641 ', ' ', 3, 1, 0, 2);
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'A', 'f0032641 ', ' ', 3, 1, 0, 2);
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'C', 'f0033639 ', ' ', 3, 1, 0, 2);
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('INTBRD', 'A', 'f0033639 ', ' ', 3, 1, 0, 2);
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
