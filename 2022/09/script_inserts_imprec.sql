DECLARE

  vr_nrseqrdr cecred.craprdr.nrseqrdr%type;

BEGIN

  INSERT INTO cecred.craprdr
    (nmprogra
    ,dtsolici)
  VALUES
    ('TELA_IMPREC'
    ,SYSDATE)
  RETURNING nrseqrdr INTO vr_nrseqrdr;

  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('PROCESSA_ARQ_CERC'
    ,NULL
    ,'credito.processarArquivoCerc'
    ,'pr_tpprodut,pr_nmarquivo'
    ,vr_nrseqrdr);

  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('OBTER_LISTA_CNPJSCPFS_TITULARES_URS'
    ,''
    ,'credito.obterListaCNPJsCPFsTitularesURs'
    ,''
    ,vr_nrseqrdr);

  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('OBTER_LISTA_AGENDA_CERC'
    ,''
    ,'credito.obterListaAgendaCERC'
    ,'pr_nrregist,pr_nriniseq,pr_nrcnpjcpf_titular'
    ,vr_nrseqrdr);

  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('OBTER_LISTA_CONTRATOS_VINCS_URS'
    ,''
    ,'credito.obterListaContratosVincsURs'
    ,'pr_cdcooperativa,pr_nrconta_corrente'
    ,vr_nrseqrdr);

  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('OBTER_LISTA_URS_VINCS_CONTRATOS'
    ,''
    ,'credito.obterListaURsVincsContratos'
    ,'pr_nrregist,pr_nriniseq,pr_cdcooperativa,pr_nrconta_corrente,pr_nrcontrato'
    ,vr_nrseqrdr);

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
    (SELECT 'IMPREC'
           ,6
           ,'I,L,E,D,X'
           ,'PROJETO CERC'
           ,'PROJETO CERC'
           ,0
           ,1
           ,' '
           ,'IMP.SAS,IMP.MAN,EXCLUIR,DETALHES,IMP. MAN LIM'
           ,1
           ,cop.cdcooper
           ,1
           ,0
           ,1
           ,1
           ,' '
           ,2
       FROM cecred.crapcop cop
      WHERE cop.flgativo = 1);

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
    (SELECT 'CRED'
           ,'IMPREC'
           ,'PROJETO CERC'
           ,' '
           ,' '
           ,' '
           ,0
           ,300
           ,1
           ,0
           ,0
           ,0
           ,0
           ,0
           ,1
           ,cop.cdcooper
           ,NULL
       FROM cecred.crapcop cop
      WHERE cop.flgativo = 1);

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
