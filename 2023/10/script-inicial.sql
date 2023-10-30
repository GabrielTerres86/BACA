DECLARE

  vr_nrseqrdr cecred.craprdr.nrseqrdr%TYPE;

BEGIN

  INSERT INTO cecred.craprdr
    (nmprogra, dtsolici)
  VALUES
    ('TELA_RESERV', SYSDATE)
  RETURNING nrseqrdr INTO vr_nrseqrdr;

  INSERT INTO cecred.crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('OBTER_RESERV_LANC'
    ,NULL
    ,'CREDITO.obterReservaLancamentoWeb'
    ,'pr_nrdconta,pr_dhregistro'
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
    (SELECT 'RESERV'
           ,6
           ,'C, R'
           ,'PROJETO DEBITADOR'
           ,'PROJETO DEBITADOR'
           ,0
           ,1
           ,' '
           ,'CONSULTAR,RESGATAR	'
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
           ,'RESERV'
           ,'PROJETO DEBITADOR'
           ,' '
           ,' '
           ,' '
           ,50
           ,(SELECT MAX(g.nrordprg) + 1
              FROM cecred.crapprg g
             WHERE g.cdcooper = cop.cdcooper
                   AND g.nrsolici = 50)
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

  INSERT INTO  cecred.crapaca
    (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES
    ('INCLUIR_CRED_RESERV'
    ,NULL
    ,'CREDITO.incluirCreditoCcReservaWeb'
    ,'pr_nrdconta, pr_vllanmto'
    ,vr_nrseqrdr);

  INSERT INTO cecred.crapaca
    (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES
    ('OBTER_SALDO_RESERVA'
    ,NULL
    ,'credito.obterValorReservaWeb'
    ,'pr_nrdconta'
    ,vr_nrseqrdr);

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
