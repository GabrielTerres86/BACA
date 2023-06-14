DECLARE 
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(3);
  
  pr_cdcooper INTEGER;

BEGIN

  FOR i IN coop.FIRST .. coop.LAST
  LOOP
    pr_cdcooper := coop(i);
    
    INSERT INTO craptel 
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
        SELECT 'CONLIQ', 
               5, 
               '@,C,B,G,X,D,Y', 
               'Conciliação', 
               'Conciliação', 
               0, 
               1, 
               ' ', 
               'Acesso,Consultar', 
               0, 
               cdcooper, 
               1, 
               0, 
               1, 
               1, 
               '', 
               2 
          FROM crapcop          
         WHERE cdcooper = pr_cdcooper; 
         
    INSERT INTO crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace) 
    (SELECT 'CONLIQ',cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace 
       FROM crapace 
      WHERE nmdatela ='COBEMP' 
        AND cdcooper = pr_cdcooper);
        
    INSERT INTO crapprg
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
               'CONLIQ',
               'Conciliação',
               '.',
               '.',
               '.',
               1,
               NULL,
               1,
               0,
               0,
               0,
               0,
               0,
               1,
               cdcooper
          FROM crapcop          
         WHERE cdcooper IN pr_cdcooper;
         
  END LOOP;
    
  INSERT INTO craprdr (nmprogra, dtsolici)
       VALUES ('TELA_CONLIQ',SYSDATE);

  INSERT INTO crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
       VALUES ('LISTA_CONCILIACAO', 'TELA_CONLIQ', 'pc_lista_conciliacao', 'pr_dtmovimento', (select nrseqrdr from craprdr where nmprogra = 'TELA_CONLIQ'));

  COMMIT;
END;
