DECLARE

  vr_nmdatela  CONSTANT craptel.nmdatela%TYPE := 'SVRPIX';
  vr_tldatela  CONSTANT craptel.tldatela%TYPE := 'SOLICITACOES DE VALORES A RECEBER VIA PIX';
  

BEGIN

  INSERT INTO cecred.craptel 
                (nmdatela,
                 nrmodulo,
                 cdopptel,
                 tldatela,
                 tlrestel,
                 flgteldf,
                 flgtelbl,
                 nmrotina,
                 lsopptel,
                 inacesso,
                 cdcooper,
                 idsistem,
                 idevento,
                 nrordrot,
                 nrdnivel,
                 nmrotpai,
                 idambtel)
                SELECT vr_nmdatela,
                   7,
                   '@,A,R,E',
                   vr_tldatela,
                   'VALORES A RECEBER VIA PIX',
                   0,
                   1, 
                   ' ',
                   'Acesso,Aprovar,Reprocessar,Encerrar',
                   1,
                   cdcooper, 
                   1,
                   0,
                   1,
                   1,
                   '',
                   2
                FROM cecred.crapcop t
                 WHERE t.flgativo = 1;

  INSERT INTO cecred.crapprg
                (nmsistem,
                 cdprogra,
                 dsprogra##1,
                 dsprogra##2,
                 dsprogra##3,
                 dsprogra##4,
                 nrsolici,
                 nrordprg,
                 inctrprg,
                 cdrelato##1,
                 cdrelato##2,
                 cdrelato##3,
                 cdrelato##4,
                 cdrelato##5,
                 inlibprg,
                 cdcooper)
                SELECT 'CRED',
                   vr_nmdatela,
                   vr_tldatela,
                   '.',
                   '.',
                   '.',
                   50,
                   (SELECT MAX(g.nrordprg)+1 FROM cecred.crapprg g WHERE g.cdcooper = c.cdcooper AND g.nrsolici = 50),
                   1,
                   0,
                   0,
                   0,
                   0,
                   0,
                   1,
                   c.cdcooper
                FROM cecred.crapcop c
                 WHERE c.flgativo = 1;


  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
